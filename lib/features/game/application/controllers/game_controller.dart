import 'package:flutter/foundation.dart';
import 'package:emojivia/features/game/domain/entities/daily_puzzle_set.dart';
import '../state/game_types.dart';

/// In-game state machine. State is flattened onto the notifier: widgets read
/// the fields/getters directly and rebuild via [notifyListeners].
class GameController extends ChangeNotifier {
  DailyPuzzleSet? puzzleSet;
  int index = 0;
  List<bool?> results = const [];
  int hearts = 0;
  int hints = 0;
  bool hintShown = false;
  String? picked;
  GamePhase phase = GamePhase.ask;

  bool get isStarted => puzzleSet != null;

  bool get isComplete =>
      puzzleSet != null && index >= puzzleSet!.puzzles.length;

  bool get isRanOut => isStarted && hearts <= 0;

  bool get isOver => isComplete || isRanOut;

  /// True when the current puzzle is the last one (or hearts ran out) — i.e.
  /// answering/dismissing feedback for the current puzzle should end the run.
  bool get isFinished =>
      puzzleSet != null &&
      (index >= puzzleSet!.puzzles.length - 1 || isRanOut);

  int get score => results.whereType<bool>().where((b) => b).length;

  void startGame(DailyPuzzleSet set, int hintBalance) {
    puzzleSet = set;
    index = 0;
    results = List.filled(set.puzzles.length, null);
    hearts = 3;
    hints = hintBalance;
    hintShown = false;
    picked = null;
    phase = GamePhase.ask;
    notifyListeners();
  }

  void pickAnswer(String option) {
    final set = puzzleSet;
    if (set == null || phase != GamePhase.ask) return;
    final puzzle = set.puzzles[index];
    final isCorrect = option == puzzle.answer;
    final newResults = List<bool?>.from(results);
    newResults[index] = isCorrect;
    results = newResults;
    if (!isCorrect) hearts -= 1;
    picked = option;
    phase = GamePhase.feedback;
    notifyListeners();
  }

  void useHint() {
    if (puzzleSet == null || hints <= 0 || hintShown) return;
    hints -= 1;
    hintShown = true;
    notifyListeners();
  }

  void advance() {
    if (puzzleSet == null || phase != GamePhase.feedback) return;
    index += 1;
    hintShown = false;
    picked = null;
    phase = GamePhase.ask;
    notifyListeners();
  }

  void reset() {
    puzzleSet = null;
    index = 0;
    results = const [];
    hearts = 0;
    hints = 0;
    hintShown = false;
    picked = null;
    phase = GamePhase.ask;
    notifyListeners();
  }

  TodayRun toTodayRun() {
    final set = puzzleSet!;
    return TodayRun(
      date: set.date,
      results: results.map((r) => r ?? false).toList(),
      score: score,
      total: set.puzzles.length,
      hearts: hearts,
      hints: hints,
      ranOut: isRanOut,
    );
  }
}
