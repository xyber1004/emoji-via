# Emojivia — Architecture Guide

This document is your complete map of the codebase. Read it once end-to-end before touching code; refer back to specific sections when you need to add a feature, fix a bug, or make a design change.

---

## 1. The 30-second version

Emojivia is a Flutter app built with **feature-first clean architecture**. Every feature owns its full vertical slice (data → domain → state → UI). Features never reach into each other's internals; they communicate only through explicitly exported providers. The design system lives in `core/` and is shared across all features.

```
User taps "Play"
  → GameScreen watches gameControllerProvider (Riverpod)
  → GameController receives pickAnswer(option)
  → GameController updates GameState (immutable value object)
  → Flutter rebuilds the affected widgets automatically
  → On game over, GameController calls streakControllerProvider.recordCompletion()
  → Navigator pushReplacementNamed("/results")
```

That's the whole data flow in one mental model.

---

## 2. Top-level directory structure

```
lib/
├── main.dart                  # Entry point — ProviderScope wraps EmojiviaApp
├── app/
│   ├── app.dart               # MaterialApp — theme, routes
│   ├── router.dart            # AppRoutes constants + appRoutes Map<String, WidgetBuilder>
│   └── bootstrap.dart         # (future) error handlers, zone config
│
├── core/                      # Shared primitives — no business logic
│   ├── theme/
│   │   ├── app_colors.dart    # EmojiviaColors ThemeExtension (12 tokens)
│   │   ├── app_typography.dart # AppTypography (Archivo Black / Nunito / Press Start 2P)
│   │   └── app_theme.dart     # buildTheme() + AppShape (radii)
│   ├── widgets/               # Dumb design-system components (no providers)
│   │   ├── chunky_button.dart
│   │   ├── emoji_stage.dart
│   │   ├── pixel_sprites.dart
│   │   ├── mascot.dart
│   │   ├── streak_chip.dart   # StreakChip, HintChip, WeekStrip
│   │   ├── confetti_overlay.dart
│   │   └── share_card.dart
│   ├── storage/
│   │   ├── storage_keys.dart  # SharedPreferences key constants
│   │   ├── storage_service.dart
│   │   └── storage_provider.dart
│   ├── utils/
│   │   └── app_date_utils.dart
│   └── constants/
│       └── app_constants.dart # dailyHintCap = 2, puzzle count, etc.
│
├── features/
│   ├── game/                  # The core gameplay loop
│   ├── streak/                # Streak tracking + persistence
│   ├── home/                  # Home screen
│   ├── results/               # Results + empty (already-played) screens
│   ├── onboarding/            # Splash screen
│   └── packs/                 # Category packs screen
│
└── l10n/
    └── app_en.arb             # All user-facing strings
```

---

## 3. The four layers (and the one rule)

Every feature has up to four layers, and there is exactly one rule:

```
presentation  →  application  →  domain  ←  data
```

**Direction of dependency is one-way.** `domain` depends on nothing. `data` implements `domain` interfaces. `application` orchestrates domain logic. `presentation` reads state from `application`.

| Layer | What lives here | What it must NOT do |
|---|---|---|
| `domain/` | Entities, abstract repository interfaces, usecases | Import Flutter, Riverpod, SharedPreferences — anything outside Dart core |
| `data/` | DTOs (JSON ↔ entity), data sources (asset/prefs/HTTP), repository implementations | Contain business logic; talk to `presentation` |
| `application/` | Riverpod providers, controllers (Notifier), services | Do IO directly; import from `presentation` |
| `presentation/` | Screens, feature-local widgets, components | Import from `data`; call repositories directly |

If you find yourself about to break one of these rules, stop — there is always a correct layer for what you need.

---

## 4. The `game` feature in depth

This is the most complex feature and the best one to learn from.

