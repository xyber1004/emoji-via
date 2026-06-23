import 'package:flutter/material.dart';
import 'package:emojivia/core/theme/app_colors.dart';
import 'package:emojivia/core/theme/app_typography.dart';
import 'package:emojivia/features/game/presentation/widgets/hearts_row.dart';
import 'package:emojivia/features/game/presentation/widgets/progress_dots.dart';

class GameTopBar extends StatelessWidget {
  const GameTopBar({
    super.key,
    required this.hearts,
    required this.hints,
    required this.total,
    required this.current,
    required this.results,
    required this.onHint,
    required this.onClose,
  });

  final int hearts;
  final int hints;
  final int total;
  final int current;
  final List<bool?> results;
  final VoidCallback onHint;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close),
              color: ec.inkSoft,
            ),
            Expanded(
              child: ProgressDots(
                  total: total, current: current, results: results),
            ),
            _HintButton(hints: hints, onTap: hints > 0 ? onHint : null, ec: ec),
            HeartsRow(hearts: hearts, total: 3),
            const SizedBox(width: 8),
          ],
        ),
      ],
    );
  }
}

class _HintButton extends StatelessWidget {
  const _HintButton({required this.hints, required this.onTap, required this.ec});
  final int hints;
  final VoidCallback? onTap;
  final EmojiviaColors ec;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('💡', style: TextStyle(fontSize: 16, color: hints > 0 ? null : ec.inkSoft)),
            const SizedBox(width: 4),
            Text('$hints',
                style: AppTypography.caption.copyWith(
                    color: hints > 0 ? ec.ink : ec.inkSoft)),
          ],
        ),
      ),
    );
  }
}
