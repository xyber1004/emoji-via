import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static TextStyle _archivo(double size, {double letterSpacing = 0}) =>
      GoogleFonts.archivoBlack(
        fontSize: size,
        fontWeight: FontWeight.w900,
        letterSpacing: letterSpacing,
      );

  static TextStyle _nunito(double size, FontWeight weight) =>
      GoogleFonts.nunito(fontSize: size, fontWeight: weight);

  static TextStyle _pressStart(double size) =>
      GoogleFonts.pressStart2p(fontSize: size, fontWeight: FontWeight.w400);

  // Archivo Black — display, buttons, labels
  static final wordmark = _archivo(72);
  static final displayL = _archivo(88);
  static final displayM = _archivo(32);
  static final displayS = _archivo(30);
  static final title = _archivo(22);
  static final button = _archivo(18, letterSpacing: 18 * 0.05);
  static final buttonS = _archivo(15);
  static final answer = _archivo(17);
  static final caption = _archivo(11, letterSpacing: 11 * 0.08);

  // Nunito — body copy
  static final body = _nunito(15, FontWeight.w700);
  static final meta = _nunito(14, FontWeight.w700);

  // Press Start 2P — pixel numerals only (streak, score, countdown, puzzle #)
  static final pixelNumeral = _pressStart(22);
  static final pixelNumeralM = _pressStart(14);
  static final pixelNumeralS = _pressStart(10);

  // Alias for the results score display
  static final score = displayL;
}
