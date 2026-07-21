import 'package:flutter/material.dart';
import 'package:emojivia/core/theme/app_colors.dart';
import 'package:emojivia/core/theme/app_typography.dart';

/// One destination in the persistent bottom [AppTabBar].
class AppTabItem {
  const AppTabItem({required this.emoji, required this.label, this.badge = 0});

  final String emoji;
  final String label;

  /// Numeric badge (e.g. un-viewed award unlocks). 0 hides the badge.
  final int badge;
}

/// Persistent bottom navigation shell (§3, §4.15). Paper surface with a 3px ink
/// top border. Active tab = yellow fill + ink border + 3px offset shadow;
/// inactive tabs are transparent with ink icon + label.
class AppTabBar extends StatelessWidget {
  const AppTabBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<AppTabItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    return Container(
      decoration: BoxDecoration(
        color: ec.paper,
        border: Border(top: BorderSide(color: ec.ink, width: 3)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _TabButton(
                    item: items[i],
                    active: i == currentIndex,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final AppTabItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: active
              ? BoxDecoration(
                  color: ec.yellow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ec.ink, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: ec.ink,
                      offset: const Offset(3, 3),
                      blurRadius: 0,
                    ),
                  ],
                )
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Text(item.emoji, style: const TextStyle(fontSize: 20)),
                  if (item.badge > 0)
                    Positioned(
                      right: -12,
                      top: -8,
                      child: _Badge(count: item.badge),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                item.label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.visible,
                style: AppTypography.caption.copyWith(
                  fontSize: 9,
                  letterSpacing: 9 * 0.08,
                  color: ec.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    return Container(
      constraints: const BoxConstraints(minWidth: 16),
      height: 16,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: ec.flame,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: ec.ink, width: 1.5),
      ),
      child: Text(
        '$count',
        style: AppTypography.pixelNumeralS.copyWith(fontSize: 7, color: ec.paper),
      ),
    );
  }
}
