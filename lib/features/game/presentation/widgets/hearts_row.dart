import 'package:flutter/material.dart';

class HeartsRow extends StatelessWidget {
  const HeartsRow({super.key, required this.hearts, required this.total});

  final int hearts;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$hearts of $total hearts remaining',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(total, (i) {
          final alive = i < hearts;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: AnimatedOpacity(
              opacity: alive ? 1.0 : 0.28,
              duration: const Duration(milliseconds: 200),
              child: ColorFiltered(
                colorFilter: alive
                    ? const ColorFilter.mode(Colors.transparent, BlendMode.dst)
                    : const ColorFilter.matrix(<double>[
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0,      0,      0,      1, 0,
                      ]),
                child: AnimatedScale(
                  scale: alive ? 1.0 : 0.85,
                  duration: const Duration(milliseconds: 200),
                  child: const Text('❤️', style: TextStyle(fontSize: 24)),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
