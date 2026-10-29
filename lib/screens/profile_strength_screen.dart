import 'package:flutter/material.dart';
import '../data/profile_store.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import '../widgets/buttons.dart';
import '../widgets/profile_bits.dart';
import 'edit_profile/edit_pages.dart';
import 'edit_profile/edit_profile_screen.dart';
import 'manage_photos_screen.dart';
import 'verification/verification_flow.dart';

/// One scored part of the profile, e.g. "Bio" or "Basic info".
class ProfileSection {
  final String title, tip; final IconData icon; final int done, total; final String? status;
  const ProfileSection(this.title, this.icon, {required this.done, required this.total, required this.tip, this.status});
  bool get isComplete => done >= total;
  String get statusLabel => status ?? '$done of $total added';
}

/// The scored sections of [u]'s profile, in the order they're shown.
List<ProfileSection> profileSections(UserProfileStore u) {
  final basics = {'name': u.name.trim().isNotEmpty, 'birthday': u.birthday != null, 'gender': u.gender != null,
      'height': u.heightCm != null, 'job title': u.job.trim().isNotEmpty};
  final more = {'education level': u.education != null, 'what you’re looking for': u.lookingFor != null,
      'interests': u.interests.length >= 3};
  String nextOf(Map<String, bool> m) => m.entries.where((e) => !e.value).map((e) => e.key).firstOrNull ?? '';
  final photos = u.photos.count.clamp(0, PhotoManager.maxPhotos), missing = PhotoManager.maxPhotos - photos;
  return [
    ProfileSection('Bio', Icons.menu_book_outlined, done: u.bio.trim().isEmpty ? 0 : 1, total: 1,
        status: u.bio.trim().isEmpty ? 'Not written' : 'Written',
        tip: 'Write a short bio so people know what you’re about.'),
    ProfileSection('Get verified', Icons.verified_outlined, done: u.verified ? 1 : 0, total: 1,
        status: u.verified ? 'Verified' : 'Not verified',
        tip: 'Verify your profile to show matches you’re really you.'),
    ProfileSection('Basic info', Icons.badge_outlined, done: basics.values.where((v) => v).length, total: basics.length,
        tip: 'Add your ${nextOf(basics)} to round out your basics.'),
    ProfileSection('More about you', Icons.explore_outlined, done: more.values.where((v) => v).length, total: more.length,
        tip: 'Add your ${nextOf(more)} to spark conversations.'),
    ProfileSection('Photos', Icons.photo_library_outlined, done: photos, total: PhotoManager.maxPhotos,
        tip: 'Add $missing more photo${missing == 1 ? '' : 's'} to get more matches.'),
  ];
}

/// Share of the profile filled in (each section weighted equally), plus the most useful next step.
(double, String) profileStrength(UserProfileStore u) {
  final sections = profileSections(u);
  final score = sections.fold<double>(0, (s, e) => s + e.done / e.total) / sections.length;
  final next = sections.where((s) => !s.isComplete).map((s) => s.tip).firstOrNull ?? 'Your profile is complete — nice work!';
  return (score, next);
}

class ProfileStrengthScreen extends StatelessWidget {
  const ProfileStrengthScreen({super.key});

  void _open(BuildContext context, ProfileSection s) {
    if (s.title == 'Photos') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ManagePhotosScreen()));
    } else if (s.title == 'Get verified') {
      openVerification(context);
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) =>
          s.title == 'Bio' ? const BioEditPage() : const EditProfileScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = currentUser;
    return Scaffold(body: SafeArea(child: ListenableBuilder(listenable: Listenable.merge([u, u.photos]), builder: (context, _) {
      final sections = profileSections(u);
      final (strength, _) = profileStrength(u);
      final next = sections.where((s) => !s.isComplete).firstOrNull;
      final (title, subtitle) = next == null
          ? ('Your profile is complete 🎉', 'You’re putting your best self forward. Nice work!')
          : strength >= .5
              ? ('You’re almost there 😍', 'Let’s take your profile from good to great. The details matter!')
              : ('Let’s build your profile ✨', 'Complete profiles get more matches. Start with the basics.');
      return ListView(padding: const EdgeInsets.all(AppSpacing.page), children: [
        Align(alignment: Alignment.centerLeft,
            child: AppIconButton(Icons.close_rounded, tooltip: 'Close', onPressed: () => Navigator.pop(context))),
        const SizedBox(height: AppSpacing.sm),
        Center(child: _StrengthRing(strength)),
        const SizedBox(height: AppSpacing.xl),
        Text(title, style: AppText.h3, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.sm),
        Text(subtitle, style: AppText.bodyMedium.copyWith(color: AppColors.muted), textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.xl),
        for (var i = 0; i < sections.length; i += 2)
          Padding(padding: const EdgeInsets.only(bottom: AppSpacing.mdSm), child: IntrinsicHeight(child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Expanded(child: _SectionTile(sections[i], onTap: () => _open(context, sections[i]))),
              const SizedBox(width: AppSpacing.mdSm),
              Expanded(child: i + 1 < sections.length
                  ? _SectionTile(sections[i + 1], onTap: () => _open(context, sections[i + 1]))
                  : const SizedBox()),
            ]))),
        const SizedBox(height: AppSpacing.mdSm),
        next == null
            ? AppButton('Done', onPressed: () => Navigator.pop(context))
            : AppButton('Next: ${next.title}', icon: Icons.arrow_forward_rounded, onPressed: () => _open(context, next)),
      ]);
    })));
  }
}

class _StrengthRing extends StatelessWidget {
  final double value;
  const _StrengthRing(this.value);
  @override
  Widget build(BuildContext context) => Semantics(label: 'Profile strength ${(value * 100).round()} percent',
    child: TweenAnimationBuilder<double>(tween: Tween(begin: 0, end: value), duration: AppDurations.slow,
      builder: (_, v, __) => SizedBox(width: 140, height: 140, child: Stack(fit: StackFit.expand, children: [
        CircularProgressIndicator(value: v, strokeWidth: 8, strokeCap: StrokeCap.round,
            color: AppColors.primary, backgroundColor: AppColors.secondary),
        Center(child: Text('${(v * 100).round()}%', style: AppText.h2)),
      ]))));
}

class _SectionTile extends StatelessWidget {
  final ProfileSection section; final VoidCallback onTap;
  const _SectionTile(this.section, {required this.onTap});
  @override
  Widget build(BuildContext context) {
    final s = section;
    return Semantics(button: true, label: '${s.title}, ${s.statusLabel}',
      child: GestureDetector(onTap: onTap, child: AppCard(padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Stack(clipBehavior: Clip.none, children: [
            Container(width: 72, height: 72, decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                child: Icon(s.icon, size: 32, color: AppColors.primary)),
            if (s.isComplete) Positioned(right: -2, bottom: -2, child: Container(
              decoration: BoxDecoration(color: AppColors.card, shape: BoxShape.circle,
                  border: Border.all(color: AppColors.card, width: 2)),
              child: const Icon(Icons.check_circle_rounded, size: 22, color: AppColors.success))),
          ]),
          const SizedBox(height: AppSpacing.md),
          Text(s.title, style: AppText.labelLarge.copyWith(fontSize: 16), textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xs),
          Text(s.statusLabel, textAlign: TextAlign.center, style: s.isComplete
              ? AppText.labelMedium.copyWith(color: AppColors.success)
              : AppText.bodySmall),
        ]))));
  }
}
