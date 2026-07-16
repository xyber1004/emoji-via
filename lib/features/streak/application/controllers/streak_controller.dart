import 'package:flutter/foundation.dart';
import 'package:emojivia/features/streak/domain/entities/streak.dart';
import 'package:emojivia/features/streak/domain/usecases/compute_streak.dart';
import 'package:emojivia/features/streak/domain/repositories/streak_repository.dart';

/// Streak state, flattened onto the notifier. Loads initial values from the
/// repository at construction.
class StreakController extends ChangeNotifier {
  StreakController(this._repo) {
    final s = _repo.load();
    count = s.count;
    lastPlayedDate = s.lastPlayedDate;
    introSeen = s.introSeen;
    hintBalance = s.hintBalance;
  }

  static const _compute = ComputeStreak();
  final StreakRepository _repo;

  int count = 0;
  String? lastPlayedDate;
  bool introSeen = false;
  int hintBalance = 0;

  bool get playedToday {
    if (lastPlayedDate == null) return false;
    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return lastPlayedDate == today;
  }

  // Public cross-feature boundary — called by the game feature.
  Future<void> recordCompletion(String date) async {
    final entity = Streak(
      count: count,
      lastPlayedDate: lastPlayedDate,
      introSeen: introSeen,
      hintBalance: hintBalance,
    );
    final newCount = _compute(entity, date);
    count = newCount;
    lastPlayedDate = date;
    notifyListeners();
    await _repo.save(
      Streak(
        count: newCount,
        lastPlayedDate: date,
        introSeen: introSeen,
        hintBalance: hintBalance,
      ),
    );
  }

  Future<void> markIntroSeen() async {
    introSeen = true;
    notifyListeners();
  }
}
