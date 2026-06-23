import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/game_provider.dart';
import '../providers/streak_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/chunky_button.dart';
import '../widgets/confetti_overlay.dart';
import '../widgets/mascot.dart';
import '../widgets/share_card.dart';
import '../l10n/app_strings.dart';

class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ec = context.ec;
    final game = ref.watch(gameProvider);
    final streak = ref.watch(streakProvider);

    if (game == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/home'));
      return const Scaffold(body: SizedBox.shrink());
    }

    final score = game.score;
    final total = game.puzzleSet.puzzles.length;
    final isPerfect = score == total;

    return ConfettiOverlay(
      trigger: isPerfect,
      child: Scaffold(
        backgroundColor: ec.bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 24),
                Mascot(
                  mood: score >= 4
                      ? MascotMood.celebrate
                      : score >= 2
                          ? MascotMood.idle
                          : MascotMood.sad,
                  size: 80,
                ),
                const SizedBox(height: 20),
                Text(
                  '$score/$total today',
                  style: AppTypography.displayS.copyWith(color: ec.ink),
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.resultsHeadline(score, total),
                  style: AppTypography.body.copyWith(color: ec.inkSoft),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '🔥 ${streak.count} day streak',
                  style: AppTypography.buttonS.copyWith(color: ec.flame),
                ),
                const SizedBox(height: 32),
                ShareCard(
                  puzzleId: game.puzzleSet.id,
                  score: score,
                  total: total,
                  results: game.results,
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ChunkyButton(
                    label: 'Share result',
                    icon: const Text('📤', style: TextStyle(fontSize: 18)),
                    onTap: () => shareResult(
                      puzzleId: game.puzzleSet.id,
                      score: score,
                      total: total,
                      streak: streak.count,
                      results: game.results,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ChunkyButton(
                    label: 'Back to home',
                    variant: ChunkyButtonVariant.ghost,
                    onTap: () {
                      ref.read(gameProvider.notifier).reset();
                      context.go('/home');
                    },
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
