import 'package:flutter/material.dart';
import '../data/icebreakers.dart';
import '../data/match_engine.dart';
import '../data/mock.dart';
import '../l10n/match_text.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'glass_card.dart';

/// One suggested opener: where it comes from ("You both love Hiking") and the line itself.
class IcebreakerCard extends StatelessWidget {
  final Icebreaker icebreaker; final VoidCallback onTap;
  const IcebreakerCard(this.icebreaker, {super.key, required this.onTap});
  @override
  Widget build(BuildContext context) => Semantics(button: true, label: context.l10n.useIcebreaker(icebreaker.text),
    child: GlassCard(onTap: onTap, radius: AppRadius.standardCard,
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.mdSm, AppSpacing.mdSm, AppSpacing.mdSm),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icebreaker.icon, size: 14, color: AppColors.accent),
            const SizedBox(width: AppSpacing.xs),
            Flexible(child: Text(icebreaker.label, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: AppText.labelSmall.copyWith(color: AppColors.muted))),
          ]),
          const SizedBox(height: AppSpacing.xs),
          Text(icebreaker.text, style: AppText.bodyMedium),
        ])),
        const SizedBox(width: AppSpacing.sm),
        const Icon(Icons.north_east_rounded, size: 18, color: AppColors.primary),
      ])));
}

/// Openers for a chat with [profile], drawn from "Why you match". [onPick] gets the line
/// so the composer can be filled for the user to edit before sending.
class IcebreakerPanel extends StatefulWidget {
  final Profile profile; final ValueChanged<String> onPick;
  const IcebreakerPanel({super.key, required this.profile, required this.onPick});
  @override
  State<IcebreakerPanel> createState() => _IcebreakerPanelState();
}

class _IcebreakerPanelState extends State<IcebreakerPanel> {
  int _variant = 0;
  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: matchEngine, builder: (context, _) {
    final l = context.l10n;
    final ideas = icebreakersFor(widget.profile, l, variant: _variant);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.lightbulb_outline_rounded, size: 18, color: AppColors.primary),
        const SizedBox(width: AppSpacing.xs),
        Expanded(child: Text(l.icebreakers, style: AppText.h4)),
        TextButton.icon(onPressed: () => setState(() => _variant++),
          icon: const Icon(Icons.shuffle_rounded, size: 16, color: AppColors.primary),
          label: Text(l.moreIdeas, style: AppText.labelMedium.copyWith(color: AppColors.primary))),
      ]),
      Text(l.icebreakersSubtitle, style: AppText.bodySmall),
      const SizedBox(height: AppSpacing.mdSm),
      AnimatedSwitcher(duration: AppDurations.base, child: Column(key: ValueKey(_variant), children: [
        for (final b in ideas) Padding(padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: IcebreakerCard(b, onTap: () => widget.onPick(b.text))),
      ])),
    ]);
  });
}

Future<void> showIcebreakers(BuildContext context, Profile p, ValueChanged<String> onPick) =>
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (c) => SafeArea(
      child: ConstrainedBox(constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(c).height * .75),
        child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.md),
          child: IcebreakerPanel(profile: p, onPick: (text) { Navigator.pop(c); onPick(text); })))));
