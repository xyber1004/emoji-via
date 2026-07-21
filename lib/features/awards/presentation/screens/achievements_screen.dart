import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:emojivia/core/theme/app_colors.dart';
import 'package:emojivia/core/theme/app_typography.dart';
import 'package:emojivia/features/awards/application/controllers/awards_controller.dart';
import 'package:emojivia/features/awards/domain/entities/achievement.dart';
import 'package:emojivia/features/awards/presentation/widgets/achievement_row.dart';
import 'package:emojivia/features/streak/application/controllers/stats_controller.dart';
import 'package:emojivia/features/streak/application/controllers/streak_controller.dart';

/// Awards tab (§4.19). Lists every achievement in [achievementCatalog] with its
/// live progress, unlocked rows highlighted. Marks unlocks as seen on open so
/// the tab badge clears.
class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AwardsController>().markSeen();
    });
  }

  int _currentValue(AchievementMetric metric, StatsController stats, int streak) {
    switch (metric) {
      case AchievementMetric.currentStreak:
        return streak;
      case AchievementMetric.longestStreak:
        return stats.longestStreak;
      case AchievementMetric.puzzlesPlayed:
        return stats.puzzlesPlayed;
      case AchievementMetric.perfectDays:
        return stats.perfectDays;
      case AchievementMetric.sharesSent:
        return stats.sharesSent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final awards = context.watch<AwardsController>();
    final stats = context.watch<StatsController>();
    final streak = context.watch<StreakController>().count;

    return Scaffold(
      backgroundColor: ec.yellow,
      appBar: AppBar(
        title: Text('Awards', style: AppTypography.title.copyWith(color: ec.ink)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        itemCount: achievementCatalog.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (_, i) {
          final a = achievementCatalog[i];
          return AchievementRow(
            achievement: a,
            current: _currentValue(a.metric, stats, streak),
            unlocked: awards.isUnlocked(a.id),
          );
        },
      ),
    );
  }
}
