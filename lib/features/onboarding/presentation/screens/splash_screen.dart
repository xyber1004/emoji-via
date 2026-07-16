import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:emojivia/app/router.dart';
import 'package:emojivia/core/theme/app_colors.dart';
import 'package:emojivia/core/theme/app_typography.dart';
import 'package:emojivia/core/widgets/chunky_button.dart';
import 'package:emojivia/core/widgets/mascot.dart';
import 'package:emojivia/features/streak/streak.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeSkip());
  }

  void _maybeSkip() {
    final streak = context.read<StreakController>();
    if (streak.introSeen) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    return Scaffold(
      backgroundColor: ec.yellow,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: Column(
            children: [
              const Spacer(),
              const Mascot(mood: MascotMood.celebrate, size: 120),
              const SizedBox(height: 28),
              Text(
                'Emojivia',
                style: AppTypography.wordmark.copyWith(color: ec.ink),
              )
                  .animate()
                  .fadeIn(duration: 600.ms, curve: Curves.easeOutCubic)
                  .slideY(begin: 0.2, end: 0),
              const SizedBox(height: 12),
              Text(
                'Daily emoji puzzles',
                style: AppTypography.body.copyWith(color: ec.inkSoft),
              )
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 500.ms),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ChunkyButton(
                  label: "Let's play",
                  variant: ChunkyButtonVariant.ghost,
                  onTap: () async {
                    final nav = Navigator.of(context);
                    await context.read<StreakController>().markIntroSeen();
                    nav.pushReplacementNamed(AppRoutes.home);
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
