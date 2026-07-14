import 'package:flutter/material.dart';
import 'package:emojivia/core/theme/app_colors.dart';
import 'package:emojivia/core/theme/app_typography.dart';
import 'package:emojivia/core/theme/app_theme.dart';

class Pack {
  const Pack({
    required this.icon,
    required this.name,
    required this.meta,
    required this.unlocked,
    this.unlockHint,
    this.comingSoon = false,
  });
  final String icon;
  final String name;
  final String meta;
  final bool unlocked;
  final String? unlockHint;
  final bool comingSoon;
}

const _packs = [
  Pack(icon: '🎬', name: 'Movies', meta: '30 puzzles', unlocked: true),
  Pack(icon: '🍕', name: 'Foodie', meta: '25 puzzles', unlocked: false, unlockHint: 'Play 3 days to unlock'),
  Pack(icon: '🎵', name: 'Music', meta: '20 puzzles', unlocked: false, unlockHint: '7-day streak to unlock'),
  Pack(icon: '⚽', name: 'Sports', meta: 'Coming soon', unlocked: false, comingSoon: true),
  Pack(icon: '✈️', name: 'Travel', meta: 'Coming soon', unlocked: false, comingSoon: true),
];

class PacksScreen extends StatelessWidget {
  const PacksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    return Scaffold(
      backgroundColor: ec.yellow,
      appBar: AppBar(
        title: Text('Packs', style: AppTypography.title.copyWith(color: ec.ink)),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: _packs.length,
        itemBuilder: (ctx, i) => _PackCard(pack: _packs[i]),
      ),
    );
  }
}

class _PackCard extends StatelessWidget {
  const _PackCard({required this.pack});
  final Pack pack;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    return GestureDetector(
      onTap: () {
        if (pack.unlocked) return;
        final msg =
            pack.comingSoon ? 'Coming soon!' : (pack.unlockHint ?? 'Locked');
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(msg)));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: AppShape.card,
          color: pack.unlocked ? ec.yellow : ec.paper,
          border: Border.all(color: ec.ink, width: 2.5),
          boxShadow: [
            BoxShadow(
                color: ec.ink, offset: const Offset(4, 4), blurRadius: 0),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pack.icon, style: const TextStyle(fontSize: 36)),
                const SizedBox(height: 12),
                Text(pack.name,
                    style: AppTypography.answer.copyWith(color: ec.ink)),
                const SizedBox(height: 4),
                Text(pack.meta,
                    style: AppTypography.meta.copyWith(color: ec.inkSoft)),
                if (pack.unlocked) ...[
                  const SizedBox(height: 8),
                  Text(
                    'UNLOCKED ✓',
                    style: AppTypography.caption.copyWith(color: ec.goodDark),
                  ),
                ],
              ],
            ),
            if (!pack.unlocked)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: pack.comingSoon ? ec.inkSoft : ec.bad,
                    borderRadius: AppShape.chip,
                    border: Border.all(color: ec.ink, width: 1.5),
                  ),
                  child: Text(
                    pack.comingSoon ? 'Soon' : '🔒',
                    style: AppTypography.caption.copyWith(color: ec.paper),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
