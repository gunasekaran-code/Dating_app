import 'package:flutter/material.dart';
import '../../data/profile_options.dart';
import '../../data/profile_store.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/buttons.dart';
import '../../widgets/photo_grid.dart';
import '../../widgets/profile_bits.dart';
import '../../widgets/teaser_widgets.dart';

/// The signed-in user's profile as other people see it.
class ProfilePreviewScreen extends StatefulWidget {
  const ProfilePreviewScreen({super.key});
  @override
  State<ProfilePreviewScreen> createState() => _ProfilePreviewScreenState();
}
class _ProfilePreviewScreenState extends State<ProfilePreviewScreen> {
  int page = 0;

  Widget _card(String title, Widget child) => Padding(padding: const EdgeInsets.only(bottom: AppSpacing.md),
    child: AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: AppText.h4), const SizedBox(height: AppSpacing.mdSm), child])));

  Widget _wrap(List<Widget> children) =>
      Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: children);

  @override
  Widget build(BuildContext context) {
    final u = currentUser;
    return Scaffold(body: ListenableBuilder(listenable: Listenable.merge([u, u.photos]), builder: (context, _) {
      final photos = u.photos.photos;
      final subtitle = [u.job, u.city].where((s) => s.trim().isNotEmpty).join(' · ');
      final facts = [
        if (u.gender != null && u.showGender) (Icons.wc_rounded, u.gender!),
        if (u.heightCm != null) (Icons.height_rounded, formatHeight(u.heightCm!, metric: u.metricHeight)),
        if (u.education != null) (Icons.school_outlined, u.education!),
        for (final q in lifestyleQuestions) if (u.lifestyle[q.key] != null) (q.icon, u.lifestyle[q.key]!),
      ];
      return CustomScrollView(slivers: [
        SliverAppBar(expandedHeight: 480, pinned: true, backgroundColor: AppColors.background,
          leading: Padding(padding: const EdgeInsets.all(AppSpacing.xs), child: AppIconButton(Icons.arrow_back_ios_new_rounded,
              tooltip: 'Back', background: AppColors.glassStrong, onPressed: () => Navigator.pop(context))),
          title: Container(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.mdSm, vertical: 6),
            decoration: BoxDecoration(color: AppColors.glassStrong, borderRadius: BorderRadius.circular(AppRadius.pill)),
            child: Text('Preview', style: AppText.labelMedium.copyWith(color: AppColors.primary))),
          flexibleSpace: FlexibleSpaceBar(background: photos.isEmpty
              ? Container(color: AppColors.secondary, child: const Icon(Icons.person_rounded, size: 96, color: AppColors.accent))
              : Stack(fit: StackFit.expand, children: [
                  PageView(onPageChanged: (p) => setState(() => page = p),
                      children: [for (final p in photos) PhotoImage(p)]),
                  if (photos.length > 1) Positioned(left: 0, right: 0, bottom: AppSpacing.md, child: Row(
                    mainAxisAlignment: MainAxisAlignment.center, children: [
                      for (var i = 0; i < photos.length; i++) AnimatedContainer(duration: AppDurations.fast,
                        margin: const EdgeInsets.symmetric(horizontal: 3), width: i == page ? 18 : 6, height: 6,
                        decoration: BoxDecoration(color: i == page ? AppColors.onPrimary : const Color(0x88FFFFFF),
                            borderRadius: BorderRadius.circular(AppRadius.pill))),
                    ])),
                ]))),
        SliverPadding(padding: const EdgeInsets.all(AppSpacing.page), sliver: SliverList.list(children: [
          Row(children: [
            Flexible(child: Text([u.name.trim(), if (u.age != null) '${u.age}'].join(', '),
                style: AppText.h1, overflow: TextOverflow.ellipsis)),
            if (u.verified) ...[const SizedBox(width: AppSpacing.sm), const VerifiedBadge(size: 22)],
          ]),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(subtitle, style: AppText.bodyMedium.copyWith(color: AppColors.muted)),
          ],
          const SizedBox(height: AppSpacing.xl),
          if (u.bio.isNotEmpty) _card('About', Text(u.bio, style: AppText.bodyLarge)),
          if (u.relationships.isNotEmpty) _card('Looking for', _wrap([
            for (final r in relationshipOptions) if (u.relationships.contains(r)) InterestChip(r, selected: true)])),
          for (final t in u.teasers) Padding(padding: const EdgeInsets.only(bottom: AppSpacing.md), child: TeaserCard(t)),
          if (facts.isNotEmpty) _card('Basics', _wrap([
            for (final (icon, label) in facts) Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.mdSm, vertical: 6),
              decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(AppRadius.pill)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(icon, size: 16, color: AppColors.primary), const SizedBox(width: 6),
                Text(label, style: AppText.labelMedium.copyWith(color: AppColors.primary)),
              ])),
          ])),
          if (u.interests.isNotEmpty) _card('Hobbies', _wrap([for (final i in u.interests) InterestChip(i)])),
          if (u.places.isNotEmpty) _card('Favourite places', _wrap([
            for (final p in u.places) InterestChip('${p.emoji}  ${p.name}')])),
          const SizedBox(height: AppSpacing.section),
        ])),
      ]);
    }));
  }
}
