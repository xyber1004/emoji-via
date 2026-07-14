import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Pixel-art heart — 11×9 grid, fills in bad color (#E63946)
class PixelHeart extends StatelessWidget {
  const PixelHeart({super.key, required this.color, this.pixelSize = 2.0});
  final Color color;
  final double pixelSize;

  static const _grid = [
    [0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0],
    [0, 1, 1, 1, 1, 0, 1, 1, 1, 1, 0],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
    [0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0],
    [0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0],
    [0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0],
    [0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0],
  ];

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(11 * pixelSize, 9 * pixelSize),
      painter: _GridPainter(grid: _grid, color: color),
    );
  }
}

// Pixel-art flame — 5×7 grid, fills in flame color (#F26B1F)
class PixelFlame extends StatelessWidget {
  const PixelFlame({super.key, required this.color, this.pixelSize = 2.5});
  final Color color;
  final double pixelSize;

  static const _grid = [
    [0, 1, 1, 0, 0],
    [1, 1, 1, 1, 0],
    [1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1],
    [1, 1, 1, 1, 0],
    [0, 1, 1, 0, 0],
    [0, 0, 1, 0, 0],
  ];

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(5 * pixelSize, 7 * pixelSize),
      painter: _GridPainter(grid: _grid, color: color),
    );
  }
}

// Pixel-art 4-point sparkle — 7×7 cross shape
class PixelSparkle extends StatelessWidget {
  const PixelSparkle({super.key, required this.color, this.pixelSize = 1.5});
  final Color color;
  final double pixelSize;

  static const _grid = [
    [0, 0, 0, 1, 0, 0, 0],
    [0, 0, 0, 1, 0, 0, 0],
    [0, 0, 1, 1, 1, 0, 0],
    [1, 1, 1, 1, 1, 1, 1],
    [0, 0, 1, 1, 1, 0, 0],
    [0, 0, 0, 1, 0, 0, 0],
    [0, 0, 0, 1, 0, 0, 0],
  ];

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(7 * pixelSize, 7 * pixelSize),
      painter: _GridPainter(grid: _grid, color: color),
    );
  }
}

// Twinkling sparkle with staggered pulse animation
class TwinklingSparkle extends StatelessWidget {
  const TwinklingSparkle({
    super.key,
    required this.color,
    this.pixelSize = 1.8,
    this.delay = Duration.zero,
  });
  final Color color;
  final double pixelSize;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return PixelSparkle(color: color, pixelSize: pixelSize)
        .animate(delay: delay, onPlay: (c) => c.repeat(reverse: true))
        .fade(
          begin: 0.2,
          end: 1.0,
          duration: 1200.ms,
          curve: Curves.easeInOut,
        )
        .scale(
          begin: const Offset(0.6, 0.6),
          end: const Offset(1.1, 1.1),
          duration: 1200.ms,
          curve: Curves.easeInOut,
        );
  }
}

// Shared CustomPainter for pixel-grid sprites
class _GridPainter extends CustomPainter {
  const _GridPainter({required this.grid, required this.color});
  final List<List<int>> grid;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (grid.isEmpty) return;
    final paint = Paint()..color = color;
    final rows = grid.length;
    final cols = grid[0].length;
    final pw = size.width / cols;
    final ph = size.height / rows;
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < grid[r].length; c++) {
        if (grid[r][c] == 1) {
          canvas.drawRect(
            Rect.fromLTWH(c * pw, r * ph, pw, ph),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.color != color;
}
