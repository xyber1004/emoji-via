import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emojivia/features/game/application/controllers/game_controller.dart';
import 'package:emojivia/features/game/application/services/feedback_copy_service.dart';
import 'package:emojivia/features/game/application/state/game_state.dart';
import 'package:emojivia/features/game/data/repositories/puzzle_repository_impl.dart';
import 'package:emojivia/features/game/data/sources/puzzle_asset_source.dart';
import 'package:emojivia/features/game/domain/entities/daily_puzzle_set.dart';
import 'package:emojivia/features/game/domain/repositories/puzzle_repository.dart';
import 'package:emojivia/features/game/domain/usecases/get_today_puzzles.dart';

final _puzzleSourceProvider = Provider<PuzzleAssetSource>(
  (_) => const PuzzleAssetSource(),
);

final puzzleRepositoryProvider = Provider<PuzzleRepository>((ref) {
  return PuzzleRepositoryImpl(ref.read(_puzzleSourceProvider));
});

final _getTodayPuzzlesProvider = Provider<GetTodayPuzzles>((ref) {
  return GetTodayPuzzles(ref.read(puzzleRepositoryProvider));
});

final todayPuzzleSetProvider = FutureProvider<DailyPuzzleSet>((ref) {
  return ref.read(_getTodayPuzzlesProvider).call();
});

final gameControllerProvider = NotifierProvider<GameController, GameState?>(
  GameController.new,
);

final feedbackCopyServiceProvider = Provider<FeedbackCopyService>(
  (_) => const FeedbackCopyService(),
);
