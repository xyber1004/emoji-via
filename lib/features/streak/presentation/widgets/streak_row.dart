import 'package:flutter/material.dart';
import 'package:emojivia/core/theme/app_colors.dart';
import 'package:emojivia/core/widgets/pixel_sprites.dart';

/// Last-9-days streak strip (§4.18). Nine 22dp squares, oldest → today.
/// `true` = hit (flame + pixel-flame), `false` = miss (bad, pixel-X),
/// `null` = gap (paper with 45° hatch).
class StreakRow extends StatelessWidget {
  const StreakRow({super.key, required this.days});

  final List<bool?> days;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final day in days) _cell(ec, day),
      ],
    );
  }

  Widget _cell(EmojiviaColors ec, bool? day) {
    Widget? glyph;
    Color fill;
    double opacity = 1;

    if (day == true) {
      fill = ec.flame;
      glyph = PixelFlame(color: ec.paper, pixelSize: 1.4);
    } else if (day == false) {
      fill = ec.bad;
      opacity = 0.5;
      glyph = PixelCross(color: ec.paper, pixelSize: 1.4);
    } else {
      fill = ec.paper;
    }

    return Opacity(
      opacity: opacity,
      child: Container(
        width: 22,
        height: 22,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: day == null ? null : fill,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: ec.ink, width: 1.5),
        ),
        child: day == null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: CustomPaint(
                  size: const Size(22, 22),
                  painter: _HatchPainter(color: ec.ink.withAlpha(60)),
                ),
              )
            : glyph,
      ),
    );
  }
}

/// 45° diagonal hatch fill for "gap" days.
class _HatchPainter extends CustomPainter {
  const _HatchPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    const step = 5.0;
    for (var x = -size.height; x < size.width; x += step) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_HatchPainter old) => old.color != color;
}
