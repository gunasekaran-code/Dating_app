import 'package:flutter/material.dart';
import '../services/haptics.dart';
import '../data/mock.dart';
import '../data/perks_store.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import '../widgets/buttons.dart';
import '../widgets/gold_border.dart';
import '../widgets/price_option_tile.dart';
import '../widgets/profile_bits.dart';
import '../widgets/states.dart';
import '../widgets/perk_art.dart';

class Benefit {
  final IconData icon; final String label;
  /// Artwork shown instead of [icon].
  final String? image;
  const Benefit(this.icon, this.label, {this.image});
}

const premiumBenefits = [
  Benefit(Icons.visibility_outlined, 'See who likes your profile'),
  Benefit(Icons.all_inclusive_rounded, 'Send unlimited likes'),
  Benefit(Icons.star_rounded, '5 free SuperCrushes every day', image: superCrushStarAsset),
  Benefit(Icons.tune_rounded, 'Refine your search criteria'),
  Benefit(Icons.replay_rounded, 'Unlimited Rewinds'),
  Benefit(Icons.block_rounded, 'No ads'),
];

const supremeBenefits = [
  Benefit(Icons.bolt_rounded, '3 free Boosts per month', image: boostBoltAsset),
  Benefit(Icons.luggage_outlined, 'Travel Mode unlimited'),
  Benefit(Icons.favorite_rounded, 'Priority Likes'),
];

enum PlanTier {
  premium('Premium', 'Send unlimited Likes and see who Likes you', AppColors.primary,
      [AppColors.accent, AppColors.primary], premiumPlans, Icons.favorite_rounded),
  supreme('Supreme', 'Boost visibility. Get more dates.', Color(0xFF916B2A),
      GoldPriceCard.defaultGradient, supremePlans, Icons.workspace_premium_rounded);

  final String label, headline; final Color color; final List<Color> gradient;
  final List<PlanOption> plans; final IconData icon;
  const PlanTier(this.label, this.headline, this.color, this.gradient, this.plans, this.icon);
}

/// Subscription picker: Premium / Supreme toggle, plan lengths, benefits, subscribe button.
class PlansScreen extends StatefulWidget {
  final PlanTier initial;
  const PlansScreen({super.key, this.initial = PlanTier.premium});
  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  late PlanTier tier = widget.initial;
  int selected = popularPackIndex;
  bool loading = false;
  final scroll = ScrollController();

  PlanOption get plan => tier.plans[selected];
  static String _months(int n) => n == 1 ? 'month' : 'months';

  @override
  void dispose() { scroll.dispose(); super.dispose(); }

  void _setTier(PlanTier t) {
    if (t == tier) return;
    Haptics.selection();
    setState(() => tier = t);
    if (scroll.hasClients && scroll.offset > 0) {
      scroll.animateTo(0, duration: AppDurations.slow, curve: Curves.easeOutCubic);
    }
  }

  void _select(int i) {
    if (i == selected) return;
    Haptics.selection();
    setState(() => selected = i);
  }

  String _tag(int i) {
    if (i == popularPackIndex) return 'Popular';
    if (i == 0) return 'Standard';
    final save = ((1 - tier.plans[i].monthly / tier.plans.first.monthly) * 100).round();
    return 'Save $save%';
  }

