import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:emojivia/app/router.dart';
import 'package:emojivia/core/storage/storage_service.dart';
import 'package:emojivia/core/theme/app_colors.dart';
import 'package:emojivia/core/theme/app_typography.dart';
import 'package:emojivia/core/widgets/chunky_button.dart';
import 'package:emojivia/core/widgets/share_card.dart';
import 'package:emojivia/features/streak/streak.dart';

class EmptyScreen extends StatefulWidget {
  const EmptyScreen({super.key});

  @override
  State<EmptyScreen> createState() => _EmptyScreenState();
}

class _EmptyScreenState extends State<EmptyScreen> {
  Duration _remaining = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(
        const Duration(seconds: 1), (_) => _updateRemaining());
  }

  void _updateRemaining() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    setState(() => _remaining = midnight.difference(now));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _fmt(Duration d) =>
      '${d.inHours.toString().padLeft(2, '0')}:'
      '${(d.inMinutes % 60).toString().padLeft(2, '0')}:'
      '${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final streak = context.watch<StreakController>();
    final storage = context.read<StorageService>();
    final ec = context.ec;
    final runJson = storage.savedRunJson;

    return Scaffold(
      backgroundColor: ec.yellow,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context, AppRoutes.home, (_) => false),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const Spacer(),
              Text(
                "You've finished today! ✓",
                style: AppTypography.displayS.copyWith(color: ec.ink),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Next puzzle drops in ⏳',
                style: AppTypography.body.copyWith(color: ec.inkSoft),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _fmt(_remaining),
                style: AppTypography.pixelNumeralM.copyWith(color: ec.ink),
                textAlign: TextAlign.center,
              ),
              if (streak.count > 0) ...[
                const SizedBox(height: 8),
                Text('🔥 ${streak.count} day streak',
                    style: AppTypography.body.copyWith(color: ec.flame)),
              ],
              const SizedBox(height: 28),
              if (runJson != null) _buildRecap(runJson),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ChunkyButton(
                  label: 'Share result',
                  onTap: runJson == null
                      ? null
                      : () => _share(runJson, streak.count),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecap(String runJson) {
    try {
      final m = jsonDecode(runJson) as Map<String, dynamic>;
      final results = (m['results'] as List).cast<bool>();
      return ShareCard(
        puzzleId: (m['id'] as int?) ?? 0,
        score: m['score'] as int,
        total: m['total'] as int,
        results: results,
      );
    } catch (_) {
      return const SizedBox.shrink();
    }
  }

  Future<void> _share(String runJson, int streakCount) async {
    try {
      final m = jsonDecode(runJson) as Map<String, dynamic>;
      await shareResult(
        puzzleId: (m['id'] as int?) ?? 0,
        score: m['score'] as int,
        total: m['total'] as int,
        streak: streakCount,
        results: (m['results'] as List).cast<bool>(),
      );
      if (!mounted) return;
      await context.read<StatsController>().recordShare();
    } catch (_) {}
  }
}
