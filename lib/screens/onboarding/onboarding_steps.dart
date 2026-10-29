import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/haptics.dart';
import '../../data/profile_options.dart';
import '../../data/profile_store.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/onboarding_widgets.dart';
import '../../widgets/photo_grid.dart';
import '../../widgets/profile_bits.dart';

final _user = currentUser;

/// Rebuilds [builder] whenever the profile changes.
class _Watch extends StatelessWidget {
  final WidgetBuilder builder;
  const _Watch(this.builder);
  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: _user, builder: (c, _) => builder(c));
}

class _Note extends StatelessWidget {
  final IconData icon; final String text; final Color color;
  const _Note(this.icon, this.text, {this.color = AppColors.muted});
  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Icon(icon, size: 18, color: color), const SizedBox(width: AppSpacing.sm),
    Expanded(child: Text(text, style: AppText.bodySmall.copyWith(color: color))),
  ]);
}

// 1 ─ Name ───────────────────────────────────────────────────────────────────
class NameStep extends StatefulWidget {
  final VoidCallback onSubmit;
  const NameStep({super.key, required this.onSubmit});
  @override
  State<NameStep> createState() => _NameStepState();
}
class _NameStepState extends State<NameStep> {
  late final c = TextEditingController(text: _user.name);
  @override
  void dispose() { c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => StepPage(title: 'What’s your first name?',
    subtitle: 'This is how you’ll appear to people on Amour.',
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      TextField(controller: c, autofocus: true, textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.next, cursorColor: AppColors.primary,
        style: AppText.displayMedium.copyWith(color: AppColors.primary),
        inputFormatters: [LengthLimitingTextInputFormatter(24),
          FilteringTextInputFormatter.allow(RegExp(r"[\p{L}\p{M} '\-]", unicode: true))],
        onChanged: (v) => _user.update(() => _user.name = v),
        onSubmitted: (_) => widget.onSubmit(),
        decoration: InputDecoration(hintText: 'First name',
          hintStyle: AppText.displayMedium.copyWith(color: AppColors.border),
          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.border, width: 2)),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary, width: 2)))),
      const SizedBox(height: AppSpacing.lg),
      const _Note(Icons.lock_outline_rounded, 'Only your first name is shown. Your last name stays private.'),
    ]));
}

// 2 ─ Birthday ───────────────────────────────────────────────────────────────
class BirthdayStep extends StatefulWidget {
  const BirthdayStep({super.key});
  @override
  State<BirthdayStep> createState() => _BirthdayStepState();
}
class _BirthdayStepState extends State<BirthdayStep> {
  static const _months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August',
    'September', 'October', 'November', 'December'];
  final _lastYear = DateTime.now().year - 18, _span = 83;
  late DateTime d = _user.birthday ?? DateTime(_lastYear - 7, 6, 15);
  late final month = FixedExtentScrollController(initialItem: d.month - 1),
      day = FixedExtentScrollController(initialItem: d.day - 1),
      year = FixedExtentScrollController(initialItem: d.year - (_lastYear - _span + 1));

  int _daysIn(int y, int m) => DateTime(y, m + 1, 0).day;

  void _set({int? y, int? m, int? dd}) {
    final ny = y ?? d.year, nm = m ?? d.month, max = _daysIn(ny, nm);
    var nd = dd ?? d.day;
    if (nd > max) { nd = max; day.animateToItem(nd - 1, duration: AppDurations.base, curve: Curves.easeOut); }
    setState(() => d = DateTime(ny, nm, nd));
    _user.update(() => _user.birthday = d);
  }

  @override
  void dispose() { month.dispose(); day.dispose(); year.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => StepPage(title: 'When’s your birthday?',
    subtitle: 'Your age is shown on your profile — your birthday isn’t.',
    child: Column(children: [
      Stack(alignment: Alignment.center, children: [
        Container(height: 46, decoration: BoxDecoration(color: AppColors.secondary,
            borderRadius: BorderRadius.circular(AppRadius.standardCard))),
        Row(children: [
          Expanded(flex: 4, child: WheelPicker(controller: month, itemCount: 12, band: false,
              labelOf: (i) => _months[i], onChanged: (i) => _set(m: i + 1))),
          Expanded(flex: 2, child: WheelPicker(controller: day, itemCount: 31, band: false,
              labelOf: (i) => '${i + 1}', isEnabled: (i) => i < _daysIn(d.year, d.month),
              onChanged: (i) => _set(dd: i + 1))),
          Expanded(flex: 3, child: WheelPicker(controller: year, itemCount: _span, band: false,
              labelOf: (i) => '${_lastYear - _span + 1 + i}', onChanged: (i) => _set(y: _lastYear - _span + 1 + i))),
        ]),
      ]),
      const SizedBox(height: AppSpacing.xl),
      _Watch((_) {
        final age = _user.age ?? 0, ok = age >= 18;
        return AnimatedSwitcher(duration: AppDurations.base, child: AppCard(key: ValueKey(ok), child: Row(children: [
          Container(width: 48, height: 48, alignment: Alignment.center,
            decoration: BoxDecoration(color: ok ? AppColors.secondary : const Color(0x1FC94A4A), shape: BoxShape.circle),
            child: Icon(ok ? Icons.cake_outlined : Icons.block_rounded, color: ok ? AppColors.primary : AppColors.error)),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: ok
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('You’re $age', style: AppText.h3.copyWith(color: AppColors.primary)),
                  Text('Born ${_months[d.month - 1]} ${d.day}, ${d.year}', style: AppText.bodySmall),
                ])
              : Text('You must be 18 or older to use Amour.', style: AppText.bodyMedium.copyWith(color: AppColors.error))),
        ])));
      }),
    ]));
}

