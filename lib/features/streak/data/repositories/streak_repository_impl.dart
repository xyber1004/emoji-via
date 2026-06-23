import 'package:emojivia/features/streak/domain/entities/streak.dart';
import 'package:emojivia/features/streak/domain/repositories/streak_repository.dart';
import '../sources/streak_prefs_source.dart';

class StreakRepositoryImpl implements StreakRepository {
  const StreakRepositoryImpl(this._source);
  final StreakPrefsSource _source;

  @override
  Streak load() => _source.load();

  @override
  Future<void> save(Streak streak) =>
      _source.save(streak.count, streak.lastPlayedDate ?? '');
}
