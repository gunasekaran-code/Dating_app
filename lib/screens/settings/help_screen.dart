import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/account_store.dart';
import '../../data/support_content.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/buttons.dart';
import '../../widgets/onboarding_widgets.dart';
import '../../widgets/settings_widgets.dart';
import '../../widgets/states.dart';
import '../../widgets/verification_widgets.dart';
import 'safety_centre_screen.dart';
import 'terms_privacy_screen.dart';

/// Settings → Help: searchable FAQs plus ways to reach support.
class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});
  @override
  State<HelpScreen> createState() => _HelpScreenState();
}
class _HelpScreenState extends State<HelpScreen> {
  final search = TextEditingController();
  String category = faqCategories.first;
  @override
  void dispose() { search.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final q = search.text.trim().toLowerCase();
    final results = faqs.where((f) => (category == 'All' || f.category == category) &&
        (q.isEmpty || f.question.toLowerCase().contains(q) || f.answer.toLowerCase().contains(q))).toList();
    return VerificationPage(title: 'Help', children: [
      Text('How can we help?', style: AppText.displaySmall),
      const SizedBox(height: AppSpacing.md),
      TextField(controller: search, onChanged: (_) => setState(() {}), style: AppText.bodyLarge,
        cursorColor: AppColors.primary, textInputAction: TextInputAction.search,
        decoration: InputDecoration(hintText: 'Search help articles',
          hintStyle: AppText.bodyLarge.copyWith(color: AppColors.muted),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.muted),
          suffixIcon: q.isEmpty ? null : IconButton(tooltip: 'Clear search',
              icon: const Icon(Icons.close_rounded, color: AppColors.muted),
              onPressed: () => setState(search.clear)),
          filled: true, fillColor: AppColors.glassStrong,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.pill),
              borderSide: const BorderSide(color: AppColors.glassBorder)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.pill),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5)))),
      const SizedBox(height: AppSpacing.md),
      SizedBox(height: 44, child: ListView.separated(scrollDirection: Axis.horizontal,
        itemCount: faqCategories.length, separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (_, i) => SelectChip(faqCategories[i], selected: category == faqCategories[i],
            onTap: () => setState(() => category = faqCategories[i])))),
      const SizedBox(height: AppSpacing.lg),
      SectionLabel(q.isEmpty ? 'Popular questions' : '${results.length} result${results.length == 1 ? '' : 's'}'),
      if (results.isEmpty)
        Padding(padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg), child: Column(children: [
          const Icon(Icons.search_off_rounded, size: 40, color: AppColors.accent),
          const SizedBox(height: AppSpacing.sm),
          Text('No articles match “${search.text.trim()}”', style: AppText.labelLarge, textAlign: TextAlign.center),
          Text('Try another word, or contact us below.', style: AppText.bodySmall),
        ]))
      else
        for (final f in results) ExpandableCard(key: ValueKey(f.question), title: f.question, body: f.answer),
      const SizedBox(height: AppSpacing.lg),
      const SectionLabel('Still need help?'),
      RowsCard([
        SettingsRow(Icons.chat_bubble_outline_rounded, 'Contact support', subtitle: 'We usually reply within a day',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactSupportScreen()))),
        SettingsRow(Icons.flag_outlined, 'Report a problem', subtitle: 'Safety issues or bugs',
            onTap: () => showReportSheet(context)),
        SettingsRow(Icons.mail_outline_rounded, 'Email us', subtitle: supportEmail,
            trailing: const Icon(Icons.copy_rounded, size: 18, color: AppColors.muted),
            onTap: () {
              Clipboard.setData(const ClipboardData(text: supportEmail));
              showToast(context, 'Email address copied');
            }),
        SettingsRow(Icons.description_outlined, 'Terms & privacy',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsPrivacyScreen()))),
      ]),
    ]);
  }
}

/// Message form to the support team.
class ContactSupportScreen extends StatefulWidget {
  final String? topic;
  const ContactSupportScreen({super.key, this.topic});
  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}
class _ContactSupportScreenState extends State<ContactSupportScreen> {
  static const topics = ['Account', 'Profile', 'Matching', 'Safety', 'Payments', 'Bug', 'Other'];
  late String? topic = widget.topic;
  final message = TextEditingController();
  bool sending = false;

  @override
  void initState() { super.initState(); message.addListener(() => setState(() {})); }
  @override
  void dispose() { message.dispose(); super.dispose(); }

  bool get _valid => topic != null && message.text.trim().length >= 10;

  Future<void> _send() async {
    FocusScope.of(context).unfocus();
    setState(() => sending = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    showToast(context, 'Message sent — we’ll reply to ${account.email.isEmpty ? 'you' : account.email}',
        type: ToastType.success);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => VerificationPage(title: 'Contact support', children: [
    Text('Send us a message', style: AppText.displaySmall),
    const SizedBox(height: AppSpacing.sm),
    Text('Tell us what’s happening and we’ll get back to you, usually within a day.',
        style: AppText.bodyMedium.copyWith(color: AppColors.muted)),
    const SizedBox(height: AppSpacing.xl),
    Text('Topic', style: AppText.labelLarge),
    const SizedBox(height: AppSpacing.sm),
    Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: [
      for (final t in topics) SelectChip(t, selected: topic == t, onTap: () => setState(() => topic = t)),
    ]),
    const SizedBox(height: AppSpacing.lg),
    Text('Message', style: AppText.labelLarge),
    const SizedBox(height: AppSpacing.sm),
    TextField(controller: message, minLines: 5, maxLines: 10, maxLength: 1000, style: AppText.bodyLarge,
      cursorColor: AppColors.primary, textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(hintText: 'Describe the issue (at least 10 characters)',
        hintStyle: AppText.bodyLarge.copyWith(color: AppColors.muted), filled: true, fillColor: AppColors.glassStrong,
        counterStyle: AppText.bodySmall,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.card),
            borderSide: const BorderSide(color: AppColors.glassBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.card),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5)))),
    if (account.email.isNotEmpty) Row(children: [
      const Icon(Icons.reply_rounded, size: 16, color: AppColors.muted),
      const SizedBox(width: AppSpacing.xs),
      Expanded(child: Text('We’ll reply to ${account.email}', style: AppText.bodySmall)),
    ]),
  ], actions: [AppButton('Send message', icon: Icons.send_rounded, loading: sending, onPressed: _valid ? _send : null)]);
}