// 3 ─ Gender identity ────────────────────────────────────────────────────────
class GenderStep extends StatefulWidget {
  const GenderStep({super.key});
  @override
  State<GenderStep> createState() => _GenderStepState();
}
class _GenderStepState extends State<GenderStep> {
  late bool more = moreGenderOptions.contains(_user.gender);
  @override
  Widget build(BuildContext context) => StepPage(title: 'How do you identify?',
    subtitle: 'Choose what fits you best. You can change this any time.',
    child: _Watch((_) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      for (final o in genderOptions) ChoiceTile(label: o.label, icon: o.icon, selected: _user.gender == o.label,
          onTap: () => _user.update(() => _user.gender = o.label)),
      TextButton.icon(onPressed: () => setState(() => more = !more),
        icon: AnimatedRotation(turns: more ? .5 : 0, duration: AppDurations.base,
            child: const Icon(Icons.expand_more_rounded, color: AppColors.primary)),
        label: Text(more ? 'Fewer options' : 'More options', style: AppText.labelLarge.copyWith(color: AppColors.primary))),
      AnimatedSize(duration: AppDurations.base, curve: Curves.easeOut, alignment: Alignment.topCenter,
        child: more ? Padding(padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.md),
          child: Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: [
            for (final g in moreGenderOptions) SelectChip(g, selected: _user.gender == g,
                onTap: () => _user.update(() => _user.gender = g)),
          ])) : const SizedBox(width: double.infinity)),
      const SizedBox(height: AppSpacing.sm),
      AppCard(padding: EdgeInsets.zero, child: SwitchListTile.adaptive(activeTrackColor: AppColors.primary, value: _user.showGender,
        onChanged: (v) { Haptics.selection(); _user.update(() => _user.showGender = v); },
        title: Text('Show on my profile', style: AppText.labelLarge),
        subtitle: Text('Others will see this under your name.', style: AppText.bodySmall))),
    ])));
}

// 4 ─ Who to meet ────────────────────────────────────────────────────────────
class ShowMeStep extends StatelessWidget {
  const ShowMeStep({super.key});
  @override
  Widget build(BuildContext context) => StepPage(title: 'Who would you like to meet?',
    subtitle: 'We’ll use this to shape your Discover feed.',
    child: _Watch((_) => Column(children: [
      for (final o in showMeOptions) ChoiceTile(label: o.label, description: o.description, icon: o.icon,
          selected: _user.showMe == o.label, onTap: () => _user.update(() => _user.showMe = o.label)),
    ])));
}

// 5 ─ Height ─────────────────────────────────────────────────────────────────
class HeightStep extends StatefulWidget {
  const HeightStep({super.key});
  @override
  State<HeightStep> createState() => _HeightStepState();
}
class _HeightStepState extends State<HeightStep> {
  static const _minCm = 120, _maxCm = 220, _minIn = 48, _maxIn = 86;
  late FixedExtentScrollController wheel = _controllerFor(_user.metricHeight);

  int get _cm => _user.heightCm ?? 170;
  FixedExtentScrollController _controllerFor(bool metric) => FixedExtentScrollController(initialItem: metric
      ? (_cm - _minCm).clamp(0, _maxCm - _minCm)
      : ((_cm / 2.54).round() - _minIn).clamp(0, _maxIn - _minIn));

