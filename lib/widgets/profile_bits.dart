import 'package:flutter/material.dart';
import '../l10n/match_text.dart';
import '../services/haptics.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'glass_card.dart';

class InterestChip extends StatelessWidget {
  final String label; final bool selected; final VoidCallback? onTap;
  const InterestChip(this.label, {super.key, this.selected = false, this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap == null ? null : () { Haptics.selection(); onTap!(); },
    child: AnimatedContainer(duration: AppDurations.fast,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.mdSm, vertical: 6),
      decoration: BoxDecoration(color: selected ? AppColors.primary : AppColors.secondary,
          borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Text(label, style: AppText.labelMedium.copyWith(
          color: selected ? AppColors.onPrimary : AppColors.primary))));
}

/// Blue verified tick — shown next to the name of profiles that passed selfie verification.
class VerifiedBadge extends StatelessWidget {
  final double size; final VoidCallback? onTap;
  const VerifiedBadge({super.key, this.size = 18, this.onTap});
  @override
  Widget build(BuildContext context) => Semantics(label: 'Verified profile', button: onTap != null,
      child: GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque,
          child: Icon(Icons.verified, size: size, color: const Color(0xFF3897F0))));
}

/// Outlined star pill shown next to the user's own name until they verify; opens verification.
class VerifyStarButton extends StatelessWidget {
  final VoidCallback onTap;
  const VerifyStarButton({super.key, required this.onTap});
  @override
  Widget build(BuildContext context) => Semantics(button: true, label: 'Verify your profile',
    child: GestureDetector(onTap: onTap, child: Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.xs, AppSpacing.mdSm, AppSpacing.xs),
      decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: AppColors.accent.withValues(alpha: .5))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.star_outline_rounded, size: 18, color: AppColors.primary),
        const SizedBox(width: AppSpacing.xs),
        Text(context.l10n.verify, style: AppText.labelMedium.copyWith(color: AppColors.primary)),
      ]))));
}

class OnlineDot extends StatelessWidget {
  const OnlineDot({super.key});
  @override
  Widget build(BuildContext context) => Semantics(label: 'Online',
    child: Container(width: 10, height: 10, decoration: BoxDecoration(color: AppColors.success,
        shape: BoxShape.circle, border: Border.all(color: AppColors.card, width: 2))));
}

class CompatibilityPill extends StatelessWidget {
  final int percent;
  /// Opens "Why you match"; shows an info icon when set.
  final VoidCallback? onTap;
  const CompatibilityPill(this.percent, {super.key, this.onTap});
  @override
  Widget build(BuildContext context) => Semantics(button: onTap != null, label: context.l10n.percentMatch(percent),
    child: GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(color: AppColors.glassStrong, borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.favorite_rounded, size: 14, color: AppColors.accent),
        const SizedBox(width: AppSpacing.xs),
        Text(context.l10n.percentMatch(percent), style: AppText.labelSmall.copyWith(color: AppColors.primary)),
        if (onTap != null) ...[const SizedBox(width: AppSpacing.xs),
          const Icon(Icons.info_outline_rounded, size: 13, color: AppColors.muted)],
      ]))));
}

class Avatar extends StatelessWidget {
  final String url; final double size; final bool online, ring;
  const Avatar(this.url, {super.key, this.size = 56, this.online = false, this.ring = false});
  @override
  Widget build(BuildContext context) => Stack(children: [
    Container(padding: EdgeInsets.all(ring ? 2 : 0),
      decoration: BoxDecoration(shape: BoxShape.circle,
          border: ring ? Border.all(color: AppColors.accent, width: 2) : null),
      child: ClipOval(child: AppImage(url, width: size, height: size))),
    if (online) const Positioned(right: 2, bottom: 2, child: OnlineDot()),
  ]);
}

class AppImage extends StatelessWidget {
  final String url; final double? width, height;
  const AppImage(this.url, {super.key, this.width, this.height});
  @override
  Widget build(BuildContext context) => Image.network(url, width: width, height: height, fit: BoxFit.cover,
    loadingBuilder: (c, w, p) => p == null ? w : Container(width: width, height: height, color: AppColors.secondary),
    errorBuilder: (c, e, s) => Container(width: width, height: height, color: AppColors.secondary,
        child: const Icon(Icons.person_rounded, color: AppColors.accent)));
}

/// Standard content card — a [GlassCard] with the app's default card padding.
class AppCard extends StatelessWidget {
  final Widget child; final EdgeInsets padding;
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(AppSpacing.md)});
  @override
  Widget build(BuildContext context) => GlassCard(padding: padding, child: child);
}
