import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:emojivia/core/widgets/app_tab_bar.dart';
import 'package:emojivia/features/awards/awards.dart';
import 'package:emojivia/features/home/presentation/screens/home_screen.dart';
import 'package:emojivia/features/packs/presentation/screens/packs_screen.dart';
import 'package:emojivia/features/settings/settings.dart';
import 'package:emojivia/features/streak/presentation/screens/stats_screen.dart';

/// Persistent tabbed shell that hosts the five bottom-nav destinations
/// (Play · Stats · Packs · Awards · More) and renders [AppTabBar] beneath them.
///
/// Uses an [IndexedStack] so each tab keeps its state and scroll position when
/// switching (CLAUDE.md §3). Immersive routes (Game, Results, Splash) are pushed
/// over this shell and are not part of the stack.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final unseen = context.watch<AwardsController>().unseenCount;
    final tabs = [
      const AppTabItem(emoji: '🏠', label: 'Play'),
      const AppTabItem(emoji: '📊', label: 'Stats'),
      const AppTabItem(emoji: '🎒', label: 'Packs'),
      AppTabItem(emoji: '🏆', label: 'Awards', badge: unseen),
      const AppTabItem(emoji: '⋯', label: 'More'),
    ];
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          HomeScreen(),
          StatsScreen(),
          PacksScreen(),
          AchievementsScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: AppTabBar(
        items: tabs,
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
