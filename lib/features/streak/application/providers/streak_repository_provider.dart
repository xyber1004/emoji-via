import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emojivia/core/storage/storage_provider.dart';
import 'package:emojivia/features/streak/data/repositories/streak_repository_impl.dart';
import 'package:emojivia/features/streak/data/sources/streak_prefs_source.dart';
import 'package:emojivia/features/streak/domain/repositories/streak_repository.dart';

final streakRepositoryProvider = Provider<StreakRepository>((ref) {
  final source = StreakPrefsSource(ref.read(storageServiceProvider));
  return StreakRepositoryImpl(source);
});
