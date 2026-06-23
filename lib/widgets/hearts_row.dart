import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class HeartsRow extends StatelessWidget {
  const HeartsRow({super.key, required this.remaining, this.total = 3});

  final int remaining;
  final int total;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    return Semantics(
      label: '$remaining of $total hearts remaining',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(total, (i) {
          final alive = i < remaining;
          return AnimatedScale(
            scale: alive ? 1.0 : 0.85,
            duration: const Duration(milliseconds: 300),
            child: AnimatedOpacity(
              opacity: alive ? 1.0 : 0.28,
              duration: const Duration(milliseconds: 300),
              child: ColorFiltered(
                colorFilter: alive
                    ? const ColorFilter.mode(
                        Colors.transparent, BlendMode.saturation)
                    : const ColorFilter.matrix([
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0,      0,      0,      1, 0,
                      ]),
                child: Text(
                  '❤️',
                  style: AppTypography.buttonS.copyWith(
                    color: alive ? ec.bad : ec.inkSoft,
                    fontSize: 22,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
