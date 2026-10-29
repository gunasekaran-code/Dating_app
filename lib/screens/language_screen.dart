import 'package:flutter/material.dart';
import '../data/locale_store.dart';
import '../l10n/app_localizations.dart';
import '../l10n/match_text.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import '../widgets/onboarding_widgets.dart';
import '../widgets/states.dart';
import '../widgets/verification_widgets.dart';

/// Welcome / Settings → App language: English, Tamil, Malayalam, Hindi, or follow the phone.
class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  void _choose(BuildContext context, AppLanguage? language) {
    final added = appLocale.choose(language);
    if (added && language != null) {
      // The tree is still in the old language this frame, so look the new one up directly.
      showToast(context, lookupAppLocalizations(language.locale).addedSpokenLanguage(language.nativeName),
          type: ToastType.success);
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: appLocale, builder: (context, _) {
    final l = context.l10n, current = appLocale.language;
    return VerificationPage(title: l.appLanguage, children: [
      Text(l.appLanguageSubtitle, style: AppText.bodyMedium.copyWith(color: AppColors.muted)),
      const SizedBox(height: AppSpacing.xl),
      ChoiceTile(label: l.deviceLanguage, description: l.deviceLanguageSubtitle, icon: Icons.smartphone_rounded,
          selected: current == null, onTap: () => _choose(context, null)),
      for (final lang in appLanguages)
        ChoiceTile(label: lang.nativeName, icon: Icons.translate_rounded,
            description: lang.nativeName == lang.spokenName ? null : lang.spokenName,
            selected: current?.code == lang.code, onTap: () => _choose(context, lang)),
    ]);
  });
}

/// Small "🌐 தமிழ்" pill that opens [LanguageScreen], for screens shown before sign-in.
class LanguagePill extends StatelessWidget {
  const LanguagePill({super.key});
  @override
  Widget build(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    final name = appLanguages.firstWhere((l) => l.code == code, orElse: () => appLanguages.first).nativeName;
    return Semantics(button: true, label: context.l10n.appLanguage, child: TextButton.icon(
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LanguageScreen())),
      style: TextButton.styleFrom(backgroundColor: AppColors.glassStrong, shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.mdSm)),
      icon: const Icon(Icons.language_rounded, size: 18, color: AppColors.primary),
      label: Text(name, style: AppText.labelLarge.copyWith(color: AppColors.primary))));
  }
}
