import 'package:flutter/material.dart';
import 'tokens.dart';

/// Glassmorphism styling, registered on [ThemeData.extensions] so every
/// [GlassCard] / [GlassBackground] in the app reads from one place.
@immutable
class GlassTheme extends ThemeExtension<GlassTheme> {
  /// Frosted fill, top-left → bottom-right.
  final List<Color> fill;
  final Color border, shadow;
  /// Soft colour blobs painted behind glass so the blur has something to frost.
  final List<Color> backdrop;
  final double blur, radius, borderWidth;

  const GlassTheme({required this.fill, required this.border, required this.shadow,
      required this.backdrop, this.blur = 18, this.radius = AppRadius.card, this.borderWidth = 1.2});

  static final light = GlassTheme(
    fill: [AppColors.card.withValues(alpha: .62), AppColors.card.withValues(alpha: .28)],
    border: AppColors.card.withValues(alpha: .7),
    shadow: AppColors.primary.withValues(alpha: .08),
    backdrop: [
      AppColors.accent.withValues(alpha: .55),
      AppColors.secondary,
      AppColors.primary.withValues(alpha: .35),
    ],
  );

  static GlassTheme of(BuildContext context) => Theme.of(context).extension<GlassTheme>() ?? light;

  @override
  GlassTheme copyWith({List<Color>? fill, Color? border, Color? shadow, List<Color>? backdrop,
      double? blur, double? radius, double? borderWidth}) => GlassTheme(
    fill: fill ?? this.fill, border: border ?? this.border, shadow: shadow ?? this.shadow,
    backdrop: backdrop ?? this.backdrop, blur: blur ?? this.blur, radius: radius ?? this.radius,
    borderWidth: borderWidth ?? this.borderWidth);

  @override
  GlassTheme lerp(GlassTheme? other, double t) {
    if (other == null) return this;
    List<Color> l(List<Color> a, List<Color> b) =>
        [for (var i = 0; i < a.length && i < b.length; i++) Color.lerp(a[i], b[i], t)!];
    return GlassTheme(
      fill: l(fill, other.fill), border: Color.lerp(border, other.border, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!, backdrop: l(backdrop, other.backdrop),
      blur: lerpDouble(blur, other.blur, t), radius: lerpDouble(radius, other.radius, t),
      borderWidth: lerpDouble(borderWidth, other.borderWidth, t));
  }

  static double lerpDouble(double a, double b, double t) => a + (b - a) * t;
}
