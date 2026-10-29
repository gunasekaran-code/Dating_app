import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import '../services/haptics.dart';
import '../l10n/match_text.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'perk_art.dart';

/// left = pass (−1), right = like (+1), up = SuperCrush.
enum SwipeDirection { left, right, up }

/// How the top card moves under the finger.
enum SwipeDeckStyle {
  /// Slides and tilts like a card held at the grab point.
  tilt,
  /// A cinematic drum: the cards sit around a turning cylinder, each one bent to its curve,
  /// with the next profiles waiting at the sides. A swipe turns the drum.
  cylinder,
}

/// A stack of cards swiped with a drag anywhere in the deck's area: left to pass,
/// right to like. The top card follows the finger (see [SwipeDeckStyle]), springs back
/// when released short, and flies out on a committed swipe or a quick flick.
/// [SwipeDeckState.swipe] and [SwipeDeckState.rewind] drive the same motion from buttons.
class SwipeDeck<T> extends StatefulWidget {
  final List<T> items;
  final Object Function(T) keyOf;
  final Widget Function(BuildContext, T) cardBuilder;
  /// Called once the top card has left; the owner should remove it from [items].
  final void Function(T item, SwipeDirection direction) onSwiped;
  final ValueChanged<T>? onTap;
  /// Live drag progress, −1 (pass) … +1 (like), for reacting UI such as buttons.
  final ValueNotifier<double>? progress;
  final SwipeDeckStyle style;
  const SwipeDeck({super.key, required this.items, required this.keyOf, required this.cardBuilder,
      required this.onSwiped, this.onTap, this.progress, this.style = SwipeDeckStyle.tilt});
  @override
  State<SwipeDeck<T>> createState() => SwipeDeckState<T>();
}

class SwipeDeckState<T> extends State<SwipeDeck<T>> with SingleTickerProviderStateMixin {
  static const _peek = 14.0, _visible = 3;
  /// Drum radius as a multiple of card width, the angle left between neighbouring cards,
  /// how many vertical strips each card is bent with, and the camera's perspective.
  static const _drumRadius = 1.1, _drumGap = .12, _strips = 18, _perspective = .0011;
  late final AnimationController _c;
  Size _size = Size.zero;
  Offset _offset = Offset.zero, _from = Offset.zero, _to = Offset.zero;
  double _grab = 1;
  bool _armed = false, _flying = false, _returning = false;
  SwipeDirection? _flyDir;
  /// SuperCrush badge strength (0..1) during the lift-then-launch.
  double _superStamp = 0;

  double get _p => _size.width == 0 ? 0 : (_offset.dx / (_size.width * .4)).clamp(-1.0, 1.0);
  double get _threshold => _size.width * .25;
  double get _upProgress => _flyDir == SwipeDirection.up ? _superStamp : 0;
  bool get _cylinder => widget.style == SwipeDeckStyle.cylinder;
  /// Where a card sits once it has left by the side: off screen for tilt, one drum step over for cylinder.
  Offset _sideExit(double dx, double dy) => _cylinder ? Offset(dx, 0) : Offset(dx, dy - 40);
  /// Angle between neighbouring cards on the drum.
  double get _step => 1 / _drumRadius + _drumGap;
  /// Drum turn under the top card: a full side exit turns it exactly one [_step].
  double get _turn => (_offset.dx / math.max(_size.width * 1.6, 1) * _step).clamp(-_step, _step);

