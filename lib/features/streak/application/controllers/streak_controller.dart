import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emojivia/features/streak/application/providers/streak_repository_provider.dart';
import 'package:emojivia/features/streak/domain/entities/streak.dart';
import 'package:emojivia/features/streak/domain/usecases/compute_streak.dart';
import 'package:emojivia/features/streak/domain/repositories/streak_repository.dart';
import '../state/streak_state.dart';

class StreakController extends Notifier<StreakState> {
  static const _compute = ComputeStreak();

  @override
  StreakState build() {
    final s = _repo.load();
    return StreakState(
      count: s.count,
      lastPlayedDate: s.lastPlayedDate,
      introSeen: s.introSeen,
      hintBalance: s.hintBalance,
    );
  }

  StreakRepository get _repo => ref.read(streakRepositoryProvider);

  // Public cross-feature boundary — called by game feature
  Future<void> recordCompletion(String date) async {
    final entity = Streak(
      count: state.count,
      lastPlayedDate: state.lastPlayedDate,
      introSeen: state.introSeen,
      hintBalance: state.hintBalance,
    );
    final newCount = _compute(entity, date);
    final updated = Streak(
      count: newCount,
      lastPlayedDate: date,
      introSeen: state.introSeen,
      hintBalance: state.hintBalance,
    );
    state = state.copyWith(count: newCount, lastPlayedDate: date);
    await _repo.save(updated);
  }

  Future<void> markIntroSeen() async {
    state = state.copyWith(introSeen: true);
  }
}
