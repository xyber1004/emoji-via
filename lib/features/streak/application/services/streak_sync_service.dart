import 'package:flutter/foundation.dart';
import 'package:emojivia/core/storage/storage_service.dart';
import 'package:emojivia/features/streak/data/sources/streak_remote_source.dart';

/// Orchestrates the read-through reconciliation between the local prefs streak
/// and the Supabase copy. Stateless; keeps IO out of the controller.
class StreakSyncService {
  const StreakSyncService(this._remote, this._storage);

  final StreakRemoteSource _remote;
  final StorageService _storage;

  /// Fetches the remote streak and, if it is strictly newer than the local
  /// copy, persists it locally and returns it. Returns null when local is
  /// up-to-date, there is no remote row, or the fetch fails (offline).
  ///
  /// Conflict rule: later `updated_at` wins; a tie prefers the server value we
  /// already hold locally, so equal timestamps return null (no-op).
  Future<RemoteStreak?> pullIfNewer() async {
    try {
      final remote = await _remote.fetch();
      if (remote == null || remote.updatedAt.isEmpty) return null;

      final remoteTs = DateTime.tryParse(remote.updatedAt);
      if (remoteTs == null) return null;

      final localRaw = _storage.streakUpdatedAt;
      final localTs = localRaw == null ? null : DateTime.tryParse(localRaw);

      final remoteWins = localTs == null || remoteTs.isAfter(localTs);
      if (!remoteWins) return null;

      // Persist locally without re-upserting to remote (avoids a write echo).
      await _storage.recordPlay(remote.count, remote.lastPlayedDate ?? '');
      await _storage.setStreakUpdatedAt(remote.updatedAt);
      return remote;
    } catch (e) {
      debugPrint('streak pullIfNewer failed: $e');
      return null;
    }
  }
}
