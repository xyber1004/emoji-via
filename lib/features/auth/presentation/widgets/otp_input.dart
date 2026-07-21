import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:emojivia/core/theme/app_colors.dart';
import 'package:emojivia/core/theme/app_theme.dart';
import 'package:emojivia/core/theme/app_typography.dart';

/// Six-box one-time-code input built from scratch (no `pin_code_fields`).
///
/// Auto-advances on entry, retreats on backspace, distributes a pasted 6-digit
/// string across all boxes, supports iOS OTP autofill, and auto-submits via
/// [onComplete] when all six digits are present.
class OtpInput extends StatefulWidget {
  const OtpInput({
    super.key,
    required this.onComplete,
    this.enabled = true,
    this.length = 6,
  });

  final ValueChanged<String> onComplete;
  final bool enabled;
  final int length;

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _nodes;
  late final List<FocusNode> _keyNodes;

  @override
  void initState() {
    super.initState();
    _controllers =
        List.generate(widget.length, (_) => TextEditingController());
    _nodes = List.generate(widget.length, (_) => FocusNode());
    _keyNodes =
        List.generate(widget.length, (_) => FocusNode(skipTraversal: true));
    for (final n in _nodes) {
      n.addListener(() => setState(() {})); // repaint focused-box fill
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    for (final n in _keyNodes) {
      n.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _distribute(String digits, int startIndex) {
    final clean = digits.replaceAll(RegExp(r'\D'), '');
    for (var i = 0; i < clean.length && startIndex + i < widget.length; i++) {
      _controllers[startIndex + i].text = clean[i];
    }
    final filled = (startIndex + clean.length).clamp(0, widget.length);
    if (filled >= widget.length) {
      _nodes[widget.length - 1].requestFocus();
      _maybeComplete();
    } else {
      _nodes[filled].requestFocus();
    }
    setState(() {});
  }

  void _onChanged(String value, int index) {
    if (value.length > 1) {
      // Paste (or autofill) landed in one box — spread it out.
      _distribute(value, index);
      return;
    }
    if (value.isNotEmpty && index < widget.length - 1) {
      _nodes[index + 1].requestFocus();
    }
    _maybeComplete();
  }

  void _onKey(KeyEvent event, int index) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _nodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
      setState(() {});
    }
  }

  void _maybeComplete() {
    final code = _code;
    if (code.length == widget.length && !code.contains(RegExp(r'\D'))) {
      FocusScope.of(context).unfocus();
      widget.onComplete(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    return Opacity(
      opacity: widget.enabled ? 1 : 0.5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(widget.length, (i) {
          final focused = _nodes[i].hasFocus;
          return SizedBox(
            width: 48,
            height: 56,
            child: KeyboardListener(
              focusNode: _keyNodes[i],
              onKeyEvent: (e) => _onKey(e, i),
              child: TextField(
                controller: _controllers[i],
                focusNode: _nodes[i],
                enabled: widget.enabled,
                autofillHints:
                    i == 0 ? const [AutofillHints.oneTimeCode] : null,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: i == 0 ? null : 1,
                style: AppTypography.displayM.copyWith(color: ec.ink),
                cursorColor: ec.ink,
                decoration: InputDecoration(
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                  filled: true,
                  fillColor: focused ? ec.yellow : ec.paper,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppShape.card,
                    borderSide: BorderSide(color: ec.ink, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppShape.card,
                    borderSide: BorderSide(color: ec.ink, width: 2.5),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: AppShape.card,
                    borderSide: BorderSide(color: ec.ink, width: 2),
                  ),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (v) => _onChanged(v, i),
              ),
            ),
          );
        }),
      ),
    );
  }
}
