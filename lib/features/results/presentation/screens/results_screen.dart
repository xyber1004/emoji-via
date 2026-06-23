import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emojivia/app/router.dart';
import 'package:emojivia/core/theme/app_colors.dart';
import 'package:emojivia/core/theme/app_typography.dart';
import 'package:emojivia/core/widgets/chunky_button.dart';
import 'package:emojivia/core/widgets/confetti_overlay.dart';
import 'package:emojivia/core/widgets/mascot.dart';
import 'package:emojivia/core/widgets/share_card.dart';
import 'package:emojivia/features/game/application/providers/game_providers.dart';
import 'package:emojivia/features/game/application/services/feedback_copy_service.dart';
import 'package:emojivia/features/streak/streak.dart';

class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameControllerProvider);
    final streak = ref.watch(streakControllerProvider);
    final ec = context.ec;

    if (game == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final score = game.score;
    final total = game.puzzleSet.puzzles.length;
    final isPerfect = score == total;
    final headline = FeedbackCopyService.resultsHeadline(score, total);

    return Scaffold(
      backgroundColor: ec.bg,
      body: SafeArea(
        child: ConfettiOverlay(
          trigger: isPerfect,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Mascot(
                  mood: isPerfect ? MascotMood.celebrate : MascotMood.idle,
                  size: 90,
                ),
                const SizedBox(height: 24),
                Text(
                  '$score/$total today',
                  style: AppTypography.score.copyWith(color: ec.ink),
                ),
                const SizedBox(height: 8),
                Text(
                  headline,
                  style: AppTypography.displayS.copyWith(color: ec.ink),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                if (streak.count > 0)
                  Text(
                    '🔥 ${streak.count} day streak',
                    style: AppTypography.body.copyWith(color: ec.flame),
                  ),
                const SizedBox(height: 28),
                ShareCard(
                  puzzleId: game.puzzleSet.id,
                  score: score,
                  total: total,
                  results: game.results,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ChunkyButton(
                    label: 'Share result',
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
                ChunkyButton(
                  label: 'Done',
                  variant: ChunkyButtonVariant.ghost,
                  onTap: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.home,
                    (_) => false,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
