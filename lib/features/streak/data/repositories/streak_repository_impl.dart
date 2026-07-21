import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:emojivia/core/storage/storage_service.dart';
import 'package:emojivia/features/streak/domain/entities/streak.dart';
import 'package:emojivia/features/streak/domain/repositories/streak_repository.dart';
import '../sources/streak_prefs_source.dart';
import '../sources/streak_remote_source.dart';

class StreakRepositoryImpl implements StreakRepository {
  const StreakRepositoryImpl(this._source, this._remote, this._storage);

  final StreakPrefsSource _source;
  final StreakRemoteSource _remote;
  final StorageService _storage;

  @override
  Streak load() => _source.load();

  @override
  Future<void> save(Streak streak) async {
    // Prefs first (instant, offline-safe), stamping the shared updated_at.
    final updatedAt = DateTime.now().toUtc().toIso8601String();
    await _source.save(streak.count, streak.lastPlayedDate ?? '');
    await _storage.setStreakUpdatedAt(updatedAt);

    // Mirror to Supabase fire-and-forget — never block the UI, no inline retry.
    // The read-through in StreakController reconciles on next launch/resume.
    unawaited(
      _remote
          .upsert(
            count: streak.count,
            lastPlayedDate: streak.lastPlayedDate,
            updatedAt: updatedAt,
          )
          .catchError((Object e) => debugPrint('streak remote upsert failed: $e')),
    );
  }
}
