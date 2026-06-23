# Emojivia — Flutter handoff

A daily emoji-trivia game. This document is the source of truth for porting the HTML prototype in this project to a production Flutter app. Read this before touching code.

The prototype HTML/JSX is reference for visual design, layout, copy, and motion only. Reimplement components natively in Flutter — do not embed WebViews.

---

## 1. Product in one paragraph

Open Emojivia → play today's 5 emoji puzzles → tap 1 of 4 answer options → instant feedback (juicy correct, gentle wrong) → end on a results screen with a Wordle-style 🟩🟥 share card. Streak counts consecutive days played. Hearts (3) let you survive wrong answers; running out ends the run early. Hints (2) reveal a text clue + category. No accounts, no leaderboards, no purchases. Just a daily 5 + streak + share.

**Out of scope for MVP:** login/accounts, endless mode, leaderboards, typed input, IAP, push notifications, web/desktop targets.

---

## 2. Visual system

### 2.1 Color tokens (light theme)

Tokens are defined as CSS variables in `styles.css` and surfaced as runtime tweaks in `app.jsx`. Port them to a Flutter `ThemeData` extension (`EmojiviaColors`). Use `oklch()` source-of-truth values; convert to sRGB hex when defining `Color(0xFFRRGGBB)`. Both themes share neutrals, good/bad, and the flame accent — only `primary` / `primaryDark` / `onPrimary` change.

| Token | Yellow theme | Coral theme |
|---|---|---|
| `primary` | `oklch(0.84 0.155 88)` ≈ `#F0C24B` | `oklch(0.70 0.165 28)` ≈ `#E26A5A` |
| `primaryDark` | `oklch(0.72 0.15 78)` ≈ `#C99A2F` | `oklch(0.60 0.165 27)` ≈ `#BD4F40` |
| `onPrimary` | `oklch(0.30 0.04 70)` (deep brown) | `#FFFFFF` |

Fixed tokens (both themes):

| Token | Value |
|---|---|
| `bg` (cream) | `oklch(0.972 0.018 84)` ≈ `#F8F1E3` |
| `surface` | `oklch(0.995 0.006 84)` ≈ `#FEFCF6` |
| `line` (borders / dividers) | `oklch(0.91 0.018 80)` ≈ `#E8E0CC` |
| `ink` (body text) | `oklch(0.30 0.02 60)` ≈ `#3A3328` |
| `inkSoft` (secondary text) | `oklch(0.55 0.02 60)` ≈ `#7A7160` |
| `good` (correct) | `oklch(0.74 0.16 150)` ≈ `#4FC57A` |
| `goodDark` | `oklch(0.62 0.15 150)` ≈ `#36A45E` |
| `bad` (wrong) | `oklch(0.64 0.20 24)` ≈ `#E14B3D` |
| `badDark` | `oklch(0.55 0.20 24)` ≈ `#C13A2D` |
| `flame` (streak) | `oklch(0.72 0.18 52)` ≈ `#F08743` |

**Ship the Yellow theme as default.** Coral is a brand variant kept for a future "theme picker" — wire it but hide the picker for v1.

Dark theme is explicitly **post-MVP**.

### 2.2 Typography

| Role | Font | Weight | Notes |
|---|---|---|---|
| Display (headlines, buttons, scores) | **Baloo 2** | 700–800 | Rounded, chunky, friendly. Bundle as TTF via `pubspec.yaml`. |
| UI (body, captions) | **Nunito** | 600–800 | Use 800 for chips and labels, 700 for paragraphs. |

Both are free on Google Fonts. **Bundle as assets** — do not load Google Fonts at runtime in production (offline + cold-start cost). Use the `google_fonts` package's `GoogleFonts.baloo2(...).copyWith(...)` only during early dev.

Type scale (logical px / dp):

