import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/haptics.dart';
import '../data/mock.dart';
import '../data/perks_store.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import '../widgets/buttons.dart';
import '../widgets/perk_card.dart';
import '../widgets/price_option_tile.dart';
import '../widgets/profile_bits.dart';
import '../widgets/states.dart';
import '../widgets/perk_art.dart';
import 'plans_screen.dart';

/// Pack picker for SuperCrushes or Boosts: hero, three price cards, buy button.
class PerkPurchaseScreen extends StatefulWidget {
  final PerkKind kind;
  const PerkPurchaseScreen({super.key, required this.kind});
  @override
  State<PerkPurchaseScreen> createState() => _PerkPurchaseScreenState();
}

class _PerkPurchaseScreenState extends State<PerkPurchaseScreen> {
  int selected = popularPackIndex;
  bool loading = false;

  PerkKind get kind => widget.kind;
  PerkPack get pack => kind.packs[selected];

  void _select(int i) {
    if (i == selected) return;
    Haptics.selection();
    setState(() => selected = i);
  }

  Future<void> _buy() async {
    setState(() => loading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    kind.add(pack.quantity);
    showToast(context, '${pack.quantity} ${kind.unitFor(pack.quantity)} added', type: ToastType.success);
    Navigator.pop(context);
  }

  Widget _packTile(int i) {
    final p = kind.packs[i];
    return PriceOptionTile(tag: p.tag, amount: '${p.quantity}', unit: kind.unitFor(p.quantity),
        price: formatRupees(p.price), caption: p.quantity > 1 ? '${formatRupees(p.unitPrice)} each' : null,
        selected: i == selected, onTap: () => _select(i));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: ListView(padding: const EdgeInsets.fromLTRB(AppSpacing.page, 0, AppSpacing.page, AppSpacing.xl), children: [
      _FloatingHero(child: kind == PerkKind.superCrush ? const LivePerkArt(superCrushStarAsset, size: 140) : const _BoostHero()),
      const SizedBox(height: AppSpacing.xl),
      Text(kind.title, style: AppText.displaySmall, textAlign: TextAlign.center),
      const SizedBox(height: AppSpacing.sm),
      Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Text(kind.subtitle, style: AppText.bodyLarge.copyWith(color: AppColors.muted), textAlign: TextAlign.center)),
      const SizedBox(height: AppSpacing.xxl),
      IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        for (var i = 0; i < kind.packs.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.sm),
          Expanded(child: _packTile(i)),
        ],
      ])),
      const SizedBox(height: AppSpacing.lg),
      Text(kind.note, style: AppText.bodySmall, textAlign: TextAlign.center),
    ]),
    bottomNavigationBar: SafeArea(child: Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.sm, AppSpacing.page, AppSpacing.md),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        AppButton('Get ${pack.quantity} ${kind.unitFor(pack.quantity)} · ${formatRupees(pack.price)}',
            icon: kind.icon, loading: loading, onPressed: _buy,
            leading: kind.image == null ? null : PerkArt(kind.image!, size: 24)),
        const SizedBox(height: AppSpacing.mdSm),
        AppButton(kind.upgrade, variant: AppButtonVariant.secondary, onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => PlansScreen(
                initial: kind == PerkKind.superCrush ? PlanTier.premium : PlanTier.supreme)))),
      ]))),
  );
}

/// Gently bobs its child up and down after popping in.
class _FloatingHero extends StatefulWidget {
  final Widget child;
  const _FloatingHero({required this.child});
  @override
  State<_FloatingHero> createState() => _FloatingHeroState();
}
class _FloatingHeroState extends State<_FloatingHero> with SingleTickerProviderStateMixin {
  late final c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))..repeat(reverse: true);
  @override
  void dispose() { c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => SizedBox(height: 240, child: TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1), duration: AppDurations.slow * 1.5, curve: Curves.easeOutBack,
    builder: (_, v, child) => Opacity(opacity: v.clamp(0, 1), child: Transform.scale(scale: .8 + .2 * v, child: child)),
    child: AnimatedBuilder(animation: c,
      builder: (_, child) => Transform.translate(
          offset: Offset(0, 6 * math.sin(Curves.easeInOut.transform(c.value) * math.pi - math.pi / 2)), child: child),
      child: widget.child)));
}

class _BoostHero extends StatelessWidget {
  const _BoostHero();
  @override
  Widget build(BuildContext context) {
    Widget photo(int i, double x, double y, double angle, double w) => Align(alignment: Alignment(x, y),
      child: Transform.rotate(angle: angle, child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.standardCard + 3),
            border: Border.all(color: AppColors.card, width: 3), boxShadow: AppShadows.elevated),
        child: ClipRRect(borderRadius: BorderRadius.circular(AppRadius.standardCard),
            child: AppImage(profiles[i % profiles.length].photos.first, width: w, height: w * 1.25)))));
    return Stack(children: [
      photo(0, -.85, -.75, -.14, 78),
      photo(1, .85, -.65, .12, 72),
      photo(2, -.6, .9, .1, 64),
      photo(3, .65, .95, -.08, 68),
      const Center(child: LivePerkArt(boostBoltAsset, size: 150)),
    ]);
  }
}
