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

Use `go_router` or stock `Navigator 2.0`. No deep linking required for MVP.

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

## 11. Suggested dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  go_router: ^14.0.0
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