| Style | Size | Weight | Family | Use |
|---|---|---|---|---|
| Display L | 46 | 800 | Baloo 2 | "Emojivia" on splash |
| Display M | 34 | 800 | Baloo 2 | Home hero headline |
| Display S | 28 | 800 | Baloo 2 | Results headline ("4/5 today") |
| Title | 22 | 800 | Baloo 2 | Screen titles |
| Score | 32 | 800 | Baloo 2 | Scoreboard numbers |
| Button | 21 | 800 | Baloo 2 | Primary CTA |
| Button S | 17 | 800 | Baloo 2 | Ghost / pill buttons |
| Answer | 19 | 700 | Baloo 2 | Answer-option label |
| Body | 15 | 700 | Nunito | Paragraphs |
| Caption | 13 | 800 | Nunito | All-caps labels, uppercase letter-spacing 0.06em |
| Meta | 12–13 | 700 | Nunito | Helper / footer text |

Numerals in scoreboards and countdowns: enable `FontFeature.tabularFigures()`.

### 2.3 Shape, elevation, motion

- **Radius scale:** base `r = 20` (tweakable 8–30). Buttons use `r`. Cards use `r + 4`. Hero cards use `r + 14`. Chips & pills are fully rounded (`999`).
- **3D "chunky" buttons:** no Material shadow. Solid color fill, a 4–8px **bottom drop** in the darker shade simulating depth (`box-shadow: 0 6px 0 primaryDark`). On press: translate Y by the drop amount and remove the shadow (`AnimatedContainer` with 60–80ms curve). See `.btn-primary`, `.btn-ghost`, `.btn-pill`, `.answer` in `styles.css`.
- **No floating Material shadows.** Surfaces are flat with a 2px border in `line` plus a chunky drop. Use a custom `BoxDecoration` with `border` + `boxShadow` (one solid offset shadow, no blur).
- **Status bar:** the prototype renders a faux iOS status bar. In Flutter use `SystemUiOverlayStyle.dark` over the cream background; do not draw your own.
- **Tap target:** every interactive element ≥ 44dp.
- **Motion:** entrance animations use `cubic-bezier(.2,.9,.3,1)` ≈ `Curves.easeOutCubic`-ish. Confetti: 1.1–2.2s duration, ~60 pieces by default. Wrong-answer shake: 400ms, `Curves.easeInOut`, ±7px translateX. Correct: pop scale 1.0 → 1.04 → 1.0 over 400ms.

---

## 3. Screen inventory & navigation

Single-stack navigation. The `splash → home → game → results → empty` flow is the spine; `packs` is a side route.

| Route | Widget | Notes |
|---|---|---|
| `/` | `SplashScreen` | Auto-skip after first launch when streak data exists. |
| `/home` | `HomeScreen` | Shows "Play today's 5" or "View recap" if already played today. |
| `/play` | `GameScreen` | Internal state machine for 5 puzzles. Pop guarded by confirm dialog. |
| `/results` | `ResultsScreen` | Push-replace from `/play` so back goes home. |
| `/done` | `EmptyScreen` | Reached from home if today is already complete. |
| `/packs` | `PacksScreen` | Push from home; back to wherever you came from. |

**Do not use `go_router`.** Use stock `Navigator 2.0` with a `RouterDelegate` + `RouteInformationParser`, or — preferred for this app's depth — plain `Navigator 1.0` (`Navigator.push` / `pushReplacement` / `pop`) with named routes declared in `app/router.dart`. No deep linking required for MVP, so the imperative API is fine and keeps the dependency list shorter.

---

## 4. Components to build (priority order)

Reference files: see `components.jsx`, `screens.jsx`, `game.jsx`, `styles.css`.

