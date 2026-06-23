import 'package:flutter/material.dart';
import '../models/pack.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_theme.dart';

class PackCard extends StatelessWidget {
  const PackCard({
    super.key,
    required this.pack,
    required this.unlocked,
    required this.onTap,
  });

  final Pack pack;
  final bool unlocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final isComingSoon = pack.status == PackStatus.comingSoon;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: ec.surface,
          borderRadius: AppShape.card,
          border: Border.all(color: ec.line, width: 2),
          boxShadow: [
            BoxShadow(
              color: ec.line,
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
          ],
          gradient: unlocked
              ? LinearGradient(
                  colors: [ec.primary.withAlpha(30), ec.surface],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(pack.icon, style: const TextStyle(fontSize: 28)),
                const Spacer(),
                if (isComingSoon)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: ec.line,
                      borderRadius: AppShape.chip,
                    ),
                    child: Text(
                      'SOON',
                      style: AppTypography.meta.copyWith(color: ec.inkSoft),
                    ),
                  )
                else if (!unlocked)
                  const Text('🔒', style: TextStyle(fontSize: 18)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              pack.name,
              style: AppTypography.buttonS.copyWith(
                color: unlocked ? ec.ink : ec.inkSoft,
              ),
            ),
            Text(
              pack.description,
              style: AppTypography.meta.copyWith(color: ec.inkSoft),
            ),
            if (!unlocked && pack.unlockCondition != null) ...[
              const SizedBox(height: 8),
              Text(
                pack.unlockCondition!,
                style: AppTypography.meta.copyWith(color: ec.primary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
