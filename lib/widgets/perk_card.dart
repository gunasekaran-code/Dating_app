import 'package:flutter/material.dart';
import '../data/perks_store.dart';
import '../screens/perk_purchase_screen.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'glass_card.dart';
import 'perk_art.dart';

/// The two purchasable perks, with everything their card and purchase screen show.
enum PerkKind {
  superCrush(
    icon: Icons.star_rounded, image: superCrushStarAsset, unit: 'SuperCrush', units: 'SuperCrushes',
    gradient: [AppColors.accent, AppColors.ruby], packs: superCrushPacks,
    cardTitle: 'My SuperCrushes', cardSubtitle: '5x more chances of finding a date',
    emptyCta: 'Get SuperCrushes',
    title: 'Get noticed with SuperCrush',
    subtitle: 'Really like a profile? Send them a SuperCrush and boost your chances of matching x5.',
    note: 'One-time purchase. SuperCrushes never expire.',
    upgrade: 'Upgrade to Amour Premium'),
  boost(
    icon: Icons.bolt_rounded, image: boostBoltAsset, unit: 'Boost', units: 'Boosts',
    gradient: [AppColors.accent, AppColors.ruby], packs: boostPacks,
    cardTitle: 'My Boosts', cardSubtitle: 'Your visibility will skyrocket for 24h',
    emptyCta: 'Get a Boost',
    title: 'Boost your profile',
    subtitle: 'Boost your visibility for 24h! You’ll appear first for people around you.',
    note: 'Each Boost lasts 24 hours. One-time purchase.',
    upgrade: 'Upgrade to Amour Supreme');

  final IconData icon; final List<Color> gradient; final List<PerkPack> packs;
  /// Artwork used instead of [icon] where it fits.
  final String? image;
  final String unit, units, cardTitle, cardSubtitle, emptyCta, title, subtitle, note, upgrade;
  const PerkKind({required this.icon, this.image, required this.unit, required this.units, required this.gradient,
      required this.packs, required this.cardTitle, required this.cardSubtitle, required this.emptyCta,
      required this.title, required this.subtitle, required this.note, required this.upgrade});

  String unitFor(int n) => n == 1 ? unit : units;
  int get balance => this == superCrush ? perks.superCrushes : perks.boosts;
  void add(int n) => this == superCrush ? perks.addSuperCrushes(n) : perks.addBoosts(n);
}

void openPerkPurchase(BuildContext context, PerkKind kind) =>
    Navigator.push(context, MaterialPageRoute(builder: (_) => PerkPurchaseScreen(kind: kind)));

/// Profile card showing a perk's balance; tapping opens its purchase screen.
class PerkCard extends StatelessWidget {
  final PerkKind kind;
  const PerkCard(this.kind, {super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: perks, builder: (context, _) {
    final n = kind.balance;
    return Semantics(button: true, label: '${kind.cardTitle}, $n left',
      child: GlassCard(onTap: () => openPerkPurchase(context, kind),
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.md, AppSpacing.lg),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(kind.cardTitle, style: AppText.h3),
            const SizedBox(height: AppSpacing.xs),
            Text(kind.cardSubtitle, style: AppText.bodyMedium.copyWith(color: AppColors.muted)),
            const SizedBox(height: AppSpacing.mdSm),
            AnimatedContainer(duration: AppDurations.base,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.mdSm, vertical: 6),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.pill),
                  color: n > 0 ? AppColors.secondary : AppColors.glassStrong,
                  border: Border.all(color: n > 0 ? AppColors.secondary : AppColors.glassBorder)),
              child: Text(n > 0 ? '$n ${kind.unitFor(n)} left' : kind.emptyCta,
                  style: AppText.labelMedium.copyWith(color: n > 0 ? AppColors.primary : AppColors.text))),
          ])),
          const SizedBox(width: AppSpacing.md),
          PerkBadge(kind),
        ])));
  });
}

/// The perk's artwork on a soft glow, or a gradient circle with its icon.
class PerkBadge extends StatelessWidget {
  final PerkKind kind; final double size;
  const PerkBadge(this.kind, {super.key, this.size = 64});
  @override
  Widget build(BuildContext context) => kind.image != null
    ? Container(width: size, height: size, alignment: Alignment.center,
        decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(
            colors: [kind.gradient.last.withValues(alpha: .22), kind.gradient.last.withValues(alpha: 0)])),
        child: Image.asset(kind.image!, width: size * .9, height: size * .9, filterQuality: FilterQuality.medium))
    : Container(width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle,
      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: kind.gradient),
      boxShadow: [BoxShadow(color: kind.gradient.last.withValues(alpha: .3), blurRadius: size * .4,
          offset: Offset(0, size * .12))]),
    child: Icon(kind.icon, size: size * .5, color: AppColors.onPrimary));
}
