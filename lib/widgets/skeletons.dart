import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import 'profile_bits.dart';

/// Simulated fetch time for screens still backed by mock data.
const kMockLoadDelay = Duration(milliseconds: 900);

/// Shows [skeleton] until [load] completes, then cross-fades to [child].
/// Without a [load], it waits [kMockLoadDelay] to stand in for a network fetch.
class SkeletonLoader extends StatefulWidget {
  final Widget skeleton, child;
  final Future<void> Function()? load;
  const SkeletonLoader({super.key, required this.skeleton, required this.child, this.load});
  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}
class _SkeletonLoaderState extends State<SkeletonLoader> {
  bool loading = true;
  @override
  void initState() {
    super.initState();
    (widget.load ?? () => Future<void>.delayed(kMockLoadDelay))()
        .whenComplete(() { if (mounted) setState(() => loading = false); });
  }
  @override
  Widget build(BuildContext context) => AnimatedSwitcher(duration: AppDurations.base,
    layoutBuilder: (current, previous) => Stack(fit: StackFit.expand, children: [...previous, if (current != null) current]),
    child: loading
        ? KeyedSubtree(key: const ValueKey('skeleton'), child: SkeletonPulse(child: widget.skeleton))
        : KeyedSubtree(key: const ValueKey('content'), child: widget.child));
}

/// Drives one shared pulse for every [Skeleton] beneath it, so bones breathe in sync.
class SkeletonPulse extends StatefulWidget {
  final Widget child;
  const SkeletonPulse({super.key, required this.child});
  @override
  State<SkeletonPulse> createState() => _SkeletonPulseState();
}
class _SkeletonPulseState extends State<SkeletonPulse> with SingleTickerProviderStateMixin {
  late final c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat(reverse: true);
  late final opacity = Tween(begin: .45, end: 1.0).animate(CurvedAnimation(parent: c, curve: Curves.easeInOut));
  @override
  void dispose() { c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Semantics(label: 'Loading', container: true,
      child: ExcludeSemantics(child: _PulseScope(opacity, child: widget.child)));
}
class _PulseScope extends InheritedWidget {
  final Animation<double> opacity;
  const _PulseScope(this.opacity, {required super.child});
  @override
  bool updateShouldNotify(_PulseScope old) => old.opacity != opacity;
}

/// A placeholder bone. Pulses when inside a [SkeletonPulse] (or [SkeletonLoader]).
class Skeleton extends StatelessWidget {
  final double width, height, radius; final Color color;
  const Skeleton({super.key, this.width = double.infinity, this.height = 16, this.radius = AppRadius.small,
      this.color = AppColors.secondary});
  const Skeleton.circle(double size, {super.key, this.color = AppColors.secondary})
      : width = size, height = size, radius = AppRadius.pill;
  @override
  Widget build(BuildContext context) {
    final bone = Container(width: width, height: height, decoration: BoxDecoration(
        color: color, borderRadius: BorderRadius.circular(radius)));
    final pulse = context.dependOnInheritedWidgetOfExactType<_PulseScope>()?.opacity;
    return pulse == null ? bone : FadeTransition(opacity: pulse, child: bone);
  }
}

/// Discover: swipe card plus the action row beneath it.
class DiscoverSkeleton extends StatelessWidget {
  const DiscoverSkeleton({super.key});
  static const _onCard = AppColors.background;
  @override
  Widget build(BuildContext context) => Column(children: [
    Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      child: Stack(fit: StackFit.expand, children: [
        const Skeleton(height: double.infinity, radius: AppRadius.card),
        const Positioned(top: AppSpacing.md, left: AppSpacing.md,
            child: Skeleton(width: 72, height: 24, radius: AppRadius.pill, color: _onCard)),
        Positioned(left: AppSpacing.lg, right: AppSpacing.lg, bottom: AppSpacing.lg,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Skeleton(width: 160, height: 28, color: _onCard),
            const SizedBox(height: AppSpacing.sm),
            const Skeleton(width: 200, height: 14, color: _onCard),
            const SizedBox(height: AppSpacing.mdSm),
            Row(children: [for (final w in const [64.0, 80.0, 56.0]) Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: Skeleton(width: w, height: 28, radius: AppRadius.pill, color: _onCard))]),
          ])),
      ]))),
    Padding(padding: const EdgeInsets.all(AppSpacing.lg), child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [for (final s in const [48.0, 50.0, 50.0, 48.0]) Skeleton.circle(s)])),
  ]);
}

/// Matches (and Chats when [chatsOnly]): new-match avatars and conversation rows.
class MatchesSkeleton extends StatelessWidget {
  final bool chatsOnly;
  const MatchesSkeleton({super.key, this.chatsOnly = false});
  @override
  Widget build(BuildContext context) => ListView(physics: const NeverScrollableScrollPhysics(), children: [
    if (!chatsOnly) ...[
      const Padding(padding: EdgeInsets.symmetric(horizontal: AppSpacing.page), child: Skeleton(width: 110, height: 14)),
      const SizedBox(height: AppSpacing.mdSm),
      SizedBox(height: 100, child: ListView.separated(scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
        itemCount: 6, separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (_, __) => const Column(children: [
          Skeleton.circle(68), SizedBox(height: AppSpacing.sm), Skeleton(width: 44, height: 10)]))),
      const SizedBox(height: AppSpacing.lg),
      const Padding(padding: EdgeInsets.symmetric(horizontal: AppSpacing.page), child: Skeleton(width: 120, height: 14)),
    ],
    for (var i = 0; i < (chatsOnly ? 6 : 4); i++)
      const Padding(padding: EdgeInsets.symmetric(horizontal: AppSpacing.page, vertical: AppSpacing.mdSm),
        child: Row(children: [
          Skeleton.circle(52), SizedBox(width: AppSpacing.md),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Skeleton(width: 110, height: 14), SizedBox(height: AppSpacing.sm), Skeleton(height: 12)])),
          SizedBox(width: AppSpacing.md), Skeleton(width: 32, height: 10),
        ])),
  ]);
}

/// My profile: avatar, name, strength card, photos strip and about card.
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});
  @override
  Widget build(BuildContext context) => ListView(physics: const NeverScrollableScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.xl, AppSpacing.page, AppSpacing.page), children: [
      const Center(child: Skeleton.circle(128)),
      const SizedBox(height: AppSpacing.md),
      const Center(child: Skeleton(width: 150, height: 24)),
      const SizedBox(height: AppSpacing.sm),
      const Center(child: Skeleton(width: 100, height: 14)),
      const SizedBox(height: AppSpacing.xl),
      const AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Skeleton(width: 130, height: 18), SizedBox(height: AppSpacing.mdSm),
        Skeleton(height: 8, radius: AppRadius.pill), SizedBox(height: AppSpacing.sm),
        Skeleton(width: 220, height: 12)])),
      const SizedBox(height: AppSpacing.md),
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Skeleton(width: 100, height: 18), const SizedBox(height: AppSpacing.mdSm),
        Row(children: [for (var i = 0; i < 3; i++) const Padding(padding: EdgeInsets.only(right: AppSpacing.sm),
            child: Skeleton(width: 72, height: 96, radius: AppRadius.standardCard))]),
      ])),
      const SizedBox(height: AppSpacing.md),
      const AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Skeleton(width: 90, height: 18), SizedBox(height: AppSpacing.mdSm),
        Skeleton(height: 14), SizedBox(height: AppSpacing.sm),
        Skeleton(height: 14), SizedBox(height: AppSpacing.sm),
        Skeleton(width: 180, height: 14)])),
    ]);
}
