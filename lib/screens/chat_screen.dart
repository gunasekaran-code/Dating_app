import 'package:flutter/material.dart';
import '../data/match_engine.dart';
import '../data/mock.dart';
import '../services/haptics.dart';
import '../l10n/match_text.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import '../widgets/buttons.dart';
import '../widgets/glass_card.dart';
import '../widgets/icebreakers.dart';
import '../widgets/profile_bits.dart';

class ChatScreen extends StatefulWidget {
  final Profile profile;
  /// A fresh match: the chat starts empty, with icebreakers in place of history.
  final bool newMatch;
  const ChatScreen({super.key, required this.profile, this.newMatch = false});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}
class _ChatScreenState extends State<ChatScreen> {
  late final msgs = widget.newMatch ? <Message>[] : List<Message>.from(chatHistory);
  final ctrl = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() { ctrl.dispose(); _focus.dispose(); super.dispose(); }

  void _send() {
    if (ctrl.text.trim().isEmpty) return;
    Haptics.light();
    setState(() => msgs.add(Message(ctrl.text.trim(), true, 'now')));
    ctrl.clear();
  }

  /// Puts an icebreaker in the composer so the user can make it their own before sending.
  void _useIcebreaker(String text) {
    ctrl.value = TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
    _focus.requestFocus();
  }
  @override
  Widget build(BuildContext context) {
    final p = widget.profile, l = context.l10n;
    return Scaffold(
      appBar: AppBar(titleSpacing: 0, title: Row(children: [
        Avatar(p.photos.first, size: 36, online: p.online), const SizedBox(width: AppSpacing.mdSm),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(p.name, style: AppText.labelLarge),
          Text(p.online ? l.online : l.recentlyActive, style: AppText.labelSmall.copyWith(
              color: p.online ? AppColors.success : AppColors.muted))]),
      ]), centerTitle: false),
      body: Column(children: [
        Expanded(child: msgs.isEmpty ? _NewMatchIntro(profile: p, onPick: _useIcebreaker)
            : ListView.builder(padding: const EdgeInsets.all(AppSpacing.page), itemCount: msgs.length,
          itemBuilder: (_, i) { final m = msgs[i];
            return Align(alignment: m.mine ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * .75),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.mdSm),
                decoration: BoxDecoration(color: m.mine ? AppColors.primary : AppColors.glassStrong,
                  border: m.mine ? null : Border.all(color: AppColors.glassBorder),
                  borderRadius: BorderRadius.only(topLeft: const Radius.circular(AppRadius.card),
                    topRight: const Radius.circular(AppRadius.card),
                    bottomLeft: Radius.circular(m.mine ? AppRadius.card : AppRadius.small),
                    bottomRight: Radius.circular(m.mine ? AppRadius.small : AppRadius.card))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(m.text, style: AppText.bodyMedium.copyWith(color: m.mine ? AppColors.onPrimary : AppColors.text)),
                  const SizedBox(height: 2),
                  Text(m.time, style: AppText.labelSmall.copyWith(color: m.mine ? AppColors.secondary : AppColors.muted)),
                ]))); })),
        SafeArea(top: false, minimum: const EdgeInsets.only(bottom: AppSpacing.sm), child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.xs, AppSpacing.page, 0),
          child: GlassCard(radius: AppRadius.pill, padding: const EdgeInsets.all(AppSpacing.xs), child: Row(children: [
            if (msgs.isNotEmpty) AppIconButton(Icons.lightbulb_outline_rounded, tooltip: l.icebreakers,
                color: AppColors.primary, onPressed: () => showIcebreakers(context, p, _useIcebreaker)),
            Expanded(child: TextField(controller: ctrl, focusNode: _focus, onSubmitted: (_) => _send(),
              style: AppText.bodyLarge, textCapitalization: TextCapitalization.sentences, minLines: 1, maxLines: 4,
              decoration: InputDecoration(hintText: msgs.isEmpty ? l.betterThanHey : l.message,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.mdSm),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.pill), borderSide: BorderSide.none)))),
            const SizedBox(width: AppSpacing.sm),
            AppIconButton(Icons.send_rounded, tooltip: l.send, color: AppColors.onPrimary,
                background: AppColors.primary, onPressed: _send),
          ])))),
      ]));
  }
}

/// Empty chat with a new match: who they are, how well you match, and openers to break the ice.
class _NewMatchIntro extends StatelessWidget {
  final Profile profile; final ValueChanged<String> onPick;
  const _NewMatchIntro({required this.profile, required this.onPick});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(AppSpacing.page), children: [
    const SizedBox(height: AppSpacing.md),
    Center(child: Avatar(profile.photos.first, size: 88, ring: true)),
    const SizedBox(height: AppSpacing.mdSm),
    Text(context.l10n.matchedWith(profile.name), style: AppText.h3, textAlign: TextAlign.center),
    const SizedBox(height: AppSpacing.sm),
    Center(child: CompatibilityPill(matchEngine.insight(profile).score)),
    const SizedBox(height: AppSpacing.xl),
    IcebreakerPanel(profile: profile, onPick: onPick),
  ]);
}
