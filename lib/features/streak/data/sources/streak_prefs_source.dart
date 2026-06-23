import 'package:emojivia/core/storage/storage_service.dart';
import 'package:emojivia/features/streak/domain/entities/streak.dart';

class StreakPrefsSource {
  const StreakPrefsSource(this._storage);
  final StorageService _storage;

  Streak load() => Streak(
        count: _storage.streakCount,
        lastPlayedDate: _storage.lastPlayedDate,
        introSeen: _storage.introSeen,
        hintBalance: _storage.hintBalance,
      );

  Future<void> save(int count, String date) =>
      _storage.recordPlay(count, date);

  Future<void> markIntroSeen() => _storage.markIntroSeen();
}
