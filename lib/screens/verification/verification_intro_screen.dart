import 'package:flutter/material.dart';
import '../../data/profile_store.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/buttons.dart';
import '../../widgets/profile_bits.dart';
import '../../widgets/verification_widgets.dart';
import '../manage_photos_screen.dart';
import 'verification_flow.dart';

/// Explains verification, how to get a good selfie video, and starts the capture.
class VerificationIntroScreen extends StatelessWidget {
  const VerificationIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final u = currentUser;
    return ListenableBuilder(listenable: Listenable.merge([u, u.photos]), builder: (context, _) {
      if (u.verified) return const _AlreadyVerified();
      final hasPhotos = u.photos.uploadedCount > 0;
      return VerificationPage(
        actions: [
          if (!hasPhotos) ...[
            const _Notice('Add at least one clear photo of your face first — we compare your video with it.'),
            const SizedBox(height: AppSpacing.xs),
            AppButton('Add photos', icon: Icons.add_photo_alternate_outlined, onPressed: () =>
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ManagePhotosScreen()))),
          ] else
            AppButton('Start verification', icon: Icons.videocam_rounded, onPressed: () => startSelfieCapture(context)),
          AppButton('Maybe later', variant: AppButtonVariant.ghost, onPressed: () => Navigator.pop(context)),
        ],
        children: [
          const VerificationAvatar(),
          const SizedBox(height: AppSpacing.xl),
          Text('Get verified', style: AppText.displaySmall, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          Text('Show your matches you’re the real you. It takes less than a minute.',
              style: AppText.bodyLarge.copyWith(color: AppColors.muted), textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.lg),
          Center(child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.mdSm, vertical: AppSpacing.sm),
            decoration: BoxDecoration(color: AppColors.verified.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(AppRadius.pill)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(  Icons.verified,  size: 20,  color: Color(0xFF3897F0)), const SizedBox(width: AppSpacing.sm),
              Flexible(child: Text('Verified profiles stand out and earn more trust',
                  style: AppText.labelMedium.copyWith(color: AppColors.verified))),
            ]))),
          const SizedBox(height: AppSpacing.xl),
          AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('How it works', style: AppText.h4),
            const SizedBox(height: AppSpacing.xs),
            const VerificationStep(1, 'Record a short selfie video',
                'Follow the on-screen prompts for about 6 seconds.'),
            const VerificationStep(2, 'We compare it with your photos',
                'We check the face in your video matches your profile photos.'),
            const VerificationStep(3, 'Get your blue star',
                'A blue verified star appears next to your name.'),
          ])),
          const SizedBox(height: AppSpacing.md),
          AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('For the best result', style: AppText.h4),
            const SizedBox(height: AppSpacing.sm),
            const VerificationTip(Icons.wb_sunny_outlined, 'Find good, even lighting on your face'),
            const VerificationTip(Icons.face_retouching_natural_outlined, 'Remove sunglasses, hats and masks'),
            const VerificationTip(Icons.stay_current_portrait_rounded, 'Hold your phone at eye level'),
            const VerificationTip(Icons.person_outline_rounded, 'Make sure you’re the only one in the frame'),
          ])),
          const SizedBox(height: AppSpacing.lg),
          const VerificationPrivacyNote(),
        ],
      );
    });
  }
}

class _AlreadyVerified extends StatelessWidget {
  const _AlreadyVerified();
  @override
  Widget build(BuildContext context) => VerificationPage(
    actions: [AppButton('Done', onPressed: () => Navigator.pop(context))],
    children: [
      const SizedBox(height: AppSpacing.xl),
      const VerificationAvatar(verified: true),
      const SizedBox(height: AppSpacing.xl),
      Text('You’re verified', style: AppText.displaySmall, textAlign: TextAlign.center),
      const SizedBox(height: AppSpacing.sm),
      Text('Your blue star shows matches that your photos are really you.',
          style: AppText.bodyLarge.copyWith(color: AppColors.muted), textAlign: TextAlign.center),
      const SizedBox(height: AppSpacing.xl),
      const VerificationTip(Icons.info_outline_rounded,
          'If you change your main photo to one that doesn’t show your face, you may be asked to verify again.',
          color: AppColors.verified),
    ],
  );
}

class _Notice extends StatelessWidget {
  final String text;
  const _Notice(this.text);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.mdSm),
    decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(AppRadius.standardCard)),
    child: Row(children: [
      const Icon(Icons.info_outline_rounded, size: 20, color: AppColors.warning),
      const SizedBox(width: AppSpacing.sm),
      Expanded(child: Text(text, style: AppText.bodySmall.copyWith(color: AppColors.text))),
    ]));
}
