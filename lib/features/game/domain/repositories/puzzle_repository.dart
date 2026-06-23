import '../entities/daily_puzzle_set.dart';

abstract class PuzzleRepository {
  Future<DailyPuzzleSet> getToday();
}
