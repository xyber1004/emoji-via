import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emojivia/app/router.dart';
import 'package:emojivia/core/theme/app_colors.dart';
import 'package:emojivia/core/theme/app_typography.dart';
import 'package:emojivia/core/widgets/chunky_button.dart';
import 'package:emojivia/core/widgets/mascot.dart';
import 'package:emojivia/core/widgets/streak_chip.dart';
import 'package:emojivia/features/streak/streak.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(streakControllerProvider);
    final ec = context.ec;

    return Scaffold(
      backgroundColor: ec.bg,
      appBar: AppBar(
        title: Text('Emojivia',
            style: AppTypography.title.copyWith(color: ec.ink)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.packs),
              child: Text('Packs',
                  style: AppTypography.buttonS.copyWith(color: ec.inkSoft)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Mascot(
                mood: streak.playedToday
                    ? MascotMood.sleepy
                    : MascotMood.idle,
                size: 100,
              ),
              const SizedBox(height: 28),
              Text(
                streak.playedToday
                    ? "You've finished today! ✓"
                    : "Play today's 5",
                style: AppTypography.displayM.copyWith(color: ec.ink),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                streak.playedToday
                    ? 'Come back tomorrow for a fresh set'
                    : '5 emoji puzzles · 3 hearts · 2 hints',
                style: AppTypography.body.copyWith(color: ec.inkSoft),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (streak.count > 0) ...[
                StreakChip(count: streak.count),
                const SizedBox(height: 16),
              ],
              WeekStrip(
                  streak: streak.count,
                  playedToday: streak.playedToday),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ChunkyButton(
                  label: streak.playedToday ? 'View recap' : 'Play',
                  onTap: () => Navigator.pushNamed(
                    context,
                    streak.playedToday ? AppRoutes.done : AppRoutes.play,
                  ),
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
