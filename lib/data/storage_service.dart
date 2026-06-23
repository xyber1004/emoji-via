import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_state.dart';

class StorageService {
  StorageService(this._prefs);

  final SharedPreferences _prefs;

  int get streakCount => _prefs.getInt('streak_count') ?? 0;
  String? get lastPlayedDate => _prefs.getString('last_played_date');
  bool get introSeen => _prefs.getBool('intro_seen') ?? false;

  int get hintBalance {
    final today = _todayStr();
    if (_prefs.getString('last_hint_date') != today) return 2;
    return _prefs.getInt('hint_balance') ?? 2;
  }

  TodayRun? get savedRun {
    final s = _prefs.getString('today_run');
    if (s == null) return null;
    try {
      return TodayRun.fromJsonString(s);
    } catch (_) {
      return null;
    }
  }

  Future<void> markIntroSeen() => _prefs.setBool('intro_seen', true);

  Future<void> saveRun(TodayRun run) =>
      _prefs.setString('today_run', run.toJsonString());

  Future<void> recordPlay(TodayRun run) async {
    final today = _todayStr();
    final yesterday = _yesterdayStr();

    int newStreak;
    final last = lastPlayedDate;
    if (last == today) {
      newStreak = streakCount;
    } else if (last == yesterday) {
      newStreak = streakCount + 1;
    } else {
      newStreak = 1;
    }

    await Future.wait([
      _prefs.setInt('streak_count', newStreak),
      _prefs.setString('last_played_date', today),
      _prefs.setString('today_run', run.toJsonString()),
    ]);
  }

  Future<void> consumeHint() async {
    final today = _todayStr();
    final newBalance = (hintBalance - 1).clamp(0, 2);
    await Future.wait([
      _prefs.setInt('hint_balance', newBalance),
      _prefs.setString('last_hint_date', today),
    ]);
  }

  bool get playedToday => lastPlayedDate == _todayStr();

  String _todayStr() {
    final d = DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  String _yesterdayStr() {
    final d = DateTime.now().subtract(const Duration(days: 1));
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
