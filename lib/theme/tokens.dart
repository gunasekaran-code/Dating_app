import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF4D1821);
  static const primaryLight = Color(0xFFDEA6B3);
  static const background = Color(0xFFFFF8F6);
  static const card = Color(0xFFFFFFFF);
  static const secondary = Color(0xFFF3E4E5);
  static const accent = Color(0xFFC9828D);
  static const text = Color(0xFF241C1E);
  static const muted = Color(0xFF756B6D);
  static const success = Color(0xFF4CAF7A);
  static const error = Color(0xFFC94A4A);
  static const warning = Color(0xFFD99A45);
  static const info = Color(0xFF557A9A);
  static const border = Color(0xFFE8DCDD);
  static const disabledBg = Color(0xFFEFE9E9);
  static const disabledText = Color(0xFFA59A9C);
  static const onPrimary = Color(0xFFFFFFFF);
  static const like = Color(0xFFFD1D1D);
  static const unlike = Color(0xFFFD1D1D);
  /// Deep red of the SuperCrush gem, for its glow.
  static const ruby = Color(0xFFC8143A);
  /// Blue of the verified star badge (light → deep, for its gradient).
  static const verified = Color(0xFF2D7FE6);
  static const verifiedLight = Color(0xFF63B0FA);
  /// Translucent white surfaces that let the glass backdrop show through.
  static const glass = Color(0xB3FFFFFF);
  static const glassStrong = Color(0xE6FFFFFF);
  static const glassBorder = Color(0xCCFFFFFF);
}

class AppSpacing {
  static const xs = 4.0, sm = 8.0, mdSm = 12.0, md = 16.0, lg = 20.0, xl = 24.0,
      xxl = 32.0, xxxl = 40.0, section = 48.0, largeSection = 64.0;
  static const page = 16.0;
}

class AppRadius {
  static const small = 4.0, input = 14.0, button = pill, standardCard = 12.0,
      card = 20.0, sheet = 28.0, modal = 24.0, pill = 999.0;
}

class AppShadows {
  static const card = [BoxShadow(color: Color(0x0F241C1E), blurRadius: 20, offset: Offset(0, 4))];
  static const elevated = [BoxShadow(color: Color(0x1A241C1E), blurRadius: 30, offset: Offset(0, 8))];
}

/// Responsive layout: phones use the full width; on tablets and landscape, content
/// sits in a centred column of [maxContentWidth] over the full-bleed background.
class AppLayout {
  static const maxContentWidth = 640.0;
  static const tabBarMaxWidth = 460.0;
}

class AppDurations {
  static const fast = Duration(milliseconds: 150);
  static const base = Duration(milliseconds: 250);
  static const slow = Duration(milliseconds: 400);
}
