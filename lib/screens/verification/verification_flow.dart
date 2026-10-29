import 'package:flutter/material.dart';
import '../../services/face_verifier.dart';
import 'camera_permission_screen.dart';
import 'selfie_capture_screen.dart';
import 'verification_intro_screen.dart';

/// Profile verification: Intro → (Camera permission) → Selfie video → Verifying → Result.
const verificationRoute = '/verification';

Future<void> openVerification(BuildContext context) => Navigator.push(context, MaterialPageRoute(
    settings: const RouteSettings(name: verificationRoute), builder: (_) => const VerificationIntroScreen()));

/// Leaves the flow, returning to wherever [openVerification] was called from.
void closeVerification(BuildContext context) {
  final nav = Navigator.of(context);
  var found = false;
  nav.popUntil((r) => (found = r.settings.name == verificationRoute) || r.isFirst);
  if (found) nav.pop();
}

/// Goes to the selfie camera, via the permission page if camera access isn't granted yet.
Future<void> startSelfieCapture(BuildContext context, {bool replace = false}) async {
  final access = await CameraPermission.status();
  if (!context.mounted) return;
  final route = MaterialPageRoute<void>(builder: (_) => access == CameraAccess.granted
      ? const SelfieCaptureScreen()
      : CameraPermissionScreen(initial: access));
  replace ? Navigator.pushReplacement(context, route) : Navigator.push(context, route);
}
