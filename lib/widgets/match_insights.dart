import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data/match_engine.dart';
import '../data/mock.dart';
import '../l10n/match_text.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'buttons.dart';
import 'profile_bits.dart';
import 'states.dart';

/// Circular compatibility gauge; the arc fills to [score]% and animates when it changes.
class MatchScoreRing extends StatelessWidget {
  final int score; final double size;
  const MatchScoreRing(this.score, {super.key, this.size = 76});
  @override
  Widget build(BuildContext context) => Semantics(label: context.l10n.percentMatch(score), child: TweenAnimationBuilder<double>(
    tween: Tween(end: score / 100), duration: AppDurations.slow, curve: Curves.easeOutCubic,
    builder: (_, v, __) => CustomPaint(painter: _RingPainter(v), child: SizedBox.square(dimension: size,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('${(v * 100).round()}%', style: AppText.h3.copyWith(color: AppColors.primary, fontSize: size * .26, height: 1)),
        if (size >= 64) Text(context.l10n.ringMatch, maxLines: 1, style: AppText.labelSmall.copyWith(color: AppColors.muted)),
      ])))));
}

class _RingPainter extends CustomPainter {
  final double value;
  const _RingPainter(this.value);
  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 7.0;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = stroke..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, paint..color = AppColors.secondary);
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * value, false, paint..shader = const SweepGradient(
        colors: [AppColors.accent, AppColors.primary], transform: GradientRotation(-math.pi / 2)).createShader(rect));
  }
  @override
  bool shouldRepaint(_RingPainter old) => old.value != value;
}

class MatchReasonTile extends StatelessWidget {
  final MatchReason reason; final Profile profile;
  const MatchReasonTile(this.reason, this.profile, {super.key});
  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Container(width: 36, height: 36, decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
        child: Icon(reason.icon, size: 18, color: AppColors.primary)),
    const SizedBox(width: AppSpacing.mdSm),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(context.l10n.reasonTitle(reason), style: AppText.labelLarge),
      const SizedBox(height: 2),
      Text(context.l10n.reasonDetail(reason, profile), style: AppText.bodySmall),
    ])),
  ]);
}

/// Score ring, headline and the strongest reasons a profile fits the user. Rebuilds as
/// the engine learns. Use [WhyYouMatchCard] on a page or [showWhyYouMatch] for a sheet.
class WhyYouMatchPanel extends StatelessWidget {
  final Profile profile; final int maxReasons;
  const WhyYouMatchPanel(this.profile, {super.key, this.maxReasons = 4});
  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: matchEngine, builder: (context, _) {
    final m = matchEngine.insight(profile), l = context.l10n;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        MatchScoreRing(m.score),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l.whyYouMatch, style: AppText.h4),
          const SizedBox(height: 2),
          Text(l.matchLabelWith(l.matchLabel(m.score), profile.name),
              style: AppText.bodyMedium.copyWith(color: AppColors.primary)),
        ])),
      ]),
      const SizedBox(height: AppSpacing.md),
      if (m.reasons.isEmpty)
        Text(l.matchNoReasons, style: AppText.bodySmall)
      else
        for (final r in m.reasons.take(maxReasons))
          Padding(padding: const EdgeInsets.only(bottom: AppSpacing.mdSm), child: MatchReasonTile(r, profile)),
      const Divider(),
      const SizedBox(height: AppSpacing.sm),
      Row(children: [
        const Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.accent),
        const SizedBox(width: AppSpacing.xs),
        Expanded(child: Text(l.picksGetSmarter, style: AppText.bodySmall)),
      ]),
    ]);
  });
}

class WhyYouMatchCard extends StatelessWidget {
  final Profile profile;
  const WhyYouMatchCard(this.profile, {super.key});
  @override
  Widget build(BuildContext context) => AppCard(child: WhyYouMatchPanel(profile));
}

Future<void> showWhyYouMatch(BuildContext context, Profile p) => showModalBottomSheet(context: context,
  isScrollControlled: true,
  builder: (c) => SafeArea(child: ConstrainedBox(
    constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(c).height * .8),
    child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.md),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Avatar(p.photos.first, size: 44, online: p.online),
          const SizedBox(width: AppSpacing.mdSm),
          Expanded(child: Text(c.l10n.youAndName(p.name), style: AppText.h3, overflow: TextOverflow.ellipsis)),
          SaveProfileButton(p, background: AppColors.secondary),
        ]),
        const SizedBox(height: AppSpacing.lg),
        WhyYouMatchPanel(p, maxReasons: 6),
      ])))));

/// The strongest reason as one line, for the bottom of a dark photo card.
class MatchHighlight extends StatelessWidget {
  final MatchReason reason;
  const MatchHighlight(this.reason, {super.key});
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(reason.icon, size: 16, color: AppColors.accent),
    const SizedBox(width: AppSpacing.xs),
    Flexible(child: Text(context.l10n.reasonTitle(reason), maxLines: 1, overflow: TextOverflow.ellipsis,
        style: AppText.labelMedium.copyWith(color: AppColors.onPrimary))),
  ]);
}

/// Bookmark toggle. Saved profiles appear on the Saved screen and teach the engine.
class SaveProfileButton extends StatelessWidget {
  final Profile profile; final Color background; final double size;
  const SaveProfileButton(this.profile, {super.key, this.background = AppColors.glassStrong, this.size = 44});
  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: matchEngine, builder: (context, _) {
    final saved = matchEngine.isSaved(profile), l = context.l10n;
    return AppIconButton(saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
      tooltip: saved ? l.removeFromSaved : l.saveProfile, size: size, background: background,
      color: saved ? AppColors.primary : AppColors.text,
      onPressed: () => showToast(context, matchEngine.toggleSave(profile)
          ? l.savedToast(profile.name) : l.removedToast(profile.name), type: ToastType.success));
  });
}
