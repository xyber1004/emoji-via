import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import 'shared_prefs_provider.dart';

class StreakState {
  const StreakState({
    required this.count,
    required this.lastPlayedDate,
    required this.introSeen,
    required this.hintBalance,
  });

  final int count;
  final String? lastPlayedDate;
  final bool introSeen;
  final int hintBalance;

  bool get playedToday {
    if (lastPlayedDate == null) return false;
    final d = DateTime.now();
    final today =
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    return lastPlayedDate == today;
  }

  StreakState copyWith({
    int? count,
    String? lastPlayedDate,
    bool? introSeen,
    int? hintBalance,
  }) =>
      StreakState(
        count: count ?? this.count,
        lastPlayedDate: lastPlayedDate ?? this.lastPlayedDate,
        introSeen: introSeen ?? this.introSeen,
        hintBalance: hintBalance ?? this.hintBalance,
      );
}

class StreakNotifier extends Notifier<StreakState> {
  @override
  StreakState build() {
    final storage = ref.read(storageProvider);
    return StreakState(
      count: storage.streakCount,
      lastPlayedDate: storage.lastPlayedDate,
      introSeen: storage.introSeen,
      hintBalance: storage.hintBalance,
    );
  }

  Future<void> markIntroSeen() async {
    await ref.read(storageProvider).markIntroSeen();
    state = state.copyWith(introSeen: true);
  }

  Future<void> recordPlay(TodayRun run) async {
    final storage = ref.read(storageProvider);
    await storage.recordPlay(run);
    state = state.copyWith(
      count: storage.streakCount,
      lastPlayedDate: storage.lastPlayedDate,
    );
  }

  Future<void> consumeHint() async {
    await ref.read(storageProvider).consumeHint();
    state = state.copyWith(hintBalance: (state.hintBalance - 1).clamp(0, 2));
  }
}

final streakProvider = NotifierProvider<StreakNotifier, StreakState>(
  StreakNotifier.new,
);
