import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:emojivia/core/storage/storage_service.dart';
import 'package:emojivia/features/game/application/controllers/game_controller.dart';
import 'package:emojivia/features/game/application/services/feedback_copy_service.dart';
import 'package:emojivia/features/game/data/repositories/puzzle_repository_impl.dart';
import 'package:emojivia/features/game/data/sources/puzzle_asset_source.dart';
import 'package:emojivia/features/game/domain/repositories/puzzle_repository.dart';
import 'package:emojivia/features/game/domain/usecases/get_today_puzzles.dart';
import 'package:emojivia/features/streak/application/controllers/streak_controller.dart';
import 'package:emojivia/features/streak/data/repositories/streak_repository_impl.dart';
import 'package:emojivia/features/streak/data/sources/streak_prefs_source.dart';
import 'package:emojivia/features/streak/domain/repositories/streak_repository.dart';

/// Root provider tree. Wires dependency-injection for the whole app.
///
/// Ordering matters: each provider may `context.read` the ones declared before
/// it. Stateless services use [Provider]; controllers use [ChangeNotifierProvider].
List<SingleChildWidget> buildAppProviders(SharedPreferences prefs) {
  return [
    Provider<SharedPreferences>.value(value: prefs),
    Provider<StorageService>(
      create: (ctx) => StorageService(ctx.read<SharedPreferences>()),
    ),
    Provider<PuzzleAssetSource>(create: (_) => const PuzzleAssetSource()),
    Provider<PuzzleRepository>(
      create: (ctx) => PuzzleRepositoryImpl(ctx.read<PuzzleAssetSource>()),
    ),
    Provider<GetTodayPuzzles>(
      create: (ctx) => GetTodayPuzzles(ctx.read<PuzzleRepository>()),
    ),
    Provider<FeedbackCopyService>(create: (_) => const FeedbackCopyService()),
    Provider<StreakRepository>(
      create: (ctx) =>
          StreakRepositoryImpl(StreakPrefsSource(ctx.read<StorageService>())),
    ),
    ChangeNotifierProvider<StreakController>(
      create: (ctx) => StreakController(ctx.read<StreakRepository>()),
    ),
    ChangeNotifierProvider<GameController>(create: (_) => GameController()),
  ];
}
