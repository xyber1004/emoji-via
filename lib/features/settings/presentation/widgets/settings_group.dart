import 'package:flutter/material.dart';
import 'package:emojivia/core/theme/app_colors.dart';
import 'package:emojivia/core/theme/app_typography.dart';

/// Grouped settings card (§4.21). 18dp radius, 3px ink border, 6px offset
/// shadow, clipped. A header line followed by rows separated by a 2px ink
/// top border (except the first).
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.title, required this.rows});

  final String title;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    return Container(
      decoration: BoxDecoration(
        color: ec.paper,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ec.ink, width: 3),
        boxShadow: [
          BoxShadow(color: ec.ink, offset: const Offset(6, 6), blurRadius: 0),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Text(
              title.toUpperCase(),
              style: AppTypography.caption.copyWith(
                fontSize: 11,
                letterSpacing: 11 * 0.1,
                color: ec.ink.withAlpha(165),
              ),
            ),
          ),
          for (var i = 0; i < rows.length; i++)
            Container(
              decoration: i == 0
                  ? null
                  : BoxDecoration(
                      border: Border(top: BorderSide(color: ec.ink, width: 2)),
                    ),
              child: rows[i],
            ),
        ],
      ),
    );
  }
}

/// One row inside a [SettingsGroup]: a label (name + optional description) on
/// the left and a control on the right.
class SettingRow extends StatelessWidget {
  const SettingRow({
    super.key,
    required this.name,
    this.description,
    this.control,
    this.onTap,
  });

  final String name;
  final String? description;
  final Widget? control;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: AppTypography.answer
                        .copyWith(fontSize: 15, color: ec.ink),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      description!,
                      style: AppTypography.body.copyWith(
                        fontSize: 12,
                        color: ec.ink.withAlpha(165),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (control != null) ...[
              const SizedBox(width: 12),
              control!,
            ],
          ],
        ),
      ),
    );
  }
}
