import 'package:flutter/material.dart';
import 'package:emojivia/core/theme/app_colors.dart';
import 'package:emojivia/core/theme/app_typography.dart';
import 'package:emojivia/core/theme/app_theme.dart';

enum ChunkyButtonVariant { primary, ghost, yellow }

class ChunkyButton extends StatefulWidget {
  const ChunkyButton({
    super.key,
    required this.label,
    required this.onTap,
    this.variant = ChunkyButtonVariant.primary,
    this.disabled = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onTap;
  final ChunkyButtonVariant variant;
  final bool disabled;
  final Widget? icon;

  @override
  State<ChunkyButton> createState() => _ChunkyButtonState();
}

class _ChunkyButtonState extends State<ChunkyButton> {
  bool _pressed = false;

  static const _shadowNormal = 5.0;
  static const _shadowPressed = 2.0;
  static const _pressShift = 3.0;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final disabled = widget.disabled || widget.onTap == null;

    Color fill, shadow, textColor;
    Color? borderColor;

    switch (widget.variant) {
      case ChunkyButtonVariant.primary:
        fill = disabled ? ec.inkSoft : ec.ink;
        shadow = disabled ? Colors.transparent : ec.yellowDeep;
        textColor = ec.paper;
        borderColor = null;
      case ChunkyButtonVariant.ghost:
        fill = ec.paper;
        shadow = disabled ? Colors.transparent : ec.ink;
        textColor = disabled ? ec.inkSoft : ec.ink;
        borderColor = ec.ink;
      case ChunkyButtonVariant.yellow:
        fill = disabled ? ec.inkSoft.withAlpha(40) : ec.yellow;
        shadow = disabled ? Colors.transparent : ec.ink;
        textColor = disabled ? ec.inkSoft : ec.ink;
        borderColor = ec.ink;
    }

    final shift = _pressed ? _pressShift : 0.0;
    final shadowSize = _pressed ? _shadowPressed : _shadowNormal;

    return GestureDetector(
      onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
      onTapUp: disabled
          ? null
          : (_) {
              setState(() => _pressed = false);
              widget.onTap?.call();
            },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 70),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(shift, shift, 0),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: AppShape.button,
          border: borderColor != null
              ? Border.all(color: borderColor, width: 2.5)
              : null,
          boxShadow: disabled
              ? null
              : [
                  BoxShadow(
                    color: shadow,
                    offset: Offset(shadowSize, shadowSize),
                    blurRadius: 0,
                  )
                ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[widget.icon!, const SizedBox(width: 8)],
            Text(
              widget.label.toUpperCase(),
              style: AppTypography.button.copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
