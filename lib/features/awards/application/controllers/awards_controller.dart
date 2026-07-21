import 'package:flutter/foundation.dart';
import 'package:emojivia/core/storage/storage_service.dart';
import 'package:emojivia/features/awards/domain/entities/achievement.dart';

/// Tracks which achievements are unlocked and how many the user hasn't seen yet
/// (drives the Awards tab badge). Unlock *evaluation* happens after a run; this
/// controller just persists and exposes the resulting map.
class AwardsController extends ChangeNotifier {
  AwardsController(this._storage) {
    _unlocked = Map<String, String>.from(
      _storage.achievementsUnlocked.map((k, v) => MapEntry(k, '$v')),
    );
    _seenCount = _storage.awardsSeenAtCount;
  }

  final StorageService _storage;
  late Map<String, String> _unlocked;
  late int _seenCount;

  /// Achievements unlocked by the most recent [evaluate] call, awaiting a
  /// celebration toast on the results screen. Read once, then [clearJustUnlocked].
  List<Achievement> justUnlocked = const [];

  Map<String, String> get unlocked => Map.unmodifiable(_unlocked);

  bool isUnlocked(String id) => _unlocked.containsKey(id);

  /// Evaluates the whole catalog against the latest stats, unlocking any newly
  /// earned achievements. Populates [justUnlocked] with the ones earned this
  /// call (for the results toast) and returns them.
  Future<List<Achievement>> evaluate({
    required int currentStreak,
    required int longestStreak,
    required int puzzlesPlayed,
    required int perfectDays,
    required int sharesSent,
  }) async {
    int valueFor(AchievementMetric m) {
      switch (m) {
        case AchievementMetric.currentStreak:
          return currentStreak;
        case AchievementMetric.longestStreak:
          return longestStreak;
        case AchievementMetric.puzzlesPlayed:
          return puzzlesPlayed;
        case AchievementMetric.perfectDays:
          return perfectDays;
        case AchievementMetric.sharesSent:
          return sharesSent;
      }
    }

    final earned = <Achievement>[];
    for (final a in achievementCatalog) {
      if (_unlocked.containsKey(a.id)) continue;
      if (valueFor(a.metric) >= a.target) earned.add(a);
    }
    if (earned.isEmpty) {
      justUnlocked = const [];
      return const [];
    }
    final now = DateTime.now().toIso8601String();
    for (final a in earned) {
      _unlocked[a.id] = now;
    }
    justUnlocked = earned;
    notifyListeners();
    await _storage.setAchievementsUnlocked(_unlocked);
    return earned;
  }

  void clearJustUnlocked() => justUnlocked = const [];

  /// Count of unlocks the user hasn't acknowledged on the Awards tab yet.
  int get unseenCount {
    final diff = _unlocked.length - _seenCount;
    return diff > 0 ? diff : 0;
  }

  /// Marks the current unlock count as seen so the tab badge clears.
  Future<void> markSeen() async {
    if (_seenCount == _unlocked.length) return;
    _seenCount = _unlocked.length;
    notifyListeners();
    await _storage.setAwardsSeenAtCount(_seenCount);
  }

  /// Records a newly-earned achievement. No-op if already unlocked.
  /// Returns true if this call unlocked it. Called by the game/results flow.
  Future<bool> unlock(String id) async {
    if (_unlocked.containsKey(id)) return false;
    _unlocked[id] = DateTime.now().toIso8601String();
    notifyListeners();
    await _storage.setAchievementsUnlocked(_unlocked);
    return true;
  }
}
