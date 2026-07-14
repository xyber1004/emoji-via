import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:emojivia/core/theme/app_colors.dart';

class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({super.key, required this.child, required this.trigger});

  final Widget child;
  final bool trigger;

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay> {
  late final ConfettiController _controller =
      ConfettiController(duration: const Duration(milliseconds: 2200));

  @override
  void didUpdateWidget(ConfettiOverlay old) {
    super.didUpdateWidget(old);
    if (widget.trigger && !old.trigger) _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    return Stack(
      children: [
        widget.child,
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _controller,
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 60,
            gravity: 0.3,
            colors: [ec.yellow, ec.good, ec.bad, ec.yellowDeep, ec.ink],
          ),
        ),
      ],
    );
  }
}
