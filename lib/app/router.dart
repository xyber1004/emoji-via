import 'package:flutter/material.dart';
import 'package:emojivia/app/main_shell.dart';
import 'package:emojivia/features/game/presentation/screens/game_screen.dart';
import 'package:emojivia/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:emojivia/features/packs/presentation/screens/packs_screen.dart';
import 'package:emojivia/features/results/presentation/screens/empty_screen.dart';
import 'package:emojivia/features/results/presentation/screens/results_screen.dart';

class AppRoutes {
  AppRoutes._();
  static const splash = '/';
  static const home = '/home';
  static const play = '/play';
  static const results = '/results';
  static const done = '/done';
  static const packs = '/packs';
}

Map<String, WidgetBuilder> get appRoutes => {
      AppRoutes.splash: (_) => const SplashScreen(),
      AppRoutes.home: (_) => const MainShell(),
      AppRoutes.play: (_) => const GameScreen(),
      AppRoutes.results: (_) => const ResultsScreen(),
      AppRoutes.done: (_) => const EmptyScreen(),
      AppRoutes.packs: (_) => const PacksScreen(),
    };
