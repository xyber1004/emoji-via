import 'package:flutter/material.dart';
import 'package:emojivia/core/theme/app_colors.dart';
import 'package:emojivia/core/theme/app_typography.dart';

/// Six vertical bars for score distribution 0/5 … 5/5 (§4.17). The tallest bar
/// is filled `good`, others `yellow`; bars have a 2px ink border and no bottom
/// border so they "stand on" the card floor.
class ScoreHistogram extends StatelessWidget {
  const ScoreHistogram({super.key, required this.counts});

  /// Six counts, index = score (0..5).
  final List<int> counts;

  static const _maxBarHeight = 90.0;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final maxCount = counts.fold<int>(0, (m, c) => c > m ? c : m);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var score = 0; score < 6; score++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _Bar(
                value: counts[score],
                fraction: maxCount == 0 ? 0 : counts[score] / maxCount,
                isTallest: counts[score] == maxCount && maxCount > 0,
                label: '$score/5',
                maxHeight: _maxBarHeight,
                fill: (counts[score] == maxCount && maxCount > 0)
                    ? ec.good
                    : ec.yellow,
                ink: ec.ink,
              ),
            ),
          ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.value,
    required this.fraction,
    required this.isTallest,
    required this.label,
    required this.maxHeight,
    required this.fill,
    required this.ink,
  });

  final int value;
  final double fraction;
  final bool isTallest;
  final String label;
  final double maxHeight;
  final Color fill;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    final barHeight = 4 + fraction * maxHeight;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$value',
          style: AppTypography.pixelNumeralS.copyWith(fontSize: 8, color: ink),
        ),
        const SizedBox(height: 4),
        Container(
          height: barHeight,
          decoration: BoxDecoration(
            color: fill,
            border: Border(
              top: BorderSide(color: ink, width: 2),
              left: BorderSide(color: ink, width: 2),
              right: BorderSide(color: ink, width: 2),
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.pixelNumeralS.copyWith(fontSize: 8, color: ink),
        ),
      ],
    );
  }
}