```
features/game/
├── game.dart                                   ← barrel file (public API)
│
├── domain/
│   ├── entities/
│   │   ├── puzzle.dart                         ← Puzzle(emoji, category, hint, answer, options)
│   │   ├── daily_puzzle_set.dart               ← DailyPuzzleSet(id, date, puzzles)
│   │   └── answer_outcome.dart                 ← enum correct | wrong
│   ├── repositories/
│   │   └── puzzle_repository.dart              ← abstract Future<DailyPuzzleSet> getToday()
│   └── usecases/
│       ├── get_today_puzzles.dart              ← calls repo.getToday()
│       └── shuffle_options.dart               ← deterministic shuffle, seed = id*31 + index
│
├── data/
│   ├── models/puzzle_dto.dart                  ← fromJson / toJson
│   ├── sources/puzzle_asset_source.dart        ← loads assets/puzzles/YYYY-MM-DD.json
│   └── repositories/puzzle_repository_impl.dart
│
├── application/
│   ├── state/game_state.dart                   ← GameState (immutable) + GamePhase enum
│   ├── controllers/game_controller.dart        ← Notifier<GameState?> state machine
│   ├── services/feedback_copy_service.dart     ← random "Nice! 🔥" / "So close 😅"
│   └── providers/game_providers.dart           ← all provider declarations
│
└── presentation/
    ├── screens/game_screen.dart
    ├── widgets/
    │   ├── answer_option.dart                  ← 5 states: idle|selected|correct|wrong|dimmed
    │   ├── clue_card.dart                      ← category tag + EmojiStage + hint
    │   ├── feedback_sheet.dart                 ← slides up after each answer
    │   ├── hearts_row.dart                     ← pixel hearts in a pill chip
    │   └── progress_dots.dart                  ← pixel squares (no border-radius)
    └── components/
        └── game_top_bar.dart                   ← close button + progress dots + HintChip + HeartsRow
```

### The GameState machine

`GameState` is an **immutable value object**. Every state change produces a brand-new `GameState`:

```
null (initial)
  ↓ startGame()
GameState(phase: ask, index: 0, results: [null,null,null,null,null], hearts: 3, hints: 2)
  ↓ pickAnswer("The Lion King")   ← correct
GameState(phase: feedback, results: [true,...], picked: "The Lion King", hearts: 3)
  ↓ advance()
GameState(phase: ask, index: 1, hintShown: false)
  ↓ pickAnswer("Madagascar")      ← wrong
GameState(phase: feedback, results: [true, false,...], hearts: 2)
  ↓ advance()
  ... (repeat until index == 5 OR hearts == 0)
  ↓ isOver == true → GameScreen calls recordCompletion() → Navigator to /results
```

`GameState.isOver` is true when `index >= puzzles.length` OR `hearts <= 0`.

### How puzzle loading works

```
todayPuzzleSetProvider (FutureProvider)
  → GetTodayPuzzles.call()
      → PuzzleRepository.getToday()
          → PuzzleRepositoryImpl
              → PuzzleAssetSource.loadToday()
                  → rootBundle.loadString("assets/puzzles/2026-07-06.json")
                  → fallback 5 hardcoded puzzles if file missing
```

Puzzle options are shuffled **deterministically** using `seed = puzzleId * 31 + puzzleIndex` so two different phones always see the same option order for the same puzzle.

---

## 5. The `streak` feature

Simpler than `game`. Its whole job is: remember how many consecutive days the user has played, and expose that to the rest of the app.

```
features/streak/
├── streak.dart                           ← exports: streakControllerProvider, StreakState
├── domain/
│   ├── entities/streak.dart              ← Streak(count, lastPlayedDate, introSeen, hintBalance)
│   ├── repositories/streak_repository.dart  ← abstract load() + save()
│   └── usecases/compute_streak.dart      ← pure function: given current streak + new date → new count
├── data/
│   ├── sources/streak_prefs_source.dart  ← reads/writes SharedPreferences
│   └── repositories/streak_repository_impl.dart
└── application/
    ├── state/streak_state.dart           ← StreakState(count, lastPlayedDate, introSeen, hintBalance)
    ├── controllers/streak_controller.dart
    └── providers/streak_providers.dart   ← streakControllerProvider (the only public export)
```

