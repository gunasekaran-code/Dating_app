import 'package:flutter/material.dart';
import '../../l10n/match_text.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/buttons.dart';
import '../../widgets/inputs.dart';
import '../../widgets/states.dart';
import '../../data/account_store.dart';
import '../../data/profile_store.dart';
import '../../services/haptics.dart';
import '../app_shell.dart';
import 'auth_scaffold.dart';
import 'create_account_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final email = TextEditingController(), pass = TextEditingController();
  String? emailErr, passErr; bool loading = false;

  @override
  void dispose() { email.dispose(); pass.dispose(); super.dispose(); }

  Future<void> _submit() async {
    final l = context.l10n;
    setState(() {
      emailErr = email.text.contains('@') ? null : l.errEmail;
      passErr = pass.text.length >= 8 ? null : l.errPassword;
    });
    if (emailErr != null || passErr != null) { Haptics.error(); return; }
    setState(() => loading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    currentUser.seedDemo();
    account..signIn(email: email.text)..seedDemo();
    showToast(context, l.signInTitle, type: ToastType.success);
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const AppShell()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AuthScaffold(
    title: l.signInTitle,
    subtitle: l.signInSubtitle,
    form: [
      AppInput(label: l.email, hint: 'you@example.com', controller: email, error: emailErr,
          keyboard: TextInputType.emailAddress, prefix: Icons.mail_outline_rounded),
      const SizedBox(height: AppSpacing.lg),
      AppInput(label: l.password, hint: l.passwordHint, controller: pass, error: passErr,
          obscure: true, prefix: Icons.lock_outline_rounded),
      Align(alignment: Alignment.centerRight, child: TextButton(
        onPressed: () => showToast(context, l.resetComingSoon),
        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
        child: Text(l.forgotPassword, style: AppText.labelMedium.copyWith(color: AppColors.primary)))),
      const SizedBox(height: AppSpacing.md),
      AppButton(l.signIn, loading: loading, onPressed: _submit),
    ],
    footer: AuthSwitchLink(question: l.newToAmour, action: l.createAccount,
        onTap: () => Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const CreateAccountScreen()))),
  );
  }
}
