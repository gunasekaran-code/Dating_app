import 'package:flutter/material.dart';
import '../../services/haptics.dart';
import '../../data/profile_options.dart';
import '../../data/profile_store.dart';
import '../../l10n/match_text.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/buttons.dart';
import '../../widgets/onboarding_widgets.dart';
import '../../widgets/profile_bits.dart';
import '../../widgets/states.dart';
import '../../widgets/teaser_widgets.dart';
import '../onboarding/onboarding_steps.dart';

final _user = currentUser;

/// Rebuilds [builder] whenever the profile changes.
class _Watch extends StatelessWidget {
  final WidgetBuilder builder;
  const _Watch(this.builder);
  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: _user, builder: (c, _) => builder(c));
}

/// Shell shared by every profile editor: back chevron, a "Delete" action while [canDelete]
/// holds, the page itself and an optional pinned [footer]. Edits save as you go.
class EditPageScaffold extends StatelessWidget {
  final Widget child; final Widget? footer;
  final bool Function()? canDelete; final VoidCallback? onDelete;
  /// Shown in the "… removed" toast after deleting.
  final String? deleteLabel;
  const EditPageScaffold({super.key, required this.child, this.footer, this.canDelete, this.onDelete,
      this.deleteLabel});

  void _delete(BuildContext context) {
    _user.update(onDelete!);
    showToast(context, '${deleteLabel ?? 'Answer'} removed');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(body: SafeArea(child: Column(children: [
    Padding(padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.sm, AppSpacing.sm, 0), child: Row(children: [
      AppIconButton(Icons.arrow_back_ios_new_rounded, tooltip: 'Back', onPressed: () => Navigator.maybePop(context)),
      const Spacer(),
      if (onDelete != null) _Watch((_) => AnimatedOpacity(duration: AppDurations.base,
        opacity: canDelete?.call() ?? true ? 1 : 0,
        child: TextButton(onPressed: canDelete?.call() ?? true ? () => _delete(context) : null,
            child: Text('Delete', style: AppText.labelLarge.copyWith(fontSize: 15))))),
    ])),
    Expanded(child: child),
    if (footer != null) Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.md), child: footer),
  ])));
}

/// Large rounded text box used by the free-text editors.
class _Field extends StatelessWidget {
  final TextEditingController controller; final String hint; final int minLines; final int? maxLength;
  final ValueChanged<String>? onChanged, onSubmitted; final IconData? prefix; final Widget? suffix;
  final TextCapitalization caps; final bool autofocus;
  const _Field(this.controller, {required this.hint, this.minLines = 1, this.maxLength, this.onChanged,
      this.onSubmitted, this.prefix, this.suffix, this.caps = TextCapitalization.sentences, this.autofocus = true});

  OutlineInputBorder _b(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.card), borderSide: BorderSide(color: c, width: w));

  @override
  Widget build(BuildContext context) => TextField(controller: controller, autofocus: autofocus,
    minLines: minLines, maxLines: minLines > 1 ? 10 : 1, maxLength: maxLength, textCapitalization: caps,
    cursorColor: AppColors.primary, style: AppText.bodyLarge, onChanged: onChanged, onSubmitted: onSubmitted,
    textInputAction: minLines > 1 ? TextInputAction.newline : TextInputAction.done,
    decoration: InputDecoration(hintText: hint, hintStyle: AppText.bodyLarge.copyWith(color: AppColors.muted),
      prefixIcon: prefix == null ? null : Icon(prefix, color: AppColors.accent, size: 22), suffixIcon: suffix,
      filled: true, fillColor: AppColors.glassStrong, counterStyle: AppText.bodySmall,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 18),
      enabledBorder: _b(AppColors.glassBorder), focusedBorder: _b(AppColors.primary, 1.5)));
}

