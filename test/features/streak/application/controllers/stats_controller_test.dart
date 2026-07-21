import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:emojivia/core/storage/storage_service.dart';
import 'package:emojivia/features/game/application/state/game_types.dart';
import 'package:emojivia/features/streak/application/controllers/stats_controller.dart';

TodayRun _run({required int score, int total = 5}) => TodayRun(
      date: '2026-07-21',
      results: List<bool>.generate(total, (i) => i < score),
      score: score,
      total: total,
      hearts: 3,
      hints: 2,
      ranOut: false,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<StatsController> build() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    return StatsController(StorageService(prefs));
  }

  test('day-1 controller reports no data', () async {
    final c = await build();
    expect(c.hasData, isFalse);
    expect(c.puzzlesPlayed, 0);
    expect(c.recentDays, List<bool?>.filled(9, null));
  });

  test('recordRun folds totals, histogram and the 9-day strip', () async {
    final c = await build();
    await c.recordRun(run: _run(score: 4), streakCount: 3);

    expect(c.puzzlesPlayed, 5);
    expect(c.puzzlesCorrect, 4);
    expect(c.accuracyPct, 80);
    expect(c.perfectDays, 0);
    expect(c.scoreHistogram[4], 1);
    expect(c.longestStreak, 3);
    // Strip shifts left; newest slot is today's completion.
    expect(c.recentDays.last, isTrue);
    expect(c.recentDays.length, 9);
    expect(c.hasData, isTrue);
  });

  test('recordRun accumulates across days and counts perfect days', () async {
    final c = await build();
    await c.recordRun(run: _run(score: 4), streakCount: 3);
    await c.recordRun(run: _run(score: 5), streakCount: 4);

    expect(c.puzzlesPlayed, 10);
    expect(c.puzzlesCorrect, 9);
    expect(c.perfectDays, 1);
    expect(c.scoreHistogram[4], 1);
    expect(c.scoreHistogram[5], 1);
    expect(c.longestStreak, 4);
  });

  test('longestStreak never regresses when the streak breaks', () async {
    final c = await build();
    await c.recordRun(run: _run(score: 5), streakCount: 9);
    await c.recordRun(run: _run(score: 5), streakCount: 1);
    expect(c.longestStreak, 9);
  });

  test('recordShare bumps the lifetime share counter', () async {
    final c = await build();
    await c.recordShare();
    await c.recordShare();
    expect(c.sharesSent, 2);
  });
}
