import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/account_store.dart';
import '../../services/haptics.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/buttons.dart';
import '../../widgets/inputs.dart';
import '../../widgets/profile_bits.dart';
import '../../widgets/settings_widgets.dart';
import '../../widgets/states.dart';
import '../../widgets/verification_widgets.dart';

enum ContactKind { email, phone }

/// Settings → Email & phone: the sign-in details on the account and their verification state.
class ContactDetailsScreen extends StatelessWidget {
  const ContactDetailsScreen({super.key});

  Widget _row(BuildContext context, ContactKind kind) {
    final isEmail = kind == ContactKind.email;
    final value = isEmail ? account.email : account.phone, verified = isEmail ? account.emailVerified : account.phoneVerified;
    return RowsCard([SettingsRow(isEmail ? Icons.mail_outline_rounded : Icons.phone_iphone_rounded,
      value.isEmpty ? (isEmail ? 'Add an email' : 'Add a phone number') : value,
      subtitle: value.isEmpty ? 'Not added' : verified ? 'Used to sign in and recover your account' : 'Not verified yet',
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChangeContactScreen(kind))),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        if (value.isNotEmpty) verified
            ? const StatusPill('Verified', color: AppColors.success, icon: Icons.check_rounded)
            : const StatusPill('Verify', color: AppColors.warning),
        const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
      ]))]);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: account, builder: (context, _) =>
    VerificationPage(title: 'Email & phone', children: [
      const VerificationIcon(icon: Icons.alternate_email_rounded, size: 96),
      const SizedBox(height: AppSpacing.lg),
      Text('Keep your account secure', style: AppText.displaySmall, textAlign: TextAlign.center),
      const SizedBox(height: AppSpacing.sm),
      Text('We use these to sign you in, send important updates and help you get back in if you’re locked out.',
          style: AppText.bodyMedium.copyWith(color: AppColors.muted), textAlign: TextAlign.center),
      const SizedBox(height: AppSpacing.xl),
      const SectionLabel('Email'),
      _row(context, ContactKind.email),
      const SizedBox(height: AppSpacing.lg),
      const SectionLabel('Phone'),
      _row(context, ContactKind.phone),
      const SizedBox(height: AppSpacing.lg),
      AppCard(child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.lock_outline_rounded, size: 20, color: AppColors.accent),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text('Your email and phone number are private — they’re never shown on your profile.',
            style: AppText.bodySmall)),
      ])),
    ]));
}

/// Enter a new email / phone, then confirm it with a one-time code.
class ChangeContactScreen extends StatefulWidget {
  final ContactKind kind;
  const ChangeContactScreen(this.kind, {super.key});
  @override
  State<ChangeContactScreen> createState() => _ChangeContactScreenState();
}
class _ChangeContactScreenState extends State<ChangeContactScreen> {
  late final isEmail = widget.kind == ContactKind.email;
  final c = TextEditingController();
  String? error; bool loading = false;
  @override
  void dispose() { c.dispose(); super.dispose(); }

