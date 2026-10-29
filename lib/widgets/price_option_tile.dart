import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';

/// One price option in a row of three (packs, plans). The selected tile gets a
/// filled header, a coloured border and a soft glow.
class PriceOptionTile extends StatelessWidget {
  final String tag, amount, unit, price; final String? caption;
  final bool selected; final Color color; final VoidCallback onTap;
  const PriceOptionTile({super.key, required this.tag, required this.amount, required this.unit,
      required this.price, this.caption, required this.selected, this.color = AppColors.primary,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(AppRadius.card);
    Widget fit(Text t) => FittedBox(fit: BoxFit.scaleDown, child: t);
    return Semantics(button: true, selected: selected, label: '$amount $unit, $price, $tag',
      child: GestureDetector(onTap: onTap, child: AnimatedScale(scale: selected ? 1 : .96,
        duration: AppDurations.base, curve: Curves.easeOutBack,
        child: AnimatedContainer(duration: AppDurations.base, curve: Curves.easeOutCubic,
          // Content (incl. the header band) runs edge to edge and is clipped to the card's
          // outer shape; the border is painted on top, so no sliver shows between them.
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: r,
            color: selected ? AppColors.glassStrong : AppColors.glass,
            boxShadow: [BoxShadow(color: color.withValues(alpha: selected ? .22 : 0),
                blurRadius: 24, offset: const Offset(0, 8))]),
          foregroundDecoration: BoxDecoration(borderRadius: r,
            border: Border.all(color: selected ? color : AppColors.border, width: selected ? 2 : 1)),
          child: Column(children: [
            AnimatedContainer(duration: AppDurations.base, width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 7),
              color: selected ? color : AppColors.secondary,
              child: fit(Text(tag, style: AppText.labelSmall.copyWith(
                  color: selected ? AppColors.onPrimary : AppColors.muted)))),
            Expanded(child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xs, AppSpacing.md, AppSpacing.xs, AppSpacing.md),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                fit(Text(amount, style: AppText.h1)),
                fit(Text(unit, style: AppText.bodyMedium)),
                const SizedBox(height: AppSpacing.sm),
                fit(Text(price, style: AppText.labelLarge.copyWith(color: selected ? color : AppColors.text))),
                if (caption != null) fit(Text(caption!, style: AppText.bodySmall)),
              ]))),
          ])))));
  }
}
