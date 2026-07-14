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

Committed palette: **textured yellow + heavy black + cream stages**. Tokens are defined as CSS variables in `styles.css`. Port them to a Flutter `ThemeData` extension (`EmojiviaColors`). Use the hex values below verbatim.

| Token | Hex | Role |
|---|---|---|
| `yellow` | `#FFD84D` | Primary surface / brand color. Rendered with a subtle SVG noise texture over it (see 2.3). |
| `yellowDeep` | `#EBC12A` | Yellow drop-shadow color on the primary CTA. |
| `ink` | `#0F0F10` | All borders, display type, primary button fill. |
| `paper` | `#FFFFFF` | White card surfaces. |
| `cream` | `#FDF6D8` | **Emoji "arcade stage" backing** — the cream card behind every emoji clue so it contrasts against the yellow. Always paired with a subtle pixel-dot grid overlay. |
| `soft` | `#FAF6EA` | Bottom-half surface on the split-hero Results screen. |
| `inkSoft` | `#4B4740` | Secondary/meta text. |
| `good` | `#2FBA5C` | Correct answers, checkmarks. |
| `goodDark` | `#218C46` | Stamp text on "Nailed it". |
| `bad` | `#E63946` | Wrong answers, X marks. |
| `badDark` | `#B72532` | Stamp text on "Oops". |
| `flame` | `#F26B1F` | Streak accent — pixel-art flame + streak numbers. |

**No dark theme, no theme switcher, no coral variant.** The visual identity is a single committed direction.

### 2.2 Typography

Three families. Each has ONE job — do not use them interchangeably.

