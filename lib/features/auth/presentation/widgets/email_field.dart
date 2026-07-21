import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:emojivia/core/theme/app_colors.dart';
import 'package:emojivia/core/theme/app_theme.dart';
import 'package:emojivia/core/theme/app_typography.dart';

/// App-styled email input: ink border, card radius, paper fill, Archivo Black
/// input text. Inline error shown in `ec.bad`.
class EmailField extends StatelessWidget {
  const EmailField({
    super.key,
    required this.controller,
    this.errorText,
    this.enabled = true,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String? errorText;
  final bool enabled;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      autocorrect: false,
      textInputAction: TextInputAction.done,
      onSubmitted: onSubmitted,
      style: AppTypography.answer.copyWith(color: ec.ink),
      cursorColor: ec.ink,
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(r'\s')),
      ],
      decoration: InputDecoration(
        hintText: 'you@example.com',
        hintStyle: AppTypography.answer.copyWith(color: ec.inkSoft),
        errorText: errorText,
        errorStyle: AppTypography.meta.copyWith(color: ec.bad),
        filled: true,
        fillColor: ec.paper,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppShape.card,
          borderSide: BorderSide(color: ec.ink, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppShape.card,
          borderSide: BorderSide(color: ec.ink, width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppShape.card,
          borderSide: BorderSide(color: ec.bad, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppShape.card,
          borderSide: BorderSide(color: ec.bad, width: 2.5),
        ),
      ),
    );
  }
}
