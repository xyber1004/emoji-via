import 'puzzle.dart';

class DailyPuzzleSet {
  const DailyPuzzleSet({
    required this.id,
    required this.date,
    required this.puzzles,
  });

  final int id;
  final String date;
  final List<Puzzle> puzzles;
}