/// Free-text editor bound to one profile string.
class _TextEditPage extends StatefulWidget {
  final String title, subtitle, hint, deleteLabel; final String Function() read; final void Function(String) write;
  final int minLines, maxLength; final IconData? prefix; final TextCapitalization caps;
  /// Tappable quick answers shown under the field.
  final List<String> suggestions;
  const _TextEditPage({required this.title, required this.subtitle, required this.hint, required this.deleteLabel,
      required this.read, required this.write, this.minLines = 1, this.maxLength = 40, this.prefix,
      this.caps = TextCapitalization.words, this.suggestions = const []});
  @override
  State<_TextEditPage> createState() => _TextEditPageState();
}
class _TextEditPageState extends State<_TextEditPage> {
  late final c = TextEditingController(text: widget.read());
  @override
  void dispose() { c.dispose(); super.dispose(); }
  void _set(String v) => _user.update(() => widget.write(v.trim()));
  @override
  Widget build(BuildContext context) => EditPageScaffold(deleteLabel: widget.deleteLabel,
    canDelete: () => widget.read().isNotEmpty, onDelete: () => widget.write(''),
    child: StepPage(title: widget.title, subtitle: widget.subtitle, child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        _Field(c, hint: widget.hint, minLines: widget.minLines, maxLength: widget.maxLength, prefix: widget.prefix,
            caps: widget.caps, onChanged: _set, onSubmitted: (_) => Navigator.maybePop(context)),
        if (widget.suggestions.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text('Quick picks', style: AppText.labelMedium.copyWith(color: AppColors.muted)),
          const SizedBox(height: AppSpacing.sm),
          _Watch((_) => Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: [
            for (final s in widget.suggestions) SelectChip(s, selected: widget.read() == s, onTap: () {
              c.text = s;
              _set(s);
            }),
          ])),
        ],
      ])));
}

// ─ Bio ───────────────────────────────────────────────────────────────────────
class BioEditPage extends StatelessWidget {
  const BioEditPage({super.key});
  @override
  Widget build(BuildContext context) => _TextEditPage(title: 'Complete your profile',
      subtitle: 'Provide more details about yourself to attract other people.',
      hint: 'Showcase your personality', deleteLabel: 'Bio', minLines: 6, maxLength: 500,
      caps: TextCapitalization.sentences, read: () => _user.bio, write: (v) => _user.bio = v);
}

// ─ Work & education ─────────────────────────────────────────────────────────
class WorkEditPage extends StatelessWidget {
  const WorkEditPage({super.key});
  @override
  Widget build(BuildContext context) => _TextEditPage(title: 'What do you do?',
      subtitle: 'Your job title shows under your name.', hint: 'e.g. App Developer', deleteLabel: 'Work',
      prefix: Icons.work_outline_rounded, read: () => _user.job, write: (v) => _user.job = v);
}

class EducationEditPage extends StatelessWidget {
  const EducationEditPage({super.key});
  @override
  Widget build(BuildContext context) => _TextEditPage(title: 'What did you study?',
      subtitle: 'Add your degree or school — or pick your level below.', hint: 'e.g. Master of computer science',
      deleteLabel: 'Education', maxLength: 60, prefix: Icons.school_outlined,
      suggestions: [for (final o in educationOptions) if (o.label != 'Prefer not to say') o.label],
      read: () => _user.education ?? '', write: (v) => _user.education = v.isEmpty ? null : v);
}

// ─ City ──────────────────────────────────────────────────────────────────────
class CityEditPage extends StatefulWidget {
  const CityEditPage({super.key});
  @override
  State<CityEditPage> createState() => _CityEditPageState();
}
class _CityEditPageState extends State<CityEditPage> {
  late final c = TextEditingController(text: _user.city);
  @override
  void dispose() { c.dispose(); super.dispose(); }

  void _pick(String city) {
    c.text = city;
    _user.update(() => _user.city = city);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) => EditPageScaffold(deleteLabel: 'City',
    canDelete: () => _user.city.isNotEmpty, onDelete: () => _user.city = '',
    child: ListView(padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xl),
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(AppRadius.sheet), child: Stack(children: [
          const AppImage('https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?w=900&q=80&auto=format&fit=crop',
              width: double.infinity, height: 170),
          Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Colors.transparent, AppColors.primary.withValues(alpha: .45)])))),
          const Positioned(left: AppSpacing.md, bottom: AppSpacing.md,
              child: Icon(Icons.location_on_rounded, color: AppColors.onPrimary, size: 28)),
        ])),
        const SizedBox(height: AppSpacing.xl),
        Text('Find a Crush in your city', style: AppText.displaySmall),
        const SizedBox(height: AppSpacing.sm),
        Text('Add your current city to receive geo-localised recommendations.',
            style: AppText.bodyMedium.copyWith(color: AppColors.muted)),
        const SizedBox(height: AppSpacing.xl),
        _Field(c, hint: 'Your city', prefix: Icons.location_on_outlined, autofocus: false,
            caps: TextCapitalization.words,
            onChanged: (v) => _user.update(() => _user.city = v.trim()), onSubmitted: (_) => Navigator.maybePop(context)),
        const SizedBox(height: AppSpacing.md),
        _Watch((_) {
          final q = _user.city.toLowerCase();
          final matches = cityOptions.where((x) => x.toLowerCase() != q && x.toLowerCase().contains(q)).take(5).toList();
          if (matches.isEmpty) return const SizedBox();
          return AppCard(padding: EdgeInsets.zero, child: Column(children: [
            for (var i = 0; i < matches.length; i++) ...[
              if (i > 0) const Divider(indent: 56),
              ListTile(leading: const Icon(Icons.place_outlined, color: AppColors.accent),
                  title: Text(matches[i], style: AppText.bodyLarge), onTap: () => _pick(matches[i])),
            ],
          ]));
        }),
      ]));
}

