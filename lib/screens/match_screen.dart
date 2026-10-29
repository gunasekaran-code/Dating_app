import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import '../data/match_engine.dart';
import '../data/mock.dart';
import '../l10n/match_text.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import '../widgets/buttons.dart';
import '../widgets/content_frame.dart';
import '../widgets/profile_bits.dart';
import 'chat_screen.dart';

class MatchScreen extends StatelessWidget {
  final Profile profile;
  const MatchScreen({super.key, required this.profile});
  @override
  Widget build(BuildContext context) => Scaffold(body: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
    child: ColoredBox(color: AppColors.background.withValues(alpha: .72), child: ContentFrame(child: SafeArea(child: Padding(padding: const EdgeInsets.all(AppSpacing.xl), child: Column(children: [
      const Spacer(),
      TweenAnimationBuilder<double>(tween: Tween(begin: .8, end: 1), duration: AppDurations.slow,
        curve: Curves.easeOutBack, builder: (_, s, c) => Transform.scale(scale: s, child: c),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Avatar(profiles[3].photos.first, size: 110, ring: true),
          const SizedBox(width: AppSpacing.md),
          const Icon(Icons.favorite_rounded, color: AppColors.primary, size: 32),
          const SizedBox(width: AppSpacing.md),
          Avatar(profile.photos.first, size: 110, ring: true),
        ])),
      const SizedBox(height: AppSpacing.xxl),
      Text(context.l10n.itsAMatch, textAlign: TextAlign.center, style: AppText.displayLarge.copyWith(color: AppColors.primary)),
      const SizedBox(height: AppSpacing.sm),
      Text(context.l10n.likeEachOther(profile.name),
          style: AppText.bodyLarge.copyWith(color: AppColors.muted), textAlign: TextAlign.center),
      const SizedBox(height: AppSpacing.md),
      CompatibilityPill(matchEngine.insight(profile).score),
      if (matchEngine.insight(profile).top case final reason?) ...[
        const SizedBox(height: AppSpacing.sm),
        Text(context.l10n.reasonTitle(reason), style: AppText.labelLarge.copyWith(color: AppColors.primary), textAlign: TextAlign.center),
      ],
      const Spacer(),
      AppButton(context.l10n.sendMessage, icon: Icons.chat_bubble_rounded, onPressed: () => Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => ChatScreen(profile: profile, newMatch: true)))),
      const SizedBox(height: AppSpacing.mdSm),
      AppButton(context.l10n.keepDiscovering, variant: AppButtonVariant.ghost, onPressed: () => Navigator.pop(context)),
    ])))))));
}
