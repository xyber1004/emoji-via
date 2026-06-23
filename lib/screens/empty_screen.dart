import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/game_provider.dart';
import '../providers/streak_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/chunky_button.dart';
import '../widgets/mascot.dart';
import '../widgets/share_card.dart';

class EmptyScreen extends ConsumerStatefulWidget {
  const EmptyScreen({super.key});

  @override
  ConsumerState<EmptyScreen> createState() => _EmptyScreenState();
}

class _EmptyScreenState extends ConsumerState<EmptyScreen> {
  late Timer _timer;
  Duration _timeLeft = _untilMidnight();

  static Duration _untilMidnight() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    return midnight.difference(now);
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _timeLeft = _untilMidnight());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _fmt(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final game = ref.watch(gameProvider);
    final streak = ref.watch(streakProvider);

    return Scaffold(
      backgroundColor: ec.bg,
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go('/home')),
        title: const Text('Today\'s recap'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              const Mascot(mood: MascotMood.sleepy, size: 80),
              const SizedBox(height: 20),
              Text(
                'You\'ve finished today! ✓',
                style: AppTypography.displayS.copyWith(color: ec.ink),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Next puzzle drops in ${_fmt(_timeLeft)} ⏳',
                style: AppTypography.body.copyWith(color: ec.inkSoft),
              ),
              if (game != null) ...[
                const SizedBox(height: 32),
                ShareCard(
                  puzzleId: game.puzzleSet.id,
                  score: game.score,
                  total: game.puzzleSet.puzzles.length,
                  results: game.results,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ChunkyButton(
                    label: 'Share result',
                    icon: const Text('📤', style: TextStyle(fontSize: 18)),
                    onTap: () => shareResult(
                      puzzleId: game.puzzleSet.id,
                      score: game.score,
                      total: game.puzzleSet.puzzles.length,
                      streak: streak.count,
                      results: game.results,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              Text(
                '🔥 ${streak.count} day streak',
                style: AppTypography.buttonS.copyWith(color: ec.flame),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
