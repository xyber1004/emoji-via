import 'package:supabase_flutter/supabase_flutter.dart';

/// Minimal shape of a `streaks` row as returned by Supabase.
class RemoteStreak {
  const RemoteStreak({
    required this.count,
    required this.lastPlayedDate,
    required this.updatedAt,
  });

  final int count;
  final String? lastPlayedDate;

  /// Server value of `updated_at` (ISO-8601 / RFC3339 string).
  final String updatedAt;
}

/// Thin wrapper over the Supabase `streaks` table, keyed on the current
/// authenticated uid (anonymous or linked). Contains no business logic.
class StreakRemoteSource {
  const StreakRemoteSource(this._client);

  final SupabaseClient _client;

  static const _table = 'streaks';

  String? get _uid => _client.auth.currentUser?.id;

  /// Upserts the caller's streak row. [updatedAt] is client-supplied so local
  /// and remote timestamps are directly comparable for conflict resolution.
  Future<void> upsert({
    required int count,
    required String? lastPlayedDate,
    required String updatedAt,
  }) async {
    final uid = _uid;
    if (uid == null) return; // no session yet — nothing to write against
    await _client.from(_table).upsert({
      'user_id': uid,
      'count': count,
      'last_played_date': lastPlayedDate,
      'updated_at': updatedAt,
    });
  }

  /// Fetches the caller's streak row, or null if none exists / no session.
  Future<RemoteStreak?> fetch() async {
    final uid = _uid;
    if (uid == null) return null;
    final row = await _client
        .from(_table)
        .select('count, last_played_date, updated_at')
        .eq('user_id', uid)
        .maybeSingle();
    if (row == null) return null;
    return RemoteStreak(
      count: (row['count'] as num?)?.toInt() ?? 0,
      lastPlayedDate: row['last_played_date'] as String?,
      updatedAt: row['updated_at'] as String? ?? '',
    );
  }
}
