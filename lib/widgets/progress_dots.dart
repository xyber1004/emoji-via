import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

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
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final isActive = i == current;
        final isPast = i < current;
        final result = isPast ? results[i] : null;

        Color color;
        if (isActive) {
          color = ec.primary;
        } else if (result == true) {
          color = ec.good;
        } else if (result == false) {
          color = ec.bad;
        } else {
          color = ec.line;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
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
