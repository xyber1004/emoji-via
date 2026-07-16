# Migrate state management: Riverpod → `provider`

**Date:** 2026-07-16
**Status:** Approved design → ready for implementation plan

## Goal

Remove `flutter_riverpod` from Emojivia entirely and use the pub.dev `provider`
package for all app-wide state, dependency injection, and cross-feature
communication. This is an explicit product decision that overrides the Riverpod
mandate previously written in `CLAUDE.md` (§5.3, §10b, §11); those sections will
be updated to match.

## Decisions (locked)

1. **Pattern:** `ChangeNotifier` controllers wired through a root `MultiProvider`.
   No `state_notifier` / `flutter_state_notifier` helper packages — "just provider".
2. **State shape:** *Flatten* — dissolve `GameState` and `StreakState`. Each
   controller exposes its fields directly (`index`, `hearts`, `hints`, `count`,
   `lastPlayedDate`, …) with the computed getters (`score`, `isFinished`,
   `isComplete`, `isRanOut`, `playedToday`) moved onto the controller.
3. **`TodayRun` stays** as a serialization DTO (it is persistence, not UI state).
   Its construction moves from `GameState.toTodayRun()` to a
   `GameController.toTodayRun()` method.

## Architecture

Dependency direction is unchanged (`presentation → application → domain ← data`).
Only the wiring mechanism changes: Riverpod providers → `provider` entries in a
single root `MultiProvider`, dependencies resolved via `context.read<T>()` in
each provider's `create`/`update`.

### Root provider tree (`main.dart` + new `core/di/app_providers.dart`)

`ProviderScope` is replaced by `MultiProvider`. `SharedPreferences` is loaded
before `runApp` (as today) and injected as a value. Order (top→bottom, each may
`context.read` the ones above it):

| Provider | Type | Depends on |
|---|---|---|
| `SharedPreferences` | `Provider.value` | — |
| `StorageService` | `Provider` | SharedPreferences |
| `PuzzleAssetSource` | `Provider` | — |
| `PuzzleRepository` | `Provider` | PuzzleAssetSource |
| `GetTodayPuzzles` | `Provider` | PuzzleRepository |
| `FeedbackCopyService` | `Provider` | — |
| `StreakRepository` | `Provider` | StorageService |
| `StreakController` | `ChangeNotifierProvider` | StreakRepository (loads in ctor) |
| `GameController` | `ChangeNotifierProvider` | — |

Stateless services use `Provider` (never rebuilt). Controllers use
`ChangeNotifierProvider`.

### Controllers

**`GameController extends ChangeNotifier`**
- Fields: `DailyPuzzleSet? puzzleSet`, `int index`, `List<bool?> results`,
  `int hearts`, `int hints`, `bool hintShown`, `String? picked`, `GamePhase phase`.
- Getters moved from `GameState`: `bool get isStarted` (`puzzleSet != null`),
  `isComplete`, `isRanOut`, `isOver`, `isFinished`, `int get score`.
- Methods keep their signatures: `startGame(set, hintBalance)`, `pickAnswer(opt)`,
  `useHint()`, `advance()`, `reset()`, plus `toTodayRun()`. Each mutation sets
  fields then calls `notifyListeners()`.
- Dependencies: none needed at construction.

**`StreakController extends ChangeNotifier`**
- Fields: `int count`, `String? lastPlayedDate`, `bool introSeen`, `int hintBalance`.
- Getter moved from `StreakState`: `bool get playedToday`.
- Constructor takes `StreakRepository` and loads initial state from it.
- Methods: `recordCompletion(date)` (uses `ComputeStreak`, saves via repo),
  `markIntroSeen()`. Each mutation calls `notifyListeners()`.

### The `FutureProvider` (`todayPuzzleSetProvider`) — removed

`provider` has no caching `FutureProvider` equivalent, and `GameScreen` already
awaits the puzzle set exactly once in `_initGame`. Replace with a direct
`await context.read<GetTodayPuzzles>()()` call in `_initGame`; delete the provider.

### Widget consumption

| Riverpod today | `provider` after |
|---|---|
| `ConsumerWidget` / `build(ctx, ref)` | `StatelessWidget` / `build(ctx)` |
| `ConsumerStatefulWidget` / `ConsumerState` | `StatefulWidget` / `State` |
| `ref.watch(streakControllerProvider)` → `StreakState` | `context.watch<StreakController>()` (read fields directly) |
| `ref.watch(gameControllerProvider)` → `GameState?` | `context.watch<GameController>()` |
| `ref.read(x.notifier).method()` | `context.read<XController>().method()` |
| `ref.read(storageServiceProvider)` | `context.read<StorageService>()` |
| `ref.read(todayPuzzleSetProvider.future)` | `context.read<GetTodayPuzzles>()()` |

Screens affected: `home_screen`, `game_screen`, `results_screen`, `empty_screen`,
`splash_screen`. `game_screen` reads both `GameController` and `StreakController`
(cross-feature via the root `MultiProvider`).

### Barrels & deletions

- `features/streak/streak.dart`: export `StreakController` (delete
  `*Provider` exports).
- `features/game/game.dart`: export `GameController`, `FeedbackCopyService` as
  needed by other features.
- **Delete:** `core/storage/storage_provider.dart`,
  `features/game/application/providers/game_providers.dart`,
  `features/streak/application/providers/streak_providers.dart`,
  `features/streak/application/providers/streak_repository_provider.dart`,
  `features/game/application/state/game_state.dart` (minus `TodayRun` + `GamePhase`,
  which move to a new `game_types.dart`), and
  `features/streak/application/state/streak_state.dart`.
- New: `core/di/app_providers.dart` (the `MultiProvider` list),
  `features/game/application/state/game_types.dart` (`GamePhase` enum + `TodayRun`).

### Docs

Update `CLAUDE.md` §5.3 (in-game state), §10b.1/§10b.2/§10b.3 (Riverpod
references in the architecture), and §11 (dependencies) to describe `provider`
instead of Riverpod.

## Error handling

No behavior change. `StreakController` loading from prefs and the puzzle-set
future keep their existing try/fallback behavior. The `game == null` gate in
`ResultsScreen`/`GameScreen` becomes a `controller.isStarted` check.

## Testing / verification

No test suite exists in `test/` today, so verification is: `flutter analyze`
clean and `flutter pub get` succeeds with `provider` and without
`flutter_riverpod`. A manual smoke run (splash → home → play 5 → results →
empty) confirms the wiring end-to-end. If a `flutter run` on-device check is
desired, that's a follow-up.

## Out of scope

- No new features or gameplay changes.
- No adoption of `context.select` micro-optimizations beyond straightforward
  `watch`/`read` (can be a later pass).
- No changes to domain entities, DTOs, or data sources beyond import cleanup.