  void _toggle(bool metric) {
    if (metric == _user.metricHeight) return;
    final old = wheel;
    setState(() => wheel = _controllerFor(metric));
    WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
    _user.update(() => _user.metricHeight = metric);
  }

  @override
  void dispose() { wheel.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => StepPage(title: 'How tall are you?',
    subtitle: 'Totally optional — but it helps with matching preferences.',
    child: _Watch((_) {
      final metric = _user.metricHeight;
      return Column(children: [
        AppCard(padding: const EdgeInsets.all(AppSpacing.xl), child: Row(children: [
          AnimatedScale(scale: .55 + .45 * ((_cm - _minCm) / (_maxCm - _minCm)), duration: AppDurations.base,
              alignment: Alignment.bottomCenter,
              child: const Icon(Icons.accessibility_new_rounded, size: 72, color: AppColors.accent)),
          const SizedBox(width: AppSpacing.lg),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(formatHeight(_cm, metric: metric), style: AppText.displayLarge.copyWith(color: AppColors.primary)),
            Text('≈ ${formatHeight(_cm, metric: !metric)}', style: AppText.bodyMedium.copyWith(color: AppColors.muted)),
          ])),
        ])),
        const SizedBox(height: AppSpacing.xl),
        UnitToggle(options: const ['cm', 'ft / in'], index: metric ? 0 : 1, onChanged: (i) => _toggle(i == 0)),
        const SizedBox(height: AppSpacing.md),
        WheelPicker(key: ValueKey(metric), controller: wheel,
          itemCount: metric ? _maxCm - _minCm + 1 : _maxIn - _minIn + 1,
          labelOf: (i) => metric ? '${_minCm + i} cm' : '${(_minIn + i) ~/ 12}′ ${(_minIn + i) % 12}″',
          onChanged: (i) => _user.update(() => _user.heightCm = metric ? _minCm + i : ((_minIn + i) * 2.54).round())),
      ]);
    }));
}

// 6 ─ Education ──────────────────────────────────────────────────────────────
class EducationStep extends StatelessWidget {
  const EducationStep({super.key});
  @override
  Widget build(BuildContext context) => StepPage(title: 'What’s your education level?',
    subtitle: 'Pick your highest level — it shows on your profile.',
    child: _Watch((_) => Column(children: [
      for (final o in educationOptions) ChoiceTile(label: o.label, icon: o.icon,
          selected: _user.education == o.label, onTap: () => _user.update(() => _user.education = o.label)),
    ])));
}

// 7 ─ Looking for ────────────────────────────────────────────────────────────
class LookingForStep extends StatelessWidget {
  const LookingForStep({super.key});
  
  @override
  Widget build(BuildContext context) => StepPage(
    title: 'What are you looking for?',
    subtitle: 'Be honest — it helps everyone find the right fit. You can change it later.',
    child: _Watch((_) => GridView(
      shrinkWrap: true, 
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, 
        mainAxisExtent: 176, 
        mainAxisSpacing: AppSpacing.mdSm, 
        crossAxisSpacing: AppSpacing.mdSm,
      ),
      children: [
        for (final o in lookingForOptions) 
          _IntentCard(
            option: o, 
            selected: _user.lookingFor == o.label,
            onTap: () => _user.update(() => _user.lookingFor = o.label)
          )
      ]
    ))
  );
}

class _IntentCard extends StatefulWidget {
  final ChoiceOption option; 
  final bool selected; 
  final VoidCallback onTap;
  
  const _IntentCard({required this.option, required this.selected, required this.onTap});

  @override
  State<_IntentCard> createState() => _IntentCardState();
}

