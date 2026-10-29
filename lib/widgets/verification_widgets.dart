import 'package:flutter/material.dart';
import '../data/profile_store.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'buttons.dart';
import 'photo_grid.dart';
import 'profile_bits.dart';

/// Shared layout for the verification pages: a top bar with back/close, scrolling
/// content, and actions pinned to the bottom.
class VerificationPage extends StatelessWidget {
  final List<Widget> children, actions;
  final Widget? child;
  final String? title;
  /// Shows a close (×) instead of a back chevron.
  final bool close;
  /// Hides the back/close button, e.g. while work is in progress.
  final bool showLeading;
  const VerificationPage({super.key, required this.children, this.actions = const [], this.title,
      this.close = false, this.showLeading = true}) : child = null;
  /// Non-scrolling variant: [child] fills the space between the top bar and the actions.
  const VerificationPage.fixed({super.key, required Widget this.child, this.actions = const [], this.title,
      this.close = false, this.showLeading = true}) : children = const [];

  @override
  Widget build(BuildContext context) => Scaffold(body: SafeArea(child: Column(children: [
    Padding(padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.sm, AppSpacing.sm, 0),
      child: SizedBox(height: 44, child: Stack(alignment: Alignment.center, children: [
        if (title != null) Text(title!, style: AppText.h4),
        if (showLeading) Align(alignment: Alignment.centerLeft, child: AppIconButton(
            close ? Icons.close_rounded : Icons.arrow_back_ios_new_rounded, tooltip: close ? 'Close' : 'Back',
            onPressed: () => Navigator.maybePop(context))),
      ]))),
    Expanded(child: child != null
        ? Padding(padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.md), child: child)
        : ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xl),
            children: children)),
    if (actions.isNotEmpty) Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.md),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        for (var i = 0; i < actions.length; i++) ...[if (i > 0) const SizedBox(height: AppSpacing.sm), actions[i]],
      ])),
  ])));
}

/// Large tinted circle holding an icon, with a soft glow — the visual anchor of a page.
class VerificationIcon extends StatelessWidget {
  final IconData? icon; final Widget? child; final Color color, background; final double size;
  const VerificationIcon({super.key, this.icon, this.child, this.color = AppColors.primary,
      this.background = AppColors.secondary, this.size = 112});
  @override
  Widget build(BuildContext context) => Center(child: Container(width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: background,
        border: Border.all(color: AppColors.glassBorder, width: 4),
        boxShadow: [BoxShadow(color: color.withValues(alpha: .22), blurRadius: 40, spreadRadius: 4)]),
    child: Center(child: child ?? Icon(icon, size: size * .44, color: color))));
}

/// The user's main photo in a ring, with the verified star (or an outlined star) on its edge.
class VerificationAvatar extends StatelessWidget {
  final double size; final bool verified;
  const VerificationAvatar({super.key, this.size = 128, this.verified = false});
  @override
  Widget build(BuildContext context) {
    final main = currentUser.photos.main;
    final star = size * .3;
    return Center(child: SizedBox(width: size + star * .3, height: size, child: Stack(clipBehavior: Clip.none, children: [
      Container(padding: const EdgeInsets.all(3), decoration: BoxDecoration(shape: BoxShape.circle,
          gradient: LinearGradient(colors: verified
              ? const [AppColors.verifiedLight, AppColors.verified]
              : const [AppColors.accent, AppColors.primary]),
          boxShadow: [BoxShadow(color: (verified ? AppColors.verified : AppColors.primary).withValues(alpha: .2),
              blurRadius: 30, offset: const Offset(0, 10))]),
        child: Container(padding: const EdgeInsets.all(3), decoration: const BoxDecoration(
            shape: BoxShape.circle, color: AppColors.card),
          child: ClipOval(child: main == null
              ? Container(width: size - 12, height: size - 12, color: AppColors.secondary,
                  child: Icon(Icons.person_rounded, size: size * .45, color: AppColors.accent))
              : PhotoImage(main, width: size - 12, height: size - 12)))),
      Positioned(right: 0, bottom: size * .02, child: Container(
        padding: const EdgeInsets.all(5),
        decoration: const BoxDecoration(color: AppColors.card, shape: BoxShape.circle, boxShadow: AppShadows.card),
        child: verified
            ? VerifiedBadge(size: star)
            : Icon(Icons.star_outline_rounded, size: star, color: AppColors.accent))),
    ])));
  }
}

/// Numbered "how it works" step.
class VerificationStep extends StatelessWidget {
  final int number; final String title, body;
  const VerificationStep(this.number, this.title, this.body, {super.key});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 32, height: 32, alignment: Alignment.center,
          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          child: Text('$number', style: AppText.labelLarge.copyWith(color: AppColors.onPrimary))),
      const SizedBox(width: AppSpacing.mdSm),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: AppText.labelLarge.copyWith(fontSize: 15)),
        const SizedBox(height: 2),
        Text(body, style: AppText.bodySmall),
      ])),
    ]));
}

/// Icon + text tip row.
class VerificationTip extends StatelessWidget {
  final IconData icon; final String text; final Color color;
  const VerificationTip(this.icon, this.text, {super.key, this.color = AppColors.accent});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      Icon(icon, size: 20, color: color),
      const SizedBox(width: AppSpacing.mdSm),
      Expanded(child: Text(text, style: AppText.bodyMedium)),
    ]));
}

/// Small lock-and-text privacy reassurance.
class VerificationPrivacyNote extends StatelessWidget {
  const VerificationPrivacyNote({super.key});
  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Icon(Icons.lock_outline_rounded, size: 16, color: AppColors.muted),
    const SizedBox(width: AppSpacing.sm),
    Expanded(child: Text('Your video is only used to confirm it’s you. It’s never shown on your profile '
        'and is deleted once verification is done.', style: AppText.bodySmall)),
  ]);
}