1. **ChunkyButton** — `primary | ghost | pill` variants. Required prop: `onTap`, `label`. Disabled state desaturates and removes shadow. Implement via `GestureDetector` + `AnimatedContainer`.
2. **AnswerOption** — 4 states: `default | selected | correct | wrong | dimmed`. Letter key (A/B/C/D) on the left, label center-left. Border + chunky drop in state color.
3. **Hearts** — row of 3 hearts; lost hearts grayscale + 85% scale + 28% opacity.
4. **StreakChip / HintChip** — pill chip with emoji glyph + tabular number.
5. **ProgressDots** — 5 dots; active = elongated pill in primary; past = green if correct, red if missed; future = neutral line.
6. **ClueCard** — Surface card with category tag, large emoji clue (64dp, letter-spacing 6dp), optional hint paragraph.
7. **Mascot** — emoji-in-a-bubble. Implement as a `Stack` with a radial-gradient circle, a dashed inner ring, and a centered emoji `Text`. Moods are different emojis + different `AnimationController` loops (idle bob, celebrate pop-bounce, sad droop, sleepy).
8. **Confetti** — overlay layer that emits ~60 colored rectangles falling with random `dx`, `rotation`, `duration` from above the screen. Use `flutter_animate` or `confetti` package; or hand-roll with `CustomPaint` + a `Ticker`.
9. **ShareCard** — gradient surface with title (`Emojivia #N`), meta line, and the result grid in one of two variants:
   - `tiles`: five 46dp rounded squares with ✓/✕ in good/bad colors, staggered flip-in.
   - `row`: five large 🟩 / 🟥 emojis side-by-side, exactly as the share text.
10. **FeedbackSheet** — bottom-anchored sheet with colored top border, ico + title + sub copy + primary action. Animate from `translateY(20)` to rest. Use a separate route or an `AnimatedPositioned`.
11. **WeekStrip** — 7 day-pips (M T W T F S S). Played days show 🔥 in flame color; today gets an outline ring.
12. **PackCard** — 2-column grid card with icon, name, meta, lock badge. Unlocked variant has primary-tinted gradient.

---

## 5. State & data

### 5.1 Daily puzzle source

The prototype has 5 hard-coded puzzles in `data.js`. For production:

- Ship the app with **30+ days of puzzles bundled** as JSON in `assets/puzzles/`. Schema:
  ```json
  {
    "id": 142,
    "date": "2026-06-22",
    "puzzles": [
      {
        "emoji": "🦁👑",
        "category": "Movie",
        "hint": "A cub becomes king of the savanna.",
        "answer": "The Lion King",
        "options": ["The Lion King", "Madagascar", "The Jungle Book", "Brave"]
      }
    ]
  }
  ```
- Today's set is picked by local device date (no server required for MVP).
- Long-term: fetch the next 30 days from a CDN-backed JSON endpoint at app launch and cache.
- **Determinism:** the 4 options should always be shuffled with a seed derived from `(puzzleId, puzzleIndex)` so two devices see the same layout. The prototype's shuffle in `data.js` is the reference algorithm.

### 5.2 Local state (persist to `shared_preferences`)

| Key | Type | Notes |
|---|---|---|
| `streak_count` | int | Days in a row played. |
| `last_played_date` | ISO date | Used to detect streak break + already-played-today. |
| `today_run` | JSON | `{date, results: bool[], score, total, hearts, hints, ranOut}` — restore mid-run if user backgrounds the app. |
| `hint_balance` | int | Daily, resets at midnight local. Default 2/day. |
| `intro_seen` | bool | Skip splash CTA after first launch. |

**Streak rules:**
- Increment on the first puzzle completed today.
- If `last_played_date` is yesterday: streak += 1.
- If `last_played_date` is older than yesterday: streak resets to 1.
- Today already played: home shows "View recap" → `EmptyScreen`.

### 5.3 In-game state (Riverpod or Bloc)

`GameNotifier` holds: `index`, `results[]`, `hearts`, `hints`, `hintShown`, `picked`, `phase: ask | feedback`. Mirror the state machine in `game.jsx` directly.

---

## 6. Microcopy

Tone: warm, light, encouraging. **Never punishing.** Copy lives in one place — port from `data.js` `COPY` object.

- Correct (randomized): `Nice! 🔥`, `Boom! 🎯`, `You got it! ⭐`, `Too easy 😎`, `Yes! 🙌`
- Wrong (randomized): `So close 😅`, `Almost! 💛`, `Not quite 🤏`, `Good guess! 🌱`
- Results: perfect → `Flawless. Emoji genius 🧠` · 4/5 → `Sharp eyes today 👀` · 2–3 → `Nice run — see you tomorrow 🎉` · 0–1 → `Tomorrow's a fresh set 🌱`
- Streak: `Streak saved! 🔥`
- Empty: `You've finished today! ✓` · `Next puzzle drops in {HH:MM:SS} ⏳`

