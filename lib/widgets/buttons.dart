import 'package:flutter/material.dart';
import '../services/haptics.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';

enum AppButtonVariant { primary, secondary, outline, ghost }

class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool loading, expanded;
  final IconData? icon;
  /// Overrides the primary variant's fill (e.g. a plan's accent colour).
  final Color? color;
  /// Shown before the label in place of [icon], e.g. an image.
  final Widget? leading;
  const AppButton(this.label, {super.key, this.onPressed, this.variant = AppButtonVariant.primary,
      this.loading = false, this.expanded = true, this.icon, this.color, this.leading});
  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _down = false;
  
  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null || widget.loading;
    Color bg, fg; 
    BorderSide side = BorderSide.none;
    
    switch (widget.variant) {
      case AppButtonVariant.primary: bg = widget.color ?? AppColors.primary; fg = AppColors.onPrimary;
      case AppButtonVariant.secondary: bg = AppColors.secondary; fg = AppColors.primary;
      case AppButtonVariant.outline: bg = Colors.transparent; fg = AppColors.primary;
        side = const BorderSide(color: AppColors.primary);
      case AppButtonVariant.ghost: bg = Colors.transparent; fg = AppColors.primary;
    }
    
    if (disabled && !widget.loading) {
      bg = widget.variant == AppButtonVariant.ghost ? Colors.transparent : AppColors.disabledBg;
      fg = AppColors.disabledText; 
      side = BorderSide.none;
    }
    
    final child = widget.loading
        ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: fg))
        : Row(mainAxisSize: MainAxisSize.min, children: [
            if (widget.leading != null) ...[widget.leading!, const SizedBox(width: AppSpacing.sm)]
            else if (widget.icon != null) ...[Icon(widget.icon, size: 20, color: fg), const SizedBox(width: AppSpacing.sm)],
            Flexible(child: Text(widget.label, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: AppText.button.copyWith(color: fg))),
          ]);
          
    return Semantics(
      button: true, 
      enabled: !disabled, 
      label: widget.label,
      child: AnimatedScale(
        scale: _down ? 0.97 : 1, 
        duration: AppDurations.fast,
        child: Material(
          color: bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
            side: side,
          ),
          child: InkWell(
            // Handles the touch ripple effect from the exact touch origin
            borderRadius: BorderRadius.circular(AppRadius.button),
            onTap: disabled ? null : () {
              // Text-style ghost buttons stay silent; filled and outlined ones give a light tap.
              if (widget.variant != AppButtonVariant.ghost) Haptics.light();
              widget.onPressed!();
            },
            splashColor: fg.withOpacity(0.15), // Dynamic ripple color based on text color
            highlightColor: fg.withOpacity(0.05), // Subtle hover color
            onHighlightChanged: (isHighlighted) {
              if (!disabled) setState(() => _down = isHighlighted);
            },
            child: Container(
              height: 52,
              width: widget.expanded ? double.infinity : null,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              alignment: Alignment.center, 
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class AppIconButton extends StatelessWidget {
  final IconData icon; final VoidCallback? onPressed; final String tooltip;
  final Color? color, background; final double size;
  /// Replaces the icon, e.g. with an image.
  final Widget? child;
  const AppIconButton(this.icon, {super.key, required this.tooltip, this.onPressed,
      this.color, this.background, this.size = 44, this.child});
  @override
  Widget build(BuildContext context) => Tooltip(message: tooltip,
    child: Material(color: background ?? Colors.transparent, shape: const CircleBorder(),
      child: InkWell(customBorder: const CircleBorder(), onTap: onPressed,
        child: SizedBox(width: size, height: size,
          child: Center(child: child ?? Icon(icon, size: 22, color: color ?? AppColors.text))))));
}