class _IntentCardState extends State<_IntentCard> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final fg = widget.selected ? AppColors.onPrimary : AppColors.text;
    
    return Semantics(
      selected: widget.selected, 
      button: true, 
      label: widget.option.label,
      child: AnimatedScale(
        scale: _down ? 0.97 : (widget.selected ? 1.03 : 1), 
        duration: AppDurations.base, 
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: AppDurations.base, 
          decoration: BoxDecoration(
            color: widget.selected ? AppColors.primary : AppColors.glass,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: widget.selected ? AppColors.primary : AppColors.glassBorder),
            boxShadow: widget.selected ? AppShadows.elevated : null
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.card),
              splashColor: fg.withOpacity(0.15),
              highlightColor: fg.withOpacity(0.05),
              onHighlightChanged: (isHighlighted) => setState(() => _down = isHighlighted),
              onTap: () { 
                Haptics.selection(); 
                widget.onTap(); 
              },
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    width: 52, 
                    height: 52, 
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.selected ? const Color(0x26FFFFFF) : AppColors.secondary
                    ),
                    child: Icon(
                      widget.option.icon, 
                      size: 26, 
                      color: widget.selected ? AppColors.onPrimary : AppColors.primary
                    )
                  ),
                  const SizedBox(height: AppSpacing.mdSm),
                  Text(
                    widget.option.label, 
                    textAlign: TextAlign.center, 
                    maxLines: 2, 
                    overflow: TextOverflow.ellipsis, 
                    style: AppText.labelLarge.copyWith(color: fg)
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.option.description!, 
                    textAlign: TextAlign.center, 
                    maxLines: 2, 
                    overflow: TextOverflow.ellipsis, 
                    style: AppText.bodySmall.copyWith(
                      fontSize: 12, 
                      color: widget.selected ? const Color(0xCCFFFFFF) : AppColors.muted
                    )
                  ),
                ])
              ),
            ),
          ),
        ),
      ),
    );
  }
}

//  8 ─ Interests──────────────────────────────────────────────────────────────
class InterestsStep extends StatelessWidget {
  static const min = 3, max = 5;
  const InterestsStep({super.key});
  
  @override
  Widget build(BuildContext context) => StepPage(title: 'What are you into?',
    subtitle: 'Pick $min to $max interests. They make great conversation starters.',
    child: _Watch((_) {
      final picked = _user.interests;
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        InterestChip('${picked.length} / $max selected', selected: picked.length >= min),
        const SizedBox(height: AppSpacing.lg),
        Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: [
          for (final i in interestOptions) 
            SelectChip(
              i, 
              selected: picked.contains(i),
              enabled: picked.contains(i) || picked.length < max,
              onTap: () => _user.update(() => picked.contains(i) ? picked.remove(i) : picked.add(i))
            ),
        ]),
      ]);
    }));
}
// 9 ─ Photos ─────────────────────────────────────────────────────────────────
class PhotosStep extends StatelessWidget {
  const PhotosStep({super.key});
  @override
  Widget build(BuildContext context) {
    final photos = _user.photos;
    return StepPage(title: 'Add your first photos',
      subtitle: 'Add at least ${PhotoManager.minPhotos} photos to continue. Your first photo is your main photo.',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        PhotoGrid(manager: photos, onAdd: () => addPhotos(context, photos),
            onPhotoTap: (p) => showPhotoOptions(context, photos, p)),
        const SizedBox(height: AppSpacing.md),
        ListenableBuilder(listenable: photos, builder: (_, __) {
          final missing = PhotoManager.minPhotos - photos.uploadedCount;
          final uploading = photos.photos.where((p) => p.status == PhotoStatus.uploading).length;
          final (icon, text, color) = photos.hasFailures
              ? (Icons.error_outline_rounded, 'Some uploads failed — tap a photo to retry.', AppColors.error)
              : uploading > 0
                  ? (Icons.cloud_upload_outlined, 'Uploading $uploading photo${uploading == 1 ? '' : 's'}…', AppColors.info)
                  : missing > 0
                      ? (Icons.add_photo_alternate_outlined, 'Add $missing more to continue', AppColors.muted)
                      : (Icons.check_circle_rounded, 'Looking good! Long-press a photo to reorder.', AppColors.success);
          return Row(children: [
            Expanded(child: _Note(icon, text, color: color)),
            Text('${photos.count}/${PhotoManager.maxPhotos}', style: AppText.labelMedium.copyWith(color: AppColors.muted)),
          ]);
        }),
        const SizedBox(height: AppSpacing.xl),
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Photo tips', style: AppText.h4),
          const SizedBox(height: AppSpacing.mdSm),
          for (final (icon, tip) in const [
            (Icons.face_retouching_natural_outlined, 'Show your face clearly — no sunglasses in your main photo.'),
            (Icons.person_outline_rounded, 'Be the only person in your main photo.'),
            (Icons.wb_sunny_outlined, 'Natural light and recent photos work best.'),
            (Icons.hiking_outlined, 'Add one doing something you love.'),
          ]) Padding(padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _Note(icon, tip, color: AppColors.text)),
        ])),
      ]));
  }
}