import 'package:flutter/material.dart';

@immutable
class EmojiviaColors extends ThemeExtension<EmojiviaColors> {
  const EmojiviaColors({
    required this.primary,
    required this.primaryDark,
    required this.onPrimary,
    required this.bg,
    required this.surface,
    required this.line,
    required this.ink,
    required this.inkSoft,
    required this.good,
    required this.goodDark,
    required this.bad,
    required this.badDark,
    required this.flame,
  });

  final Color primary;
  final Color primaryDark;
  final Color onPrimary;
  final Color bg;
  final Color surface;
  final Color line;
  final Color ink;
  final Color inkSoft;
  final Color good;
  final Color goodDark;
  final Color bad;
  final Color badDark;
  final Color flame;

  static const yellow = EmojiviaColors(
    primary: Color(0xFFF0C24B),
    primaryDark: Color(0xFFC99A2F),
    onPrimary: Color(0xFF4A3D1A),
    bg: Color(0xFFF8F1E3),
    surface: Color(0xFFFEFCF6),
    line: Color(0xFFE8E0CC),
    ink: Color(0xFF3A3328),
    inkSoft: Color(0xFF7A7160),
    good: Color(0xFF4FC57A),
    goodDark: Color(0xFF36A45E),
    bad: Color(0xFFE14B3D),
    badDark: Color(0xFFC13A2D),
    flame: Color(0xFFF08743),
  );

  static const coral = EmojiviaColors(
    primary: Color(0xFFE26A5A),
    primaryDark: Color(0xFFBD4F40),
    onPrimary: Color(0xFFFFFFFF),
    bg: Color(0xFFF8F1E3),
    surface: Color(0xFFFEFCF6),
    line: Color(0xFFE8E0CC),
    ink: Color(0xFF3A3328),
    inkSoft: Color(0xFF7A7160),
    good: Color(0xFF4FC57A),
    goodDark: Color(0xFF36A45E),
    bad: Color(0xFFE14B3D),
    badDark: Color(0xFFC13A2D),
    flame: Color(0xFFF08743),
  );

  @override
  EmojiviaColors copyWith({
    Color? primary, Color? primaryDark, Color? onPrimary,
    Color? bg, Color? surface, Color? line, Color? ink, Color? inkSoft,
    Color? good, Color? goodDark, Color? bad, Color? badDark, Color? flame,
  }) => EmojiviaColors(
    primary: primary ?? this.primary, primaryDark: primaryDark ?? this.primaryDark,
    onPrimary: onPrimary ?? this.onPrimary, bg: bg ?? this.bg,
    surface: surface ?? this.surface, line: line ?? this.line,
    ink: ink ?? this.ink, inkSoft: inkSoft ?? this.inkSoft,
    good: good ?? this.good, goodDark: goodDark ?? this.goodDark,
    bad: bad ?? this.bad, badDark: badDark ?? this.badDark, flame: flame ?? this.flame,
  );

  @override
  EmojiviaColors lerp(EmojiviaColors? other, double t) {
    if (other is! EmojiviaColors) return this;
    return EmojiviaColors(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      line: Color.lerp(line, other.line, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkSoft: Color.lerp(inkSoft, other.inkSoft, t)!,
      good: Color.lerp(good, other.good, t)!,
      goodDark: Color.lerp(goodDark, other.goodDark, t)!,
      bad: Color.lerp(bad, other.bad, t)!,
      badDark: Color.lerp(badDark, other.badDark, t)!,
      flame: Color.lerp(flame, other.flame, t)!,
    );
  }
}

extension EmojiviaColorsContext on BuildContext {
  EmojiviaColors get ec => Theme.of(this).extension<EmojiviaColors>()!;
}