// ─ Relationships ─────────────────────────────────────────────────────────────
class RelationshipsEditPage extends StatelessWidget {
  const RelationshipsEditPage({super.key});
  @override
  Widget build(BuildContext context) => EditPageScaffold(deleteLabel: 'Relationships',
    canDelete: () => _user.relationships.isNotEmpty, onDelete: _user.relationships.clear,
    child: StepPage(title: 'What are you looking for?', subtitle: 'Choose the option(s) that suits you best.',
      child: _Watch((_) => Column(children: [
        for (var i = 0; i < relationshipOptions.length; i++)
          ChoiceTile(label: relationshipOptions[i], emoji: relationshipEmojis[i],
              selected: _user.relationships.contains(relationshipOptions[i]),
              onTap: () => _user.update(() {
                final o = relationshipOptions[i], s = _user.relationships;
                s.contains(o) ? s.remove(o) : s.add(o);
              })),
      ]))));
}

// ─ Hobbies ───────────────────────────────────────────────────────────────────
class HobbiesEditPage extends StatelessWidget {
  const HobbiesEditPage({super.key});
  static const max = UserProfileStore.maxHobbies;
  @override
  Widget build(BuildContext context) => EditPageScaffold(deleteLabel: 'Hobbies',
    canDelete: () => _user.interests.isNotEmpty, onDelete: _user.interests.clear,
    child: StepPage(title: 'What are your hobbies?', subtitle: 'Pick up to $max. They make great conversation starters.',
      child: _Watch((_) {
        final picked = _user.interests;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          InterestChip('${picked.length} / $max selected', selected: picked.isNotEmpty),
          const SizedBox(height: AppSpacing.lg),
          Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: [
            for (final i in interestOptions)
              SelectChip(i, selected: picked.contains(i), enabled: picked.contains(i) || picked.length < max,
                  onTap: () => _user.update(() => picked.contains(i) ? picked.remove(i) : picked.add(i))),
          ]),
        ]);
      })));
}

// ─ Languages ─────────────────────────────────────────────────────────────────
class LanguagesEditPage extends StatelessWidget {
  const LanguagesEditPage({super.key});
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return EditPageScaffold(deleteLabel: l.languagesISpeak,
      canDelete: () => _user.languages.isNotEmpty, onDelete: _user.languages.clear,
      child: StepPage(title: l.languagesEditTitle, subtitle: l.languagesEditSubtitle,
        child: _Watch((_) {
          final picked = _user.languages;
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            InterestChip(l.selectedCount(picked.length), selected: picked.isNotEmpty),
            const SizedBox(height: AppSpacing.lg),
            Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: [
              for (final (english, native) in spokenLanguages)
                SelectChip(native == english ? english : '$native · $english', selected: picked.contains(english),
                    onTap: () => _user.update(() => picked.contains(english) ? picked.remove(english) : picked.add(english))),
            ]),
          ]);
        })));
  }
}

// ─ Places ────────────────────────────────────────────────────────────────────
class PlacesEditPage extends StatefulWidget {
  const PlacesEditPage({super.key});
  @override
  State<PlacesEditPage> createState() => _PlacesEditPageState();
}
class _PlacesEditPageState extends State<PlacesEditPage> {
  static const max = UserProfileStore.maxPlaces;
  final c = TextEditingController();
  String emoji = placeCategories.first.$1;
  @override
  void dispose() { c.dispose(); super.dispose(); }

  void _add() {
    final name = c.text.trim();
    if (name.isEmpty || _user.places.length >= max) return;
    if (_user.places.any((p) => p.name.toLowerCase() == name.toLowerCase())) {
      showToast(context, '$name is already on your list');
      return;
    }
    Haptics.light();
    _user.update(() => _user.places.add(FavouritePlace(emoji, name)));
    c.clear();
  }

