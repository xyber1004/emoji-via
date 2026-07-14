import 'package:flutter/material.dart';
import 'package:emojivia/core/theme/app_colors.dart';
import 'package:emojivia/core/theme/app_typography.dart';
import 'package:emojivia/core/theme/app_theme.dart';
import 'package:emojivia/core/widgets/pixel_sprites.dart';

class StreakChip extends StatelessWidget {
  const StreakChip({super.key, required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: ec.yellow,
        borderRadius: AppShape.chip,
        border: Border.all(color: ec.ink, width: 2.5),
        boxShadow: [
          BoxShadow(color: ec.ink, offset: const Offset(3, 3), blurRadius: 0),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PixelFlame(color: ec.flame, pixelSize: 2.5),
          const SizedBox(width: 6),
          Text(
            count.toString().padLeft(2, '0'),
            style: AppTypography.pixelNumeralS.copyWith(color: ec.ink),
          ),
        ],
      ),
    );
  }
}

class HintChip extends StatelessWidget {
  const HintChip({
    super.key,
    required this.count,
    required this.onTap,
  });
  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final active = count > 0;
    return GestureDetector(
      onTap: active ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? ec.paper : ec.paper.withAlpha(120),
          borderRadius: AppShape.chip,
          border: Border.all(
            color: active ? ec.ink : ec.inkSoft,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '💡',
              style: TextStyle(
                fontSize: 13,
                color: active ? null : ec.inkSoft,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: AppTypography.pixelNumeralS.copyWith(
                color: active ? ec.ink : ec.inkSoft,
              ),
            ),
          ],
        ),
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
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: played ? ec.flame : Colors.transparent,
                  border: isToday
                      ? Border.all(color: ec.yellowDeep, width: 3)
                      : Border.all(color: ec.ink.withAlpha(50), width: 1),
                ),
                alignment: Alignment.center,
                child: played
                    ? PixelFlame(color: ec.paper, pixelSize: 1.6)
                    : null,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: isToday ? ec.ink : ec.inkSoft,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
