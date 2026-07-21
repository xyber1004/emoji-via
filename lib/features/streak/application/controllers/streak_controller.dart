import 'package:flutter/foundation.dart';
import 'package:emojivia/core/storage/storage_service.dart';
import 'package:emojivia/features/streak/application/services/streak_sync_service.dart';
import 'package:emojivia/features/streak/domain/entities/streak.dart';
import 'package:emojivia/features/streak/domain/usecases/compute_streak.dart';
import 'package:emojivia/features/streak/domain/repositories/streak_repository.dart';

/// Streak state, flattened onto the notifier. Loads initial values from the
/// repository at construction and reconciles with the backend in the background.
class StreakController extends ChangeNotifier {
  StreakController(this._repo, this._storage, this._sync) {
    final s = _repo.load();
    count = s.count;
    lastPlayedDate = s.lastPlayedDate;
    introSeen = s.introSeen;
    hintBalance = s.hintBalance;
    emailLinked = _storage.emailLinkedAt != null;
    lastSavePromptShown = _storage.lastSavePromptShown;
    // Fire the read-through reconcile without blocking construction.
    syncFromRemote();
  }

  static const _compute = ComputeStreak();
  final StreakRepository _repo;
  final StorageService _storage;
  final StreakSyncService _sync;

  int count = 0;
  String? lastPlayedDate;
  bool introSeen = false;
  int hintBalance = 0;
  bool emailLinked = false;
  DateTime? lastSavePromptShown;

  bool get playedToday {
    if (lastPlayedDate == null) return false;
    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return lastPlayedDate == today;
  }

  /// Whether to offer the "save your streak" prompt on the results screen.
  bool get shouldPromptSave {
    if (emailLinked) return false;
    if (count < 7) return false;
    final last = lastSavePromptShown;
    if (last == null) return true;
    return DateTime.now().difference(last).inDays >= 7;
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

  /// Records that the save prompt was shown so it isn't re-offered for 7 days.
  Future<void> markSavePromptShown() async {
    final now = DateTime.now();
    lastSavePromptShown = now;
    notifyListeners();
    await _storage.setLastSavePromptShown(now);
  }

  /// Re-reads the linked-email flag after a successful OTP verify so the save
  /// prompt never fires again.
  void refreshEmailLinked() {
    emailLinked = _storage.emailLinkedAt != null;
    notifyListeners();
  }

  /// Background reconcile: adopt the remote streak if it is newer than local.
  Future<void> syncFromRemote() async {
    final remote = await _sync.pullIfNewer();
    if (remote == null) return;
    count = remote.count;
    lastPlayedDate = remote.lastPlayedDate;
    notifyListeners();
  }
}