  @override
  Widget build(BuildContext context) => EditPageScaffold(deleteLabel: 'Places',
    canDelete: () => _user.places.isNotEmpty, onDelete: _user.places.clear,
    child: StepPage(title: 'Your favourite places',
      subtitle: 'Share up to $max spots you love — a café, a cinema, your go-to dinner place.',
      child: _Watch((_) {
        final places = _user.places, full = places.length >= max;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (!full) ...[
            SizedBox(height: 48, child: ListView.separated(scrollDirection: Axis.horizontal,
              itemCount: placeCategories.length, separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (_, i) {
                final (e, label) = placeCategories[i];
                final on = e == emoji;
                return Semantics(selected: on, button: true, label: label, child: GestureDetector(
                  onTap: () { Haptics.selection(); setState(() => emoji = e); },
                  child: AnimatedContainer(duration: AppDurations.base, width: 48, alignment: Alignment.center,
                    decoration: BoxDecoration(shape: BoxShape.circle,
                        color: on ? AppColors.primary : AppColors.glass,
                        border: Border.all(color: on ? AppColors.primary : AppColors.glassBorder)),
                    child: Text(e, style: const TextStyle(fontSize: 22)))));
              })),
            const SizedBox(height: AppSpacing.md),
            _Field(c, hint: 'Add a place', autofocus: false, caps: TextCapitalization.words, onSubmitted: (_) => _add(),
              prefix: null, suffix: Padding(padding: const EdgeInsets.only(right: AppSpacing.xs),
                child: AppIconButton(Icons.add_rounded, tooltip: 'Add place', color: AppColors.onPrimary,
                    background: AppColors.primary, size: 40, onPressed: _add))),
            const SizedBox(height: AppSpacing.lg),
          ],
          Row(children: [
            Text('My places', style: AppText.h4), const SizedBox(width: AppSpacing.sm),
            Text('${places.length}/$max', style: AppText.bodySmall),
          ]),
          const SizedBox(height: AppSpacing.mdSm),
          if (places.isEmpty)
            Text('Nothing here yet — add the first spot you’d take a date to.', style: AppText.bodySmall)
          else
            for (final p in places) Padding(padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AppCard(padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.xs, AppSpacing.sm),
                child: Row(children: [
                  Container(width: 40, height: 40, alignment: Alignment.center,
                      decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                      child: Text(p.emoji, style: const TextStyle(fontSize: 20))),
                  const SizedBox(width: AppSpacing.mdSm),
                  Expanded(child: Text(p.name, style: AppText.labelLarge.copyWith(fontSize: 15),
                      overflow: TextOverflow.ellipsis)),
                  AppIconButton(Icons.close_rounded, tooltip: 'Remove ${p.name}', color: AppColors.muted,
                      onPressed: () => _user.update(() => _user.places.remove(p))),
                ]))),
        ]);
      })));
}

// ─ Teasers ───────────────────────────────────────────────────────────────────
Future<String?> _pickPrompt(BuildContext context, {String? current}) {
  final used = {for (final t in _user.teasers) t.prompt}..remove(current);
  return showModalBottomSheet<String>(context: context, isScrollControlled: true, builder: (c) => SafeArea(
    child: ConstrainedBox(constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(c).height * .7),
      child: ListView(shrinkWrap: true, padding: const EdgeInsets.fromLTRB(AppSpacing.page, 0, AppSpacing.page, AppSpacing.md),
        children: [
          Text('Pick a prompt', style: AppText.h3),
          const SizedBox(height: AppSpacing.md),
          for (final p in teaserPrompts) if (!used.contains(p)) ChoiceTile(label: p, selected: p == current,
              onTap: () => Navigator.pop(c, p)),
        ]))));
}

class TeasersEditPage extends StatelessWidget {
  const TeasersEditPage({super.key});
  static const max = UserProfileStore.maxTeasers;

  Future<void> _add(BuildContext context) async {
    final prompt = await _pickPrompt(context);
    if (prompt != null && context.mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => TeaserAnswerPage(prompt: prompt)));
    }
  }

  @override
  Widget build(BuildContext context) => EditPageScaffold(deleteLabel: 'Teasers',
    canDelete: () => _user.teasers.isNotEmpty, onDelete: _user.teasers.clear,
    child: StepPage(title: 'My Teasers',
      subtitle: 'Answer up to $max prompts to give people an easy way to start a conversation.',
      child: _Watch((_) {
        final teasers = _user.teasers;
        return Column(children: [
          for (var i = 0; i < max; i++) Padding(padding: const EdgeInsets.only(bottom: AppSpacing.mdSm),
            child: i < teasers.length
                ? TeaserCard(teasers[i], onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => TeaserAnswerPage(prompt: teasers[i].prompt, index: i))))
                : _EmptyTeaser(onTap: () => _add(context), first: i == teasers.length)),
        ]);
      })));
}

