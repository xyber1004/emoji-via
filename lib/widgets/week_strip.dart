import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class WeekStrip extends StatelessWidget {
  const WeekStrip({super.key, required this.streak, required this.playedToday});

  final int streak;
  final bool playedToday;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final today = DateTime.now().weekday; // 1=Mon, 7=Sun
    // Compute which of the last 7 days were played based on streak
    // streak=0: none; streak=N: last N days (including today if playedToday)
    final daysPlayed = playedToday ? streak : (streak > 0 ? streak - 1 : 0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(7, (i) {
        final dayIndex = i + 1; // 1=Mon
        final isToday = dayIndex == today;
        // Days before or equal today in the current week
        final daysFromToday = today - dayIndex;
        final played =
            daysFromToday >= 0 && daysFromToday < daysPlayed;
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
                  border: isToday
                      ? Border.all(color: ec.primary, width: 2)
                      : null,
                  color: played ? ec.flame.withAlpha(20) : Colors.transparent,
                ),
                alignment: Alignment.center,
                child: Text(
                  played ? '🔥' : '',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTypography.meta.copyWith(
                  color: isToday ? ec.primary : ec.inkSoft,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
