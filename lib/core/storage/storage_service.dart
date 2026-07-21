import 'dart:convert';

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

  // Backend-sync state. All stored as ISO-8601 strings (or null when unset).
  DateTime? get lastSavePromptShown =>
      _parseDate(_prefs.getString(StorageKeys.lastSavePromptShown));
  DateTime? get emailLinkedAt =>
      _parseDate(_prefs.getString(StorageKeys.emailLinkedAt));
  String? get streakUpdatedAt => _prefs.getString(StorageKeys.streakUpdatedAt);

  Future<void> setLastSavePromptShown(DateTime when) => _prefs.setString(
        StorageKeys.lastSavePromptShown,
        when.toIso8601String(),
      );

  Future<void> setEmailLinkedAt(DateTime when) =>
      _prefs.setString(StorageKeys.emailLinkedAt, when.toIso8601String());

  Future<void> setStreakUpdatedAt(String iso) =>
      _prefs.setString(StorageKeys.streakUpdatedAt, iso);

  static DateTime? _parseDate(String? raw) =>
      raw == null ? null : DateTime.tryParse(raw);

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

  // --- Stats -----------------------------------------------------------------

  int get longestStreak => _prefs.getInt(StorageKeys.longestStreak) ?? 0;

  Future<void> setLongestStreak(int value) =>
      _prefs.setInt(StorageKeys.longestStreak, value);

  /// Aggregated lifetime counters. See CLAUDE.md §5.2 `stats_totals`.
  Map<String, dynamic> get statsTotals =>
      _readJsonMap(StorageKeys.statsTotals);

  Future<void> setStatsTotals(Map<String, dynamic> value) =>
      _prefs.setString(StorageKeys.statsTotals, jsonEncode(value));

  /// Rolling 9-slot ring buffer of recent-day outcomes (true/false/null).
  List<bool?> get statsRecentDays {
    final raw = _prefs.getString(StorageKeys.statsRecentDays);
    if (raw == null) return List<bool?>.filled(9, null);
    final decoded = jsonDecode(raw);
    if (decoded is! List) return List<bool?>.filled(9, null);
    return decoded.map((e) => e is bool ? e : null).toList();
  }

  Future<void> setStatsRecentDays(List<bool?> value) =>
      _prefs.setString(StorageKeys.statsRecentDays, jsonEncode(value));

  // --- Awards ----------------------------------------------------------------

  /// Map of `{ achievementId: unlockedIso }`.
  Map<String, dynamic> get achievementsUnlocked =>
      _readJsonMap(StorageKeys.achievementsUnlocked);

  Future<void> setAchievementsUnlocked(Map<String, dynamic> value) =>
      _prefs.setString(StorageKeys.achievementsUnlocked, jsonEncode(value));

  int get awardsSeenAtCount =>
      _prefs.getInt(StorageKeys.awardsSeenAtCount) ?? 0;

  Future<void> setAwardsSeenAtCount(int value) =>
      _prefs.setInt(StorageKeys.awardsSeenAtCount, value);

  // --- Onboarding + settings -------------------------------------------------

  bool get howtoSeen => _prefs.getBool(StorageKeys.howtoSeen) ?? false;

  Future<void> markHowtoSeen() =>
      _prefs.setBool(StorageKeys.howtoSeen, true);

  Map<String, dynamic> get settings => _readJsonMap(StorageKeys.settings);

  Future<void> setSettings(Map<String, dynamic> value) =>
      _prefs.setString(StorageKeys.settings, jsonEncode(value));

  Map<String, dynamic> _readJsonMap(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return {};
    final decoded = jsonDecode(raw);
    return decoded is Map<String, dynamic> ? decoded : {};
  }
}

