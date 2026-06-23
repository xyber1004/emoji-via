import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/streak_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/chunky_button.dart';
import '../widgets/mascot.dart';
import '../widgets/streak_chip.dart';
import '../widgets/week_strip.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ec = context.ec;
    final streak = ref.watch(streakProvider);
    final alreadyPlayed = streak.playedToday;

    return Scaffold(
      backgroundColor: ec.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Emojivia',
                    style: AppTypography.title.copyWith(color: ec.ink),
                  ),
                  const Spacer(),
                  StreakChip(count: streak.count),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => context.push('/packs'),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ec.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: ec.line),
                      ),
                      child: const Text('🎮', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Center(
                child: Mascot(
                  mood: alreadyPlayed ? MascotMood.sleepy : MascotMood.idle,
                  size: 110,
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: Text(
                  alreadyPlayed
                      ? 'You\'ve finished today! ✓'
                      : 'Play today\'s 5',
                  style: AppTypography.displayM.copyWith(color: ec.ink),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  alreadyPlayed
                      ? 'Come back tomorrow for a fresh set 🌱'
                      : '5 emoji puzzles · 3 lives · 2 hints',
                  style: AppTypography.body.copyWith(color: ec.inkSoft),
                  textAlign: TextAlign.center,
                ),
              ),
              const Spacer(),
              WeekStrip(
                streak: streak.count,
                playedToday: streak.playedToday,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ChunkyButton(
                  label: alreadyPlayed ? 'View recap' : 'Play today\'s 5 →',
                  onTap: () => context.go(alreadyPlayed ? '/done' : '/play'),
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
