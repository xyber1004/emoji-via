import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:emojivia/core/theme/app_colors.dart';
import 'package:emojivia/core/widgets/pixel_sprites.dart';

enum MascotMood { idle, celebrate, sad, sleepy }

class Mascot extends StatelessWidget {
  const Mascot({super.key, this.mood = MascotMood.idle, this.size = 80});

  final MascotMood mood;
  final double size;

  String get _emoji => switch (mood) {
        MascotMood.idle => '😊',
        MascotMood.celebrate => '🥳',
        MascotMood.sad => '😢',
        MascotMood.sleepy => '😴',
      };

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;

    // Organic blob shape approximating CSS border-radius: 50% 45% 60% 40% / 50% 55% 45% 50%
    final blobRadius = BorderRadius.only(
      topLeft: Radius.elliptical(size * 0.50, size * 0.50),
      topRight: Radius.elliptical(size * 0.45, size * 0.55),
      bottomRight: Radius.elliptical(size * 0.60, size * 0.45),
      bottomLeft: Radius.elliptical(size * 0.40, size * 0.50),
    );

    // The blob itself, rotated −8°
    final blob = Transform.rotate(
      angle: -8 * math.pi / 180,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: ec.yellow,
          borderRadius: blobRadius,
          border: Border.all(color: ec.ink, width: 2.5),
          boxShadow: [
            BoxShadow(color: ec.ink, offset: const Offset(4, 4), blurRadius: 0),
          ],
        ),
        child: Center(
          child: Text(
            _emoji,
            style: TextStyle(fontSize: size * 0.44),
          ),
        ),
      ),
    );

    final sparklePixelSize = (size * 0.1).clamp(1.4, 2.4);
    final pad = size * 0.15;

    // Sparkles + blob in one Stack, then the whole thing is animated
    final content = SizedBox(
      width: size + pad * 2,
      height: size + pad * 2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          blob,
          // 4 twinkling sparkles, alternating ink/flame with staggered delays
          Positioned(
            top: 0,
            right: pad * 0.6,
            child: TwinklingSparkle(
              color: ec.ink,
              pixelSize: sparklePixelSize,
              delay: Duration.zero,
            ),
          ),
          Positioned(
            top: pad * 0.8,
            left: 0,
            child: TwinklingSparkle(
              color: ec.flame,
              pixelSize: sparklePixelSize,
              delay: 600.ms,
            ),
          ),
          Positioned(
            bottom: pad * 0.6,
            right: 0,
            child: TwinklingSparkle(
              color: ec.flame,
              pixelSize: sparklePixelSize,
              delay: 1200.ms,
            ),
          ),
          Positioned(
            bottom: 0,
            left: pad * 0.7,
            child: TwinklingSparkle(
              color: ec.ink,
              pixelSize: sparklePixelSize,
              delay: 1800.ms,
            ),
          ),
        ],
      ),
    );

    // Mood animation applied to the whole SizedBox (so sparkles move with blob)
    return switch (mood) {
      MascotMood.idle => content
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveY(
            begin: 0,
            end: -6,
            duration: 2000.ms,
            curve: Curves.easeInOut,
          ),
      MascotMood.celebrate => content
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.08, 1.08),
            duration: 400.ms,
          ),
      MascotMood.sad => content
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveY(
            begin: 0,
            end: 4,
            duration: 1500.ms,
            curve: Curves.easeInOut,
          ),
      MascotMood.sleepy => content
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveY(
            begin: 0,
            end: -2,
            duration: 3000.ms,
            curve: Curves.easeInOut,
          ),
    };
  }
}
