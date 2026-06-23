import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/storage_service.dart';

final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override sharedPrefsProvider in main()');
});

final storageProvider = Provider<StorageService>((ref) {
  return StorageService(ref.watch(sharedPrefsProvider));
});
