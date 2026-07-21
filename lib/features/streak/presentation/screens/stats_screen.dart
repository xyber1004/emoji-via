import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:emojivia/core/theme/app_colors.dart';
import 'package:emojivia/core/theme/app_typography.dart';
import 'package:emojivia/core/widgets/mascot.dart';
import 'package:emojivia/features/streak/application/controllers/stats_controller.dart';
import 'package:emojivia/features/streak/application/controllers/streak_controller.dart';
import 'package:emojivia/features/streak/presentation/widgets/big_stat_tile.dart';
import 'package:emojivia/features/streak/presentation/widgets/score_histogram.dart';
import 'package:emojivia/features/streak/presentation/widgets/streak_row.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final stats = context.watch<StatsController>();
    final streak = context.watch<StreakController>();

    return Scaffold(
      backgroundColor: ec.yellow,
      appBar: AppBar(
        title: Text('Stats', style: AppTypography.title.copyWith(color: ec.ink)),
      ),
      body: SafeArea(
        top: false,
        child: stats.hasData
            ? _StatsBody(stats: stats, streakCount: streak.count)
            : const _EmptyStats(),
      ),
    );
  }
}

class _StatsBody extends StatelessWidget {
  const _StatsBody({required this.stats, required this.streakCount});

  final StatsController stats;
  final int streakCount;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            BigStatTile(
              label: 'Current streak',
              value: streakCount.toString().padLeft(2, '0'),
              flame: true,
            ),
            BigStatTile(
              label: 'Best streak',
              value: stats.longestStreak.toString().padLeft(2, '0'),
              flame: true,
            ),
            BigStatTile(
              label: 'Puzzles played',
              value: '${stats.puzzlesPlayed}',
            ),
            BigStatTile(label: 'Accuracy', value: '${stats.accuracyPct}%'),
            BigStatTile(label: 'Perfect days', value: '${stats.perfectDays}'),
            BigStatTile(label: 'Shares sent', value: '${stats.sharesSent}'),
          ],
        ),
        const SizedBox(height: 28),
        _SectionCard(
          title: 'Score distribution',
          child: ScoreHistogram(counts: stats.scoreHistogram),
        ),
        const SizedBox(height: 20),
        _SectionCard(
          title: 'Last 9 days',
          child: StreakRow(days: stats.recentDays),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Oldest → today',
            style: AppTypography.body.copyWith(
              fontSize: 12,
              color: ec.inkSoft,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ec.paper,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ec.ink, width: 3),
        boxShadow: [
          BoxShadow(color: ec.ink, offset: const Offset(6, 6), blurRadius: 0),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: AppTypography.caption.copyWith(
              fontSize: 11,
              letterSpacing: 11 * 0.1,
              color: ec.ink.withAlpha(180),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _EmptyStats extends StatelessWidget {
  const _EmptyStats();

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Mascot(mood: MascotMood.idle, size: 90),
            const SizedBox(height: 24),
            Text(
              'No stats yet',
              style: AppTypography.displayS.copyWith(color: ec.ink),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Play today's 5 to start filling this in.",
              style: AppTypography.body.copyWith(color: ec.inkSoft),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