  Future<void> _subscribe() async {
    setState(() => loading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    showToast(context, 'Welcome to Amour ${tier.label}!', type: ToastType.success);
    Navigator.pop(context);
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.xl, bottom: AppSpacing.mdSm),
    child: Text(title, style: AppText.h4));

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Our Plans')),
    body: ListView(controller: scroll,
      padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.sm, AppSpacing.page, AppSpacing.xl), children: [
      _TierToggle(tier: tier, onChanged: _setTier),
      const SizedBox(height: AppSpacing.md),
      AnimatedSwitcher(duration: AppDurations.slow, child: _Hero(tier, key: ValueKey(tier))),
      _section('Choose your plan'),
      IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        for (var i = 0; i < tier.plans.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.sm),
          Expanded(child: PriceOptionTile(tag: _tag(i), amount: '${tier.plans[i].months}',
            unit: _months(tier.plans[i].months), price: formatRupees(tier.plans[i].price),
            caption: tier.plans[i].months > 1 ? '${formatRupees(tier.plans[i].monthly)}/month' : null,
            color: tier.color, selected: i == selected, onTap: () => _select(i))),
        ],
      ])),
      _section('${tier.label} benefits'),
      AnimatedSwitcher(duration: AppDurations.slow,
        transitionBuilder: (c, a) => FadeTransition(opacity: a, child: SizeTransition(sizeFactor: a, child: c)),
        child: tier == PlanTier.premium
            ? Column(key: const ValueKey('premium'), children: [
                _BenefitsCard(tier: tier, benefits: premiumBenefits),
                const SizedBox(height: AppSpacing.md),
                _BenefitsCard(tier: PlanTier.supreme, benefits: supremeBenefits, locked: true,
                    title: 'Upgrade and boost your visibility',
                    footer: AppButton('View Supreme Benefits', variant: AppButtonVariant.secondary, expanded: false,
                        onPressed: () => _setTier(PlanTier.supreme))),
              ])
            : Column(key: const ValueKey('supreme'), children: [
                _SupremePerksCard(tier: tier),
                const SizedBox(height: AppSpacing.md),
                _BenefitsCard(tier: tier, benefits: premiumBenefits, title: 'Includes all Premium benefits'),
              ])),
      const SizedBox(height: AppSpacing.xl),
      Text('By paying, you agree to our Terms & Conditions. Your subscription auto-renews at the same '
          'price and duration unless cancelled in your app store settings.',
          style: AppText.bodySmall, textAlign: TextAlign.center),
    ]),
    bottomNavigationBar: SafeArea(child: Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.sm, AppSpacing.page, AppSpacing.md),
      child: AppButton('Get ${plan.months} ${_months(plan.months)} for ${formatRupees(plan.price)}',
          color: tier.color, icon: tier.icon, loading: loading, onPressed: _subscribe))),
  );
}

/// Glass segmented control with a sliding, tier-coloured thumb.
class _TierToggle extends StatelessWidget {
  final PlanTier tier; final ValueChanged<PlanTier> onChanged;
  const _TierToggle({required this.tier, required this.onChanged});
  @override
  Widget build(BuildContext context) => Container(height: 48, padding: const EdgeInsets.all(AppSpacing.xs),
    decoration: BoxDecoration(color: AppColors.glass, borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.glassBorder)),
    child: Stack(children: [
      AnimatedAlign(duration: AppDurations.base, curve: Curves.easeOutCubic,
        alignment: tier == PlanTier.premium ? Alignment.centerLeft : Alignment.centerRight,
        child: FractionallySizedBox(widthFactor: .5, heightFactor: 1, child: AnimatedContainer(
          duration: AppDurations.base,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.pill),
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: tier.gradient),
            boxShadow: [BoxShadow(color: tier.color.withValues(alpha: .25), blurRadius: 12, offset: const Offset(0, 4))])))),
      Row(children: [
        for (final t in PlanTier.values) Expanded(child: Semantics(button: true, selected: t == tier, label: t.label,
          child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => onChanged(t),
            child: Center(child: AnimatedDefaultTextStyle(duration: AppDurations.base,
              style: AppText.labelLarge.copyWith(color: t == tier ? AppColors.onPrimary : AppColors.muted),
              child: Text(t.label)))))),
      ]),
    ]));
}

