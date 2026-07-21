import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:emojivia/core/theme/app_colors.dart';
import 'package:emojivia/core/theme/app_typography.dart';
import 'package:emojivia/core/widgets/pixel_toggle.dart';
import 'package:emojivia/features/settings/application/controllers/settings_controller.dart';
import 'package:emojivia/features/settings/presentation/widgets/settings_group.dart';

/// More tab — preferences + about (§4.21, §14 "settings" slice).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final s = context.watch<SettingsController>();

    return Scaffold(
      backgroundColor: ec.yellow,
      appBar: AppBar(
        title: Text('More', style: AppTypography.title.copyWith(color: ec.ink)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          SettingsGroup(
            title: 'Preferences',
            rows: [
              SettingRow(
                name: 'Sound',
                description: 'Play sound effects during the game.',
                control: PixelToggle(value: s.sound, onChanged: s.setSound),
              ),
              SettingRow(
                name: 'Haptics',
                description: 'Vibrate on correct and wrong answers.',
                control: PixelToggle(value: s.haptics, onChanged: s.setHaptics),
              ),
              SettingRow(
                name: 'Daily reminder',
                description: "We'll ping you once a day to play.",
                control: PixelToggle(
                  value: s.dailyReminder,
                  onChanged: s.setDailyReminder,
                ),
              ),
              SettingRow(
                name: 'Reduced motion',
                description: 'Tone down confetti and screen shake.',
                control: PixelToggle(
                  value: s.reducedMotion,
                  onChanged: s.setReducedMotion,
                ),
              ),
              SettingRow(
                name: 'Yellow texture',
                description: 'Subtle paper grain over the yellow background.',
                control: PixelToggle(
                  value: s.yellowTexture,
                  onChanged: s.setYellowTexture,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SettingsGroup(
            title: 'About',
            rows: [
              const SettingRow(name: 'Version', description: 'Emojivia 1.0.0'),
              SettingRow(
                name: 'Send feedback',
                description: 'Tell us what you think.',
                onTap: () {
                  ScaffoldMessenger.of(context)
                    ..clearSnackBars()
                    ..showSnackBar(
                      const SnackBar(content: Text('Thanks! Feedback coming soon 💛')),
                    );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
