import 'package:flutter/material.dart';

@immutable
class EmojiviaColors extends ThemeExtension<EmojiviaColors> {
  const EmojiviaColors({
    required this.yellow,
    required this.yellowDeep,
    required this.ink,
    required this.paper,
    required this.cream,
    required this.soft,
    required this.inkSoft,
    required this.good,
    required this.goodDark,
    required this.bad,
    required this.badDark,
    required this.flame,
  });

  final Color yellow;
  final Color yellowDeep;
  final Color ink;
  final Color paper;
  final Color cream;
  final Color soft;
  final Color inkSoft;
  final Color good;
  final Color goodDark;
  final Color bad;
  final Color badDark;
  final Color flame;

  static const light = EmojiviaColors(
    yellow: Color(0xFFFFD84D),
    yellowDeep: Color(0xFFEBC12A),
    ink: Color(0xFF0F0F10),
    paper: Color(0xFFFFFFFF),
    cream: Color(0xFFFDF6D8),
    soft: Color(0xFFFAF6EA),
    inkSoft: Color(0xFF4B4740),
    good: Color(0xFF2FBA5C),
    goodDark: Color(0xFF218C46),
    bad: Color(0xFFE63946),
    badDark: Color(0xFFB72532),
    flame: Color(0xFFF26B1F),
  );

  @override
  EmojiviaColors copyWith({
    Color? yellow,
    Color? yellowDeep,
    Color? ink,
    Color? paper,
    Color? cream,
    Color? soft,
    Color? inkSoft,
    Color? good,
    Color? goodDark,
    Color? bad,
    Color? badDark,
    Color? flame,
  }) =>
      EmojiviaColors(
        yellow: yellow ?? this.yellow,
        yellowDeep: yellowDeep ?? this.yellowDeep,
        ink: ink ?? this.ink,
        paper: paper ?? this.paper,
        cream: cream ?? this.cream,
        soft: soft ?? this.soft,
        inkSoft: inkSoft ?? this.inkSoft,
        good: good ?? this.good,
        goodDark: goodDark ?? this.goodDark,
        bad: bad ?? this.bad,
        badDark: badDark ?? this.badDark,
        flame: flame ?? this.flame,
      );

  @override
  EmojiviaColors lerp(EmojiviaColors? other, double t) {
    if (other is! EmojiviaColors) return this;
    return EmojiviaColors(
      yellow: Color.lerp(yellow, other.yellow, t)!,
      yellowDeep: Color.lerp(yellowDeep, other.yellowDeep, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      paper: Color.lerp(paper, other.paper, t)!,
      cream: Color.lerp(cream, other.cream, t)!,
      soft: Color.lerp(soft, other.soft, t)!,
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
