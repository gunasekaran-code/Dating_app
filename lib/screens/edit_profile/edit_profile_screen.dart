import 'package:flutter/material.dart';
import '../../data/profile_options.dart';
import '../../data/profile_store.dart';
import '../../l10n/match_text.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/buttons.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/photo_grid.dart';
import '../../widgets/profile_bits.dart';
import '../../widgets/teaser_widgets.dart';
import '../manage_photos_screen.dart';
import '../verification/verification_flow.dart';
import 'edit_pages.dart';
import 'profile_preview_screen.dart';

/// "Personal details": the whole profile at a glance, every section opening its own editor.
class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  static void _open(BuildContext context, Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    final u = currentUser;
    void open(Widget page) => _open(context, page);
    return Scaffold(body: SafeArea(bottom: false, child: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.sm, AppSpacing.sm, 0), child: Row(children: [
        AppIconButton(Icons.arrow_back_ios_new_rounded, tooltip: 'Back', onPressed: () => Navigator.maybePop(context)),
        const Spacer(),
        TextButton.icon(onPressed: () => open(const ProfilePreviewScreen()),
            icon: const Icon(Icons.visibility_outlined, size: 18, color: AppColors.primary),
            label: Text('View my profile', style: AppText.labelLarge.copyWith(color: AppColors.primary))),
      ])),
      Expanded(child: ListenableBuilder(listenable: Listenable.merge([u, u.photos]), builder: (context, _) {
        String? lifestyle(LifestyleQuestion q) => u.lifestyle[q.key];
        final relationships = [for (final o in relationshipOptions) if (u.relationships.contains(o)) o];
        return ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.sm, AppSpacing.page, AppSpacing.section),
          children: [
            if (!u.verified) ...[const _VerifyBanner(), const SizedBox(height: AppSpacing.xl)],
            Row(children: [
              Flexible(child: Text([u.name.trim(), if (u.age != null) '${u.age}'].join(', '),
                  style: AppText.displaySmall, overflow: TextOverflow.ellipsis)),
              if (u.verified) ...[const SizedBox(width: AppSpacing.sm), const VerifiedBadge(size: 24)],
            ]),
            const SizedBox(height: AppSpacing.md),
            const _PhotoCarousel(),
            const SizedBox(height: AppSpacing.xl),

            _Section(title: 'My Teasers', count: '${u.teasers.length}/${UserProfileStore.maxTeasers}',
              action: u.teasers.isEmpty ? 'Add' : 'Edit', onTap: () => open(const TeasersEditPage()),
              child: u.teasers.isEmpty
                  ? const _Placeholders(Icons.format_quote_rounded)
                  : Column(children: [
                      for (final t in u.teasers) Padding(padding: const EdgeInsets.only(bottom: AppSpacing.mdSm),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(t.prompt, style: AppText.labelMedium.copyWith(color: AppColors.accent)),
                          const SizedBox(height: 2),
                          if (t.voice != null) Padding(padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                              child: VoiceNotePlayer(t.voice!)),
                          if (t.answer.isNotEmpty) Text(t.answer, style: AppText.bodyLarge),
                        ])),
                    ])),

            _Section(title: 'Relationships', action: relationships.isEmpty ? 'Add' : 'Edit',
              onTap: () => open(const RelationshipsEditPage()),
              child: relationships.isEmpty
                  ? const _Empty('Tell people what kind of connection you’re after.')
                  : _Chips([for (final r in relationships)
                      '${relationshipEmojis[relationshipOptions.indexOf(r)]}  $r'])),

            _Section(title: 'Hobbies', count: '${u.interests.length}/${UserProfileStore.maxHobbies}',
              action: u.interests.isEmpty ? 'Add' : 'Edit', onTap: () => open(const HobbiesEditPage()),
              child: u.interests.isEmpty ? const _Placeholders(Icons.interests_outlined) : _Chips(u.interests.toList())),

            _Section(title: context.l10n.languagesISpeak,
              action: u.languages.isEmpty ? context.l10n.add : context.l10n.edit,
              onTap: () => open(const LanguagesEditPage()),
              child: u.languages.isEmpty
                  ? const _Placeholders(Icons.translate_rounded)
                  : _Chips([for (final (english, native) in spokenLanguages) if (u.languages.contains(english)) native])),

            _Section(title: 'Places', count: '${u.places.length}/${UserProfileStore.maxPlaces}',
              action: u.places.isEmpty ? 'Add' : 'Edit', onTap: () => open(const PlacesEditPage()),
              child: u.places.isEmpty
                  ? const _Placeholders(Icons.place_outlined)
                  : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      for (final p in u.places) Padding(padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: _Pill('${p.emoji}  ${p.name}')),
                    ])),

            _Section(title: 'My bio', action: u.bio.isEmpty ? 'Add' : 'Edit', onTap: () => open(const BioEditPage()),
              child: u.bio.isEmpty
                  ? Text('Tell us a bit more about your passions, hobbies… anything that might interest your future Crush.',
                      style: AppText.h4.copyWith(color: AppColors.muted, fontWeight: FontWeight.w400))
                  : Text(u.bio, style: AppText.bodyLarge)),

            _InfoGroup('About me', [
              _InfoRow(Icons.cake_outlined, 'Age', u.age?.toString(), () => open(const AgeEditPage())),
              _InfoRow(Icons.wc_rounded, 'Gender', u.gender, () => open(const GenderEditPage())),
              _InfoRow(Icons.location_on_outlined, 'City', u.city, () => open(const CityEditPage())),
              _InfoRow(Icons.work_outline_rounded, 'Work', u.job, () => open(const WorkEditPage())),
              _InfoRow(Icons.school_outlined, 'Education', u.education, () => open(const EducationEditPage())),
            ]),
            const SizedBox(height: AppSpacing.xl),
            _InfoGroup('About', [
              for (final q in [kidsQuestion, smokingQuestion])
                _InfoRow(q.icon, q.key, lifestyle(q), () => open(LifestyleEditPage(q))),
              _InfoRow(Icons.height_rounded, 'Height', u.heightCm == null ? null
                  : '${formatHeight(u.heightCm!)} (${formatHeight(u.heightCm!, metric: false)})',
                  () => open(const HeightEditPage())),
              for (final q in [sportQuestion, drinkingQuestion, foodQuestion])
                _InfoRow(q.icon, q.key, lifestyle(q), () => open(LifestyleEditPage(q))),
            ]),
          ]);
      })),
    ])));
  }
}

