import 'package:flutter/material.dart';
import '../../data/account_store.dart';
import '../../data/mock.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/profile_bits.dart';
import '../../widgets/states.dart';
import '../../widgets/verification_widgets.dart';

/// Settings → Blocked profiles: everyone the user has blocked, with unblock.
class BlockedProfilesScreen extends StatelessWidget {
  const BlockedProfilesScreen({super.key});

  Future<void> _unblock(BuildContext context, Profile p) async {
    final ok = await showConfirmDialog(context, title: 'Unblock ${p.name}?',
        message: 'They’ll be able to see your profile and appear in Discover again. They won’t be told.',
        confirm: 'Unblock');
    if (!ok || !context.mounted) return;
    account.unblock(p);
    ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(
      content: Text('${p.name} unblocked'),
      action: SnackBarAction(label: 'Undo', textColor: AppColors.accent, onPressed: () => account.block(p))));
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: account, builder: (context, _) {
    final blocked = account.blocked;
    if (blocked.isEmpty) {
      return const VerificationPage.fixed(title: 'Blocked profiles', child: EmptyState(icon: Icons.block_rounded,
          title: 'No one blocked',
          message: 'People you block won’t see your profile or be able to message you. They’ll show up here.'));
    }
    return VerificationPage(title: 'Blocked profiles', children: [
      Text('${blocked.length} blocked', style: AppText.displaySmall),
      const SizedBox(height: AppSpacing.sm),
      Text('These people can’t see your profile, match with you or message you.',
          style: AppText.bodyMedium.copyWith(color: AppColors.muted)),
      const SizedBox(height: AppSpacing.xl),
      for (final p in blocked) Padding(padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: AppCard(padding: const EdgeInsets.all(AppSpacing.mdSm), child: Row(children: [
          ColorFiltered(colorFilter: const ColorFilter.matrix([
            .5, .4, .1, 0, 0, .3, .6, .1, 0, 0, .3, .4, .3, 0, 0, 0, 0, 0, 1, 0]),
              child: Avatar(p.photos.first, size: 52)),
          const SizedBox(width: AppSpacing.mdSm),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${p.name}, ${p.age}', style: AppText.labelLarge.copyWith(fontSize: 15)),
            Text(p.city, style: AppText.bodySmall),
          ])),
          OutlinedButton(onPressed: () => _unblock(context, p),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, shape: const StadiumBorder(),
                side: const BorderSide(color: AppColors.primary), visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md)),
            child: Text('Unblock', style: AppText.labelMedium.copyWith(color: AppColors.primary))),
        ]))),
      const SizedBox(height: AppSpacing.md),
      Text('Blocking is private — people are never told that you blocked them.',
          style: AppText.bodySmall, textAlign: TextAlign.center),
    ]);
  });
}
