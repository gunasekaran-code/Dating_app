import 'package:flutter/material.dart';
import '../data/profile_options.dart';
import '../data/profile_store.dart';
import '../l10n/match_text.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import '../widgets/buttons.dart';
import '../widgets/perk_card.dart';
import '../widgets/photo_grid.dart';
import '../widgets/profile_bits.dart';
import '../widgets/skeletons.dart';
import 'edit_profile/edit_profile_screen.dart';
import 'manage_photos_screen.dart';
import 'profile_strength_screen.dart';
import 'settings_screen.dart';
import 'verification/verification_flow.dart';

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  void _managePhotos(BuildContext context) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ManagePhotosScreen()));

  @override
  Widget build(BuildContext context) {
    final u = currentUser, l = context.l10n;
    return SafeArea(child: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.page, AppSpacing.page, 0),
        child: Row(children: [Text(l.tabProfile, style: AppText.h1), const Spacer(),
          AppIconButton(Icons.settings_outlined, tooltip: l.settings, onPressed: () =>
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())))])),
      Expanded(child: SkeletonLoader(skeleton: const ProfileSkeleton(),
          child: ListenableBuilder(listenable: Listenable.merge([u, u.photos]), builder: (context, _) {
      final photos = u.photos.photos, main = u.photos.main;
      final (strength, tip) = profileStrength(u);
      final basics = [
        if (u.gender != null && u.showGender) (Icons.person_outline_rounded, u.gender!),
        if (u.heightCm != null) (Icons.height_rounded, formatHeight(u.heightCm!, metric: u.metricHeight)),
        if (u.education != null) (Icons.school_outlined, u.education!),
        if (u.lookingFor != null) (Icons.favorite_border_rounded, u.lookingFor!),
        if (u.languages.isNotEmpty) (Icons.translate_rounded, l.speaks(l.languageList(u.languages))),
      ];
      return ListView(padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.xl, AppSpacing.page, AppSpacing.page), children: [
        Center(child: Stack(children: [
          GestureDetector(
            onTap: main == null ? () => _managePhotos(context) : () => openPhotoViewer(context, u.photos),
            child: Container(padding: const EdgeInsets.all(2), decoration: BoxDecoration(shape: BoxShape.circle,
                border: Border.all(color: AppColors.accent, width: 2)),
              child: ClipOval(child: main == null
                  ? Container(width: 120, height: 120, color: AppColors.secondary,
                      child: const Icon(Icons.person_rounded, size: 56, color: AppColors.accent))
                  : PhotoImage(main, width: 120, height: 120)))),
          Positioned(right: 0, bottom: 0, child: AppIconButton(Icons.photo_camera_outlined, tooltip: l.managePhotos,
              size: 38, color: AppColors.onPrimary, background: AppColors.primary, onPressed: () => _managePhotos(context))),
        ])),
        const SizedBox(height: AppSpacing.md),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Flexible(child: Text([u.name.trim(), if (u.age != null) '${u.age}'].join(', '), style: AppText.h2,
              overflow: TextOverflow.ellipsis)),
          const SizedBox(width: AppSpacing.sm),
          u.verified
              ? VerifiedBadge(size: 24, onTap: () => openVerification(context))
              : VerifyStarButton(onTap: () => openVerification(context)),
        ]),
        if (u.job.isNotEmpty || u.city.isNotEmpty)
          Text([u.job, u.city].where((s) => s.trim().isNotEmpty).join(' · '), style: AppText.bodyMedium.copyWith(color: AppColors.muted), textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.xl),
        GestureDetector(onTap: () => Navigator.push(context,
            MaterialPageRoute(fullscreenDialog: true, builder: (_) => const ProfileStrengthScreen())),
          child: AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: Text(l.profileStrength, style: AppText.h4, overflow: TextOverflow.ellipsis)),
            Text('${(strength * 100).round()}%', style: AppText.labelLarge.copyWith(color: AppColors.primary)),
            const Icon(Icons.chevron_right_rounded, color: AppColors.muted)]),
          const SizedBox(height: AppSpacing.mdSm),
          ClipRRect(borderRadius: BorderRadius.circular(AppRadius.pill), child: TweenAnimationBuilder<double>(
            tween: Tween(end: strength), duration: AppDurations.slow,
            builder: (_, v, __) => LinearProgressIndicator(value: v, minHeight: 8,
                color: AppColors.primary, backgroundColor: AppColors.secondary))),
          const SizedBox(height: AppSpacing.sm),
          Text(tip, style: AppText.bodySmall),
        ]))),
        const SizedBox(height: AppSpacing.md),
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(l.myPhotos, style: AppText.h4), const SizedBox(width: AppSpacing.sm),
            Text('${photos.length}/${PhotoManager.maxPhotos}', style: AppText.bodySmall),
            const Spacer(),
            GestureDetector(onTap: () => _managePhotos(context),
                child: Text(l.manage, style: AppText.labelLarge.copyWith(color: AppColors.primary))),
          ]),
          const SizedBox(height: AppSpacing.mdSm),
          SizedBox(height: 96, child: ListView.separated(scrollDirection: Axis.horizontal,
            itemCount: photos.length + (u.photos.isFull ? 0 : 1),
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (_, i) => i == photos.length
                ? GestureDetector(onTap: () => addPhotos(context, u.photos), child: Container(width: 72,
                    decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(AppRadius.standardCard)),
                    child: const Icon(Icons.add_rounded, color: AppColors.primary)))
                : GestureDetector(onTap: () => openPhotoViewer(context, u.photos, initialIndex: i),
                    child: ClipRRect(borderRadius: BorderRadius.circular(AppRadius.standardCard),
                      child: Stack(children: [
                        PhotoImage(photos[i], width: 72, height: 96),
                        if (i == 0) const Positioned(left: 4, top: 4,
                            child: Icon(Icons.star_rounded, size: 18, color: AppColors.onPrimary)),
                      ]))))),
        ])),
        const SizedBox(height: AppSpacing.md),
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l.aboutMe, style: AppText.h4), const SizedBox(height: AppSpacing.sm),
          Text(u.bio.isEmpty ? l.addBioHint : u.bio,
              style: u.bio.isEmpty ? AppText.bodyMedium.copyWith(color: AppColors.muted) : AppText.bodyLarge),
          if (basics.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            for (final (icon, label) in basics) Padding(padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(children: [Icon(icon, size: 18, color: AppColors.accent), const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(label, style: AppText.bodyMedium))])),
          ],
          if (u.interests.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: u.interests.map((e) => InterestChip(e)).toList()),
          ],
        ])),
        const SizedBox(height: AppSpacing.md),
        const PerkCard(PerkKind.boost),
        const SizedBox(height: AppSpacing.md),
        const PerkCard(PerkKind.superCrush),
        const SizedBox(height: AppSpacing.xl),
        AppButton(l.editProfile, icon: Icons.edit_outlined, onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const EditProfileScreen()))),
        const SizedBox(height: AppSpacing.mdSm),
        AppButton(l.editPhotos, variant: AppButtonVariant.secondary, icon: Icons.photo_library_outlined,
            onPressed: () => _managePhotos(context)),
      ]);
    }))),
    ]));
  }
}