### The streak rule (in `ComputeStreak`)

```dart
if (lastPlayedDate == null)   → return 1   // first time ever
if (lastPlayed == today)      → return count  // already counted
if (diff == 1 day)            → return count + 1  // consecutive
else                          → return 1   // streak broken
```

### Cross-feature boundary

`game` feature calls streak like this — one line, through the barrel:
```dart
// in game_controller.dart or game_screen.dart:
ref.read(streakControllerProvider.notifier).recordCompletion(date);
```

`results` and `home` read streak like this:
```dart
final streak = ref.watch(streakControllerProvider); // → StreakState
streak.count        // the number
streak.playedToday  // bool, computed from lastPlayedDate
```

---

## 6. State management — Riverpod

The app uses `flutter_riverpod ^2.5.0`. The pattern is **Notifier** (not StateNotifier).

### Provider types in use

| Provider type | Used for | Example |
|---|---|---|
| `NotifierProvider` | Mutable state with methods | `gameControllerProvider`, `streakControllerProvider` |
| `FutureProvider` | Async one-shot loads | `todayPuzzleSetProvider` (loads JSON) |
| `Provider` | Pure factories / services | `puzzleRepositoryProvider`, `feedbackCopyServiceProvider` |

### Reading providers in widgets

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(streakControllerProvider); // rebuilds on change
    final repo = ref.read(puzzleRepositoryProvider);    // one-time read, no rebuild
  }
}
```

Use `ref.watch` in `build()`. Use `ref.read` inside callbacks (`onTap`, `initState`, etc.).

### Where providers live

Every feature declares its own providers in `features/<feature>/application/providers/`. The barrel file (`<feature>.dart`) re-exports only what other features need. Nothing outside a feature should import from inside its `application/` or `data/` directories.

---

## 7. Navigation

Plain Navigator 1.0 with named routes. No `go_router`, no deep linking.

```dart
// All routes declared in lib/app/router.dart
class AppRoutes {
  static const splash   = '/';
  static const home     = '/home';
  static const play     = '/play';
  static const results  = '/results';
  static const done     = '/done';
  static const packs    = '/packs';
}
```

### Navigation flow

```
/  (SplashScreen)
  → auto-skip to /home if introSeen == true
  → tap "Let's play" → markIntroSeen() → /home

/home (HomeScreen)
  → tap "Play"       → push /play
  → tap "View recap" → push /done   (if already played today)
  → tap "Packs"      → push /packs

/play (GameScreen)
  → game over        → pushReplacement /results   (back goes to /home)
  → back button      → confirm dialog → pop

/results (ResultsScreen)
  → tap "Done"       → pushNamedAndRemoveUntil /home   (clears stack)

/done (EmptyScreen)
  → back button      → pushNamedAndRemoveUntil /home

/packs (PacksScreen)
  → back button      → pop
