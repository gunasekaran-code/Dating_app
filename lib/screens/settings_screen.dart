import 'package:flutter/material.dart';
import '../data/account_store.dart';
import '../data/locale_store.dart';
import '../data/match_engine.dart';
import '../data/profile_store.dart';
import '../l10n/match_text.dart';
import '../services/haptics.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import '../widgets/buttons.dart';
import '../widgets/profile_bits.dart';
import '../widgets/states.dart';
import 'edit_profile/edit_profile_screen.dart';
import 'language_screen.dart';
import 'preferences_screen.dart';
import 'settings/blocked_profiles_screen.dart';
import 'settings/contact_details_screen.dart';
import 'settings/help_screen.dart';
import 'settings/safety_centre_screen.dart';
import 'settings/terms_privacy_screen.dart';
import 'welcome_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}
class _SettingsScreenState extends State<SettingsScreen> {
  final toggles = {'discover': true, 'online': true, 'matches': true, 'messages': true};

  Widget _section(String title, List<Widget> rows) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.xl),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.sm),
          child: Text(title.toUpperCase(), style: AppText.labelSmall.copyWith(color: AppColors.muted))),
      AppCard(padding: EdgeInsets.zero, child: Column(children: [
        for (var i = 0; i < rows.length; i++) ...[if (i > 0) const Divider(indent: 62), rows[i]]])),
    ]));

  Widget _icon(IconData icon) => Container(width: 30, height: 30,
      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, size: 18, color: AppColors.onPrimary));
  Widget _nav(IconData icon, String label, Widget page, {String? subtitle}) => ListTile(leading: _icon(icon),
      title: Text(label, style: AppText.bodyLarge),
      subtitle: subtitle == null ? null : Text(subtitle, style: AppText.bodySmall, overflow: TextOverflow.ellipsis),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)));
  Widget _switch(String k, String label) => SwitchListTile.adaptive(activeTrackColor: AppColors.primary,
      value: toggles[k]!, onChanged: (v) { Haptics.selection(); setState(() => toggles[k] = v); },
      title: Text(label, style: AppText.bodyLarge));
  // Turning haptics on plays one tick as a preview; turning them off stays silent.
  Widget _hapticsSwitch(String label) => SwitchListTile.adaptive(activeTrackColor: AppColors.primary,
      value: Haptics.enabled.value, onChanged: (v) { Haptics.enabled.value = v; Haptics.selection(); },
      title: Text(label, style: AppText.bodyLarge));

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(appBar: AppBar(title: Text(l.settings)),
    body: ListenableBuilder(listenable: Listenable.merge([account, appLocale, Haptics.enabled]), builder: (context, _) => ListView(padding: const EdgeInsets.all(AppSpacing.page), children: [
      _section(l.sectionAccount, [_nav(Icons.person_outline_rounded, l.personalDetails, const EditProfileScreen()),
        _nav(Icons.mail_outline_rounded, l.emailAndPhone, const ContactDetailsScreen(),
            subtitle: account.email.isNotEmpty ? account.email : account.phone.isNotEmpty ? account.phone : null)]),
      _section(l.sectionGeneral, [_nav(Icons.translate_rounded, l.appLanguage, const LanguageScreen(),
          subtitle: appLocale.language?.nativeName ?? l.deviceLanguage), _hapticsSwitch(l.hapticFeedback)]),
      _section(l.sectionDiscovery, [_switch('discover', l.showMeInDiscover),
        _nav(Icons.tune_rounded, l.preferences, const PreferencesScreen())]),
      _section(l.sectionPrivacy, [_switch('online', l.showOnlineStatus), _nav(Icons.block_rounded, l.blockedProfiles,
          const BlockedProfilesScreen(), subtitle: account.blocked.isEmpty ? null : l.blockedCount(account.blocked.length)),
        _nav(Icons.shield_outlined, l.safetyCentre, const SafetyCentreScreen())]),
      _section(l.sectionNotifications, [_switch('matches', l.newMatches), _switch('messages', l.messages)]),
      _section(l.sectionSupport, [_nav(Icons.help_outline_rounded, l.help, const HelpScreen()),
        _nav(Icons.description_outlined, l.termsAndPrivacy, const TermsPrivacyScreen())]),
      AppButton(l.signOut, variant: AppButtonVariant.outline, onPressed: () async {
        if (await showConfirmDialog(context, title: l.signOutTitle, message: l.signOutMessage, confirm: l.signOut)
            && context.mounted) {
          currentUser.reset();
          account.reset();
          matchEngine.reset();
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const WelcomeScreen()), (_) => false);
        }
      }),
      const SizedBox(height: AppSpacing.md),
      Center(child: TextButton(onPressed: () {}, child: Text(l.deleteAccount,
          style: AppText.labelLarge.copyWith(color: AppColors.error)))),
      Center(child: InterestChip(l.version('1.0.0'))),
    ])));
  }
}
