import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/pack.dart';
import '../providers/streak_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/pack_card.dart';

class PacksScreen extends ConsumerWidget {
  const PacksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ec = context.ec;
    final streak = ref.watch(streakProvider);

    return Scaffold(
      backgroundColor: ec.bg,
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Packs'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: kDefaultPacks.length,
          itemBuilder: (ctx, i) {
            final pack = kDefaultPacks[i];
            final unlocked = pack.isUnlockedForStreak(streak.count);
            return PackCard(
              pack: pack,
              unlocked: unlocked,
              onTap: () {
                if (pack.status == PackStatus.comingSoon) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${pack.name} is coming soon!',
                        style: AppTypography.body.copyWith(color: Colors.white),
                      ),
                      backgroundColor: ec.ink,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                } else if (!unlocked && pack.unlockCondition != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Unlock by: ${pack.unlockCondition}',
                        style: AppTypography.body.copyWith(color: Colors.white),
                      ),
                      backgroundColor: ec.ink,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}
