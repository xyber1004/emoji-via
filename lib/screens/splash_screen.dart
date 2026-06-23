import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/streak_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/chunky_button.dart';
import '../widgets/mascot.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final streak = ref.read(streakProvider);
      if (streak.introSeen) {
        context.go('/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final streak = ref.watch(streakProvider);

    if (streak.introSeen) {
      return const Scaffold(body: SizedBox.shrink());
    }

    return Scaffold(
      backgroundColor: ec.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(),
              const Mascot(mood: MascotMood.idle, size: 100),
              const SizedBox(height: 32),
              Text(
                'Emojivia',
                style: AppTypography.displayL.copyWith(color: ec.ink),
              ),
              const SizedBox(height: 12),
              Text(
                'A new emoji puzzle every day.',
                style: AppTypography.body.copyWith(color: ec.inkSoft),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ChunkyButton(
                  label: 'Play today\'s 5 →',
                  onTap: () async {
                    await ref.read(streakProvider.notifier).markIntroSeen();
                    if (context.mounted) context.go('/home');
                  },
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
