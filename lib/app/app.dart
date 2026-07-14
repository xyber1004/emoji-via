import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:emojivia/core/theme/app_colors.dart';
import 'package:emojivia/core/theme/app_theme.dart';
import 'router.dart';

class EmojiviaApp extends StatelessWidget {
  const EmojiviaApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    final theme = buildTheme(EmojiviaColors.light);
    return MaterialApp(
      title: 'Emojivia',
      theme: theme,
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      routes: appRoutes,
    );
  }
}