  @override
  void initState() {
    super.initState();
    _c = AnimationController.unbounded(vsync: this)..addListener(_tick);
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  void _tick() {
    setState(() => _offset = Offset.lerp(_from, _to, _c.value)!);
    widget.progress?.value = _returning ? 0 : _p;
  }

  void _onStart(DragStartDetails d) {
    if (_flying || widget.items.isEmpty) return;
    _c.stop(); _returning = false;
    // Grabbed high, the card pivots like it hangs from your finger; grabbed low, it tips the other way.
    _grab = d.localPosition.dy < _size.height / 2 ? 1 : -1;
  }

  void _onUpdate(DragUpdateDetails d) {
    if (_flying || widget.items.isEmpty) return;
    // On the cylinder the card only turns about its vertical axis.
    setState(() => _offset += _cylinder ? Offset(d.delta.dx, 0) : d.delta);
    widget.progress?.value = _p;
    final armed = _offset.dx.abs() > _threshold;
    if (armed != _armed) {
      _armed = armed;
      if (armed) Haptics.selection();
    }
  }

  void _onEnd(DragEndDetails d) {
    if (_flying || widget.items.isEmpty) return;
    final v = d.velocity.pixelsPerSecond, dx = _offset.dx;
    SwipeDirection? dir;
    if (dx.abs() > _threshold) {
      dir = dx > 0 ? SwipeDirection.right : SwipeDirection.left;
    } else if (v.dx.abs() > 800 && v.dx.abs() > v.dy.abs()) {
      dir = v.dx > 0 ? SwipeDirection.right : SwipeDirection.left; // quick flick
    }
    dir == null ? _springBack() : _fly(dir, velocity: v);
  }

  void _springBack() {
    _armed = false;
    _from = _offset; _to = Offset.zero;
    _c.value = 0;
    _c.animateWith(SpringSimulation(
        SpringDescription.withDampingRatio(mass: 1, stiffness: 380, ratio: .72), 0, 1, 0));
  }

  /// Sends the top card off in [dir], as if swiped.
  Future<void> swipe(SwipeDirection dir) { _grab = 1; return _fly(dir); }

  Future<void> _fly(SwipeDirection dir, {Offset velocity = Offset.zero}) async {
    if (_flying || widget.items.isEmpty) return;
    _flying = true; _flyDir = dir; _returning = false;
    Haptics.light();
    final w = _size.width, h = _size.height;
    try {
      if (dir == SwipeDirection.up) {
        // A beat to lift the card and show the SuperCrush badge, then launch.
        _from = _offset; _to = _offset + const Offset(0, -28);
        _c.value = 0;
        final lift = _c.animateTo(1, duration: const Duration(milliseconds: 240), curve: Curves.easeOutCubic);
        void stamp() => _superStamp = _c.value.clamp(0.0, 1.0);
        _c.addListener(stamp);
        await lift.orCancel.whenComplete(() => _c.removeListener(stamp));
        _superStamp = 1;
      }
    } on TickerCanceled {
      return;
    }
    _from = _offset;
    _to = switch (dir) {
      SwipeDirection.right => _sideExit(w * 1.6, _offset.dy + velocity.dy * .12),
      SwipeDirection.left => _sideExit(-w * 1.6, _offset.dy + velocity.dy * .12),
      SwipeDirection.up => Offset(_offset.dx, -h * 1.3),
    };
    // A harder flick leaves faster; a SuperCrush accelerates away like a launch.
    final up = dir == SwipeDirection.up;
    final ms = up ? 380 : (340 - velocity.distance / 18).clamp(200, 340).round();
    _c.value = 0;
    try {
      await _c.animateTo(1, duration: Duration(milliseconds: ms),
          curve: up ? Curves.easeInCubic : Curves.easeOutCubic).orCancel;
    } on TickerCanceled {
      return; // interrupted (e.g. a rewind) — don't commit
    }
    if (!mounted) return;
    final item = widget.items.first;
    _flying = false; _flyDir = null; _armed = false; _superStamp = 0;
    _offset = Offset.zero;
    widget.progress?.value = 0;
    widget.onSwiped(item, dir);
    setState(() {});
  }

  /// Brings a re-inserted top card back in from the side it left by.
  void rewind(SwipeDirection leftBy) {
    _c.stop(); _flying = false; _flyDir = null; _returning = true; _superStamp = 0;
    final w = _size.width;
    _from = switch (leftBy) {
      SwipeDirection.right => _sideExit(w * 1.6, 0),
      SwipeDirection.left => _sideExit(-w * 1.6, 0),
      SwipeDirection.up => Offset(0, -_size.height * 1.3),
    };
    _to = Offset.zero; _offset = _from;
    _c.value = 0;
    _c.animateTo(1, duration: const Duration(milliseconds: 460), curve: Curves.easeOutBack)
        .whenCompleteOrCancel(() => _returning = false);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
    _size = Size(box.maxWidth, box.maxHeight - (_cylinder ? 0 : _peek * (_visible - 1)));
    final items = widget.items;
    // How far the top card has travelled (0..1); the cards behind rise by the same amount.
    final travel = _returning ? 0.0
        : math.max(_p.abs(), _upProgress).clamp(0.0, 1.0);
    final n = math.min(items.length, _visible);
    return GestureDetector(behavior: HitTestBehavior.opaque,
      onPanStart: _onStart, onPanUpdate: _onUpdate, onPanEnd: _onEnd,
      onTap: items.isEmpty || widget.onTap == null ? null : () {
        if (!_flying && _offset.distance < 4) widget.onTap!(items.first);
      },
      child: Stack(clipBehavior: Clip.none, children: _cylinder ? _drum(items) : [
        for (var i = n - 1; i >= 0; i--) _card(items[i], i, travel),
      ]));
  });