/// "Build trust" card nudging unverified users towards selfie verification.
class _VerifyBanner extends StatelessWidget {
  const _VerifyBanner();
  @override
  Widget build(BuildContext context) {
    final main = currentUser.photos.main;
    final r = BorderRadius.circular(AppRadius.card);
    return Material(type: MaterialType.transparency, child: InkWell(borderRadius: r, onTap: () => openVerification(context),
      child: Ink(padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(borderRadius: r, border: Border.all(color: AppColors.verified.withValues(alpha: .2)),
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [
            AppColors.verifiedLight.withValues(alpha: .22), AppColors.verified.withValues(alpha: .08)])),
        child: Row(children: [
          Stack(clipBehavior: Clip.none, children: [
            ClipRRect(borderRadius: BorderRadius.circular(AppRadius.standardCard), child: main == null
                ? Container(width: 44, height: 44, color: AppColors.secondary,
                    child: const Icon(Icons.person_rounded, color: AppColors.accent))
                : PhotoImage(main, width: 44, height: 44)),
            Positioned(right: -6, bottom: -6, child: Container(padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(color: AppColors.card, shape: BoxShape.circle),
                child: const VerifiedBadge(size: 16))),
          ]),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Build trust', style: AppText.labelLarge.copyWith(fontSize: 15)),
            Text('Verify your profile to get 2x more Likes', style: AppText.bodySmall),
          ])),
          const SizedBox(width: AppSpacing.sm),
          Container(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(AppRadius.pill)),
            child: Text('Verify now', style: AppText.labelMedium.copyWith(color: AppColors.onPrimary))),
        ]))));
  }
}

/// Swipeable photos with the next one peeking in, an "Edit photos" pill and page dots.
class _PhotoCarousel extends StatefulWidget {
  const _PhotoCarousel();
  @override
  State<_PhotoCarousel> createState() => _PhotoCarouselState();
}
class _PhotoCarouselState extends State<_PhotoCarousel> {
  static const _fraction = .86;
  final pc = PageController(viewportFraction: _fraction);
  int page = 0;
  @override
  void dispose() { pc.dispose(); super.dispose(); }

  void _manage() => EditProfileScreen._open(context, const ManagePhotosScreen());