/// Photo banner: two profiles behind a tier-tinted scrim with the tier's headline.
class _Hero extends StatelessWidget {
  final PlanTier tier;
  const _Hero(this.tier, {super.key});
  @override
  Widget build(BuildContext context) => ClipRRect(borderRadius: BorderRadius.circular(AppRadius.card),
    // Grows with its text (large accessibility sizes) instead of clipping it.
    child: ConstrainedBox(constraints: const BoxConstraints(minHeight: 180), child: Stack(alignment: Alignment.center, children: [
      Positioned.fill(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Expanded(child: AppImage(profiles[0].photos.first)),
        Expanded(child: AppImage(profiles[1].photos.first)),
      ])),
      Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [tier.gradient.last.withValues(alpha: .35), const Color(0xD9241C1E)])))),
      Padding(padding: const EdgeInsets.all(AppSpacing.lg), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.mdSm, vertical: AppSpacing.xs),
          decoration: BoxDecoration(color: const Color(0x33FFFFFF), borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: const Color(0x66FFFFFF))),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(tier.icon, size: 14, color: tier.gradient.first),
            const SizedBox(width: AppSpacing.xs),
            Text('AMOUR ${tier.label.toUpperCase()}', style: AppText.labelSmall.copyWith(color: AppColors.onPrimary,
                letterSpacing: 1.2)),
          ])),
        const SizedBox(height: AppSpacing.mdSm),
        Text(tier.headline, textAlign: TextAlign.center,
            style: AppText.displaySmall.copyWith(color: AppColors.onPrimary, fontSize: 24, height: 1.25)),
      ])),
    ])));
}

/// Tinted rounded square with the benefit's icon or artwork.
class _BenefitIcon extends StatelessWidget {
  final Benefit benefit; final Color color;
  const _BenefitIcon(this.benefit, this.color);
  @override
  Widget build(BuildContext context) => Container(width: 34, height: 34, alignment: Alignment.center,
    decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(10)),
    child: benefit.image != null
        ? Image.asset(benefit.image!, width: 24, height: 24, filterQuality: FilterQuality.medium)
        : Icon(benefit.icon, size: 18, color: color));
}

class _BenefitsCard extends StatelessWidget {
  final PlanTier tier; final List<Benefit> benefits; final String? title; final bool locked; final Widget? footer;
  const _BenefitsCard({required this.tier, required this.benefits, this.title, this.locked = false, this.footer});
  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (title != null) Padding(padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.xs),
          child: Text(title!, style: AppText.h4)),
      for (var i = 0; i < benefits.length; i++) ...[
        if (i > 0) const Divider(indent: 50),
        Padding(padding: const EdgeInsets.symmetric(vertical: AppSpacing.mdSm), child: Row(children: [
          Opacity(opacity: locked ? .45 : 1, child: _BenefitIcon(benefits[i], tier.color)),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(benefits[i].label, style: AppText.bodyLarge.copyWith(
              color: locked ? AppColors.muted : AppColors.text))),
          if (locked) const Icon(Icons.lock_rounded, size: 16, color: AppColors.muted),
        ])),
      ],
      if (footer != null) Padding(padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.sm),
          child: Center(child: footer)),
    ]));
}

/// Supreme-only perks, each shown on a profile photo with the perk's badge.
class _SupremePerksCard extends StatelessWidget {
  final PlanTier tier;
  const _SupremePerksCard({required this.tier});
  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
    child: Column(children: [
      for (var i = 0; i < supremeBenefits.length; i++) ...[
        if (i > 0) const Divider(indent: 72),
        Padding(padding: const EdgeInsets.symmetric(vertical: AppSpacing.mdSm), child: Row(children: [
          Stack(clipBehavior: Clip.none, children: [
            ClipRRect(borderRadius: BorderRadius.circular(AppRadius.standardCard),
                child: AppImage(profiles[(i + 2) % profiles.length].photos.first, width: 52, height: 52)),
            Positioned(right: -6, bottom: -6, child: Container(width: 24, height: 24,
              // Artwork sits on white so the ruby reads; icons sit on the tier gradient.
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.card, width: 2),
                  color: AppColors.card,
                  gradient: supremeBenefits[i].image != null ? null
                      : LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: tier.gradient)),
              child: supremeBenefits[i].image != null
                  ? Padding(padding: const EdgeInsets.all(2), child: PerkArt(supremeBenefits[i].image!))
                  : Icon(supremeBenefits[i].icon, size: 12, color: AppColors.onPrimary))),
          ]),
          const SizedBox(width: AppSpacing.lg),
          Expanded(child: Text(supremeBenefits[i].label, style: AppText.labelLarge.copyWith(fontSize: 16))),
        ])),
      ],
    ]));
}
