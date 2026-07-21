import 'package:flutter/foundation.dart';
import 'package:emojivia/core/storage/storage_service.dart';
import 'package:emojivia/features/game/application/state/game_types.dart';

/// Reads the aggregated `stats_totals` + `stats_recent_days` counters (CLAUDE.md
/// §5.2) and exposes them as typed getters for the Stats screen. Day-1 users see
/// zeros — the screen renders a friendly empty state on top of that.
class StatsController extends ChangeNotifier {
  StatsController(this._storage) {
    _load();
  }

  final StorageService _storage;

  int puzzlesPlayed = 0;
  int puzzlesCorrect = 0;
  int perfectDays = 0;
  int hintsUsed = 0;
  int sharesSent = 0;
  List<int> scoreHistogram = List<int>.filled(6, 0);
  List<bool?> recentDays = List<bool?>.filled(9, null);
  int longestStreak = 0;

  bool get hasData => puzzlesPlayed > 0;

  int get accuracyPct =>
      puzzlesPlayed == 0 ? 0 : ((puzzlesCorrect / puzzlesPlayed) * 100).round();

  void _load() {
    final t = _storage.statsTotals;
    puzzlesPlayed = _asInt(t['puzzlesPlayed']);
    puzzlesCorrect = _asInt(t['puzzlesCorrect']);
    perfectDays = _asInt(t['perfectDays']);
    hintsUsed = _asInt(t['hintsUsed']);
    sharesSent = _asInt(t['sharesSent']);
    final hist = t['scoreHistogram'];
    if (hist is List) {
      scoreHistogram = List<int>.generate(
        6,
        (i) => i < hist.length ? _asInt(hist[i]) : 0,
      );
    }
    recentDays = _storage.statsRecentDays;
    longestStreak = _storage.longestStreak;
  }

  /// Re-reads from storage (e.g. after returning from a completed run).
  void refresh() {
    _load();
    notifyListeners();
  }

  /// Folds a completed run into the aggregated counters + the 9-day strip, and
  /// updates the all-time longest streak. Persists everything, then refreshes
  /// the in-memory fields so watchers rebuild. Idempotency is the caller's
  /// responsibility (guarded by `playedToday`).
  Future<void> recordRun({
    required TodayRun run,
    required int streakCount,
  }) async {
    final totals = Map<String, dynamic>.from(statsTotalsSnapshot());
    totals['puzzlesPlayed'] = puzzlesPlayed + run.total;
    totals['puzzlesCorrect'] = puzzlesCorrect + run.score;
    totals['perfectDays'] = perfectDays + (run.score == run.total ? 1 : 0);
    totals['sharesSent'] = sharesSent;
    final hist = List<int>.from(scoreHistogram);
    if (run.score >= 0 && run.score < hist.length) hist[run.score] += 1;
    totals['scoreHistogram'] = hist;

    // Shift the rolling 9-day strip left and append today's outcome.
    final nextDays = <bool?>[...recentDays.skip(1), true];

    await _storage.setStatsTotals(totals);
    await _storage.setStatsRecentDays(nextDays);
    if (streakCount > longestStreak) {
      await _storage.setLongestStreak(streakCount);
    }
    refresh();
  }

  /// Increments the lifetime share counter (called after a successful share).
  Future<void> recordShare() async {
    final totals = Map<String, dynamic>.from(statsTotalsSnapshot());
    totals['sharesSent'] = sharesSent + 1;
    await _storage.setStatsTotals(totals);
    refresh();
  }

  /// The persisted totals map with the current derived fields written back in,
  /// so partial writes never drop keys the screen doesn't read.
  Map<String, dynamic> statsTotalsSnapshot() => {
        'puzzlesPlayed': puzzlesPlayed,
        'puzzlesCorrect': puzzlesCorrect,
        'perfectDays': perfectDays,
        'hintsUsed': hintsUsed,
        'sharesSent': sharesSent,
        'scoreHistogram': scoreHistogram,
      };

  static int _asInt(dynamic v) => v is int ? v : (v is num ? v.toInt() : 0);
}
