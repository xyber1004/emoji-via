import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:emojivia/core/storage/storage_service.dart';
import 'package:emojivia/features/awards/application/controllers/awards_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<AwardsController> build() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    return AwardsController(StorageService(prefs));
  }

  test('unlocks first_steps once the first puzzle is played', () async {
    final c = await build();
    final earned = await c.evaluate(
      currentStreak: 1,
      longestStreak: 1,
      puzzlesPlayed: 5,
      perfectDays: 0,
      sharesSent: 0,
    );
    expect(earned.map((a) => a.id), contains('first_steps'));
    expect(c.isUnlocked('first_steps'), isTrue);
    expect(c.justUnlocked, isNotEmpty);
  });

  test('does not re-award an already-unlocked achievement', () async {
    final c = await build();
    await c.evaluate(
      currentStreak: 1,
      longestStreak: 1,
      puzzlesPlayed: 5,
      perfectDays: 0,
      sharesSent: 0,
    );
    final second = await c.evaluate(
      currentStreak: 2,
      longestStreak: 2,
      puzzlesPlayed: 10,
      perfectDays: 0,
      sharesSent: 0,
    );
    expect(second.map((a) => a.id), isNot(contains('first_steps')));
  });

  test('threshold achievements stay locked until the target is met', () async {
    final c = await build();
    var earned = await c.evaluate(
      currentStreak: 6,
      longestStreak: 6,
      puzzlesPlayed: 5,
      perfectDays: 0,
      sharesSent: 0,
    );
    expect(earned.map((a) => a.id), isNot(contains('on_fire')));
    expect(c.isUnlocked('on_fire'), isFalse);

    earned = await c.evaluate(
      currentStreak: 7,
      longestStreak: 7,
      puzzlesPlayed: 5,
      perfectDays: 0,
      sharesSent: 0,
    );
    expect(earned.map((a) => a.id), contains('on_fire'));
  });

  test('unseenCount tracks unlocks until markSeen is called', () async {
    final c = await build();
    await c.evaluate(
      currentStreak: 7,
      longestStreak: 7,
      puzzlesPlayed: 5,
      perfectDays: 1,
      sharesSent: 0,
    );
    expect(c.unseenCount, greaterThan(0));
    await c.markSeen();
    expect(c.unseenCount, 0);
  });
}
