import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:emojivia/core/theme/app_colors.dart';
import 'package:emojivia/core/theme/app_theme.dart';
import 'package:emojivia/core/theme/app_typography.dart';
import 'package:emojivia/core/widgets/chunky_button.dart';
import 'package:emojivia/core/widgets/pixel_sprites.dart';
import 'package:emojivia/features/streak/streak.dart';
import 'email_entry_screen.dart';

/// Bottom-sheet body offering to back up a 7-day streak via email.
///
/// Show with `showModalBottomSheet(isScrollControlled: true,
/// backgroundColor: Colors.transparent, builder: (_) => const SaveStreakScreen())`.
class SaveStreakScreen extends StatelessWidget {
  const SaveStreakScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final count = context.select<StreakController, int>((c) => c.count);

    return Container(
      decoration: BoxDecoration(
        color: ec.paper,
        borderRadius: BorderRadius.only(
          topLeft: AppShape.heroCard.topLeft,
          topRight: AppShape.heroCard.topRight,
        ),
        border: Border(top: BorderSide(color: ec.ink, width: 3)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 3,
            decoration: BoxDecoration(
              color: ec.ink,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 20),
          PixelFlame(color: ec.flame, pixelSize: 8),
          const SizedBox(height: 12),
          Text(
            '$count days!',
            style: AppTypography.pixelNumeral.copyWith(color: ec.flame),
          ),
          const SizedBox(height: 12),
          Text(
            'Save your streak?',
            style: AppTypography.displayS.copyWith(color: ec.ink),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Add your email so you can pick up where you left off on any device.',
            style: AppTypography.body.copyWith(color: ec.inkSoft),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ChunkyButton(
              label: 'Save my streak',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EmailEntryScreen()),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ChunkyButton(
              label: 'Maybe later',
              variant: ChunkyButtonVariant.ghost,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "No password. We'll email you a 6-digit code.",
            style: AppTypography.meta.copyWith(color: ec.inkSoft),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
