import 'dart:convert';
import 'puzzle.dart';

enum GamePhase { ask, feedback }

class TodayRun {
  const TodayRun({
    required this.date,
    required this.results,
    required this.score,
    required this.total,
    required this.hearts,
    required this.hints,
    required this.ranOut,
  });

  final String date;
  final List<bool> results;
  final int score;
  final int total;
  final int hearts;
  final int hints;
  final bool ranOut;

  String toJsonString() => jsonEncode({
        'date': date,
        'results': results,
        'score': score,
        'total': total,
        'hearts': hearts,
        'hints': hints,
        'ranOut': ranOut,
      });

  factory TodayRun.fromJsonString(String s) {
    final m = jsonDecode(s) as Map<String, dynamic>;
    return TodayRun(
      date: m['date'] as String,
      results: List<bool>.from(m['results'] as List),
      score: m['score'] as int,
      total: m['total'] as int,
      hearts: m['hearts'] as int,
      hints: m['hints'] as int,
      ranOut: m['ranOut'] as bool,
    );
  }
}

class GameState {
  const GameState({
    required this.puzzleSet,
    required this.index,
    required this.results,
    required this.hearts,
    required this.hints,
    required this.hintShown,
    this.picked,
    required this.phase,
  });

  final DailyPuzzleSet puzzleSet;
  final int index;
  final List<bool?> results;
  final int hearts;
  final int hints;
  final bool hintShown;
  final String? picked;
  final GamePhase phase;

  bool get isComplete => index >= puzzleSet.puzzles.length;
  bool get isRanOut => hearts <= 0;
  bool get isOver => isComplete || isRanOut;
  int get score => results.whereType<bool>().where((b) => b).length;

  TodayRun toTodayRun() => TodayRun(
        date: puzzleSet.date,
        results: results.map((r) => r ?? false).toList(),
        score: score,
        total: puzzleSet.puzzles.length,
        hearts: hearts,
        hints: hints,
        ranOut: isRanOut,
      );
}