  /// Returns the cleaned value, or sets [error] and returns null.
  String? _validate() {
    final v = c.text.trim();
    if (isEmail) {
      if (!emailPattern.hasMatch(v)) return _fail('Enter a valid email address');
      if (v.toLowerCase() == account.email.toLowerCase()) return _fail('That’s already your email');
      return v;
    }
    var digits = v.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 12 && digits.startsWith('91')) digits = digits.substring(2);
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(digits)) return _fail('Enter a valid 10-digit mobile number');
    final formatted = formatIndianPhone(digits);
    if (formatted == account.phone) return _fail('That’s already your number');
    return formatted;
  }
  String? _fail(String msg) { Haptics.error(); setState(() => error = msg); return null; }

  Future<void> _send() async {
    FocusScope.of(context).unfocus();
    setState(() => error = null);
    final value = _validate();
    if (value == null) return;
    setState(() => loading = true);
    await account.sendCode(value);
    if (!mounted) return;
    setState(() => loading = false);
    final ok = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => VerifyCodeScreen(
        destination: value, kind: widget.kind)));
    if (ok != true || !mounted) return;
    isEmail ? account.setEmail(value) : account.setPhone(value);
    showToast(context, isEmail ? 'Email updated' : 'Phone number updated', type: ToastType.success);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final current = isEmail ? account.email : account.phone;
    return VerificationPage(title: isEmail ? 'Email' : 'Phone number', children: [
      Text(isEmail ? 'What’s your new email?' : 'What’s your mobile number?', style: AppText.displaySmall),
      const SizedBox(height: AppSpacing.sm),
      Text('We’ll send a 6-digit code to confirm it’s you.', style: AppText.bodyMedium.copyWith(color: AppColors.muted)),
      const SizedBox(height: AppSpacing.xl),
      if (current.isNotEmpty) ...[
        AppCard(child: Row(children: [
          IconTile(isEmail ? Icons.mail_outline_rounded : Icons.phone_iphone_rounded, size: 36),
          const SizedBox(width: AppSpacing.mdSm),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Current', style: AppText.labelSmall.copyWith(color: AppColors.muted)),
            Text(current, style: AppText.labelLarge, overflow: TextOverflow.ellipsis),
          ])),
        ])),
        const SizedBox(height: AppSpacing.lg),
      ],
      AppInput(label: isEmail ? 'New email' : 'Mobile number (+91)', hint: isEmail ? 'you@example.com' : '98765 43210',
          controller: c, error: error, prefix: isEmail ? Icons.alternate_email_rounded : Icons.dialpad_rounded,
          keyboard: isEmail ? TextInputType.emailAddress : TextInputType.phone),
    ], actions: [AppButton('Send code', loading: loading, icon: Icons.send_rounded, onPressed: _send)]);
  }
}

/// Six-digit code entry with resend countdown. Pops `true` once the code checks out.
class VerifyCodeScreen extends StatefulWidget {
  final String destination; final ContactKind kind;
  const VerifyCodeScreen({super.key, required this.destination, required this.kind});
  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}
class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  static const _resendAfter = 30;
  String code = ''; bool loading = false, wrong = false;
  int wait = _resendAfter;
  Timer? timer;

  @override
  void initState() { super.initState(); _startTimer(); }
  @override
  void dispose() { timer?.cancel(); super.dispose(); }

  void _startTimer() {
    timer?.cancel();
    setState(() => wait = _resendAfter);
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (wait <= 1) t.cancel();
      setState(() => wait--);
    });
  }

  Future<void> _resend() async {
    await account.sendCode(widget.destination);
    if (!mounted) return;
    showToast(context, 'New code sent to ${widget.destination}');
    _startTimer();
  }

  Future<void> _verify() async {
    if (code.length < 6 || loading) return;
    setState(() { loading = true; wrong = false; });
    final ok = await account.verifyCode(code);
    if (!mounted) return;
    setState(() { loading = false; wrong = !ok; });
    if (ok) { Navigator.pop(context, true); } else { Haptics.error(); }
  }

  @override
  Widget build(BuildContext context) => VerificationPage(title: 'Verify', children: [
    VerificationIcon(icon: widget.kind == ContactKind.email ? Icons.mark_email_read_outlined : Icons.sms_outlined,
        size: 96),
    const SizedBox(height: AppSpacing.lg),
    Text('Enter the code', style: AppText.displaySmall, textAlign: TextAlign.center),
    const SizedBox(height: AppSpacing.sm),
    Text.rich(TextSpan(text: 'We sent a 6-digit code to ', children: [
      TextSpan(text: widget.destination, style: AppText.labelLarge.copyWith(color: AppColors.text)),
    ]), style: AppText.bodyMedium.copyWith(color: AppColors.muted), textAlign: TextAlign.center),
    const SizedBox(height: AppSpacing.xl),
    CodeInput(error: wrong, onChanged: (v) => setState(() { code = v; wrong = false; }), onCompleted: (_) => _verify()),
    if (wrong) ...[
      const SizedBox(height: AppSpacing.sm),
      Text('That code didn’t work. Check it and try again.',
          style: AppText.bodySmall.copyWith(color: AppColors.error), textAlign: TextAlign.center),
    ],
    const SizedBox(height: AppSpacing.lg),
    Center(child: wait > 0
        ? Text('Resend code in 0:${wait.toString().padLeft(2, '0')}', style: AppText.bodySmall)
        : TextButton(onPressed: _resend,
            child: Text('Resend code', style: AppText.labelLarge.copyWith(color: AppColors.primary)))),
  ], actions: [AppButton('Verify', loading: loading, onPressed: code.length == 6 ? _verify : null)]);
}
