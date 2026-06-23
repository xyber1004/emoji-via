import 'package:emojivia/features/game/domain/entities/daily_puzzle_set.dart';
import 'package:emojivia/features/game/domain/repositories/puzzle_repository.dart';
import '../sources/puzzle_asset_source.dart';

class PuzzleRepositoryImpl implements PuzzleRepository {
  const PuzzleRepositoryImpl(this._source);
  final PuzzleAssetSource _source;

  @override
  Future<DailyPuzzleSet> getToday() => _source.loadToday();
}
