import 'package:flutter/material.dart';
import '../../l10n/match_text.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/buttons.dart';
import '../../widgets/inputs.dart';
import '../../widgets/states.dart';
import '../../data/account_store.dart';
import '../../services/haptics.dart';
import '../onboarding/onboarding_flow.dart';
import '../settings/terms_privacy_screen.dart';
import 'auth_scaffold.dart';
import 'sign_in_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});
  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final name = TextEditingController(), email = TextEditingController(),
      pass = TextEditingController(), confirm = TextEditingController();
  String? nameErr, emailErr, passErr, confirmErr;
  bool agreed = false, termsErr = false, loading = false;

  @override
  void dispose() { name.dispose(); email.dispose(); pass.dispose(); confirm.dispose(); super.dispose(); }

  Future<void> _submit() async {
    final l = context.l10n;
    setState(() {
      nameErr = name.text.trim().isNotEmpty ? null : l.errName;
      emailErr = email.text.contains('@') ? null : l.errEmail;
      passErr = pass.text.length >= 8 ? null : l.errPassword;
      confirmErr = confirm.text == pass.text ? null : l.errPasswordMismatch;
      termsErr = !agreed;
    });
    if ([nameErr, emailErr, passErr, confirmErr].any((e) => e != null) || termsErr) { Haptics.error(); return; }
    setState(() => loading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    account.signIn(email: email.text);
    showToast(context, l.accountCreated, type: ToastType.success);
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const OnboardingFlow()), (_) => false);
  }

  /// "I agree to the Terms and Privacy Policy", with both links tappable wherever the language puts them.
  List<Widget> _agreement(BuildContext context) {
    final l = context.l10n;
    final plain = AppText.bodySmall.copyWith(color: termsErr ? AppColors.error : AppColors.text);
    Widget link(String label, int tab) => GestureDetector(onTap: () => Navigator.push(context,
        MaterialPageRoute(builder: (_) => TermsPrivacyScreen(initialTab: tab))),
      child: Text(label, style: AppText.labelMedium.copyWith(color: AppColors.primary,
          decoration: TextDecoration.underline, decorationColor: AppColors.primary)));
    // Fill the placeholders with marker characters, then split the sentence around them.
    const terms = '\u0001', privacy = '\u0002';
    return [
      for (final part in l.agreeTerms(terms, privacy).split(RegExp('(?=[$terms$privacy])|(?<=[$terms$privacy])')))
        if (part == terms) link(l.terms, 0)
        else if (part == privacy) link(l.privacyPolicy, 1)
        else if (part.isNotEmpty) Text(part, style: plain),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AuthScaffold(
    title: l.createTitle,
    subtitle: l.createSubtitle,
    form: [
      AppInput(label: l.fullName, hint: l.nameHint, controller: name, error: nameErr,
          keyboard: TextInputType.name, prefix: Icons.person_outline_rounded),
      const SizedBox(height: AppSpacing.lg),
      AppInput(label: l.email, hint: 'you@example.com', controller: email, error: emailErr,
          keyboard: TextInputType.emailAddress, prefix: Icons.mail_outline_rounded),
      const SizedBox(height: AppSpacing.lg),
      AppInput(label: l.password, hint: l.passwordHint, controller: pass, error: passErr,
          obscure: true, prefix: Icons.lock_outline_rounded),
      const SizedBox(height: AppSpacing.lg),
      AppInput(label: l.confirmPassword, hint: l.confirmPasswordHint, controller: confirm, error: confirmErr,
          obscure: true, prefix: Icons.lock_outline_rounded),
      const SizedBox(height: AppSpacing.md),
      InkWell(
        borderRadius: BorderRadius.circular(AppRadius.small),
        onTap: () { Haptics.selection(); setState(() { agreed = !agreed; termsErr = false; }); },
        child: Row(children: [
          Checkbox(value: agreed, activeColor: AppColors.primary,
              side: BorderSide(color: termsErr ? AppColors.error : AppColors.muted),
              onChanged: (v) { Haptics.selection(); setState(() { agreed = v ?? false; termsErr = false; }); }),
          Expanded(child: Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: _agreement(context))),
        ])),
      const SizedBox(height: AppSpacing.lg),
      AppButton(l.createAccount, loading: loading, onPressed: _submit),
    ],
    footer: AuthSwitchLink(question: l.haveAccount, action: l.signIn,
        onTap: () => Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const SignInScreen()))),
  );
  }
}
