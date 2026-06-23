import 'package:flutter/material.dart';
import 'package:emojivia/core/theme/app_colors.dart';
import 'package:emojivia/core/theme/app_typography.dart';
import 'package:emojivia/core/theme/app_theme.dart';

enum AnswerOptionState { idle, selected, correct, wrong, dimmed }

class AnswerOption extends StatefulWidget {
  const AnswerOption({
    super.key,
    required this.label,
    required this.letter,
    required this.state,
    required this.onTap,
  });

  final String label;
  final String letter;
  final AnswerOptionState state;
  final VoidCallback? onTap;

  @override
  State<AnswerOption> createState() => _AnswerOptionState();
}

class _AnswerOptionState extends State<AnswerOption> {
  bool _pressed = false;

  static const _drop = 4.0;

  (Color fill, Color border, Color shadow, Color text) _colors(
      EmojiviaColors ec) {
    return switch (widget.state) {
      AnswerOptionState.idle => (ec.surface, ec.line, ec.line, ec.ink),
      AnswerOptionState.selected => (ec.primary.withAlpha(30), ec.primary, ec.primaryDark, ec.ink),
      AnswerOptionState.correct => (ec.good.withAlpha(30), ec.good, ec.goodDark, ec.ink),
      AnswerOptionState.wrong => (ec.bad.withAlpha(30), ec.bad, ec.badDark, ec.ink),
      AnswerOptionState.dimmed => (ec.surface, ec.line, Colors.transparent, ec.inkSoft),
    };
  }

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final (fill, border, shadow, text) = _colors(ec);
    final tappable = widget.state == AnswerOptionState.idle &&
        widget.onTap != null;

    String? semanticLabel;
    if (widget.state == AnswerOptionState.correct) {
      semanticLabel = 'Correct answer: ${widget.label}';
    } else if (widget.state == AnswerOptionState.wrong) {
      semanticLabel = 'Wrong answer: ${widget.label}';
    } else if (widget.state == AnswerOptionState.selected) {
      semanticLabel = 'Selected: ${widget.label}';
    }

    return Semantics(
      label: semanticLabel,
      button: tappable,
      child: GestureDetector(
        onTapDown: tappable ? (_) => setState(() => _pressed = true) : null,
        onTapUp: tappable
            ? (_) {
                setState(() => _pressed = false);
                widget.onTap?.call();
              }
            : null,
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 70),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _pressed ? _drop : 0, 0),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: AppShape.card,
            border: Border.all(color: border, width: 2),
            boxShadow: (_pressed || widget.state == AnswerOptionState.dimmed)
                ? null
                : [BoxShadow(color: shadow, offset: Offset(0, _drop), blurRadius: 0)],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: border.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(widget.letter,
                    style: AppTypography.buttonS.copyWith(color: border)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(widget.label,
                    style: AppTypography.answer.copyWith(color: text)),
              ),
              if (widget.state == AnswerOptionState.correct)
                Text('✓',
                    style: AppTypography.title.copyWith(color: ec.goodDark)),
              if (widget.state == AnswerOptionState.wrong)
                Text('✕',
                    style: AppTypography.title.copyWith(color: ec.badDark)),
            ],
          ),
        ),
      ),
    );
  }
}
