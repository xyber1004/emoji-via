import 'package:flutter/material.dart';
import 'package:emojivia/core/theme/app_colors.dart';
import 'package:emojivia/core/widgets/streak_chip.dart';
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close),
            color: ec.inkSoft,
          ),
          Expanded(
            child: ProgressDots(
              total: total,
              current: current,
              results: results,
            ),
          ),
          HintChip(count: hints, onTap: hints > 0 ? onHint : null),
          const SizedBox(width: 8),
          HeartsRow(hearts: hearts, total: 3),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
