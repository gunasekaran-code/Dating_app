import 'package:flutter/material.dart';
import '../data/match_engine.dart';
import '../data/mock.dart';
import '../l10n/match_text.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import '../widgets/buttons.dart';
import '../widgets/match_insights.dart';
import '../widgets/profile_bits.dart';
import '../widgets/states.dart';
import '../widgets/verification_widgets.dart';
import 'profile_detail_screen.dart';

/// Discover → Saved: bookmarked profiles, best match first, and what the engine has learned.
class SavedProfilesScreen extends StatelessWidget {
  const SavedProfilesScreen({super.key});

  Future<void> _resetLearning(BuildContext context) async {
    final l = context.l10n;
    if (!await showConfirmDialog(context, title: l.resetPicksTitle, message: l.resetPicksMessage,
        confirm: l.reset, destructive: true) || !context.mounted) { return; }
    matchEngine.resetLearning();
    showToast(context, l.picksReset);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: matchEngine, builder: (context, _) {
    final saved = matchEngine.rank(matchEngine.saved), l = context.l10n;
    return VerificationPage(title: l.saved, children: [
      _TasteCard(onReset: () => _resetLearning(context)),
      const SizedBox(height: AppSpacing.xl),
      Row(children: [
        Flexible(child: Text(l.savedProfiles, style: AppText.h4, overflow: TextOverflow.ellipsis)),
        const SizedBox(width: AppSpacing.sm),
        Text('${saved.length}', style: AppText.bodySmall),
      ]),
      const SizedBox(height: AppSpacing.mdSm),
      if (saved.isEmpty)
        EmptyState(icon: Icons.bookmark_border_rounded, title: l.nothingSaved, message: l.nothingSavedMessage)
      else
        for (final p in saved) Padding(padding: const EdgeInsets.only(bottom: AppSpacing.sm), child: _SavedTile(p)),
    ]);
  });
}

class _SavedTile extends StatelessWidget {
  final Profile p;
  const _SavedTile(this.p);
  @override
  Widget build(BuildContext context) {
    final m = matchEngine.insight(p);
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileDetailScreen(profile: p))),
      child: AppCard(padding: const EdgeInsets.all(AppSpacing.mdSm), child: Row(children: [
        Avatar(p.photos.first, size: 52, online: p.online),
        const SizedBox(width: AppSpacing.mdSm),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Flexible(child: Text('${p.name}, ${p.age}', overflow: TextOverflow.ellipsis,
                style: AppText.labelLarge.copyWith(fontSize: 15))),
            if (p.verified) ...[const SizedBox(width: AppSpacing.xs), const VerifiedBadge(size: 16)],
          ]),
          Text(m.top == null ? '${p.job} · ${p.city}' : context.l10n.reasonTitle(m.top!), maxLines: 1, overflow: TextOverflow.ellipsis,
              style: AppText.bodySmall),
        ])),
        const SizedBox(width: AppSpacing.sm),
        GestureDetector(onTap: () => showWhyYouMatch(context, p), child: MatchScoreRing(m.score, size: 48)),
        SaveProfileButton(p, background: Colors.transparent, size: 40),
      ])));
  }
}

/// What the engine has picked up from the user's activity, with a way to start over.
class _TasteCard extends StatelessWidget {
  final VoidCallback onReset;
  const _TasteCard({required this.onReset});

  Widget _stat(String value, String label) => Expanded(child: Column(children: [
    Text(value, style: AppText.h3.copyWith(color: AppColors.primary)),
    Text(label, style: AppText.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
  ]));

  @override
  Widget build(BuildContext context) {
    final e = matchEngine, drawn = e.learnedInterests(), l = context.l10n;
    return AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(width: 36, height: 36, decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
            child: const Icon(Icons.auto_awesome_rounded, size: 18, color: AppColors.primary)),
        const SizedBox(width: AppSpacing.mdSm),
        Expanded(child: Text(l.yourPicks, style: AppText.h4)),
      ]),
      const SizedBox(height: AppSpacing.sm),
      Text(l.yourPicksBody, style: AppText.bodySmall),
      const SizedBox(height: AppSpacing.md),
      Row(children: [
        _stat('${e.count(MatchSignal.like) + e.count(MatchSignal.superCrush)}', l.liked),
        _stat('${e.count(MatchSignal.skip)}', l.skipped),
        _stat('${e.saved.length}', l.saved),
      ]),
      if (drawn.isNotEmpty) ...[
        const SizedBox(height: AppSpacing.md),
        Text(l.drawnTo, style: AppText.labelLarge.copyWith(color: AppColors.muted)),
        const SizedBox(height: AppSpacing.sm),
        Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: [for (final i in drawn) InterestChip(i)]),
      ],
      if (e.count(MatchSignal.like) + e.count(MatchSignal.superCrush) + e.count(MatchSignal.skip) > 0) ...[
        const SizedBox(height: AppSpacing.sm),
        AppButton(l.resetPicks, variant: AppButtonVariant.ghost, icon: Icons.restart_alt_rounded, onPressed: onReset),
      ],
    ]));
  }
}
