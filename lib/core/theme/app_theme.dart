import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

const double _r = 20;

ThemeData buildTheme(EmojiviaColors colors) => ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: colors.bg,
      colorScheme: ColorScheme.light(
        primary: colors.primary,
        onPrimary: colors.onPrimary,
        surface: colors.surface,
        onSurface: colors.ink,
      ),
      extensions: [colors],
      appBarTheme: AppBarTheme(
        backgroundColor: colors.bg,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTypography.title.copyWith(color: colors.ink),
        iconTheme: IconThemeData(color: colors.ink),
      ),
      textTheme: TextTheme(
        bodyMedium: AppTypography.body.copyWith(color: colors.ink),
        bodySmall: AppTypography.caption.copyWith(color: colors.inkSoft),
      ),
    );

class AppShape {
  AppShape._();
  static const double r = _r;
  static final button = BorderRadius.circular(_r);
  static final card = BorderRadius.circular(_r + 4);
  static final heroCard = BorderRadius.circular(_r + 14);
  static final chip = BorderRadius.circular(999);
}
