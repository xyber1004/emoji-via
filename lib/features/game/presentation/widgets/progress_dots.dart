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

        Color color;
        if (result == true) {
          color = ec.good;
        } else if (result == false) {
          color = ec.bad;
        } else if (isActive) {
          color = ec.primary;
        } else {
          color = ec.line;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            width: isActive ? 24 : 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        );
      }),
    );
  }
}
