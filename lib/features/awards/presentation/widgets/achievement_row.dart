import 'package:flutter/material.dart';
import 'package:emojivia/core/theme/app_colors.dart';
import 'package:emojivia/core/theme/app_typography.dart';
import 'package:emojivia/features/awards/domain/entities/achievement.dart';

/// One achievement row (§4.19). Icon tile + title/description + progress pill.
class AchievementRow extends StatelessWidget {
  const AchievementRow({
    super.key,
    required this.achievement,
    required this.current,
    required this.unlocked,
  });

  final Achievement achievement;
  final int current;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final capped = current > achievement.target ? achievement.target : current;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: unlocked ? ec.yellow : ec.paper,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ec.ink, width: 2.5),
        boxShadow: [
          BoxShadow(color: ec.ink, offset: const Offset(4, 4), blurRadius: 0),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: unlocked ? ec.cream : ec.paper,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ec.ink, width: 2),
              boxShadow: [
                BoxShadow(
                  color: ec.ink,
                  offset: const Offset(2, 2),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Opacity(
              opacity: unlocked ? 1 : 0.5,
              child: ColorFiltered(
                colorFilter: unlocked
                    ? const ColorFilter.mode(
                        Colors.transparent, BlendMode.saturation)
                    : const ColorFilter.matrix(<double>[
                        0.2126, 0.7152, 0.0722, 0, 0, //
                        0.2126, 0.7152, 0.0722, 0, 0, //
                        0.2126, 0.7152, 0.0722, 0, 0, //
                        0, 0, 0, 1, 0, //
                      ]),
                child: Text(
                  achievement.icon,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  achievement.title,
                  style: AppTypography.answer.copyWith(fontSize: 15, color: ec.ink),
                ),
                const SizedBox(height: 2),
                Text(
                  achievement.description,
                  style: AppTypography.body.copyWith(
                    fontSize: 12,
                    color: ec.ink.withAlpha(190),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _ProgressPill(
            current: capped,
            target: achievement.target,
            unlocked: unlocked,
          ),
        ],
      ),
    );
  }
}

class _ProgressPill extends StatelessWidget {
  const _ProgressPill({
    required this.current,
    required this.target,
    required this.unlocked,
  });

  final int current;
  final int target;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: unlocked ? ec.good : ec.paper,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: ec.ink, width: 2),
      ),
      child: Text(
        '$current/$target',
        style: AppTypography.pixelNumeralS.copyWith(
          fontSize: 9,
          color: unlocked ? ec.paper : ec.ink,
        ),
      ),
    );
  }
}
