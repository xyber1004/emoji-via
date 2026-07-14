import 'package:flutter/material.dart';
import 'package:emojivia/core/theme/app_colors.dart';
import 'package:emojivia/core/theme/app_theme.dart';
import 'package:emojivia/core/widgets/pixel_sprites.dart';

class HeartsRow extends StatelessWidget {
  const HeartsRow({super.key, required this.hearts, required this.total});

  final int hearts;
  final int total;

  static const _deadColor = Color(0xFFD5D1C2);

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    return Semantics(
      label: '$hearts of $total hearts remaining',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: ec.paper,
          borderRadius: AppShape.chip,
          border: Border.all(color: ec.ink, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(total, (i) {
            final alive = i < hearts;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: AnimatedOpacity(
                opacity: alive ? 1.0 : 0.5,
                duration: const Duration(milliseconds: 200),
                child: PixelHeart(
                  color: alive ? ec.bad : _deadColor,
                  pixelSize: 1.8,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
