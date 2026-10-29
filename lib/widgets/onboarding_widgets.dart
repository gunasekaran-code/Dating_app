import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../services/haptics.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';

class SegmentedProgress extends StatelessWidget {
  final int total, current;
  const SegmentedProgress({super.key, required this.total, required this.current});
  @override
  Widget build(BuildContext context) => Semantics(label: 'Step ${current + 1} of $total', child: Row(children: [
    for (var i = 0; i < total; i++) Expanded(child: AnimatedContainer(duration: AppDurations.slow, curve: Curves.easeOut,
      height: 4, margin: EdgeInsets.only(right: i == total - 1 ? 0 : 4),
      decoration: BoxDecoration(color: i <= current ? AppColors.primary : AppColors.border,
          borderRadius: BorderRadius.circular(AppRadius.pill)))),
  ]));
}

/// Standard layout for one onboarding question: serif title, muted subtitle, content.
class StepPage extends StatelessWidget {
  final String title; final String? subtitle; final Widget child; final bool scroll;
  const StepPage({super.key, required this.title, this.subtitle, required this.child, this.scroll = true});
  @override
  Widget build(BuildContext context) {
    final header = [
      Text(title, style: AppText.displaySmall),
      if (subtitle != null) ...[
        const SizedBox(height: AppSpacing.sm),
        Text(subtitle!, style: AppText.bodyMedium.copyWith(color: AppColors.muted)),
      ],
      const SizedBox(height: AppSpacing.xxl),
    ];
    const pad = EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xl);
    return scroll
        ? ListView(padding: pad, children: [...header, child])
        : Padding(padding: pad, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [...header, Expanded(child: child)]));
  }
}

/// Full-width selectable row with an icon or emoji and an animated check.
class ChoiceTile extends StatelessWidget {
  final String label; final String? description, emoji; final IconData? icon;
  final bool selected; final VoidCallback onTap;
  const ChoiceTile({super.key, required this.label, this.description, this.emoji, this.icon,
      required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.mdSm),
    child: Semantics(selected: selected, button: true, label: label, child: GestureDetector(
      onTap: () { Haptics.selection(); onTap(); },
      child: AnimatedContainer(duration: AppDurations.base, curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.secondary : AppColors.glass,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: selected ? AppColors.primary : AppColors.glassBorder, width: selected ? 1.5 : 1)),
        child: Row(children: [
          if (icon != null || emoji != null) ...[
            AnimatedContainer(duration: AppDurations.base, width: 40, height: 40, alignment: Alignment.center,
              decoration: BoxDecoration(color: selected ? AppColors.primary : AppColors.secondary, shape: BoxShape.circle),
              child: emoji != null ? Text(emoji!, style: const TextStyle(fontSize: 20))
                  : Icon(icon, size: 20, color: selected ? AppColors.onPrimary : AppColors.primary)),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: AppText.labelLarge.copyWith(fontSize: 15)),
            if (description != null) Text(description!, style: AppText.bodySmall),
          ])),
          _Check(selected: selected),
        ])))));
}

class _Check extends StatelessWidget {
  final bool selected;
  const _Check({required this.selected});
  @override
  Widget build(BuildContext context) => AnimatedContainer(duration: AppDurations.base, width: 24, height: 24,
    decoration: BoxDecoration(shape: BoxShape.circle, color: selected ? AppColors.primary : Colors.transparent,
        border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: 1.5)),
    child: AnimatedScale(scale: selected ? 1 : 0, duration: AppDurations.base, curve: Curves.easeOutBack,
        child: const Icon(Icons.check_rounded, size: 16, color: AppColors.onPrimary)));
}

/// Pill chip used for multi-select lists (interests, extra identities).
class SelectChip extends StatefulWidget {
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const SelectChip(this.label, {
    super.key,
    required this.selected,
    this.enabled = true,
    required this.onTap,
  });

  @override
  State<SelectChip> createState() => _SelectChipState();
}