Strings should be in `lib/l10n/app_en.arb` to allow later localization.

---

## 7. Sharing

Tap **Share result** on results/empty → compose:

```
Emojivia #142 — 4/5 🔥7
🟩🟩🟥🟩🟩
emojivia.app
```

Use `share_plus`. **No spoilers** in the share text — emoji clues are never included, only the grid + score + streak.

---

## 8. Hint mechanic (decided)

- 2 hints per day. Tapping the hint button on the gameplay screen reveals the **category tag + a one-line text hint** for the current puzzle.
- Hints do not regenerate within a day. Reset at local midnight.
- No "remove two wrong answers" mechanic — that's explicitly out of scope.

---

## 9. Category packs

V1 ships with one **locked** placeholder list (Movies unlocked, others locked behind streak milestones). No real pack content yet. Tapping a locked pack shows a toast naming the unlock condition.

Unlock conditions in the prototype (subject to product confirmation):
- Foodie: play 3 days
- Music: 7-day streak
- Sports / Travel: "coming soon" (server-toggled later)

---

## 10. Accessibility checklist

- [ ] All emojis used as content (clues, mascot) have `Semantics(label: …)` with text alternatives. The clue's semantic label should read e.g. _"Emoji puzzle: lion, crown"_, **not** the answer.
- [ ] Answer buttons announce state: `Selected`, `Correct answer`, `Wrong answer, the correct answer was X`.
- [ ] Hearts row announces `2 of 3 hearts remaining`.
- [ ] Color is never the sole signal: ✓/✕ glyph appears with green/red, dashed border or stamp text appears with the correct/wrong banner.
- [ ] Respect `MediaQuery.disableAnimations` — drop confetti, shake, and bouncy mascot to static end-states.
- [ ] Min text size scaling supported up to `textScaleFactor = 1.3` without truncation in the gameplay screen.
- [ ] Min hit target 44dp.

---

## 10b. Architecture — feature-first clean architecture

**The whole app is organized by feature, not by layer.** Every feature is a self-contained slice that owns its UI, state, business logic, data access, and helpers. Cross-feature imports go through a feature's public `index.dart` barrel only — never reach into another feature's internals.

### 10b.1 Top-level layout

```
lib/
├── main.dart
├── app/                       # app shell — MaterialApp, router, theme wiring
│   ├── app.dart
│   ├── router.dart            # named-route table + Navigator helpers; routes delegate to feature screens
│   └── bootstrap.dart         # runZonedGuarded, error handlers, provider overrides
│
├── core/                      # cross-cutting, feature-agnostic primitives ONLY
│   ├── theme/                 # EmojiviaColors extension, text styles, radii, shadows
│   ├── widgets/               # ChunkyButton, Mascot, Confetti, ShareCard, etc. — see §4
│   ├── storage/               # SharedPreferences wrapper + key constants
│   ├── result/                # Result<T, E> sealed class for service returns
│   ├── errors/                # AppFailure hierarchy
│   ├── utils/                 # date, random-seed, formatters
│   └── constants/             # app-wide constants (puzzle count, hint cap, etc.)
│
├── features/
│   ├── home/
│   ├── game/
│   ├── results/
│   ├── streak/
│   ├── packs/
│   └── onboarding/
│
└── l10n/                      # ARB files (see §6)
```

`core/widgets/` is where the design-system components from §4 live — they are reused across features and are intentionally **dumb** (no providers, no business logic).

### 10b.2 Inside a feature

Every feature directory follows the **same** shape. Use this exact structure; missing files are simply omitted, never renamed.

