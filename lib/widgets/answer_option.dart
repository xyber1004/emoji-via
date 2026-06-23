import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_theme.dart';

enum AnswerOptionState { idle, selected, correct, wrong, dimmed }

class AnswerOption extends StatefulWidget {
  const AnswerOption({
    super.key,
    required this.letter,
    required this.label,
    required this.optionState,
    this.onTap,
  });

  final String letter;
  final String label;
  final AnswerOptionState optionState;
  final VoidCallback? onTap;

  @override
  State<AnswerOption> createState() => _AnswerOptionState();
}

class _AnswerOptionState extends State<AnswerOption> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;

    Color fill;
    Color border;
    Color shadow;
    Color letterBg;
    Color textColor;
    double opacity = 1.0;

    switch (widget.optionState) {
      case AnswerOptionState.idle:
        fill = ec.surface;
        border = ec.line;
        shadow = ec.line;
        letterBg = ec.line;
        textColor = ec.ink;
      case AnswerOptionState.selected:
        fill = ec.surface;
        border = ec.primary;
        shadow = ec.primaryDark;
        letterBg = ec.primary;
        textColor = ec.ink;
      case AnswerOptionState.correct:
        fill = ec.good.withAlpha(30);
        border = ec.good;
        shadow = ec.goodDark;
        letterBg = ec.good;
        textColor = ec.ink;
      case AnswerOptionState.wrong:
        fill = ec.bad.withAlpha(20);
        border = ec.bad;
        shadow = ec.badDark;
        letterBg = ec.bad;
        textColor = ec.ink;
      case AnswerOptionState.dimmed:
        fill = ec.surface;
        border = ec.line;
        shadow = Colors.transparent;
        letterBg = ec.line;
        textColor = ec.inkSoft;
        opacity = 0.5;
    }

    final interactive = widget.optionState == AnswerOptionState.idle &&
        widget.onTap != null;

    return Semantics(
      button: true,
      label: '${widget.letter}: ${widget.label}',
      hint: switch (widget.optionState) {
        AnswerOptionState.correct => 'Correct answer',
        AnswerOptionState.wrong => 'Wrong answer',
        _ => null,
      },
      child: Opacity(
        opacity: opacity,
        child: GestureDetector(
          onTapDown: interactive ? (_) => setState(() => _pressed = true) : null,
          onTapUp: interactive
              ? (_) {
                  setState(() => _pressed = false);
                  widget.onTap?.call();
                }
              : null,
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 70),
            transform: Matrix4.translationValues(0, _pressed ? 4 : 0, 0),
            decoration: BoxDecoration(
              color: fill,
              borderRadius: AppShape.card,
              border: Border.all(color: border, width: 2),
              boxShadow: _pressed || widget.optionState == AnswerOptionState.dimmed
                  ? null
                  : [
                      BoxShadow(
                        color: shadow,
                        offset: const Offset(0, 4),
                        blurRadius: 0,
                      ),
                    ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: letterBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    widget.letter,
                    style: AppTypography.buttonS.copyWith(
                      color: widget.optionState == AnswerOptionState.correct
                          ? Colors.white
                          : widget.optionState == AnswerOptionState.wrong
                              ? Colors.white
                              : ec.ink,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.label,
                    style: AppTypography.answer.copyWith(color: textColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
