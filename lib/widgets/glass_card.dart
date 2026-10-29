import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import '../theme/glass_theme.dart';
import '../theme/tokens.dart';

/// Frosted-glass surface. Styling comes from [GlassTheme] on the app theme;
/// per-instance overrides are optional.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? radius, blur, width, height;
  final VoidCallback? onTap;
  const GlassCard({super.key, required this.child, this.padding = const EdgeInsets.all(AppSpacing.xl),
      this.radius, this.blur, this.width, this.height, this.onTap});

  @override
  Widget build(BuildContext context) {
    final g = GlassTheme.of(context);
    final r = BorderRadius.circular(radius ?? g.radius);
    final sigma = blur ?? g.blur;
    return Container(width: width, height: height,
      decoration: BoxDecoration(borderRadius: r,
          boxShadow: [BoxShadow(color: g.shadow, blurRadius: 30, offset: const Offset(0, 10))]),
      child: ClipRRect(borderRadius: r,
        child: BackdropFilter(filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: Material(type: MaterialType.transparency,
            child: InkWell(borderRadius: r, onTap: onTap,
              child: Ink(
                decoration: BoxDecoration(borderRadius: r,
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: g.fill),
                  border: Border.all(color: g.border, width: g.borderWidth)),
                child: Padding(padding: padding, child: child)))))));
  }
}

/// Theme background with soft colour blobs, so [GlassCard]s placed on it
/// actually look frosted.
class GlassBackground extends StatelessWidget {
  final Widget child;
  const GlassBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final b = GlassTheme.of(context).backdrop;
    Widget blob(Color c, double size) => IgnorePointer(child: Container(width: size, height: size,
        decoration: BoxDecoration(shape: BoxShape.circle,
            gradient: RadialGradient(colors: [c, c.withValues(alpha: 0)]))));
    return LayoutBuilder(builder: (context, box) {
      final w = box.maxWidth;
      return ColoredBox(color: AppColors.background, child: Stack(children: [
        if (b.isNotEmpty) Positioned(top: -w * .25, right: -w * .3, child: blob(b[0], w * 1.1)),
        if (b.length > 1) Positioned(top: box.maxHeight * .35, left: -w * .45, child: blob(b[1], w * 1.2)),
        if (b.length > 2) Positioned(bottom: -w * .35, right: -w * .25, child: blob(b[2], w)),
        Positioned.fill(child: child),
      ]));
    });
  }
}
