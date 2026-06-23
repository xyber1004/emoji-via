import 'package:shared_preferences/shared_preferences.dart';
import 'storage_keys.dart';
import '../utils/app_date_utils.dart';
import '../constants/app_constants.dart';

class StorageService {
  const StorageService(this._prefs);

  final SharedPreferences _prefs;

  int get streakCount => _prefs.getInt(StorageKeys.streakCount) ?? 0;
  String? get lastPlayedDate => _prefs.getString(StorageKeys.lastPlayedDate);
  bool get introSeen => _prefs.getBool(StorageKeys.introSeen) ?? false;
  String? get savedRunJson => _prefs.getString(StorageKeys.todayRun);

  int get hintBalance {
    final today = AppDateUtils.todayStr();
    if (_prefs.getString(StorageKeys.lastHintDate) != today) {
      return AppConstants.dailyHintCap;
    }
    return _prefs.getInt(StorageKeys.hintBalance) ?? AppConstants.dailyHintCap;
  }

  bool get playedToday => lastPlayedDate == AppDateUtils.todayStr();

  Future<void> markIntroSeen() =>
      _prefs.setBool(StorageKeys.introSeen, true);

  Future<void> saveTodayRunJson(String json) =>
      _prefs.setString(StorageKeys.todayRun, json);

  Future<void> recordPlay(int newStreak, String date) => Future.wait([
        _prefs.setInt(StorageKeys.streakCount, newStreak),
        _prefs.setString(StorageKeys.lastPlayedDate, date),
      ]);

  Future<void> consumeHint(int newBalance) => Future.wait([
        _prefs.setInt(StorageKeys.hintBalance, newBalance),
        _prefs.setString(StorageKeys.lastHintDate, AppDateUtils.todayStr()),
      ]);
}

