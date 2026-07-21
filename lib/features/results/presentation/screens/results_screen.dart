import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:emojivia/app/router.dart';
import 'package:emojivia/core/theme/app_colors.dart';
import 'package:emojivia/core/theme/app_typography.dart';
import 'package:emojivia/core/widgets/chunky_button.dart';
import 'package:emojivia/core/widgets/confetti_overlay.dart';
import 'package:emojivia/core/widgets/mascot.dart';
import 'package:emojivia/core/widgets/share_card.dart';
import 'package:emojivia/features/auth/auth.dart';
import 'package:emojivia/features/awards/awards.dart';
import 'package:emojivia/features/game/game.dart';
import 'package:emojivia/features/streak/streak.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool _promptShown = false;
  bool _linkCelebrated = false;
  bool _linkCelebrate = false;

  bool _awardsCelebrated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maybeCelebrateAwards();
    _maybePromptSave();
    _maybeCelebrateLink();
  }

  /// Show a toast for any achievement unlocked by the run just completed (§14).
  void _maybeCelebrateAwards() {
    if (_awardsCelebrated) return;
    final awards = context.read<AwardsController>();
    if (awards.justUnlocked.isEmpty) return;
    _awardsCelebrated = true;
    final earned = awards.justUnlocked;
    awards.clearJustUnlocked();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      for (final a in earned) {
        messenger.showSnackBar(
          SnackBar(content: Text('🏆 ${a.title} unlocked!')),
        );
      }
    });
  }

  /// Offer the save-streak sheet once per visit when a 7-day streak qualifies.
  void _maybePromptSave() {
    if (_promptShown) return;
    final streak = context.read<StreakController>();
    if (!streak.shouldPromptSave) return;
    _promptShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const SaveStreakScreen(),
      );
      context.read<StreakController>().markSavePromptShown();
    });
  }

  /// React once when the email link succeeds: refresh state, confetti + toast.
  void _maybeCelebrateLink() {
    if (_linkCelebrated) return;
    final auth = context.read<AuthController>();
    if (auth.status != AuthStatus.linked) return;
    _linkCelebrated = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<StreakController>().refreshEmailLinked();
      setState(() => _linkCelebrate = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Streak saved! 🔥')),
      );
    });
  }

  /// Share the result, then count the share and unlock the "Show Off"
  /// achievement once the threshold is reached.
  Future<void> _handleShare({
    required int puzzleId,
    required int score,
    required int total,
    required int streakCount,
    required List<bool?> results,
  }) async {
    await shareResult(
      puzzleId: puzzleId,
      score: score,
      total: total,
      streak: streakCount,
      results: results,
    );
    if (!mounted) return;
    final stats = context.read<StatsController>();
    final awards = context.read<AwardsController>();
    await stats.recordShare();
    final earned = await awards.evaluate(
      currentStreak: streakCount,
      longestStreak: stats.longestStreak,
      puzzlesPlayed: stats.puzzlesPlayed,
      perfectDays: stats.perfectDays,
      sharesSent: stats.sharesSent,
    );
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    for (final a in earned) {
      messenger.showSnackBar(SnackBar(content: Text('🏆 ${a.title} unlocked!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameController>();
    final streak = context.watch<StreakController>();
    context.watch<AuthController>(); // rebuild on link status change
    final ec = context.ec;

    if (!game.isStarted) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final puzzleSet = game.puzzleSet!;
    final score = game.score;
    final total = puzzleSet.puzzles.length;
    final isPerfect = score == total;
    final headline = FeedbackCopyService.resultsHeadline(score, total);

    return Scaffold(
      backgroundColor: ec.yellow,
      body: SafeArea(
        child: ConfettiOverlay(
          trigger: isPerfect || _linkCelebrate,
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
                  '$score/$total',
                  style: AppTypography.displayL.copyWith(color: ec.ink),
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
                  puzzleId: puzzleSet.id,
                  score: score,
                  total: total,
                  results: game.results,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ChunkyButton(
                    label: 'Share result',
                    onTap: () => _handleShare(
                      puzzleId: puzzleSet.id,
                      score: score,
                      total: total,
                      streakCount: streak.count,
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
