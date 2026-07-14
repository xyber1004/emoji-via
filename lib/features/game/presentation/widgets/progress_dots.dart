import 'package:flutter/material.dart';
import 'package:emojivia/core/theme/app_colors.dart';

class ProgressDots extends StatelessWidget {
  const ProgressDots({
    super.key,
    required this.total,
    required this.current,
    required this.results,
  });

  final int total;
  final int current;
  final List<bool?> results;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isActive = i == current;
        final result = i < results.length ? results[i] : null;

        Color fill;
        Color? borderColor;

        if (result == true) {
          fill = ec.good;
        } else if (result == false) {
          fill = ec.bad;
        } else if (isActive) {
          fill = ec.ink;
        } else {
          fill = ec.paper;
          borderColor = ec.ink;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            width: isActive ? 30 : 12,
            height: 12,
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.zero,
              border: borderColor != null
                  ? Border.all(color: borderColor, width: 1.5)
                  : null,
            ),
          ),
        );
      }),
    );
  }
}