  @override
  Widget build(BuildContext context) {
    final manager = currentUser.photos, photos = manager.photos;
    final r = BorderRadius.circular(AppRadius.sheet);
    if (photos.isEmpty) {
      return GestureDetector(onTap: _manage, child: AspectRatio(aspectRatio: 4 / 3, child: GlassCard(radius: AppRadius.sheet,
        padding: EdgeInsets.zero, onTap: _manage, child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.add_a_photo_outlined, size: 40, color: AppColors.primary),
          const SizedBox(height: AppSpacing.sm),
          Text('Add your photos', style: AppText.labelLarge.copyWith(color: AppColors.primary)),
        ])))));
    }
    final current = page.clamp(0, photos.length - 1);
    return LayoutBuilder(builder: (_, c) => Column(children: [
      SizedBox(height: c.maxWidth * _fraction * 1.2, child: PageView.builder(controller: pc, padEnds: false,
        itemCount: photos.length, onPageChanged: (p) => setState(() => page = p),
        itemBuilder: (_, i) => Padding(padding: const EdgeInsets.only(right: AppSpacing.mdSm), child: ClipRRect(
          borderRadius: r, child: Stack(fit: StackFit.expand, children: [
            GestureDetector(onTap: () => openPhotoViewer(context, manager, initialIndex: i),
                child: PhotoImage(photos[i])),
            Positioned(top: AppSpacing.mdSm, right: AppSpacing.mdSm, child: Material(
              color: AppColors.text.withValues(alpha: .78), shape: const StadiumBorder(),
              child: InkWell(customBorder: const StadiumBorder(), onTap: _manage, child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.mdSm, vertical: AppSpacing.sm),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.edit_rounded, size: 16, color: AppColors.onPrimary),
                  const SizedBox(width: AppSpacing.xs),
                  Text('Edit photos', style: AppText.labelMedium.copyWith(color: AppColors.onPrimary)),
                ]))))),
          ]))))),
      if (photos.length > 1) ...[
        const SizedBox(height: AppSpacing.mdSm),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          for (var i = 0; i < photos.length; i++) AnimatedContainer(duration: AppDurations.fast,
            margin: const EdgeInsets.symmetric(horizontal: 3), width: i == current ? 18 : 6, height: 6,
            decoration: BoxDecoration(color: i == current ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(AppRadius.pill))),
        ]),
      ],
    ]));
  }
}

/// Titled card with an "Edit ›" / "Add ›" link; the whole card opens the editor.
class _Section extends StatelessWidget {
  final String title, action; final String? count; final VoidCallback onTap; final Widget child;
  const _Section({required this.title, required this.action, required this.onTap, required this.child, this.count});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: AppSpacing.xl),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(count == null ? title : '$title ($count)', style: AppText.h4),
      const SizedBox(height: AppSpacing.mdSm),
      Semantics(button: true, label: '$action $title', child: GlassCard(padding: const EdgeInsets.all(AppSpacing.md),
        onTap: onTap, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          child,
          const SizedBox(height: AppSpacing.mdSm),
          Align(alignment: Alignment.centerRight, child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(action, style: AppText.labelLarge.copyWith(color: AppColors.primary)),
            const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.primary),
          ])),
        ]))),
    ]));
}

/// Three soft empty slots shown while a section has nothing in it.
class _Placeholders extends StatelessWidget {
  final IconData icon;
  const _Placeholders(this.icon);
  @override
  Widget build(BuildContext context) => Row(children: [
    for (var i = 0; i < 3; i++) ...[
      if (i > 0) const SizedBox(width: AppSpacing.sm),
      Expanded(child: Container(height: 52,
        decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: .45),
            borderRadius: BorderRadius.circular(AppRadius.input), border: Border.all(color: AppColors.border)),
        child: Icon(icon, color: AppColors.accent.withValues(alpha: .7)))),
    ],
  ]);
}

class _Empty extends StatelessWidget {
  final String text;
  const _Empty(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: AppText.bodyMedium.copyWith(color: AppColors.muted));
}

class _Pill extends StatelessWidget {
  final String label;
  const _Pill(this.label);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.input),
      gradient: LinearGradient(colors: [AppColors.secondary, AppColors.accent.withValues(alpha: .35)]),
      border: Border.all(color: AppColors.accent.withValues(alpha: .3))),
    child: Text(label, style: AppText.labelLarge.copyWith(color: AppColors.primary)));
}

class _Chips extends StatelessWidget {
  final List<String> labels;
  const _Chips(this.labels);
  @override
  Widget build(BuildContext context) => Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm,
      children: [for (final l in labels) _Pill(l)]);
}

/// Heading plus a card of tappable rows (icon tile, label, value, chevron).
class _InfoGroup extends StatelessWidget {
  final String title; final List<_InfoRow> rows;
  const _InfoGroup(this.title, this.rows);
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: AppText.h4),
    const SizedBox(height: AppSpacing.mdSm),
    AppCard(padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs), child: Column(children: [
      for (var i = 0; i < rows.length; i++) ...[if (i > 0) const Divider(indent: 72, endIndent: AppSpacing.md), rows[i]],
    ])),
  ]);
}

class _InfoRow extends StatelessWidget {
  final IconData icon; final String label; final String? value; final VoidCallback onTap;
  const _InfoRow(this.icon, this.label, this.value, this.onTap);
  @override
  Widget build(BuildContext context) {
    final v = value?.trim() ?? '', empty = v.isEmpty;
    return Semantics(button: true, label: '$label, ${empty ? 'not provided' : v}', excludeSemantics: true,
      child: InkWell(onTap: onTap, child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.mdSm),
        child: Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.secondary,
              borderRadius: BorderRadius.circular(AppRadius.standardCard)),
              child: Icon(icon, size: 20, color: AppColors.primary)),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: AppText.labelLarge.copyWith(fontSize: 15)),
            Text(empty ? 'Not provided' : v, overflow: TextOverflow.ellipsis, style: empty
                ? AppText.bodySmall.copyWith(color: AppColors.accent)
                : AppText.bodySmall),
          ])),
          const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
        ]))));
  }
}
