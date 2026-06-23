import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'chunky_button.dart';

class FeedbackSheet extends StatelessWidget {
  const FeedbackSheet({
    super.key,
    required this.correct,
    required this.headline,
    required this.subtext,
    required this.onNext,
    required this.visible,
  });

  final bool correct;
  final String headline;
  final String subtext;
  final VoidCallback onNext;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final accentColor = correct ? ec.good : ec.bad;
    return AnimatedSlide(
      offset: visible ? Offset.zero : const Offset(0, 1),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          decoration: BoxDecoration(
            color: ec.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: accentColor, width: 4),
              left: BorderSide(color: ec.line),
              right: BorderSide(color: ec.line),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(correct ? '✅' : '❌', style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          headline,
                          style: AppTypography.title.copyWith(color: ec.ink),
                        ),
                        Text(
                          subtext,
                          style: AppTypography.body.copyWith(color: ec.inkSoft),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ChunkyButton(
                  label: 'Next',
                  onTap: onNext,
                  variant: ChunkyButtonVariant.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
