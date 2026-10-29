import 'package:flutter/material.dart';
import '../data/account_store.dart';
import '../data/match_engine.dart';
import '../data/mock.dart';
import '../l10n/match_text.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import '../widgets/buttons.dart';
import '../widgets/match_insights.dart';
import '../widgets/profile_bits.dart';
import '../widgets/states.dart';
import '../widgets/teaser_widgets.dart';
import 'settings/safety_centre_screen.dart';

class ProfileDetailScreen extends StatelessWidget {
  final Profile profile;
  const ProfileDetailScreen({super.key, required this.profile});

  void _safety(BuildContext context) {
    final l = context.l10n;
    showModalBottomSheet(context: context, builder: (c) => SafeArea(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      ListTile(leading: const Icon(Icons.flag_outlined, color: AppColors.error),
        title: Text(l.reportName(profile.name), style: AppText.bodyLarge),
        onTap: () { Navigator.pop(c); showReportSheet(context, name: profile.name); }),
      ListTile(leading: const Icon(Icons.block_rounded, color: AppColors.text),
        title: Text(l.blockName(profile.name), style: AppText.bodyLarge),
        onTap: () async { Navigator.pop(c);
          if (await showConfirmDialog(context, title: l.blockTitle(profile.name),
              message: l.blockMessage, confirm: l.block)) {
            account.block(profile);
            if (!context.mounted) return;
            showToast(context, l.blockedToast(profile.name));
            Navigator.pop(context);
          } }),
      const SizedBox(height: AppSpacing.md),
    ])));
  }

  @override
  Widget build(BuildContext context) {
    final p = profile, l = context.l10n;
    final m = matchEngine.insight(p);
    return Scaffold(body: CustomScrollView(slivers: [
      SliverAppBar(expandedHeight: 480, pinned: true, backgroundColor: AppColors.background,
        leading: Padding(padding: const EdgeInsets.all(AppSpacing.xs), child: AppIconButton(Icons.arrow_back_ios_new_rounded,
            tooltip: l.back, background: AppColors.glassStrong, onPressed: () => Navigator.pop(context))),
        actions: [SaveProfileButton(p), const SizedBox(width: AppSpacing.sm),
          AppIconButton(Icons.more_horiz_rounded, tooltip: l.more, background: AppColors.glassStrong,
            onPressed: () => _safety(context)), const SizedBox(width: AppSpacing.sm)],
        flexibleSpace: FlexibleSpaceBar(background: PageView(
            children: p.photos.map((u) => AppImage(u)).toList()))),
      SliverPadding(padding: const EdgeInsets.all(AppSpacing.page), sliver: SliverList.list(children: [
        Row(children: [
          Flexible(child: Text('${p.name}, ${p.age}', style: AppText.h1, overflow: TextOverflow.ellipsis)),
          const SizedBox(width: AppSpacing.sm),
          if (p.verified) const VerifiedBadge(size: 22),
          const Spacer(),
          const SizedBox(width: AppSpacing.sm),
          ListenableBuilder(listenable: matchEngine, builder: (context, _) => CompatibilityPill(
              matchEngine.insight(p).score, onTap: () => showWhyYouMatch(context, p))),
        ]),
        const SizedBox(height: AppSpacing.xs),
        Text('${p.job} · ${p.city} · ${l.kmAway(p.distanceKm)}', style: AppText.bodyMedium.copyWith(color: AppColors.muted)),
        const SizedBox(height: AppSpacing.xl),
        WhyYouMatchCard(p),
        const SizedBox(height: AppSpacing.md),
        for (final t in p.teasers) Padding(padding: const EdgeInsets.only(bottom: AppSpacing.md), child: TeaserCard(t)),
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l.about, style: AppText.h4), const SizedBox(height: AppSpacing.sm),
          Text(p.bio, style: AppText.bodyLarge),
          const SizedBox(height: AppSpacing.md),
          Row(children: [const Icon(Icons.favorite_border_rounded, size: 18, color: AppColors.accent),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(l.lookingFor(p.lookingFor), style: AppText.bodyMedium))]),
          if (p.languages.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.mdSm),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Padding(padding: EdgeInsets.only(top: 3),
                  child: Icon(Icons.translate_rounded, size: 18, color: AppColors.accent)),
              const SizedBox(width: AppSpacing.sm),
              // Languages you share are highlighted.
              Expanded(child: Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: [
                for (final lang in p.languages)
                  InterestChip(l.languageName(lang), selected: m.sharedLanguages.contains(lang)),
              ])),
            ]),
          ],
        ])),
        const SizedBox(height: AppSpacing.md),
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l.interests, style: AppText.h4), const SizedBox(height: AppSpacing.mdSm),
          Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm,
              children: p.interests.map((e) => InterestChip(e, selected: m.sharedInterests.contains(e))).toList())])),
        const SizedBox(height: AppSpacing.section),
      ])),
    ]));
  }
}
