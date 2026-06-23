import 'package:flutter/material.dart';
import 'package:emojivia/core/theme/app_colors.dart';
import 'package:emojivia/core/theme/app_typography.dart';
import 'package:emojivia/core/theme/app_theme.dart';

class ClueCard extends StatelessWidget {
  const ClueCard({
    super.key,
    required this.emoji,
    required this.category,
    this.hint,
    this.hintVisible = false,
  });

  final String emoji;
  final String category;
  final String? hint;
  final bool hintVisible;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: ec.surface,
        borderRadius: AppShape.heroCard,
        border: Border.all(color: ec.line, width: 2),
        boxShadow: [
          BoxShadow(color: ec.line, offset: const Offset(0, 6), blurRadius: 0),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: ec.primary.withAlpha(30),
              borderRadius: AppShape.chip,
              border: Border.all(color: ec.primary.withAlpha(60), width: 1.5),
            ),
            child: Text(
              category.toUpperCase(),
              style: AppTypography.caption.copyWith(color: ec.primaryDark),
            ),
          ),
          const SizedBox(height: 20),
          Semantics(
            label: 'Emoji puzzle: $emoji',
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 64, letterSpacing: 6),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            child: hintVisible && hint != null
                ? Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      hint!,
                      textAlign: TextAlign.center,
                      style: AppTypography.body.copyWith(color: ec.inkSoft),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
