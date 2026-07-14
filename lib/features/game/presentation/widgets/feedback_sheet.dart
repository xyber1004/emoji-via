import 'package:flutter/material.dart';
import 'package:emojivia/core/theme/app_colors.dart';
import 'package:emojivia/core/theme/app_typography.dart';
import 'package:emojivia/core/widgets/chunky_button.dart';

class FeedbackSheet extends StatelessWidget {
  const FeedbackSheet({
    super.key,
    required this.visible,
    required this.isCorrect,
    required this.copy,
    required this.correctAnswer,
    required this.isLast,
    required this.onNext,
  });

  final bool visible;
  final bool isCorrect;
  final String copy;
  final String correctAnswer;
  final bool isLast;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final bg = isCorrect ? ec.good : ec.bad;

    return AnimatedSlide(
      offset: visible ? Offset.zero : const Offset(0, 1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: ec.ink, width: 3)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isCorrect ? '✓  $copy' : '✕  $copy',
                style: AppTypography.title.copyWith(color: ec.paper),
              ),
              if (!isCorrect) ...[
                const SizedBox(height: 6),
                Text(
                  'Correct: $correctAnswer',
                  style: AppTypography.body.copyWith(color: ec.paper.withAlpha(200)),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ChunkyButton(
                  label: isLast ? 'See results' : 'Next',
                  variant: ChunkyButtonVariant.ghost,
                  onTap: onNext,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
