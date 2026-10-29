import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';

class GoldPriceCard extends StatelessWidget {
  static const defaultGradient = [Color(0xFFEDDB8F), Color(0xFF916B2A)];

  final List<String> items;
  final String price;
  /// Null sizes to the parent's width / the content's height.
  final double? width, height;
  final double borderRadius, borderWidth;
  final List<Color> gradientColors;
  final Color background;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  const GoldPriceCard({super.key, required this.items, required this.price, this.width, this.height,
      this.borderRadius = 20, this.borderWidth = 1.5, this.gradientColors = defaultGradient,
      this.background = AppColors.card,
      this.padding = const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xxl),
      this.onTap});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    return SizedBox(width: width, height: height,
      child: CustomPaint(
        painter: _GradientBorderPainter(radius: borderRadius, width: borderWidth,
            colors: gradientColors, background: background),
        child: Material(type: MaterialType.transparency,
          child: InkWell(borderRadius: radius, onTap: onTap,
            child: Padding(padding: padding + EdgeInsets.all(borderWidth),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [for (final i in items) Text(i, style: AppText.h4)])),
                const SizedBox(width: AppSpacing.md),
                // Sits level with the middle of the item list, as in the design.
                Padding(padding: EdgeInsets.only(top: items.length > 1 ? AppText.h4.fontSize! * .6 : 0),
                    child: Text(price, style: AppText.h4)),
              ]))))));
  }
}

class _GradientBorderPainter extends CustomPainter {
  final double radius, width; final List<Color> colors; final Color background;
  const _GradientBorderPainter({required this.radius, required this.width, required this.colors,
      required this.background});

  @override
  void paint(Canvas canvas, Size size) {
    // Inset by half the stroke so the whole border stays inside the widget's bounds.
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect.deflate(width / 2), Radius.circular(radius - width / 2));
    canvas.drawRRect(rrect, Paint()..color = background);
    canvas.drawRRect(rrect, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: colors)
          .createShader(rect));
  }

  @override
  bool shouldRepaint(_GradientBorderPainter old) =>
      old.radius != radius || old.width != width || old.colors != colors || old.background != background;
}

class GradientBorderPainter extends CustomPainter {
  final double radius, width; final List<Color> colors; final Color background;
  const GradientBorderPainter({required this.radius, required this.width, required this.colors,
      required this.background});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect.deflate(width / 2), Radius.circular(radius - width / 2));
    canvas.drawRRect(rrect, Paint()..color = background);
    canvas.drawRRect(rrect, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: colors)
          .createShader(rect));
  }

  @override
  bool shouldRepaint(GradientBorderPainter old) =>
      old.radius != radius || old.width != width || old.colors != colors || old.background != background;
}