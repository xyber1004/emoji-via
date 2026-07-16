import 'dart:convert';

enum GamePhase { ask, feedback }

/// Serialization DTO for the persisted "today's run" snapshot.
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
