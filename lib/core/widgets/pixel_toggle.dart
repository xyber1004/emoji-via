import 'package:flutter/material.dart';
import 'package:emojivia/core/theme/app_colors.dart';

/// A chunky pixel-styled switch (§4.22). 46×26dp pill with a 2px ink border and
/// 2px offset shadow. Never use Material [Switch] — this matches the app's
/// shape/border/shadow language.
class PixelToggle extends StatelessWidget {
  const PixelToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  static const _width = 46.0;
  static const _height = 26.0;
  static const _knob = 18.0;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final enabled = onChanged != null;
    return GestureDetector(
      onTap: enabled ? () => onChanged!(!value) : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          width: _width,
          height: _height,
          decoration: BoxDecoration(
            color: value ? ec.yellow : ec.paper,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: ec.ink, width: 2),
            boxShadow: [
              BoxShadow(color: ec.ink, offset: const Offset(2, 2), blurRadius: 0),
            ],
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Container(
                    width: _knob,
                    height: _knob,
                    decoration: BoxDecoration(
                      color: ec.ink,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
