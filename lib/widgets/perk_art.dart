import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/tokens.dart';

const superCrushStarAsset = 'assets/images/supercrush_star.png';
const boostBoltAsset = 'assets/images/boost_bolt.png';

/// A perk's ruby artwork (SuperCrush star, Boost bolt), fitted into a [size] square.
class PerkArt extends StatelessWidget {
  final String asset; final double size;
  const PerkArt(this.asset, {super.key, this.size = 24});
  @override
  Widget build(BuildContext context) => Image.asset(asset, width: size, height: size,
      fit: BoxFit.contain, filterQuality: FilterQuality.medium, excludeFromSemantics: true);
}

/// The artwork, alive: a slow sway and breath, a pulsing ruby glow, a light glint
/// sweeping across the facets and a few twinkling sparkles. Holds still when the
/// system asks for reduced motion.
class LivePerkArt extends StatefulWidget {
  final String asset; final double size;
  const LivePerkArt(this.asset, {super.key, this.size = 160});
  @override
  State<LivePerkArt> createState() => _LivePerkArtState();
}

class _LivePerkArtState extends State<LivePerkArt> with SingleTickerProviderStateMixin {
  late final c = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();

  // (x, y) in the star's box (-1..1), size as a fraction of the star, phase offset.
  static const _sparkles = [(-.95, -.55, .16, 0.0), (.9, -.8, .11, .35), (1.0, .45, .14, .6), (-.8, .85, .1, .8)];

  @override
  void dispose() { c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    final still = MediaQuery.disableAnimationsOf(context);
    return SizedBox(width: s * 1.7, height: s * 1.7, child: AnimatedBuilder(animation: c, builder: (_, __) {
      final t = still ? 0.0 : c.value;
      final sway = math.sin(2 * math.pi * t), breath = .5 + .5 * math.sin(4 * math.pi * t);
      // The glint crosses once in the first ~30% of each cycle, then rests off the gem.
      final glint = t < .3 ? -1.2 + 2.4 * Curves.easeInOut.transform(t / .3) : 1.2;
      return Stack(alignment: Alignment.center, children: [
        Container(width: s * 1.6, height: s * 1.6, decoration: BoxDecoration(shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              AppColors.ruby.withValues(alpha: .22 + .14 * breath), AppColors.accent.withValues(alpha: .08),
              AppColors.accent.withValues(alpha: 0)], stops: const [0, .55, 1]))),
        for (final (x, y, f, phase) in _sparkles)
          Align(alignment: Alignment(x * .85, y * .85), child: _Sparkle(
              size: s * f, opacity: still ? .8 : (.5 + .5 * math.sin(2 * math.pi * (t * 2 + phase))).clamp(0, 1))),
        Transform.rotate(angle: .05 * sway, child: Transform.scale(scale: 1 + .035 * breath,
          child: ShaderMask(blendMode: BlendMode.srcATop,
            shaderCallback: (r) => LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: const [Color(0x00FFFFFF), Color(0x73FFFFFF), Color(0x00FFFFFF)], stops: const [.4, .5, .6],
                transform: _Slide(glint)).createShader(r),
            child: PerkArt(widget.asset, size: s)))),
      ]);
    }));
  }
}

/// Shifts a gradient diagonally by [f] of the box size.
class _Slide extends GradientTransform {
  final double f;
  const _Slide(this.f);
  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * f, bounds.height * f, 0);
}

/// Four-point twinkle that scales and fades with [opacity].
class _Sparkle extends StatelessWidget {
  final double size, opacity;
  const _Sparkle({required this.size, required this.opacity});
  @override
  Widget build(BuildContext context) => Opacity(opacity: opacity, child: Transform.scale(scale: .6 + .4 * opacity,
      child: CustomPaint(size: Size.square(size), painter: const _SparklePainter())));
}

class _SparklePainter extends CustomPainter {
  const _SparklePainter();
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height, cx = w / 2, cy = h / 2;
    final path = Path()
      ..moveTo(cx, 0)..quadraticBezierTo(cx, cy, w, cy)
      ..quadraticBezierTo(cx, cy, cx, h)..quadraticBezierTo(cx, cy, 0, cy)
      ..quadraticBezierTo(cx, cy, cx, 0)..close();
    canvas.drawPath(path, Paint()..shader = const RadialGradient(colors: [AppColors.card, AppColors.accent])
        .createShader(Offset.zero & size));
  }
  @override
  bool shouldRepaint(_SparklePainter old) => false;
}
