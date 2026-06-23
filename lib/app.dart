import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/game_screen.dart';
import 'screens/results_screen.dart';
import 'screens/empty_screen.dart';
import 'screens/packs_screen.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

class EmojiviaApp extends StatefulWidget {
  const EmojiviaApp({super.key});

  @override
  State<EmojiviaApp> createState() => _EmojiviaAppState();
}

class _EmojiviaAppState extends State<EmojiviaApp> {
  late final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: '/play',
        builder: (_, __) => const GameScreen(),
      ),
      GoRoute(
        path: '/results',
        builder: (_, __) => const ResultsScreen(),
      ),
      GoRoute(
        path: '/done',
        builder: (_, __) => const EmptyScreen(),
      ),
      GoRoute(
        path: '/packs',
        builder: (_, __) => const PacksScreen(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Emojivia',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(EmojiviaColors.yellow),
      routerConfig: _router,
    );
  }
}
