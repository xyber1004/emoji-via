import 'package:flutter/material.dart';
import 'package:emojivia/core/theme/app_colors.dart';
import 'package:emojivia/core/theme/app_typography.dart';
import 'package:emojivia/core/theme/app_theme.dart';

enum ChunkyButtonVariant { primary, ghost, pill }

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
  static const _drop = 6.0;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final disabled = widget.disabled || widget.onTap == null;

    Color fill, shadow, textColor;
    BorderRadius radius;

    switch (widget.variant) {
      case ChunkyButtonVariant.primary:
        fill = disabled ? ec.line : ec.primary;
        shadow = disabled ? Colors.transparent : ec.primaryDark;
        textColor = disabled ? ec.inkSoft : ec.onPrimary;
        radius = AppShape.button;
      case ChunkyButtonVariant.ghost:
        fill = ec.surface;
        shadow = disabled ? Colors.transparent : ec.line;
        textColor = disabled ? ec.inkSoft : ec.ink;
        radius = AppShape.button;
      case ChunkyButtonVariant.pill:
        fill = ec.surface;
        shadow = disabled ? Colors.transparent : ec.line;
        textColor = disabled ? ec.inkSoft : ec.ink;
        radius = AppShape.chip;
    }

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
        transform: Matrix4.translationValues(0, _pressed ? _drop : 0, 0),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: radius,
          border: widget.variant != ChunkyButtonVariant.primary
              ? Border.all(color: ec.line, width: 2)
              : null,
          boxShadow: _pressed || disabled
              ? null
              : [BoxShadow(color: shadow, offset: Offset(0, _drop), blurRadius: 0)],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[widget.icon!, const SizedBox(width: 8)],
            Text(
              widget.label,
              style: (widget.variant == ChunkyButtonVariant.pill
                      ? AppTypography.buttonS
                      : AppTypography.button)
                  .copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
