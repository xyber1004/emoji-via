import 'package:flutter/material.dart';
import 'package:emojivia/core/theme/app_colors.dart';
import 'package:emojivia/core/theme/app_typography.dart';

/// KPI tile for the Stats screen (§4.16). Caps label + big pixel value.
class BigStatTile extends StatelessWidget {
  const BigStatTile({
    super.key,
    required this.label,
    required this.value,
    this.flame = false,
  });

  final String label;
  final String value;

  /// When true the value renders in the flame accent color.
  final bool flame;

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
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.caption.copyWith(
              fontSize: 10,
              letterSpacing: 10 * 0.08,
              color: ec.ink.withAlpha(180),
            ),
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppTypography.pixelNumeral.copyWith(
                fontSize: 26,
                color: flame ? ec.flame : ec.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
