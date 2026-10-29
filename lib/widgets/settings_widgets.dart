import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/haptics.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'profile_bits.dart';

/// Small uppercase heading above a group of settings.
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.sm),
    child: Text(text.toUpperCase(), style: AppText.labelSmall.copyWith(color: AppColors.muted, letterSpacing: .6)));
}

/// Rounded tinted square holding an icon, used at the start of rows.
class IconTile extends StatelessWidget {
  final IconData icon; final Color color, background; final double size;
  const IconTile(this.icon, {super.key, this.color = AppColors.primary, this.background = AppColors.secondary,
      this.size = 40});
  @override
  Widget build(BuildContext context) => Container(width: size, height: size,
    decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(AppRadius.standardCard)),
    child: Icon(icon, size: size * .5, color: color));
}

/// Tappable row: icon tile, title, optional subtitle and trailing widget (chevron by default).
class SettingsRow extends StatelessWidget {
  final IconData icon; final String title; final String? subtitle; final Widget? trailing;
  final VoidCallback? onTap; final Color? color;
  const SettingsRow(this.icon, this.title, {super.key, this.subtitle, this.trailing, this.onTap, this.color});
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.mdSm),
    child: Row(children: [
      IconTile(icon, color: color ?? AppColors.primary,
          background: color == null ? AppColors.secondary : color!.withValues(alpha: .12)),
      const SizedBox(width: AppSpacing.md),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: AppText.labelLarge.copyWith(fontSize: 15, color: color ?? AppColors.text)),
        if (subtitle != null) Text(subtitle!, style: AppText.bodySmall),
      ])),
      trailing ?? const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
    ])));
}

/// [AppCard] holding rows separated by hairlines.
class RowsCard extends StatelessWidget {
  final List<Widget> rows;
  const RowsCard(this.rows, {super.key});
  @override
  Widget build(BuildContext context) => AppCard(padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
    child: Column(children: [
      for (var i = 0; i < rows.length; i++) ...[if (i > 0) const Divider(indent: 72, endIndent: AppSpacing.md), rows[i]],
    ]));
}

/// Small coloured pill, e.g. "Verified" / "Not verified".
class StatusPill extends StatelessWidget {
  final String label; final Color color; final IconData? icon;
  const StatusPill(this.label, {super.key, required this.color, this.icon});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
    decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(AppRadius.pill)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      if (icon != null) ...[Icon(icon, size: 13, color: color), const SizedBox(width: 3)],
      Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
          style: AppText.labelSmall.copyWith(color: color))),
    ]));
}

/// Card that expands to reveal [body] — FAQs, safety tips, policy sections.
class ExpandableCard extends StatefulWidget {
  final String title, body; final IconData? icon; final bool initiallyOpen;
  const ExpandableCard({super.key, required this.title, required this.body, this.icon, this.initiallyOpen = false});
  @override
  State<ExpandableCard> createState() => _ExpandableCardState();
}
class _ExpandableCardState extends State<ExpandableCard> {
  late bool open = widget.initiallyOpen;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: Semantics(expanded: open, button: true, child: AppCard(padding: EdgeInsets.zero, child: InkWell(
      onTap: () { Haptics.selection(); setState(() => open = !open); },
      child: Padding(padding: const EdgeInsets.all(AppSpacing.md), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            if (widget.icon != null) ...[IconTile(widget.icon!, size: 36), const SizedBox(width: AppSpacing.mdSm)],
            Expanded(child: Text(widget.title, style: AppText.labelLarge.copyWith(fontSize: 15))),
            AnimatedRotation(turns: open ? .5 : 0, duration: AppDurations.base,
                child: const Icon(Icons.expand_more_rounded, color: AppColors.muted)),
          ]),
          AnimatedSize(duration: AppDurations.base, curve: Curves.easeOut, alignment: Alignment.topCenter,
            child: open
                ? Padding(padding: EdgeInsets.only(top: AppSpacing.sm, left: widget.icon != null ? 48 : 0),
                    child: Text(widget.body, style: AppText.bodyMedium.copyWith(color: AppColors.muted)))
                : const SizedBox(width: double.infinity)),
        ]))))));
}

/// Six boxes for a one-time code, backed by a single invisible text field.
class CodeInput extends StatefulWidget {
  final int length; final ValueChanged<String> onChanged; final ValueChanged<String>? onCompleted;
  final bool error;
  const CodeInput({super.key, this.length = 6, required this.onChanged, this.onCompleted, this.error = false});
  @override
  State<CodeInput> createState() => _CodeInputState();
}
class _CodeInputState extends State<CodeInput> {
  final c = TextEditingController(), focus = FocusNode();
  @override
  void initState() {
    super.initState();
    focus.addListener(() => setState(() {}));
  }
  @override
  void dispose() { c.dispose(); focus.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final code = c.text;
    return Stack(children: [
      Row(children: [
        for (var i = 0; i < widget.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.sm),
          Expanded(child: AnimatedContainer(duration: AppDurations.fast, height: 56, alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.glassStrong, borderRadius: BorderRadius.circular(AppRadius.input),
              border: Border.all(width: 1.5, color: widget.error
                  ? AppColors.error
                  : focus.hasFocus && i == code.length.clamp(0, widget.length - 1) ? AppColors.primary
                  : i < code.length ? AppColors.accent : AppColors.glassBorder)),
            child: Text(i < code.length ? code[i] : '', style: AppText.h2.copyWith(color: AppColors.primary)))),
        ],
      ]),
      Positioned.fill(child: Opacity(opacity: 0, child: TextField(controller: c, focusNode: focus, autofocus: true,
        keyboardType: TextInputType.number, showCursor: false, enableInteractiveSelection: false,
        autofillHints: const [AutofillHints.oneTimeCode],
        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(widget.length)],
        onChanged: (v) {
          setState(() {});
          widget.onChanged(v);
          if (v.length == widget.length) widget.onCompleted?.call(v);
        }))),
    ]);
  }
}
