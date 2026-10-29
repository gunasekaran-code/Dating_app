import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';

class AppInput extends StatelessWidget {
  final String label; final String? hint, error; final bool obscure, enabled;
  final TextEditingController? controller; final TextInputType? keyboard; final IconData? prefix;
  const AppInput({super.key, required this.label, this.hint, this.error, this.obscure = false,
      this.enabled = true, this.controller, this.keyboard, this.prefix});

  OutlineInputBorder _b(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.input), borderSide: BorderSide(color: c, width: w));

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: AppText.labelLarge),
    const SizedBox(height: AppSpacing.sm),
    TextField(controller: controller, obscureText: obscure, enabled: enabled, keyboardType: keyboard,
      style: AppText.bodyLarge, cursorColor: AppColors.primary,
      decoration: InputDecoration(hintText: hint, hintStyle: AppText.bodyLarge.copyWith(color: AppColors.muted),
        prefixIcon: prefix == null ? null : Icon(prefix, color: AppColors.muted, size: 20),
        filled: true, fillColor: enabled ? AppColors.glass : AppColors.disabledBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
        enabledBorder: _b(error != null ? AppColors.error : AppColors.glassBorder),
        focusedBorder: _b(error != null ? AppColors.error : AppColors.primary, 1.5),
        disabledBorder: _b(AppColors.glassBorder))),
    if (error != null) ...[
      const SizedBox(height: AppSpacing.xs),
      Text(error!, style: AppText.bodySmall.copyWith(color: AppColors.error)),
    ],
  ]);
}
