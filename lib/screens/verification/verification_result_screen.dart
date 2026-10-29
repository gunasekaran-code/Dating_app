import 'package:flutter/material.dart';
import '../../data/profile_store.dart';
import '../../services/face_verifier.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/buttons.dart';
import '../../widgets/photo_grid.dart';
import '../../widgets/profile_bits.dart';
import '../../widgets/verification_widgets.dart';
import '../manage_photos_screen.dart';
import 'verification_flow.dart';

/// Verified / Not verified outcome, with a retry on failure.
class VerificationResultScreen extends StatelessWidget {
  final VerificationResult result;
  const VerificationResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) => result.isVerified ? const _Verified() : _NotVerified(result.failure!);
}

class _StatusPill extends StatelessWidget {
  final bool verified;
  const _StatusPill({required this.verified});
  @override
  Widget build(BuildContext context) {
    final color = verified ? AppColors.verified : AppColors.error;
    return Center(child: Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.mdSm, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: .1), borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(verified ? Icons.check_rounded : Icons.close_rounded, size: 16, color: color),
        const SizedBox(width: AppSpacing.xs),
        Text(verified ? 'Verified' : 'Not verified', style: AppText.labelMedium.copyWith(color: color)),
      ])));
  }
}

class _Verified extends StatelessWidget {
  const _Verified();
  @override
  Widget build(BuildContext context) {
    final u = currentUser, main = u.photos.main;
    return VerificationPage(close: true, actions: [
      AppButton('Back to profile', onPressed: () => closeVerification(context)),
    ], children: [
      const SizedBox(height: AppSpacing.xl),
      TweenAnimationBuilder<double>(tween: Tween(begin: 0, end: 1), duration: const Duration(milliseconds: 900),
        curve: Curves.elasticOut,
        builder: (_, v, child) => Transform.scale(scale: v, child: child),
        child: VerificationIcon(color: AppColors.verified, background: AppColors.verified.withValues(alpha: .1),
            child: const VerifiedBadge(size: 64))),
      const SizedBox(height: AppSpacing.xl),
      const _StatusPill(verified: true),
      const SizedBox(height: AppSpacing.md),
      Text('You’re verified!', style: AppText.displaySmall, textAlign: TextAlign.center),
      const SizedBox(height: AppSpacing.sm),
      Text('Your video matched your photos. Your blue star now shows matches you’re the real deal.',
          style: AppText.bodyLarge.copyWith(color: AppColors.muted), textAlign: TextAlign.center),
      const SizedBox(height: AppSpacing.xl),
      Text('HOW IT LOOKS ON YOUR PROFILE', style: AppText.labelSmall.copyWith(color: AppColors.muted, letterSpacing: .8)),
      const SizedBox(height: AppSpacing.sm),
      AppCard(child: Row(children: [
        ClipOval(child: main == null
            ? Container(width: 48, height: 48, color: AppColors.secondary,
                child: const Icon(Icons.person_rounded, color: AppColors.accent))
            : PhotoImage(main, width: 48, height: 48)),
        const SizedBox(width: AppSpacing.mdSm),
        Flexible(child: Text([u.name.trim(), if (u.age != null) '${u.age}'].join(', '),
            style: AppText.h4, overflow: TextOverflow.ellipsis)),
        const SizedBox(width: AppSpacing.sm),
        const VerifiedBadge(size: 22),
      ])),
    ]);
  }
}

class _NotVerified extends StatelessWidget {
  final VerificationFailure failure;
  const _NotVerified(this.failure);

  @override
  Widget build(BuildContext context) {
    final (icon, title, body) = switch (failure) {
      VerificationFailure.noFaceDetected => (Icons.face_retouching_off_rounded, 'We couldn’t see your face',
          'Keep your whole face inside the oval, in good light, while you follow the prompts.'),
      VerificationFailure.faceMismatch => (Icons.person_search_rounded, 'Your video didn’t match your photos',
          'We couldn’t match the face in your video to your profile photos. Make sure your photos clearly show you.'),
      VerificationFailure.noProfilePhotos => (Icons.add_photo_alternate_outlined, 'Add a photo of yourself first',
          'We compare your video with your profile photos, so you need at least one clear photo of your face.'),
      VerificationFailure.network => (Icons.wifi_off_rounded, 'Something went wrong',
          'We couldn’t finish checking your video. Check your connection and try again.'),
    };
    void photos() => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ManagePhotosScreen()));
    return VerificationPage(close: true, actions: [
      if (failure == VerificationFailure.noProfilePhotos)
        AppButton('Add photos', icon: Icons.add_photo_alternate_outlined, onPressed: photos)
      else
        AppButton('Try again', icon: Icons.refresh_rounded, onPressed: () => startSelfieCapture(context, replace: true)),
      if (failure == VerificationFailure.faceMismatch)
        AppButton('Update my photos', variant: AppButtonVariant.secondary, onPressed: photos),
      AppButton('Not now', variant: AppButtonVariant.ghost, onPressed: () => closeVerification(context)),
    ], children: [
      const SizedBox(height: AppSpacing.xl),
      VerificationIcon(icon: icon, color: AppColors.error, background: AppColors.error.withValues(alpha: .1)),
      const SizedBox(height: AppSpacing.xl),
      const _StatusPill(verified: false),
      const SizedBox(height: AppSpacing.md),
      Text(title, style: AppText.displaySmall, textAlign: TextAlign.center),
      const SizedBox(height: AppSpacing.sm),
      Text(body, style: AppText.bodyLarge.copyWith(color: AppColors.muted), textAlign: TextAlign.center),
      const SizedBox(height: AppSpacing.xl),
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Tips for your next try', style: AppText.h4),
        const SizedBox(height: AppSpacing.sm),
        const VerificationTip(Icons.wb_sunny_outlined, 'Face a window or light — avoid backlight'),
        const VerificationTip(Icons.center_focus_strong_outlined, 'Keep your face inside the oval the whole time'),
        const VerificationTip(Icons.slow_motion_video_rounded, 'Turn your head slowly when prompted'),
        const VerificationTip(Icons.face_retouching_natural_outlined, 'Take off sunglasses, hats or masks'),
      ])),
    ]);
  }
}
