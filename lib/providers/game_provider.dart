import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import '../models/puzzle.dart';

class GameNotifier extends Notifier<GameState?> {
  @override
  GameState? build() => null;

  void startGame(DailyPuzzleSet puzzleSet, int hintBalance) {
    state = GameState(
      puzzleSet: puzzleSet,
      index: 0,
      results: List.filled(puzzleSet.puzzles.length, null),
      hearts: 3,
      hints: hintBalance,
      hintShown: false,
      picked: null,
      phase: GamePhase.ask,
    );
  }

  void pickAnswer(String option) {
    final game = state;
    if (game == null || game.phase != GamePhase.ask) return;
    final puzzle = game.puzzleSet.puzzles[game.index];
    final isCorrect = option == puzzle.answer;
    final newResults = List<bool?>.from(game.results);
    newResults[game.index] = isCorrect;
    state = GameState(
      puzzleSet: game.puzzleSet,
      index: game.index,
      results: newResults,
      hearts: isCorrect ? game.hearts : game.hearts - 1,
      hints: game.hints,
      hintShown: game.hintShown,
      picked: option,
      phase: GamePhase.feedback,
    );
  }

  void useHint() {
    final game = state;
    if (game == null || game.hints <= 0 || game.hintShown) return;
    state = GameState(
      puzzleSet: game.puzzleSet,
      index: game.index,
      results: game.results,
      hearts: game.hearts,
      hints: game.hints - 1,
      hintShown: true,
      picked: game.picked,
      phase: game.phase,
    );
  }

  void advance() {
    final game = state;
    if (game == null || game.phase != GamePhase.feedback) return;
    state = GameState(
      puzzleSet: game.puzzleSet,
      index: game.index + 1,
      results: game.results,
      hearts: game.hearts,
      hints: game.hints,
      hintShown: false,
      picked: null,
      phase: GamePhase.ask,
    );
  }

  void reset() => state = null;
}

final gameProvider = NotifierProvider<GameNotifier, GameState?>(
  GameNotifier.new,
);
