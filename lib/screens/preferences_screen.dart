import 'package:flutter/material.dart';
import '../data/preferences_store.dart';
import '../data/profile_options.dart';
import '../data/profile_store.dart';
import '../services/haptics.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import '../widgets/buttons.dart';
import '../widgets/profile_bits.dart';
import '../widgets/states.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});
  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  // Draft copy — only written to [discoveryPrefs] on confirm.
  late String showMe = discoveryPrefs.showMe;
  late RangeValues ageRange = discoveryPrefs.ageRange;
  late RangeValues heightRange = discoveryPrefs.heightRange;
  late final Map<String, Set<String>> filters = {
    for (final e in discoveryPrefs.filters.entries) e.key: {...e.value}};

  void _reset() {
    setState(() {
      showMe = 'Everyone';
      ageRange = DiscoveryPreferences.defaultAge;
      heightRange = DiscoveryPreferences.defaultHeight;
      filters.clear();
    });
    showToast(context, 'Preferences reset to default');
  }

  void _toggle(String group, String option) => setState(() {
    final selected = filters.putIfAbsent(group, () => {});
    selected.contains(option) ? selected.remove(option) : selected.add(option);
  });

  Future<void> _confirm() async {
    discoveryPrefs.save(showMe: showMe, ageRange: ageRange, heightRange: heightRange, filters: filters);
    Haptics.success();
    await showModalBottomSheet(context: context, builder: (c) => const _UpdatedSheet());
    if (mounted) Navigator.pop(context);
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.mdSm),
    child: Text(text, style: AppText.h4));

  Widget _group(FilterGroup g) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.xl),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _label(g.title),
      Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: [
        for (final o in g.options)
          InterestChip(o, selected: filters[g.title]?.contains(o) ?? false, onTap: () => _toggle(g.title, o)),
      ]),
    ]));

  @override
  Widget build(BuildContext context) {
    String height(double cm) => formatHeight(cm.round(), metric: currentUser.metricHeight);
    return Scaffold(
      appBar: AppBar(actions: [
        TextButton(onPressed: _reset,
            child: Text('Reset', style: AppText.labelLarge.copyWith(color: AppColors.primary))),
        const SizedBox(width: AppSpacing.sm),
      ]),
      body: ListView(padding: const EdgeInsets.fromLTRB(AppSpacing.page, 0, AppSpacing.page, AppSpacing.xl), children: [
        Text('Preferences', style: AppText.h1),
        const SizedBox(height: AppSpacing.xs),
        Text('Refine your search criteria', style: AppText.bodySmall),
        const SizedBox(height: AppSpacing.xl),

        _label("I'm looking for"),
        Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: [
          for (final g in lookingForGenderOptions)
            InterestChip(g, selected: showMe == g, onTap: () => setState(() => showMe = g)),
        ]),
        const SizedBox(height: AppSpacing.xl),

        _label('Age range'),
        _RangeCard(values: ageRange, min: DiscoveryPreferences.minAge, max: DiscoveryPreferences.maxAge,
            format: (v) => '${v.round()}', onChanged: (v) => setState(() => ageRange = v)),
        const SizedBox(height: AppSpacing.xxl),

        Padding(padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.md),
            child: Text('ADVANCED FILTERS', style: AppText.labelSmall.copyWith(color: AppColors.muted))),
        ...relationshipFilters.map(_group),

        _label('Height'),
        _RangeCard(values: heightRange, min: DiscoveryPreferences.minHeightCm, max: DiscoveryPreferences.maxHeightCm,
            format: height, onChanged: (v) => setState(() => heightRange = v)),
        const SizedBox(height: AppSpacing.xl),

        ...lifestyleFilters.map(_group),
      ]),
      bottomNavigationBar: SafeArea(child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.sm, AppSpacing.page, AppSpacing.md),
        child: AppButton('Confirm my preferences', onPressed: _confirm))),
    );
  }
}

class _RangeCard extends StatelessWidget {
  final RangeValues values; final double min, max;
  final String Function(double) format; final ValueChanged<RangeValues> onChanged;
  const _RangeCard({required this.values, required this.min, required this.max,
      required this.format, required this.onChanged});

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
    child: Column(children: [
      Row(children: [
        Text(format(values.start), style: AppText.h4.copyWith(color: AppColors.primary)),
        const Spacer(),
        Text(format(values.end), style: AppText.h4.copyWith(color: AppColors.primary)),
      ]),
      SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 4,
          activeTrackColor: AppColors.primary, inactiveTrackColor: AppColors.secondary,
          thumbColor: AppColors.primary, overlayColor: AppColors.primary.withValues(alpha: .12),
          rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 11),
        ),
        child: RangeSlider(values: values, min: min, max: max, divisions: (max - min).round(),
            labels: RangeLabels(format(values.start), format(values.end)),
            onChanged: (v) { if (v != values) Haptics.selection(); onChanged(v); }),
      ),
    ]));
}

class _UpdatedSheet extends StatelessWidget {
  const _UpdatedSheet();

  @override
  Widget build(BuildContext context) => SafeArea(child: Padding(
    padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xl),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Stack(clipBehavior: Clip.none, children: [
        Container(width: 88, height: 88,
            decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
            child: const Icon(Icons.favorite_rounded, size: 40, color: AppColors.primary)),
        Positioned(top: -2, right: -2, child: Container(width: 30, height: 30,
            decoration: BoxDecoration(color: AppColors.success, shape: BoxShape.circle,
                border: Border.all(color: AppColors.card, width: 3)),
            child: const Icon(Icons.check_rounded, size: 16, color: AppColors.onPrimary))),
      ]),
      const SizedBox(height: AppSpacing.lg),
      Text('Preferences updated', style: AppText.displaySmall, textAlign: TextAlign.center),
      const SizedBox(height: AppSpacing.sm),
      Text('Your preferences will be applied to future matches.',
          style: AppText.bodyMedium.copyWith(color: AppColors.muted), textAlign: TextAlign.center),
      const SizedBox(height: AppSpacing.xl),
      AppButton('Got it', onPressed: () => Navigator.pop(context)),
    ])));
}
