import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_theme.dart';

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

class HintChip extends StatelessWidget {
  const HintChip({super.key, required this.remaining, required this.onTap});

  final int remaining;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final enabled = remaining > 0 && onTap != null;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: enabled ? ec.surface : ec.line.withAlpha(80),
          borderRadius: AppShape.chip,
          border: Border.all(color: ec.line, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '💡',
              style: TextStyle(
                fontSize: 15,
                color: enabled ? null : Colors.grey,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '$remaining',
              style: AppTypography.caption.copyWith(
                color: enabled ? ec.ink : ec.inkSoft,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