```

`pushReplacement` from `/play` to `/results` means the back button on results goes to `/home`, not back into the game — intentional.

---

## 8. The design system (`core/theme/` + `core/widgets/`)

### Color tokens — `EmojiviaColors`

A Flutter `ThemeExtension` with 12 named tokens. Access from any widget:

```dart
final ec = context.ec;  // shorthand via EmojiviaColorsContext extension
ec.yellow      // #FFD84D — main app background, selected state
ec.yellowDeep  // #EBC12A — CTA shadow color
ec.ink         // #0F0F10 — ALL borders, primary button fill, text
ec.paper       // #FFFFFF — card surfaces, ghost button fill
ec.cream       // #FDF6D8 — emoji arcade stage backing
ec.soft        // #FAF6EA — results screen bottom half
ec.inkSoft     // #4B4740 — secondary text
ec.good        // #2FBA5C — correct answer fill
ec.goodDark    // #218C46 — correct answer border / stamp text
ec.bad         // #E63946 — wrong answer fill, pixel hearts
ec.badDark     // #B72532 — wrong answer border / stamp text
ec.flame       // #F26B1F — streak accent, pixel flames
```

**The non-obvious rule:** `ec.ink` is used for *both* borders (on cards, buttons, answer options) *and* as the fill for the primary CTA button (which is black with white text). Do not confuse this with a border-only token.

### Typography — `AppTypography`

Three families, each with one job:

```dart
// Archivo Black (weight 900) — display, labels, buttons, answers
AppTypography.wordmark    // 72px — "Emojivia" on splash
AppTypography.displayL    // 88px — big score "4/5" on results
AppTypography.displayM    // 32px — home hero headline
AppTypography.displayS    // 30px — results/empty headlines
AppTypography.title       // 22px — screen titles
AppTypography.button      // 18px — CTA labels (auto-uppercase in ChunkyButton)
AppTypography.buttonS     // 15px — ghost button
AppTypography.answer      // 17px — answer option labels
AppTypography.caption     // 11px — all-caps section labels (category tags, day letters)

// Nunito (weight 700–800) — body copy only
AppTypography.body        // 15px — hints, feedback sub-copy
AppTypography.meta        // 14px — pack descriptions, secondary text

// Press Start 2P — pixel numerals only (streak, score, countdown, hint count)
AppTypography.pixelNumeral   // 22px
AppTypography.pixelNumeralM  // 14px — countdown timer
AppTypography.pixelNumeralS  // 10px — streak chip count, hint count
```

**Never use Press Start 2P for prose.** It's for digits and short codes only.

### Shape — `AppShape`

```dart
AppShape.button      // BorderRadius.circular(14) — all buttons
AppShape.card        // BorderRadius.circular(18) — answer options, share card
AppShape.heroCard    // BorderRadius.circular(22) — clue card, feedback sheet
AppShape.emojiStage  // BorderRadius.circular(6)  — cream emoji panel
AppShape.chip        // BorderRadius.circular(999) — pills, chips
```

### Shadow rule

Every raised surface has a **solid-color offset shadow** with `blurRadius: 0`. Never use blurred shadows.

```dart
BoxShadow(color: ec.ink, offset: Offset(5, 5), blurRadius: 0)        // cards
BoxShadow(color: ec.yellowDeep, offset: Offset(5, 5), blurRadius: 0) // primary CTA
BoxShadow(color: ec.ink, offset: Offset(3, 3), blurRadius: 0)        // chips, small elements
```

When a button is pressed: translate `+3, +3` (both axes) and the shadow logically disappears because the button has caught up to its shadow.

### Design system widgets (`core/widgets/`)

These are **pure presentation** — no providers, no business logic.

| Widget | Props | Notes |
|---|---|---|
| `ChunkyButton` | `label, onTap, variant, disabled` | `primary` = ink fill; `ghost` = paper fill; `yellow` = yellow fill. Always uppercases label. |
| `EmojiStage` | `child, showYellowAccent` | Cream panel with pixel-dot grid + L-bracket corners. |
| `PixelHeart` | `color, pixelSize` | 11×9 pixel-grid heart. Use `ec.bad` for active, `#D5D1C2` for lost. |
| `PixelFlame` | `color, pixelSize` | 5×7 pixel-grid flame. Use `ec.flame`. |
| `PixelSparkle` | `color, pixelSize` | 7×7 cross star. |
| `TwinklingSparkle` | `color, pixelSize, delay` | Animated PixelSparkle (fade+scale loop, 1200ms half-period). |
| `Mascot` | `mood, size` | Blob shape, −8° rotation, 4 twinkling sparkles. Moods: `idle|celebrate|sad|sleepy`. |
| `StreakChip` | `count` | Yellow pill, `PixelFlame`, count in `pixelNumeralS`. |
| `HintChip` | `count, onTap` | White pill, 💡 emoji, count in `pixelNumeralS`. |
| `WeekStrip` | `streak, playedToday` | 7-day row. Played days: `flame`-colored circle with white `PixelFlame`. |
| `ConfettiOverlay` | `child, trigger` | Wraps any widget. Set `trigger = !trigger` to fire a burst. |
| `ShareCard` | `puzzleId, score, total, results` | Yellow card. Also exports `shareResult()` function. |