  /// The top card with the next profile on the side it will turn in from: dragging right (like)
  /// brings items[1] in from the left, dragging left from the right. At rest the top card is flat
  /// and alone; a swipe curves the deck into the drum, and it flattens again as the next card settles.
  List<Widget> _drum(List<T> items) {
    if (items.isEmpty) return const [];
    final step = _step, turn = _turn;
    // A SuperCrush lifts the top card off flat while the drum turns the next one in.
    final launch = _flyDir != SwipeDirection.up ? 0.0
        : ((-_offset.dy - 28) / math.max(_size.height * 1.3 - 28, 1)).clamp(0.0, 1.0);
    final spin = turn + step * launch, fromLeft = _offset.dx >= 0;
    // How far through one card's turn the drum is (0 at rest, 1 once the next card is in front).
    final t = (turn.abs() / step).clamp(0.0, 1.0), tn = (spin.abs() / step).clamp(0.0, 1.0);
    final bend = _bend(tn);
    final sides = [
      // Incoming: fades in as it turns toward the front.
      if (items.length > 1) (items[1], spin + (fromLeft ? -step : step), _ease(tn / .3)),
      // The one beyond it on the far side shows only while the drum is curved.
      if (items.length > 2) (items[2], spin + (fromLeft ? step : -step), bend * (1 - tn)),
    ]..sort((a, b) => b.$2.abs().compareTo(a.$2.abs()));
    return [
      for (final (item, angle, opacity) in sides)
        if (opacity > 0) _bentCard(item, angle, 0, bend: bend, opacity: opacity, top: false),
      _bentCard(items.first, turn, _offset.dy, bend: _bend(t), opacity: 1 - _ease((t - .6) / .4), top: true),
    ];
  }

  /// Drum curvature (0 flat … 1 full) for turn progress [t]: it curls up as a swipe starts and
  /// relaxes as the next card settles in front.
  static double _bend(double t) => _ease(math.min(math.min(t / .15, (1 - t) / .25), 1));
  static double _ease(double x) => Curves.easeInOut.transform(x.clamp(0.0, 1.0));

  /// [item] on the drum with its centre at [angle] (0 = front). With [bend] above 0 the card is
  /// drawn as vertical strips, each placed and turned on a cylinder of radius [_drumRadius] / [bend],
  /// so the image curves smoothly; at 0 it is the plain flat card.
  Widget _bentCard(T item, double angle, double dy,
      {required double bend, required double opacity, required bool top}) {
    final w = _size.width, r = w * _drumRadius, sw = w / _strips;
    // Positions are measured along the surface, so a card keeps its place as the curve relaxes.
    final arc = angle * r, k = bend / r;
    // Light falls from the front; the face darkens as it curves away.
    double shade(double a) => (.62 * (1 - math.cos(a))).clamp(0.0, .85);
    final face = ClipRRect(borderRadius: BorderRadius.circular(AppRadius.card), child: Stack(fit: StackFit.expand, children: [
      widget.cardBuilder(context, item),
      if (bend > 0) IgnorePointer(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(colors: [
        for (var j = 0; j <= 8; j++) Colors.black.withValues(alpha: shade((arc + (j / 8 - .5) * w) * k)),
      ])))),
      if (top && !_returning) _Overlays(p: _p, up: _upProgress),
    ]));
    // Surface position and drum angle of each strip's centre; strips turned past edge-on face away.
    final arcs = [for (var i = 0; i < _strips; i++) arc + (i + .5) * sw - w / 2];
    final card = bend == 0 ? Transform.translate(offset: Offset(arc, dy), child: face) : Stack(fit: StackFit.expand, children: [
      for (var i = 0; i < _strips; i++)
        if ((arcs[i] * k).abs() < math.pi / 2) Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, _perspective)
            ..translateByDouble(math.sin(arcs[i] * k) / k, dy, (1 - math.cos(arcs[i] * k)) / k, 1)
            // Turn the strip to lie tangent to the drum (rotateY's +angle swings the right edge
            // toward the viewer, so the drum's curve away needs −angle).
            ..rotateY(-arcs[i] * k)
            ..translateByDouble(w / 2 - (i + .5) * sw, 0, 0, 1),
          // Strips overlap by a pixel so no seams show between them.
          child: ClipRect(clipper: _Slice(i * sw - .5, sw + 1), child: face)),
    ]);
    return Positioned(key: ValueKey(widget.keyOf(item)), left: 0, right: 0, top: 0, height: _size.height,
      child: IgnorePointer(ignoring: !top, child: opacity >= 1 ? card : Opacity(opacity: opacity.clamp(0.0, 1.0), child: card)));
  }

  Widget _card(T item, int index, double travel) {
    final top = index == 0;
    final level = top ? 0.0 : index - travel;
    final m = Matrix4.identity();
    if (top) {
      m
        ..translateByDouble(_offset.dx, _offset.dy, 0, 1)
        ..rotateZ(_grab * (_offset.dx / math.max(_size.width, 1)) * .32);
    } else {
      final s = 1 - .05 * level;
      m
        ..translateByDouble(0, _peek * level, 0, 1)
        ..scaleByDouble(s, s, 1, 1);
    }
    return Positioned(key: ValueKey(widget.keyOf(item)), left: 0, right: 0, top: 0, height: _size.height,
      child: IgnorePointer(ignoring: !top, child: Transform(transform: m, alignment: Alignment.center,
        child: DecoratedBox(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.card), boxShadow: [
            BoxShadow(color: AppColors.text.withValues(alpha: top ? .10 + .12 * travel : .06),
                blurRadius: top ? 24 + 16 * travel : 16, offset: Offset(0, top ? 10 + 8 * travel : 6)),
          ]),
          child: ClipRRect(borderRadius: BorderRadius.circular(AppRadius.card), child: Stack(fit: StackFit.expand, children: [
            widget.cardBuilder(context, item),
            if (top && !_returning) _Overlays(p: _p, up: _upProgress),
          ]))))));
  }
}

