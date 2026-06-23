import '../entities/daily_puzzle_set.dart';
import '../repositories/puzzle_repository.dart';

class GetTodayPuzzles {
  const GetTodayPuzzles(this._repository);
  final PuzzleRepository _repository;

  Future<DailyPuzzleSet> call() => _repository.getToday();
}
