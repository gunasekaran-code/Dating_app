import 'package:flutter/material.dart';
import '../data/mock.dart';
import '../l10n/match_text.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import '../widgets/profile_bits.dart';
import '../widgets/skeletons.dart';
import 'chat_screen.dart';

class MatchesScreen extends StatelessWidget {
  final bool chatsOnly;
  const MatchesScreen({super.key, this.chatsOnly = false});
  void _open(BuildContext c, Profile p, {bool newMatch = false}) =>
      Navigator.push(c, MaterialPageRoute(builder: (_) => ChatScreen(profile: p, newMatch: newMatch)));
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return SafeArea(child: Column(children: [
    Align(alignment: Alignment.centerLeft, child: Padding(padding: const EdgeInsets.all(AppSpacing.page),
        child: Text(chatsOnly ? l.tabChats : l.tabMatches, style: AppText.h1))),
    Expanded(child: SkeletonLoader(skeleton: MatchesSkeleton(chatsOnly: chatsOnly), child: ListView(children: [
    if (!chatsOnly) ...[
      Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Text(l.newMatches, style: AppText.labelLarge.copyWith(color: AppColors.muted))),
      const SizedBox(height: AppSpacing.mdSm),
      SizedBox(height: 100, child: ListView.separated(scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
        itemCount: profiles.length, separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (c, i) => GestureDetector(onTap: () => _open(c, profiles[i], newMatch: true), child: Column(children: [
          Avatar(profiles[i].photos.first, size: 64, ring: true, online: profiles[i].online),
          const SizedBox(height: AppSpacing.xs),
          Text(profiles[i].name, style: AppText.labelMedium)])))),
      const SizedBox(height: AppSpacing.lg),
      Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Text(l.conversations, style: AppText.labelLarge.copyWith(color: AppColors.muted))),
    ],
    for (final p in profiles.take(3))
      ListTile(onTap: () => _open(context, p),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.page, vertical: AppSpacing.xs),
        leading: Avatar(p.photos.first, size: 52, online: p.online),
        title: Text(p.name, style: AppText.labelLarge),
        subtitle: Text(chatHistory.last.text, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.bodySmall),
        trailing: Text(chatHistory.last.time, style: AppText.labelSmall.copyWith(color: AppColors.muted))),
  ]))),
  ]));
  }
}