/// A full-height vertical slice of a card, from [left] and [width] wide.
class _Slice extends CustomClipper<Rect> {
  final double left, width;
  const _Slice(this.left, this.width);
  @override
  Rect getClip(Size size) => Rect.fromLTWH(left, 0, width, size.height);
  @override
  bool shouldReclip(_Slice old) => old.left != left || old.width != width;
}

/// Edge tint + LIKE / NOPE / SUPERCRUSH stamps that fade in with the swipe.
class _Overlays extends StatelessWidget {
  final double p, up;
  const _Overlays({required this.p, required this.up});
  @override
  Widget build(BuildContext context) {
    final like = p.clamp(0.0, 1.0), nope = (-p).clamp(0.0, 1.0);
    final l = context.l10n;
    return IgnorePointer(child: Stack(fit: StackFit.expand, children: [
      if (like > 0) DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
          begin: Alignment.centerRight, end: Alignment.centerLeft,
          colors: [AppColors.ruby.withValues(alpha: .45 * like), AppColors.ruby.withValues(alpha: 0)]))),
      if (nope > 0) DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
          begin: Alignment.centerLeft, end: Alignment.centerRight,
          colors: [AppColors.text.withValues(alpha: .5 * nope), AppColors.text.withValues(alpha: 0)]))),
      if (up > 0) DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
          begin: Alignment.bottomCenter, end: Alignment.topCenter,
          colors: [AppColors.primary.withValues(alpha: .45 * up), AppColors.primary.withValues(alpha: 0)]))),
      Positioned(top: AppSpacing.xxl, left: AppSpacing.lg, child: _Stamp(t: like, angle: -.22,
        label: l.stampLike, fg: AppColors.onPrimary, border: AppColors.onPrimary,
        gradient: const [AppColors.accent, AppColors.ruby],
        leading: const Icon(Icons.favorite_rounded, size: 20, color: AppColors.onPrimary))),
      Positioned(top: AppSpacing.xxl, right: AppSpacing.lg, child: _Stamp(t: nope, angle: .22,
        label: l.stampNope, fg: AppColors.text, border: AppColors.glassBorder,
        gradient: const [AppColors.glassStrong, AppColors.glassStrong],
        leading: const Icon(Icons.close_rounded, size: 20, color: AppColors.text))),
      Align(alignment: const Alignment(0, .35), child: _Stamp(t: up, angle: 0,
        label: 'SUPERCRUSH', fg: AppColors.primary, border: AppColors.glassBorder,
        gradient: const [AppColors.glassStrong, AppColors.glassStrong],
        leading: const PerkArt(superCrushStarAsset, size: 26))),
    ]));
  }
}

class _Stamp extends StatelessWidget {
  final double t, angle; final String label; final Color fg, border;
  final List<Color> gradient; final Widget leading;
  const _Stamp({required this.t, required this.angle, required this.label, required this.fg,
      required this.border, required this.gradient, required this.leading});
  @override
  Widget build(BuildContext context) {
    if (t <= 0) return const SizedBox.shrink();
    final e = Curves.easeOut.transform(t);
    return Opacity(opacity: e, child: Transform.rotate(angle: angle, child: Transform.scale(scale: .8 + .2 * e,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.pill),
          gradient: LinearGradient(colors: gradient), border: Border.all(color: border, width: 2),
          boxShadow: AppShadows.elevated),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          leading, const SizedBox(width: AppSpacing.sm),
          Text(label, style: AppText.h4.copyWith(color: fg, letterSpacing: 2)),
        ])))));
  }
}
