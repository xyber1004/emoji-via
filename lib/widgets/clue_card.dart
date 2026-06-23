import 'package:flutter/material.dart';
import '../models/puzzle.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_theme.dart';

class ClueCard extends StatelessWidget {
  const ClueCard({
    super.key,
    required this.puzzle,
    required this.hintShown,
  });

  final Puzzle puzzle;
  final bool hintShown;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: ec.surface,
        borderRadius: AppShape.heroCard,
        border: Border.all(color: ec.line, width: 2),
        boxShadow: [
          BoxShadow(
            color: ec.line,
            offset: const Offset(0, 6),
            blurRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Category tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: ec.primary.withAlpha(30),
              borderRadius: AppShape.chip,
            ),
            child: Text(
              puzzle.category.toUpperCase(),
              style: AppTypography.caption.copyWith(color: ec.primaryDark),
            ),
          ),
          const SizedBox(height: 20),
          // Emoji clue
          Semantics(
            label: 'Emoji puzzle: ${puzzle.emoji}',
            child: Text(
              puzzle.emoji,
              style: const TextStyle(
                fontSize: 64,
                letterSpacing: 6,
              ),
            ),
          ),
          // Hint
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: hintShown
                ? Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      puzzle.hint,
                      style: AppTypography.body.copyWith(color: ec.inkSoft),
                      textAlign: TextAlign.center,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
