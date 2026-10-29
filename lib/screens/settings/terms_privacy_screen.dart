import 'package:flutter/material.dart';
import '../../data/support_content.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/onboarding_widgets.dart';
import '../../widgets/profile_bits.dart';
import '../../widgets/settings_widgets.dart';
import '../../widgets/states.dart';
import '../../widgets/verification_widgets.dart';
import 'help_screen.dart';

/// Settings → Terms & privacy: both documents behind a toggle, plus privacy controls.
class TermsPrivacyScreen extends StatefulWidget {
  /// 0 = Terms of service, 1 = Privacy policy.
  final int initialTab;
  const TermsPrivacyScreen({super.key, this.initialTab = 0});
  @override
  State<TermsPrivacyScreen> createState() => _TermsPrivacyScreenState();
}
class _TermsPrivacyScreenState extends State<TermsPrivacyScreen> {
  late int tab = widget.initialTab;

  @override
  Widget build(BuildContext context) {
    final terms = tab == 0, sections = terms ? termsSections : privacySections;
    return VerificationPage(title: 'Terms & privacy', children: [
      Center(child: UnitToggle(options: const ['Terms', 'Privacy'], index: tab, onChanged: (i) => setState(() => tab = i))),
      const SizedBox(height: AppSpacing.xl),
      AnimatedSwitcher(duration: AppDurations.base, child: Column(key: ValueKey(tab),
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(terms ? 'Terms of service' : 'Privacy policy', style: AppText.displaySmall),
          const SizedBox(height: AppSpacing.sm),
          const StatusPill('Last updated $policyUpdated', color: AppColors.info, icon: Icons.update_rounded),
          const SizedBox(height: AppSpacing.md),
          Text(terms
              ? 'These terms explain the rules for using Amour. By creating an account you agree to them.'
              : 'Your privacy matters. Here’s what we collect, why, and the choices you have.',
              style: AppText.bodyMedium.copyWith(color: AppColors.muted)),
          const SizedBox(height: AppSpacing.lg),
          for (var i = 0; i < sections.length; i++) Padding(padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: AppCard(child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 28, height: 28, alignment: Alignment.center,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: Text('${i + 1}', style: AppText.labelMedium.copyWith(color: AppColors.onPrimary))),
              const SizedBox(width: AppSpacing.mdSm),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(sections[i].title, style: AppText.labelLarge.copyWith(fontSize: 15)),
                const SizedBox(height: AppSpacing.xs),
                Text(sections[i].body, style: AppText.bodyMedium.copyWith(color: AppColors.muted)),
              ])),
            ]))),
          if (!terms) ...[
            const SizedBox(height: AppSpacing.md),
            const SectionLabel('Your data'),
            RowsCard([
              SettingsRow(Icons.download_rounded, 'Download my data', subtitle: 'Get a copy by email within 48 hours',
                  onTap: () => showToast(context, 'Request received — we’ll email your data soon', type: ToastType.success)),
              SettingsRow(Icons.cookie_outlined, 'Personalised ads', subtitle: 'Off',
                  onTap: () => showToast(context, 'Amour doesn’t show personalised ads')),
            ]),
          ],
        ])),
      const SizedBox(height: AppSpacing.lg),
      Center(child: TextButton.icon(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactSupportScreen(topic: 'Other'))),
        icon: const Icon(Icons.help_outline_rounded, size: 18, color: AppColors.primary),
        label: Text('Questions? Contact us', style: AppText.labelLarge.copyWith(color: AppColors.primary)))),
    ]);
  }
}
