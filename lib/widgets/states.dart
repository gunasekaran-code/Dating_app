import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../l10n/match_text.dart';
import '../services/haptics.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'buttons.dart';

class EmptyState extends StatelessWidget {
  final IconData icon; final String title, message; final String? action; final VoidCallback? onAction;
  const EmptyState({super.key, required this.icon, required this.title, required this.message,
      this.action, this.onAction});
  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(AppSpacing.xxl),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 80, height: 80, decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
          child: Icon(icon, size: 36, color: AppColors.primary)),
      const SizedBox(height: AppSpacing.xl),
      Text(title, style: AppText.displaySmall, textAlign: TextAlign.center),
      const SizedBox(height: AppSpacing.sm),
      Text(message, style: AppText.bodyMedium.copyWith(color: AppColors.muted), textAlign: TextAlign.center),
      if (action != null) ...[const SizedBox(height: AppSpacing.xl),
        AppButton(action!, onPressed: onAction, expanded: false)],
    ])));
}

enum ToastType { success, error, info }
void showToast(BuildContext context, String msg, {ToastType type = ToastType.info}) {
  final color = switch (type) { ToastType.success => AppColors.success, ToastType.error => AppColors.error, _ => AppColors.info };
  final icon = switch (type) { ToastType.success => Icons.check_circle_rounded, ToastType.error => Icons.error_rounded, _ => Icons.info_rounded };
  switch (type) { case ToastType.success: Haptics.success(); case ToastType.error: Haptics.error(); case ToastType.info: }
  ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(
    content: Row(children: [Icon(icon, color: color, size: 20), const SizedBox(width: AppSpacing.sm),
      Expanded(child: Text(msg))]), duration: const Duration(seconds: 3)));
}

Future<bool> showConfirmDialog(BuildContext context, {required String title, required String message,
    required String confirm, bool destructive = false}) async {
  if (destructive) Haptics.warning();
  // Native iOS alert: frosted panel, stacked title/message, hairline-separated actions.
  final r = await showCupertinoDialog<bool>(context: context, barrierDismissible: true, builder: (c) => CupertinoAlertDialog(
    title: Text(title, style: AppText.h4),
    content: Padding(padding: const EdgeInsets.only(top: AppSpacing.xs),
        child: Text(message, style: AppText.bodyMedium.copyWith(color: AppColors.muted))),
    actions: [
      CupertinoDialogAction(onPressed: () => Navigator.pop(c, false),
          child: Text(context.l10n.cancel, style: AppText.bodyLarge.copyWith(color: AppColors.primary))),
      CupertinoDialogAction(isDefaultAction: true, isDestructiveAction: destructive,
          onPressed: () => Navigator.pop(c, true),
          child: Text(confirm, style: AppText.labelLarge.copyWith(fontSize: 16,
              color: destructive ? AppColors.error : AppColors.primary))),
    ]));
  return r ?? false;
}
