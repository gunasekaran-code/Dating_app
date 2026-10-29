import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/account_store.dart';
import '../../data/profile_store.dart';
import '../../data/support_content.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/buttons.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/onboarding_widgets.dart';
import '../../widgets/settings_widgets.dart';
import '../../widgets/states.dart';
import '../../widgets/verification_widgets.dart';
import '../verification/verification_flow.dart';
import 'blocked_profiles_screen.dart';
import 'help_screen.dart';

/// Settings → Safety centre: quick safety actions, dating tips and helplines.
class SafetyCentreScreen extends StatelessWidget {
  const SafetyCentreScreen({super.key});

  void _push(BuildContext context, Widget page) => Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: Listenable.merge([account, currentUser]),
    builder: (context, _) => VerificationPage(title: 'Safety centre', children: [
      const VerificationIcon(icon: Icons.shield_outlined, size: 96),
      const SizedBox(height: AppSpacing.lg),
      Text('Your safety comes first', style: AppText.displaySmall, textAlign: TextAlign.center),
      const SizedBox(height: AppSpacing.sm),
      Text('Tools and tips to help you date with confidence — online and in person.',
          style: AppText.bodyMedium.copyWith(color: AppColors.muted), textAlign: TextAlign.center),
      const SizedBox(height: AppSpacing.xl),
      GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: AppSpacing.mdSm, crossAxisSpacing: AppSpacing.mdSm, childAspectRatio: 1.15, children: [
          _ActionTile(icon: currentUser.verified ? Icons.verified_rounded : Icons.verified_outlined,
              title: currentUser.verified ? 'Verified' : 'Get verified',
              subtitle: currentUser.verified ? 'You have the blue badge' : 'Show you’re really you',
              color: AppColors.verified, onTap: () => openVerification(context)),
          _ActionTile(icon: Icons.block_rounded, title: 'Blocked',
              subtitle: '${account.blocked.length} profile${account.blocked.length == 1 ? '' : 's'}',
              onTap: () => _push(context, const BlockedProfilesScreen())),
          _ActionTile(icon: Icons.flag_outlined, title: 'Report', subtitle: 'Tell us about a problem',
              color: AppColors.warning, onTap: () => showReportSheet(context)),
          _ActionTile(icon: Icons.sos_rounded, title: 'Emergency', subtitle: 'Helplines & SOS',
              color: AppColors.error, onTap: () => _showHelplines(context)),
        ]),
      const SizedBox(height: AppSpacing.xl),
      const SectionLabel('Before you meet'),
      for (final t in meetingTips) ExpandableCard(icon: t.icon, title: t.title, body: t.body),
      const SizedBox(height: AppSpacing.md),
      const SectionLabel('Staying safe online'),
      for (final t in onlineTips) ExpandableCard(icon: t.icon, title: t.title, body: t.body),
      const SizedBox(height: AppSpacing.md),
      GlassCard(padding: const EdgeInsets.all(AppSpacing.lg), onTap: () => _push(context, const ContactSupportScreen(
          topic: 'Safety')),
        child: Row(children: [
          const IconTile(Icons.support_agent_rounded, size: 48),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Talk to our safety team', style: AppText.h4),
            Text('We’re here 24/7 if something doesn’t feel right.', style: AppText.bodySmall),
          ])),
          const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
        ])),
    ]));
}

class _ActionTile extends StatelessWidget {
  final IconData icon; final String title, subtitle; final Color color; final VoidCallback onTap;
  const _ActionTile({required this.icon, required this.title, required this.subtitle, required this.onTap,
      this.color = AppColors.primary});
  @override
  Widget build(BuildContext context) => Semantics(button: true, label: '$title, $subtitle', excludeSemantics: true,
    child: GlassCard(padding: const EdgeInsets.all(AppSpacing.md), onTap: onTap,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconTile(icon, color: color, background: color.withValues(alpha: .12), size: 44),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: AppText.labelLarge.copyWith(fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(subtitle, style: AppText.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),
        ])));
}

void _showHelplines(BuildContext context) => showModalBottomSheet(context: context, builder: (c) => SafeArea(
  child: Padding(padding: const EdgeInsets.fromLTRB(AppSpacing.page, 0, AppSpacing.page, AppSpacing.md),
    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('Need help now?', style: AppText.h3),
      const SizedBox(height: AppSpacing.xs),
      Text('If you’re in immediate danger, contact local emergency services first.', style: AppText.bodySmall),
      const SizedBox(height: AppSpacing.md),
      RowsCard([
        for (final (icon, label, number) in helplines) SettingsRow(icon, label, subtitle: number,
          color: number == '112' ? AppColors.error : null,
          trailing: const Icon(Icons.copy_rounded, size: 18, color: AppColors.muted),
          onTap: () {
            Clipboard.setData(ClipboardData(text: number));
            Navigator.pop(c);
            showToast(context, '$number copied — open your phone app to call');
          }),
      ]),
    ]))));

/// Bottom sheet to report a person (or a general problem when [name] is null).
Future<void> showReportSheet(BuildContext context, {String? name}) =>
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => _ReportSheet(name: name));

class _ReportSheet extends StatefulWidget {
  final String? name;
  const _ReportSheet({this.name});
  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}
class _ReportSheetState extends State<_ReportSheet> {
  final details = TextEditingController();
  String? reason; bool sending = false;
  @override
  void dispose() { details.dispose(); super.dispose(); }

  Future<void> _submit() async {
    setState(() => sending = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    Navigator.pop(context);
    showToast(context, 'Thanks — our safety team will review this within 24 hours', type: ToastType.success);
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: SafeArea(child: ConstrainedBox(constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .85),
      child: ListView(shrinkWrap: true, padding: const EdgeInsets.fromLTRB(AppSpacing.page, 0, AppSpacing.page, AppSpacing.md),
        children: [
          Text(widget.name == null ? 'Report a problem' : 'Report ${widget.name}', style: AppText.h3),
          const SizedBox(height: AppSpacing.xs),
          Text('Your report is anonymous. What’s going on?', style: AppText.bodySmall),
          const SizedBox(height: AppSpacing.md),
          for (final (icon, label) in reportReasons)
            ChoiceTile(label: label, icon: icon, selected: reason == label, onTap: () => setState(() => reason = label)),
          const SizedBox(height: AppSpacing.xs),
          TextField(controller: details, minLines: 3, maxLines: 5, maxLength: 300, style: AppText.bodyLarge,
            cursorColor: AppColors.primary, textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(hintText: 'Add details (optional)',
              hintStyle: AppText.bodyLarge.copyWith(color: AppColors.muted), filled: true, fillColor: AppColors.card,
              counterStyle: AppText.bodySmall,
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.input),
                  borderSide: const BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.input),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5)))),
          const SizedBox(height: AppSpacing.sm),
          AppButton('Submit report', loading: sending, onPressed: reason == null ? null : _submit),
        ]))));
}