| Role | Font | Weight | Notes |
|---|---|---|---|
| Display (headlines, wordmark, buttons, answer labels) | **Archivo Black** | 900 (single weight) | Chunky editorial sans. Use for everything that needs to shout. |
| UI (body copy, secondary text) | **Nunito** | 700–800 | Round humanist for supporting text and paragraphs. |
| Accent numerals (scores, streak count, countdown, puzzle #) | **Press Start 2P** | 400 (single weight) | Pixel arcade font. **Numerals only** — never for paragraphs. Reserve for stat values, score/streak digits, and the empty-state countdown. |

All three are free on Google Fonts. **Bundle as assets** — do not load Google Fonts at runtime in production (offline + cold-start cost). Use the `google_fonts` package's `GoogleFonts.archivoBlack(...)` etc. only during early dev.

Type scale (logical px / dp):

| Style | Size | Weight | Family | Use |
|---|---|---|---|---|
| Wordmark | 72 | 900 | Archivo Black | "Emojivia" on splash |
| Display L | 88 | 900 | Archivo Black | Big score `4/5` on results hero |
| Display M | 32 | 900 | Archivo Black | Home hero headline |
| Display S | 30 | 900 | Archivo Black | Results/Empty headlines |
| Title | 22 | 900 | Archivo Black | Screen titles ("Hi there", "Category packs") |
| Button | 18 | 900 | Archivo Black | Primary CTA, uppercase, letter-spacing 0.05em |
| Button S | 15 | 900 | Archivo Black | Ghost button |
| Answer | 17 | 900 | Archivo Black | Answer-option label |
| Caps label | 11–12 | 900 | Archivo Black | All-caps section labels, letter-spacing 0.06–0.10em |
| Body | 14–15 | 700–800 | Nunito | Feedback sheet sub-copy, hint text |
| Pixel numeral | 20–24 | — | Press Start 2P | Streak `06`, score `04/05`, countdown `10:15:46`, puzzle `#142` |

Numerals in Archivo Black also want `FontFeature.tabularFigures()` where they animate (streak +1, score tick).

### 2.3 Shape, elevation, motion

- **Radius scale:** buttons 14, cards 18, hero 22, emoji stage 6, chips/pills 999. Everything is **less rounded** than a typical Material app — the pixel identity leans on sharper corners.
- **Chunky offset shadows, no blur.** Every raised surface has a solid-color drop shadow with 4–6px offset in `ink` (or `yellowDeep` on the primary CTA). Use `boxShadow: [BoxShadow(color: ink, offset: Offset(5, 5), blurRadius: 0)]`. **Never use blurred Material shadows.**
- **Heavy black borders on everything.** 2.5–3px `ink` border on cards, chips, buttons, answer options. Use a custom `BoxDecoration` — do not rely on `Card`'s default chrome.
- **Textured yellow background.** The main surface is `yellow` overlaid with a subtle SVG turbulence (≈20% opacity, multiply blend) that reads as very fine paper grain. In Flutter: render a `CustomPainter` with pre-baked noise, OR use a bundled 240×240 tiling noise PNG at `Opacity(0.18, BlendMode.multiply)`. Ship a `TweakToggle` to disable it (users may prefer flat).
- **Cream "arcade stage" backing for every emoji clue.** Emojis on yellow don't read — lions/crowns/bees blend in. Every emoji clue sits inside a `#FDF6D8` panel with a 3px black border, a chunky `ink` drop shadow, four **pixel L-bracket corners** protruding from each corner, and an inner **pixel-dot grid** (10×10 grid, 1px black dot at 9% opacity). See the `EmojiStage` component in `components.jsx`.
- **Yellow "peeking" accent** behind the cream stage: a rotated (-3°) yellow rectangle with a 2.5px black border offset so it peeks out from behind the stage — the collage/cutout look. Optional, decorative only.
- **Pixel-art accents everywhere** — pixel L-brackets on stage corners, pixel sparkles (9px 4-point star, `image-rendering: pixelated`) floating around clues and the mascot, pixel-square progress dots (no border-radius), pixel-heart glyphs in the top bar (custom 11×10 rect grid), pixel-flame on the streak chip, pixel-check/pixel-X on the share tiles. All defined as SVG symbols in `components.jsx`'s `PixelSprite`.
- **Status bar:** faux iOS status bar in the prototype. In Flutter use `SystemUiOverlayStyle.dark` over yellow / `.light` over the dark results hero.
- **Tap target:** ≥ 44dp everywhere.
- **Motion:** entrance easing `cubic-bezier(.2,.9,.3,1)` ≈ `Curves.easeOutCubic`. Buttons press-in by translating (+3, +3) and reducing shadow to 2px. Wrong-answer shakes the whole screen 400ms ±6px. Confetti: 60 pieces (of pixel squares in `flame`/`good`/`bad`/`yellowDeep`/`ink` — no rounded circles), 1.1–2.2s durations. Correct: pop scale 1 → 1.03 → 1.

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

1. **ChunkyButton** — `primary | ghost | yellow` variants. Required prop: `onTap`, `label`. Primary = black fill, white text, yellow-deep offset shadow. Ghost = white fill, black border, black offset shadow. Yellow = yellow fill, black border, black offset shadow. On press: translate (+3, +3), reduce shadow to 2px. Disabled desaturates.
2. **EmojiStage** — the cream "arcade" panel that every emoji clue sits inside. Cream background (`#FDF6D8`), inner pixel-dot grid (10×10 spacing, 9% opacity black), 3px black border, 5px offset black shadow, four **pixel L-bracket corners** SVG'd at each corner protruding −4px. Takes an optional list of pixel-sparkle overlays at specific positions/colors, and a bool for the yellow "peeking" accent block behind it.
3. **AnswerOption** — 5 states: `default | selected | correct | wrong | dimmed`. Letter key (A/B/C/D) in a 28dp rounded-8 square on the left, label in Archivo Black 17. Correct = green fill + pixel-check trailing icon. Wrong = red fill + pixel-X trailing icon. Selected = yellow fill.
4. **Hearts** — pill chip containing 3 **pixel-art hearts** (not ❤️ emoji — the custom 11×10 rect SVG in `bad` color). Lost hearts fade to `#d5d1c2`.
5. **StreakChip** — yellow pill chip with **pixel-art flame** SVG in `flame` color + streak count in **Press Start 2P** (padded to 2 digits: `06`, `12`).
6. **HintChip** — white pill chip with 💡 + count in Press Start 2P.
7. **ProgressDots** — **pixel squares** (12×12, no border-radius). Active = elongated 30×12 in `ink`; past correct = `good`; past wrong = `bad`; future = `paper` with black border.
8. **ClueCard** — outer card wrapping the category tag, an `EmojiStage`, and the optional hint text. Category tag is a yellow-fill pill with black border, uppercase Archivo Black 11, letter-spacing 0.1em.
9. **Mascot** — emoji cutout on a rotated (−8°) yellow blob (`border-radius: 50% 45% 60% 40% / 50% 55% 45% 50%`) with a 2.5px black border, plus **4 pixel sparkles** twinkling around it (alternating `ink` and `flame` colors, 2.4s ease-in-out infinite with staggered delays). Moods swap the emoji and animation (idle bob, celebrate pop-bounce, sad droop, sleepy is static 😴).
10. **Confetti** — overlay layer emitting ~60 mixed pieces: pixel squares (no border-radius) in `flame`/`good`/`bad`/`yellow`/`yellowDeep`/`ink`, plus ~30% pixel-sparkle SVGs. Random dx, rotation, 1.1–2.2s duration.
11. **ShareCard** — yellow-gradient panel with 3px black border and chunky drop shadow. Title `Emojivia · #{n}` in Archivo Black 15. Meta `4/5 · 🔥 7 DAY STREAK` in Press Start 2P 10. Two variants:
    - `tiles`: five 44dp rounded squares with **pixel-check / pixel-X** SVGs in white on `good`/`bad` fills, black border, staggered flip-in.
    - `row`: five 32px 🟩 / 🟥 emojis in a row — exactly as the copied share text.
12. **FeedbackSheet** — bottom-anchored sheet in `good` or `bad`, 3px black top border, 24 24 0 0 radius. Ico + Archivo Black title 26 + Nunito sub 14 (with `<b>` underline on the answer word). CTA is a white pill with black border and inner drop shadow. Slides up from translateY(20).
13. **WeekStrip** — 7 26dp circles in a row (M T W T F S S in Archivo Black 10). Played days = `flame` fill with **pixel-flame** SVG in white. Today gets a 3px `yellowDeep` outline offset 2px.
14. **PackCard** — 2-column grid card. Unlocked = yellow fill + `unlocked ✓` tag in `goodDark`. Locked = white fill, grayscaled icon, lock badge top-right (28dp circle, white, 2px border, 2px offset shadow), unlock condition in `flame` uppercase.

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
| `components.jsx` | Atoms: `PixelSprite` (SVG symbol library — pixel heart, flame, sparkle, check, X, corner, squiggle, arrow), `EmojiStage` (cream arcade panel), StatusBar, buttons, Hearts, ProgressDots, Mascot, Confetti, ShareCard, WeekStrip. |
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
