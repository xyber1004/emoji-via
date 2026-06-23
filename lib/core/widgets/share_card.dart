import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:emojivia/core/theme/app_colors.dart';
import 'package:emojivia/core/theme/app_typography.dart';
import 'package:emojivia/core/theme/app_theme.dart';

String buildShareText({
  required int puzzleId,
  required int score,
  required int total,
  required int streak,
  required List<bool?> results,
}) {
  final grid = results.map((r) => r == true ? '🟩' : '🟥').join();
  return 'Emojivia #$puzzleId — $score/$total 🔥$streak\n$grid\nemojivia.app';
}

Future<void> shareResult({
  required int puzzleId,
  required int score,
  required int total,
  required int streak,
  required List<bool?> results,
}) =>
    Share.share(buildShareText(
      puzzleId: puzzleId,
      score: score,
      total: total,
      streak: streak,
      results: results,
    ));

class ShareCard extends StatelessWidget {
  const ShareCard({
    super.key,
    required this.puzzleId,
    required this.score,
    required this.total,
    required this.results,
  });

  final int puzzleId;
  final int score;
  final int total;
  final List<bool?> results;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [ec.primary.withAlpha(40), ec.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppShape.card,
        border: Border.all(color: ec.line, width: 2),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Emojivia #$puzzleId',
              style: AppTypography.title.copyWith(color: ec.ink)),
          const SizedBox(height: 4),
          Text('$score/$total correct',
              style: AppTypography.body.copyWith(color: ec.inkSoft)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: results
                .map((r) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: _ResultTile(correct: r ?? false),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.correct});
  final bool correct;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: correct ? ec.good : ec.bad,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(correct ? '✓' : '✕',
            style: AppTypography.title.copyWith(color: Colors.white)),
      ),
    );
  }
}
