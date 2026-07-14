import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

ThemeData buildTheme(EmojiviaColors colors) => ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: colors.yellow,
      colorScheme: ColorScheme.light(
        primary: colors.yellow,
        onPrimary: colors.ink,
        surface: colors.paper,
        onSurface: colors.ink,
      ),
      extensions: [colors],
      appBarTheme: AppBarTheme(
        backgroundColor: colors.yellow,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTypography.title.copyWith(color: colors.ink),
        iconTheme: IconThemeData(color: colors.ink),
      ),
      textTheme: TextTheme(
        bodyMedium: AppTypography.body.copyWith(color: colors.ink),
        bodySmall: AppTypography.meta.copyWith(color: colors.inkSoft),
      ),
    );

class AppShape {
  AppShape._();

  static final button = BorderRadius.circular(14);
  static final card = BorderRadius.circular(18);
  static final heroCard = BorderRadius.circular(22);
  static final emojiStage = BorderRadius.circular(6);
  static final chip = BorderRadius.circular(999);
}