class _SelectChipState extends State<SelectChip> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final fg = widget.selected ? AppColors.onPrimary : AppColors.text;
    final disabled = !widget.enabled && !widget.selected;

    return Semantics(
      selected: widget.selected,
      button: true,
      label: widget.label,
      child: AnimatedScale(
        scale: _down ? 0.95 : (widget.selected ? 1.03 : 1.0),
        duration: AppDurations.fast,
        child: AnimatedContainer(
          duration: AppDurations.base,
          decoration: BoxDecoration(
            color: widget.selected ? AppColors.primary : AppColors.glass,
            borderRadius: BorderRadius.circular(100), // Pill shape for chips
            border: Border.all(
              color: widget.selected ? AppColors.primary : AppColors.glassBorder,
            ),
            boxShadow: widget.selected ? AppShadows.elevated : null,
          ),
          child: Material(
            type: MaterialType.transparency, // Allows AnimatedContainer color to show through
            child: InkWell(
              borderRadius: BorderRadius.circular(100),
              splashColor: fg.withOpacity(0.15), // Dynamic touch-origin ripple
              highlightColor: fg.withOpacity(0.05),
              onHighlightChanged: (isHighlighted) {
                if (!disabled) setState(() => _down = isHighlighted);
              },
              onTap: disabled ? null : () {
                Haptics.selection();
                widget.onTap();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
                child: Text(
                  widget.label,
                  style: AppText.labelLarge.copyWith(
                    color: disabled ? AppColors.disabledText : fg,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Two-option segmented control (e.g. cm / ft).
class UnitToggle extends StatelessWidget {
  final List<String> options; final int index; final ValueChanged<int> onChanged;
  const UnitToggle({super.key, required this.options, required this.index, required this.onChanged});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(AppSpacing.xs),
    decoration: BoxDecoration(color: AppColors.glass, borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.glassBorder)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      for (var i = 0; i < options.length; i++) GestureDetector(
        onTap: () { if (i == index) return; Haptics.selection(); onChanged(i); },
        child: AnimatedContainer(duration: AppDurations.base,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          decoration: BoxDecoration(color: i == index ? AppColors.card : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.pill), boxShadow: i == index ? AppShadows.card : null),
          child: Text(options[i], style: AppText.labelLarge.copyWith(
              color: i == index ? AppColors.primary : AppColors.muted)))),
    ]));
}

/// Scroll wheel with a highlighted selection band. Works with touch, mouse drag and scroll wheel.
class WheelPicker extends StatefulWidget {
  final FixedExtentScrollController controller;
  final int itemCount; final String Function(int) labelOf; final ValueChanged<int> onChanged;
  final bool Function(int)? isEnabled; final double height;
  /// Set false when several wheels share one band drawn by the parent.
  final bool band;
  const WheelPicker({super.key, required this.controller, required this.itemCount, required this.labelOf,
      required this.onChanged, this.isEnabled, this.height = 220, this.band = true});
  @override
  State<WheelPicker> createState() => _WheelPickerState();
}
class _WheelPickerState extends State<WheelPicker> {
  static const _extent = 46.0;
  late int selected = widget.controller.initialItem;
  @override
  Widget build(BuildContext context) => SizedBox(height: widget.height, child: Stack(children: [
    if (widget.band) Center(child: Container(height: _extent, decoration: BoxDecoration(color: AppColors.glassStrong,
        borderRadius: BorderRadius.circular(AppRadius.standardCard)))),
    ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(dragDevices: PointerDeviceKind.values.toSet()),
      child: ListWheelScrollView.useDelegate(controller: widget.controller, itemExtent: _extent,
        physics: const FixedExtentScrollPhysics(), diameterRatio: 1.5, perspective: .004,
        overAndUnderCenterOpacity: .5,
        onSelectedItemChanged: (i) { Haptics.selection(); setState(() => selected = i); widget.onChanged(i); },
        childDelegate: ListWheelChildBuilderDelegate(childCount: widget.itemCount, builder: (_, i) {
          final enabled = widget.isEnabled?.call(i) ?? true;
          return Center(child: Text(widget.labelOf(i), style: (i == selected ? AppText.h3 : AppText.bodyLarge)
              .copyWith(color: !enabled ? AppColors.disabledText : i == selected ? AppColors.primary : AppColors.text)));
        }))),
  ]));
}
