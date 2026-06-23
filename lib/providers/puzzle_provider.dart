import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/puzzle_repository.dart';
import '../models/puzzle.dart';

final puzzleRepositoryProvider = Provider<PuzzleRepository>(
  (_) => PuzzleRepository(),
);

final todayPuzzleSetProvider = FutureProvider<DailyPuzzleSet>((ref) {
  return ref.read(puzzleRepositoryProvider).getTodayPuzzles();
});
