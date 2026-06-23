import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static TextStyle _baloo(double size, FontWeight weight) =>
      GoogleFonts.baloo2(fontSize: size, fontWeight: weight);

  static TextStyle _nunito(double size, FontWeight weight) =>
      GoogleFonts.nunito(fontSize: size, fontWeight: weight);

  static final displayL = _baloo(46, FontWeight.w800);
  static final displayM = _baloo(34, FontWeight.w800);
  static final displayS = _baloo(28, FontWeight.w800);
  static final title = _baloo(22, FontWeight.w800);
  static final score = _baloo(32, FontWeight.w800)
      .copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
  static final button = _baloo(21, FontWeight.w800);
  static final buttonS = _baloo(17, FontWeight.w800);
  static final answer = _baloo(19, FontWeight.w700);
  static final body = _nunito(15, FontWeight.w700);
  static final caption = _nunito(13, FontWeight.w800)
      .copyWith(letterSpacing: 13 * 0.06);
  static final meta = _nunito(13, FontWeight.w700);
}
