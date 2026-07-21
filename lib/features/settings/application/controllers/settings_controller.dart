import 'package:flutter/foundation.dart';
import 'package:emojivia/core/storage/storage_service.dart';

/// Holds the user's preference toggles (CLAUDE.md §5.2 `settings`). Values
/// default to on and persist to storage on every change.
///
/// Note: these flags are persisted and read back, but wiring each one to
/// runtime behavior (e.g. actually disabling the yellow texture) is handled
/// where that behavior lives — this controller is the source of truth.
class SettingsController extends ChangeNotifier {
  SettingsController(this._storage) {
    final s = _storage.settings;
    sound = _asBool(s['sound']);
    haptics = _asBool(s['haptics']);
    dailyReminder = _asBool(s['dailyReminder']);
    reducedMotion = _asBool(s['reducedMotion'], fallback: false);
    yellowTexture = _asBool(s['yellowTexture']);
  }

  final StorageService _storage;

  bool sound = true;
  bool haptics = true;
  bool dailyReminder = true;
  bool reducedMotion = false;
  bool yellowTexture = true;

  Future<void> setSound(bool v) => _update(() => sound = v);
  Future<void> setHaptics(bool v) => _update(() => haptics = v);
  Future<void> setDailyReminder(bool v) => _update(() => dailyReminder = v);
  Future<void> setReducedMotion(bool v) => _update(() => reducedMotion = v);
  Future<void> setYellowTexture(bool v) => _update(() => yellowTexture = v);

  Future<void> _update(VoidCallback mutate) async {
    mutate();
    notifyListeners();
    await _storage.setSettings({
      'sound': sound,
      'haptics': haptics,
      'dailyReminder': dailyReminder,
      'reducedMotion': reducedMotion,
      'yellowTexture': yellowTexture,
    });
  }

  static bool _asBool(dynamic v, {bool fallback = true}) =>
      v is bool ? v : fallback;
}
