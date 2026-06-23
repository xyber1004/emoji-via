import 'package:flutter/material.dart';
import 'package:emojivia/core/theme/app_colors.dart';
import 'package:emojivia/core/theme/app_typography.dart';
import 'package:emojivia/core/theme/app_theme.dart';

class StreakChip extends StatelessWidget {
  const StreakChip({super.key, required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: ec.flame.withAlpha(20),
        borderRadius: AppShape.chip,
        border: Border.all(color: ec.flame.withAlpha(60), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 15)),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: AppTypography.caption.copyWith(
              color: ec.flame,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class WeekStrip extends StatelessWidget {
  const WeekStrip({super.key, required this.streak, required this.playedToday});

  final int streak;
  final bool playedToday;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final today = DateTime.now().weekday;
    final daysPlayed = playedToday ? streak : (streak > 0 ? streak - 1 : 0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(7, (i) {
        final dayIndex = i + 1;
        final isToday = dayIndex == today;
        final daysFromToday = today - dayIndex;
        final played = daysFromToday >= 0 && daysFromToday < daysPlayed;
        final label = ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: isToday ? Border.all(color: ec.primary, width: 2) : null,
                  color: played ? ec.flame.withAlpha(20) : Colors.transparent,
                ),
                alignment: Alignment.center,
                child: Text(played ? '🔥' : '', style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 4),
              Text(label,
                  style: AppTypography.meta
                      .copyWith(color: isToday ? ec.primary : ec.inkSoft)),
            ],
          ),
        );
      }),
    );
  }
}
