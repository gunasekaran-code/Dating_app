import 'package:flutter/material.dart';
import '../../services/face_verifier.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/buttons.dart';
import '../../widgets/profile_bits.dart';
import '../../widgets/states.dart';
import '../../widgets/verification_widgets.dart';
import 'selfie_capture_screen.dart';

/// Asks for camera access before recording. When access is blocked, sends the user to
/// Settings and continues automatically once they come back with it enabled.
class CameraPermissionScreen extends StatefulWidget {
  final CameraAccess initial;
  const CameraPermissionScreen({super.key, this.initial = CameraAccess.denied});
  @override
  State<CameraPermissionScreen> createState() => _CameraPermissionScreenState();
}

class _CameraPermissionScreenState extends State<CameraPermissionScreen> with WidgetsBindingObserver {
  late var _access = widget.initial;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _access == CameraAccess.blocked) _recheck();
  }

  Future<void> _recheck() async => _handle(await CameraPermission.status());

  Future<void> _allow() async {
    setState(() => _busy = true);
    final access = await CameraPermission.request();
    if (!mounted) return;
    setState(() => _busy = false);
    _handle(access);
    if (access == CameraAccess.denied) {
      showToast(context, 'Camera access is needed to record your selfie video.', type: ToastType.error);
    }
  }

  Future<void> _openSettings() async {
    if (!await CameraPermission.openSettings() && mounted) {
      showToast(context, 'Open your device Settings and allow camera access for Amour.');
    }
  }

  void _handle(CameraAccess access) {
    if (!mounted) return;
    if (access == CameraAccess.granted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SelfieCaptureScreen()));
    } else {
      setState(() => _access = access);
    }
  }

  @override
  Widget build(BuildContext context) {
    final blocked = _access == CameraAccess.blocked;
    return VerificationPage(
      actions: [
        blocked
            ? AppButton('Open Settings', icon: Icons.settings_outlined, onPressed: _openSettings)
            : AppButton('Allow camera', icon: Icons.photo_camera_outlined, loading: _busy, onPressed: _allow),
        AppButton('Not now', variant: AppButtonVariant.ghost, onPressed: () => Navigator.pop(context)),
      ],
      children: [
        const SizedBox(height: AppSpacing.xl),
        VerificationIcon(icon: blocked ? Icons.no_photography_outlined : Icons.photo_camera_front_outlined),
        const SizedBox(height: AppSpacing.xl),
        Text(blocked ? 'Camera access is off' : 'Allow camera access',
            style: AppText.displaySmall, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.sm),
        Text(blocked
            ? 'To verify your profile, turn on camera access for Amour in Settings. We’ll pick up right where you left off.'
            : 'We use your front camera to record a short selfie video, so we can check it matches your photos.',
            style: AppText.bodyLarge.copyWith(color: AppColors.muted), textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.xl),
        AppCard(child: Column(children: blocked
            ? const [
                VerificationTip(Icons.settings_outlined, 'Open Settings › Amour', color: AppColors.primary),
                VerificationTip(Icons.toggle_on_outlined, 'Switch Camera on', color: AppColors.primary),
                VerificationTip(Icons.keyboard_return_rounded, 'Come back here to continue', color: AppColors.primary),
              ]
            : const [
                VerificationTip(Icons.videocam_outlined, 'Only used while you record', color: AppColors.primary),
                VerificationTip(Icons.mic_off_outlined, 'No audio is recorded', color: AppColors.primary),
                VerificationTip(Icons.visibility_off_outlined, 'Your video is never shown to anyone',
                    color: AppColors.primary),
              ])),
        const SizedBox(height: AppSpacing.lg),
        const VerificationPrivacyNote(),
      ],
    );
  }
}