```
features/<feature>/
├── <feature>.dart             # barrel: exports only what other features may use
│
├── data/                      # outermost ring — talks to the world
│   ├── models/                # DTOs: fromJson / toJson, no business logic
│   │   └── puzzle_dto.dart
│   ├── sources/               # raw IO: asset loaders, prefs reads, HTTP clients
│   │   └── puzzle_asset_source.dart
│   └── repositories/          # implements a domain repository contract
│       └── puzzle_repository_impl.dart
│
├── domain/                    # pure Dart, zero Flutter imports
│   ├── entities/              # business objects (Puzzle, DailySet, Streak)
│   ├── repositories/          # ABSTRACT repository interfaces
│   │   └── puzzle_repository.dart
│   └── usecases/              # one class per action — GetTodayPuzzles, RecordAnswer
│
├── application/               # state + orchestration (Riverpod lives here)
│   ├── providers/             # Riverpod provider declarations
│   │   └── game_providers.dart
│   ├── controllers/           # StateNotifier / AsyncNotifier — the state machine
│   │   └── game_controller.dart
│   ├── services/              # cross-usecase orchestration; pure Dart
│   │   └── streak_service.dart
│   └── state/                 # immutable state classes + freezed unions
│       └── game_state.dart
│
├── presentation/              # everything the user sees
│   ├── screens/               # route-level widgets (GameScreen, ResultsScreen)
│   ├── widgets/               # feature-local widgets (AnswerOption, FeedbackSheet)
│   └── components/            # composite widgets used in 2+ screens of this feature
│
└── utils/                     # feature-local helpers (shuffle seed, copy picker)
```

#### Layer rules (must hold for every feature)

1. **Direction of dependency is one-way:** `presentation → application → domain ← data`. Domain depends on nothing; data implements domain interfaces.
2. **`presentation/` never imports from `data/`.** It reads/writes through providers exposed by `application/`. Repositories are an implementation detail.
3. **`domain/` is pure Dart** — no `package:flutter` imports, no Riverpod, no `SharedPreferences`. This lets domain be unit-tested without a Flutter binding.
4. **Controllers don't do IO.** A controller calls a usecase (or a service); the usecase calls a repository; the repository calls a source. Controllers translate UI events into state transitions and nothing else.
5. **Services vs usecases:**
   - **Usecase** = one verb, one repository call (`GetTodayPuzzles`, `IncrementStreak`).
   - **Service** = orchestrates multiple usecases or repositories (`StreakService` reads `last_played_date`, computes the new streak, writes back). Services are stateless.
6. **Providers are the only public surface from `application/`.** Everything else in `application/` is package-private.
7. **State classes are immutable.** Use `freezed` for unions (`GameState.asking | feedback | finished`).

#### Naming conventions

- Files: `snake_case.dart`. Classes: `PascalCase`. Providers: `camelCaseProvider`.
- Repository interface: `PuzzleRepository`. Implementation: `PuzzleRepositoryImpl`.
- Controller: `GameController extends StateNotifier<GameState>`. Its provider: `gameControllerProvider`.
- Usecase: verb-first, `GetTodayPuzzles`, `RecordAnswer`. Call via `usecase.call(...)` or `usecase(...)`.

### 10b.3 Worked example — the `game` feature

Mapping the state machine in `game.jsx` onto this structure:

```
features/game/
├── game.dart                          # exports: GameScreen, gameControllerProvider
├── domain/
│   ├── entities/
│   │   ├── puzzle.dart                # Puzzle(emoji, category, hint, answer, options)
│   │   └── answer_outcome.dart        # enum: correct | wrong
│   ├── repositories/
│   │   └── puzzle_repository.dart     # abstract: Future<List<Puzzle>> getToday()
│   └── usecases/
│       ├── get_today_puzzles.dart
│       └── shuffle_options.dart       # deterministic shuffle (port from data.js)
├── data/
│   ├── models/puzzle_dto.dart         # fromJson / toJson
│   ├── sources/puzzle_asset_source.dart   # loads assets/puzzles/2026-06-23.json
│   └── repositories/puzzle_repository_impl.dart
├── application/
│   ├── state/game_state.dart          # freezed: index, results, hearts, hints, phase, picked
│   ├── controllers/game_controller.dart   # answer(), useHint(), advance()
│   ├── services/feedback_copy_service.dart  # randomized "Nice! 🔥" / "So close 😅"
│   └── providers/game_providers.dart  # gameControllerProvider, todayPuzzlesProvider
├── presentation/
│   ├── screens/game_screen.dart       # consumes gameControllerProvider
│   ├── widgets/
│   │   ├── answer_option.dart
│   │   ├── clue_card.dart
│   │   ├── feedback_sheet.dart
│   │   └── hearts_row.dart            # if not shared in core/widgets
│   └── components/game_top_bar.dart
└── utils/
    └── seed.dart                      # seed = puzzleId * 31 + index
```

