import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:emojivia/core/theme/app_colors.dart';
import 'package:emojivia/core/theme/app_theme.dart';

/// The cream "arcade stage" panel that every emoji clue sits inside.
/// Cream background, pixel-dot grid, 3px ink border, 5px ink shadow,
/// four pixel L-bracket corners protruding −4px, and an optional
/// rotated yellow "peeking" accent behind it.
class EmojiStage extends StatelessWidget {
  const EmojiStage({
    super.key,
    required this.child,
    this.showYellowAccent = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
  });

  final Widget child;
  final bool showYellowAccent;
  final EdgeInsets padding;

  static const _protrude = 5.0;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;

    // Inner cream stage with dot-grid overlay
    final stageBox = Container(
      decoration: BoxDecoration(
        color: ec.cream,
        borderRadius: AppShape.emojiStage,
        border: Border.all(color: ec.ink, width: 3),
        boxShadow: [
          BoxShadow(color: ec.ink, offset: const Offset(5, 5), blurRadius: 0),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppShape.emojiStage,
        child: Stack(
          children: [
            // Pixel-dot grid (10×10 spacing, 9% opacity)
            Positioned.fill(
              child: CustomPaint(
                painter: _DotGridPainter(
                  color: ec.ink.withAlpha(23), // ~9% opacity
                ),
              ),
            ),
            // Content with padding
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );

    // L-bracket overlay extended beyond the stage's bounds
    final withBrackets = Stack(
      clipBehavior: Clip.none,
      children: [
        stageBox,
        Positioned(
          top: -_protrude,
          left: -_protrude,
          right: -_protrude,
          bottom: -_protrude,
          child: CustomPaint(
            painter: _LBracketPainter(color: ec.ink),
          ),
        ),
      ],
    );

    if (!showYellowAccent) return withBrackets;

    // Yellow "peeking" accent: rotated −3° rectangle behind the stage
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: Transform.rotate(
            angle: -3 * math.pi / 180,
            child: Container(
              margin: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: ec.yellow,
                borderRadius: AppShape.emojiStage,
                border: Border.all(color: ec.ink, width: 2.5),
              ),
            ),
          ),
        ),
        withBrackets,
      ],
    );
  }
}

class _DotGridPainter extends CustomPainter {
  const _DotGridPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (double x = 10; x < size.width; x += 10) {
      for (double y = 10; y < size.height; y += 10) {
        canvas.drawRect(Rect.fromLTWH(x, y, 1.5, 1.5), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter old) => old.color != color;
}

// Draws 4 pixel L-bracket corners. The painter's bounds extend _protrude
// outside the stage box, so coordinates 0,0 correspond to the top-left
// corner of the padded bounding box (i.e., protrude px outside the stage).
class _LBracketPainter extends CustomPainter {
  const _LBracketPainter({required this.color});
  final Color color;

  static const _arm = 14.0;
  static const _thick = 3.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final w = size.width;
    final h = size.height;

    // Top-left
    canvas.drawRect(Rect.fromLTWH(0, 0, _arm, _thick), paint);
    canvas.drawRect(Rect.fromLTWH(0, 0, _thick, _arm), paint);

    // Top-right
    canvas.drawRect(Rect.fromLTWH(w - _arm, 0, _arm, _thick), paint);
    canvas.drawRect(Rect.fromLTWH(w - _thick, 0, _thick, _arm), paint);

    // Bottom-left
    canvas.drawRect(Rect.fromLTWH(0, h - _thick, _arm, _thick), paint);
    canvas.drawRect(Rect.fromLTWH(0, h - _arm, _thick, _arm), paint);

    // Bottom-right
    canvas.drawRect(Rect.fromLTWH(w - _arm, h - _thick, _arm, _thick), paint);
    canvas.drawRect(Rect.fromLTWH(w - _thick, h - _arm, _thick, _arm), paint);
  }

  @override
  bool shouldRepaint(_LBracketPainter old) => old.color != color;
}