class _EmptyTeaser extends StatelessWidget {
  final VoidCallback onTap; final bool first;
  const _EmptyTeaser({required this.onTap, required this.first});
  @override
  Widget build(BuildContext context) => Semantics(button: true, label: 'Add a teaser', child: GestureDetector(
    onTap: onTap,
    child: Container(height: 76, padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(color: AppColors.glass, borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: first ? AppColors.accent : AppColors.glassBorder, width: first ? 1.5 : 1)),
      child: Row(children: [
        const Icon(Icons.format_quote_rounded, color: AppColors.accent, size: 28),
        const SizedBox(width: AppSpacing.mdSm),
        Expanded(child: Text('Choose a prompt', style: AppText.labelLarge.copyWith(
            color: first ? AppColors.primary : AppColors.muted))),
        Icon(Icons.add_circle_outline_rounded, color: first ? AppColors.primary : AppColors.border),
      ]))));
}

/// Answers (or re-answers) one prompt with a voice note, words, or both. Unlike the other editors
/// this keeps a draft and only saves on "Save", so a half-finished answer isn't published.
class TeaserAnswerPage extends StatefulWidget {
  final String prompt; final int? index;
  const TeaserAnswerPage({super.key, required this.prompt, this.index});
  @override
  State<TeaserAnswerPage> createState() => _TeaserAnswerPageState();
}
class _TeaserAnswerPageState extends State<TeaserAnswerPage> {
  late String prompt = widget.prompt;
  late final _existing = widget.index == null ? null : _user.teasers[widget.index!];
  late final c = TextEditingController(text: _existing?.answer ?? '')..addListener(() => setState(() {}));
  late VoiceNote? voice = _existing?.voice;
  @override
  void dispose() { c.dispose(); super.dispose(); }

  bool get _canSave => c.text.trim().isNotEmpty || voice != null;

  void _save() {
    final t = Teaser(prompt, c.text.trim(), voice: voice), i = widget.index;
    _user.update(() => i == null ? _user.teasers.add(t) : _user.teasers[i] = t);
    showToast(context, context.l10n.teaserSaved, type: ToastType.success);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return EditPageScaffold(deleteLabel: 'Teaser',
      onDelete: widget.index == null ? null : () => _user.teasers.removeAt(widget.index!),
      footer: AppButton(l.save, onPressed: _canSave ? _save : null),
      child: StepPage(title: prompt, subtitle: l.teaserSubtitle,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          VoiceRecorderPanel(initial: voice, onChanged: (v) => setState(() => voice = v)),
          const SizedBox(height: AppSpacing.lg),
          // With a voice note the written answer becomes an optional caption.
          _Field(c, hint: voice == null ? l.yourAnswer : l.captionHint, minLines: 3, maxLength: 150, autofocus: false),
          const SizedBox(height: AppSpacing.sm),
          TextButton.icon(onPressed: () async {
              final p = await _pickPrompt(context, current: prompt);
              if (p != null) setState(() => prompt = p);
            },
            icon: const Icon(Icons.swap_horiz_rounded, color: AppColors.primary),
            label: Text(l.changePrompt, style: AppText.labelLarge.copyWith(color: AppColors.primary))),
        ])));
  }
}

// ─ Lifestyle (kids, smoking, sport, …) ───────────────────────────────────────
class LifestyleEditPage extends StatelessWidget {
  final LifestyleQuestion question;
  const LifestyleEditPage(this.question, {super.key});
  @override
  Widget build(BuildContext context) {
    final k = question.key;
    return EditPageScaffold(deleteLabel: k, canDelete: () => _user.lifestyle.containsKey(k),
      onDelete: () => _user.lifestyle.remove(k),
      child: StepPage(title: question.question, subtitle: 'Pick the answer that fits you best.',
        child: _Watch((_) => Column(children: [
          for (final o in question.options) ChoiceTile(label: o, selected: _user.lifestyle[k] == o, onTap: () {
            _user.update(() => _user.lifestyle[k] = o);
            Future.delayed(AppDurations.slow, () { if (context.mounted) Navigator.maybePop(context); });
          }),
        ]))));
  }
}

// ─ Reused onboarding steps ───────────────────────────────────────────────────
class AgeEditPage extends StatelessWidget {
  const AgeEditPage({super.key});
  @override
  Widget build(BuildContext context) => const EditPageScaffold(child: BirthdayStep());
}

class GenderEditPage extends StatelessWidget {
  const GenderEditPage({super.key});
  @override
  Widget build(BuildContext context) => const EditPageScaffold(child: GenderStep());
}

class HeightEditPage extends StatelessWidget {
  const HeightEditPage({super.key});
  @override
  Widget build(BuildContext context) => EditPageScaffold(deleteLabel: 'Height',
      canDelete: () => _user.heightCm != null, onDelete: () => _user.heightCm = null, child: const HeightStep());
}
