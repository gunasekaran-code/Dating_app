import 'package:flutter/material.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/glass_card.dart';

/// Shared layout for Sign in / Create account: glass backdrop, heading, form in a [GlassCard].
class AuthScaffold extends StatelessWidget {
  final String title, subtitle;
  final List<Widget> form;
  final Widget? footer;
  const AuthScaffold({super.key, required this.title, required this.subtitle, required this.form, this.footer});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: SafeArea(child: ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        Text(title, style: AppText.displaySmall),
        const SizedBox(height: AppSpacing.sm),
        Text(subtitle, style: AppText.bodyMedium.copyWith(color: AppColors.muted)),
        const SizedBox(height: AppSpacing.xxl),
        GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: form)),
        if (footer != null) ...[const SizedBox(height: AppSpacing.xl), footer!],
      ])));
}

/// "Question? Action" line used under the auth card.
class AuthSwitchLink extends StatelessWidget {
  final String question, action; final VoidCallback onTap;
  const AuthSwitchLink({super.key, required this.question, required this.action, required this.onTap});
  @override
  Widget build(BuildContext context) => Wrap(alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center, children: [
    Text(question, style: AppText.bodyMedium.copyWith(color: AppColors.muted)),
    TextButton(onPressed: onTap, style: TextButton.styleFrom(foregroundColor: AppColors.primary),
        child: Text(action, style: AppText.labelLarge.copyWith(color: AppColors.primary))),
  ]);
}
