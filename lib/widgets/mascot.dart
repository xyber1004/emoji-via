import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';

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
    final bubble = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [ec.surface, ec.bg],
        ),
        border: Border.all(
          color: ec.line,
          width: 2,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
      ),
      child: Center(
        child: Text(
          _emoji,
          style: TextStyle(fontSize: size * 0.45),
        ),
      ),
    );

    return switch (mood) {
      MascotMood.idle => bubble
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveY(begin: 0, end: -6, duration: 2000.ms, curve: Curves.easeInOut),
      MascotMood.celebrate => bubble
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(begin: const Offset(1, 1), end: const Offset(1.08, 1.08), duration: 400.ms)
          .then()
          .scale(begin: const Offset(1.08, 1.08), end: const Offset(1, 1), duration: 400.ms),
      MascotMood.sad => bubble
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveY(begin: 0, end: 4, duration: 1500.ms, curve: Curves.easeInOut),
      MascotMood.sleepy => bubble
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveY(begin: 0, end: -2, duration: 3000.ms, curve: Curves.easeInOut),
    };
  }
}