### 10b.4 Cross-feature interaction

`game` finishes a run → must update streak (owned by `streak` feature) → results screen reads the new streak.

- `game` does **not** import from `streak/data/` or `streak/application/internals`.
- `game/application/controllers/game_controller.dart` calls `ref.read(streakControllerProvider.notifier).recordCompletion(date)` — a method exposed via `streak/streak.dart`.
- `results` reads `ref.watch(streakControllerProvider)` for display.

If two features need the same primitive (e.g. a `DateProvider` for "today"), it lives in `core/`, not in either feature.

### 10b.5 Testing layout

Mirror the source tree under `test/`:

```
test/
├── core/
└── features/
    └── game/
        ├── domain/usecases/get_today_puzzles_test.dart
        ├── application/controllers/game_controller_test.dart   # uses ProviderContainer
        └── presentation/screens/game_screen_test.dart          # widget test
```

Domain tests are pure Dart (`test:` package). Controller tests use `ProviderContainer` with mocked repositories. Widget tests use `pumpWidget` with provider overrides.

### 10b.6 Quick decision guide

| If you're adding… | Put it in |
|---|---|
| A new puzzle source (API, Firestore) | `features/game/data/sources/` + new repository impl |
| A new gameplay rule (e.g. combo bonus) | `features/game/domain/usecases/` + update controller |
| A reusable widget used by 2+ features | `core/widgets/` |
| A widget used only inside one feature | `features/<that one>/presentation/widgets/` |
| A persistence key | `core/storage/storage_keys.dart` |
| A new screen for an existing feature | `features/<feature>/presentation/screens/` + route in `app/router.dart` |
| A whole new flow (e.g. "achievements") | new `features/achievements/` with the full subtree |

---

## 11. Suggested dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.0
  shared_preferences: ^2.2.0
  share_plus: ^10.0.0
  flutter_animate: ^4.5.0      # mascot loops, screen transitions
  confetti: ^0.7.0             # results-screen burst
```

Avoid: any WebView, any heavy game engine, anything Material-3-decorative. Keep widget tree shallow.

---

## 12. File map of the prototype (for cross-reference)

| File | What's in it |
|---|---|
| `Emojivia.html` | Entry point — loads everything below. |
| `Emojivia Frames.html` | Figma-style board of every screen & state. |
| `styles.css` | Design tokens + every component's visual styles. **Read this first.** |
| `data.js` | Puzzle set, category pack list, microcopy, deterministic shuffle. |
| `components.jsx` | Atoms: StatusBar, buttons, Hearts, ProgressDots, Mascot, Confetti, ShareCard, WeekStrip. |
| `screens.jsx` | Splash, Home, Results, Empty, Packs. |
| `game.jsx` | Gameplay state machine + feedback states. |
| `app.jsx` | Root: routing, tweak system, frame mode. |
| `tweaks-panel.jsx` | Live-tweak panel scaffolding (ignored at build). |

---

## 13. Open questions for product

1. Are puzzles authored or sourced? Need an editorial pipeline before launch.
2. Anti-cheat: prevent date manipulation? (For MVP, accept that users can time-travel locally — no backend.)
3. Notification reminder ("Today's Emojivia is ready 🔥") — yes/no? Post-MVP either way.
4. Onboarding tour for first-time users — needed, or is the splash + "Play" CTA enough?
5. Telemetry: are we wiring analytics for v1? (Recommend: anonymous funnel events — `daily_started`, `puzzle_answered`, `daily_completed`, `share_tapped`.)
