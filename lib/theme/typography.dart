import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tokens.dart';

class AppText {
  static TextStyle _serif(double s, double h, [FontWeight w = FontWeight.w600]) =>
      GoogleFonts.playfairDisplay(fontSize: s, height: h / s, fontWeight: w, color: AppColors.text);
  static TextStyle _sans(double s, double h, [FontWeight w = FontWeight.w400, Color c = AppColors.text]) =>
      GoogleFonts.dmSans(fontSize: s, height: h / s, fontWeight: w, color: c);

  static final displayLarge = _serif(36, 42);
  static final displayMedium = _serif(32, 38);
  static final displaySmall = _serif(28, 34);
  static final h1 = _sans(28, 34, FontWeight.w700);
  static final h2 = _sans(24, 30, FontWeight.w700);
  static final h3 = _sans(20, 26, FontWeight.w700);
  static final h4 = _sans(18, 24, FontWeight.w600);
  static final bodyLarge = _sans(16, 24);
  static final bodyMedium = _sans(14, 21);
  static final bodySmall = _sans(13, 19, FontWeight.w400, AppColors.muted);
  static final labelLarge = _sans(14, 20, FontWeight.w600);
  static final labelMedium = _sans(12, 18, FontWeight.w600);
  static final labelSmall = _sans(11, 16, FontWeight.w600);
  static final button = _sans(15, 20, FontWeight.w600);
}