---

## 9. Persistence — `StorageService`

All persistence goes through `StorageService`, backed by `SharedPreferences`. Never call `SharedPreferences` directly from a widget or controller — go through `storageServiceProvider`.

```dart
final storage = ref.read(storageServiceProvider);

storage.streakCount       // int
storage.lastPlayedDate    // String? ISO date
storage.introSeen         // bool
storage.savedRunJson      // String? (today_run JSON)
storage.hintBalance       // int (resets at midnight via lastHintDate comparison)
storage.playedToday       // bool shorthand
```

Keys live in `StorageKeys` constants. Adding a new persisted field means: add a constant to `StorageKeys`, add a getter/setter to `StorageService`.

---

## 10. Assets — `assets/puzzles/`

JSON files named `YYYY-MM-DD.json`. The app loads today's date string and looks up the matching file. If the file doesn't exist, it falls back to 5 hardcoded movie puzzles.

### Schema

```json
{
  "id": 11,
  "date": "2026-07-03",
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

Rules:
- `options` must contain exactly 4 items and must include `answer`
- `id` is globally unique across all puzzle sets
- `date` must match the filename
- Options are **shuffled at runtime** using `seed = id * 31 + puzzleIndex` — the order in the JSON doesn't matter for what the user sees, but the seed is derived from `id` so keep IDs stable once shipped

---

## 11. Practical: how to add things

### Add a new puzzle day

1. Create `assets/puzzles/YYYY-MM-DD.json` following the schema above.
2. That's it. No code changes needed.

### Add a new screen to an existing feature

1. Create the widget in `features/<feature>/presentation/screens/`.
2. Add a route constant to `AppRoutes` in `lib/app/router.dart`.
3. Add the route to the `appRoutes` map in `router.dart`.
4. Navigate to it with `Navigator.pushNamed(context, AppRoutes.myNewRoute)`.

### Add a reusable design system widget

1. Create the file in `lib/core/widgets/`.
2. It must accept only plain Dart types and maybe `EmojiviaColors` (via `context.ec`) — no providers.
3. Use it anywhere.

### Add a new gameplay rule (e.g., combo bonus)

1. Add the rule to `features/game/domain/usecases/` as a new usecase class.
2. Call it from `GameController` (never call it from a widget).
3. If new state fields are needed, update `GameState` in `application/state/game_state.dart`.

### Change a color

Edit only `lib/core/theme/app_colors.dart`. Change the hex value in `EmojiviaColors.light`. Every widget that reads `context.ec` will pick up the change automatically.

### Add a persisted setting

1. Add a key string constant to `lib/core/storage/storage_keys.dart`.
2. Add getter + async setter to `StorageService`.
3. Read it via `ref.read(storageServiceProvider)` anywhere in `application/` or `presentation/`.

### Add a new feature (e.g., Achievements)

Create `features/achievements/` with the full structure:
```
features/achievements/
├── achievements.dart          ← barrel: export only public providers
├── domain/entities/
├── domain/repositories/
├── domain/usecases/
├── data/models/
├── data/sources/
├── data/repositories/
├── application/state/
├── application/controllers/
├── application/providers/
└── presentation/screens/
```

Other features interact with it **only** through `achievements.dart`.

---

## 12. Common mistakes to avoid

**Importing across feature internals.** If you find yourself writing `import 'package:emojivia/features/streak/data/repositories/streak_repository_impl.dart'` from inside the `game` feature, stop. Use the barrel (`streak/streak.dart`) and the exported provider.

**Calling `ref.watch` inside a callback.** `ref.watch` only works inside `build()`. Inside `onTap`, `initState`, or async methods, use `ref.read`.

**Putting business logic in a widget.** If a widget is doing date arithmetic, computing a streak, or deciding what copy to show based on a score — that logic belongs in a usecase or service, not in `build()`.

**Using `AppTypography.pixelNumeralS` for anything other than short digit strings.** Press Start 2P is a decorative font at small sizes. Using it for even a 3-word phrase looks terrible.

**Blurred shadows.** `blurRadius` must always be `0`. The design identity depends on hard-edged offset shadows.

**Using Material card default chrome.** Always use a custom `BoxDecoration` with an `ec.ink` border. The `Card` widget's default elevation and rounded corners do not match the design.

---

## 13. Dependency graph at a glance

```
main.dart
  └── app/app.dart
        ├── core/theme/*          (theme, colors, typography, shapes)
        └── app/router.dart
              ├── features/onboarding/presentation/screens/splash_screen.dart
              │     └── features/streak/streak.dart (streakControllerProvider)
              │
              ├── features/home/presentation/screens/home_screen.dart
              │     ├── features/streak/streak.dart
              │     └── core/widgets/* (ChunkyButton, Mascot, StreakChip, WeekStrip)
              │
              ├── features/game/presentation/screens/game_screen.dart
              │     ├── features/game/application/providers/game_providers.dart
              │     │     ├── features/game/domain/usecases/get_today_puzzles.dart
              │     │     └── features/game/data/repositories/puzzle_repository_impl.dart
              │     │           └── features/game/data/sources/puzzle_asset_source.dart
              │     │                 └── assets/puzzles/YYYY-MM-DD.json
              │     ├── features/streak/streak.dart  ← cross-feature call on game over
              │     └── core/widgets/* (EmojiStage, AnswerOption, FeedbackSheet, ...)
              │
              ├── features/results/presentation/screens/results_screen.dart
              │     ├── features/game/game.dart (gameControllerProvider)
              │     ├── features/streak/streak.dart
              │     └── core/widgets/* (ShareCard, ConfettiOverlay, Mascot)
              │
              ├── features/results/presentation/screens/empty_screen.dart
              │     └── features/streak/streak.dart
              │
              └── features/packs/presentation/screens/packs_screen.dart
                    └── core/widgets/chunky_button.dart
```

---

## 14. File quick-reference

| You want to… | Look in |
|---|---|
| Change a color | `lib/core/theme/app_colors.dart` |
| Change a font size or family | `lib/core/theme/app_typography.dart` |
| Change border radii or shadows | `lib/core/theme/app_theme.dart` |
| Add/change a button | `lib/core/widgets/chunky_button.dart` |
| Change the emoji arcade panel | `lib/core/widgets/emoji_stage.dart` |
| Change pixel-art sprites | `lib/core/widgets/pixel_sprites.dart` |
| Change the mascot | `lib/core/widgets/mascot.dart` |
| Change streak/hint chips or week strip | `lib/core/widgets/streak_chip.dart` |
| Add a screen route | `lib/app/router.dart` |
| Change gameplay rules | `lib/features/game/domain/usecases/` |
| Change what state the game tracks | `lib/features/game/application/state/game_state.dart` |
| Change game controller logic | `lib/features/game/application/controllers/game_controller.dart` |
| Change puzzle loading or fallback | `lib/features/game/data/sources/puzzle_asset_source.dart` |
| Add/change puzzle content | `assets/puzzles/YYYY-MM-DD.json` |
| Change streak rules | `lib/features/streak/domain/usecases/compute_streak.dart` |
| Change what's persisted | `lib/core/storage/storage_keys.dart` + `storage_service.dart` |
| Change user-facing copy | `lib/l10n/app_en.arb` + `lib/features/game/application/services/feedback_copy_service.dart` |
