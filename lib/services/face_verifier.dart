import 'dart:math';
import 'package:camera/camera.dart' show XFile;
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import '../data/profile_store.dart';

/// What the verifier is doing, so the UI can show progress.
enum VerificationStage { uploading, detectingFace, comparing }

/// Why a selfie video didn't pass.
enum VerificationFailure { noProfilePhotos, noFaceDetected, faceMismatch, network }

class VerificationResult {
  final VerificationFailure? failure;
  /// Similarity between the video face and the best-matching profile photo, 0..1.
  final double? similarity;
  const VerificationResult.verified({this.similarity}) : failure = null;
  const VerificationResult.failed(VerificationFailure this.failure, {this.similarity});
  bool get isVerified => failure == null;
}

/// Verification seam — replace [MockFaceVerifier] with a real backend. A typical setup uploads the
/// video, samples frames server-side, runs a liveness check, then compares the face against each
/// profile photo (e.g. AWS Rekognition CompareFaces, Azure Face Verify) and passes above a threshold.
abstract class FaceVerifier {
  /// Reports progress through [onStage]; network errors should throw so the UI can offer a retry.
  Future<VerificationResult> verify({required XFile video, required List<ProfilePhoto> photos,
      void Function(VerificationStage)? onStage});
}

class MockFaceVerifier implements FaceVerifier {
  /// Share of attempts that randomly fail, so the failure screens can be seen in development.
  final double failureRate;
  final Duration stepDelay;
  const MockFaceVerifier({this.failureRate = .25, this.stepDelay = const Duration(milliseconds: 1200)});

  @override
  Future<VerificationResult> verify({required XFile video, required List<ProfilePhoto> photos,
      void Function(VerificationStage)? onStage}) async {
    final rnd = Random();
    for (final stage in VerificationStage.values) {
      onStage?.call(stage);
      await Future.delayed(stepDelay);
    }
    if (photos.where((p) => p.status == PhotoStatus.uploaded).isEmpty) {
      return const VerificationResult.failed(VerificationFailure.noProfilePhotos);
    }
    if (rnd.nextDouble() < failureRate) {
      return VerificationResult.failed(rnd.nextBool() ? VerificationFailure.faceMismatch : VerificationFailure.noFaceDetected,
          similarity: rnd.nextDouble() * .5);
    }
    return VerificationResult.verified(similarity: .9 + rnd.nextDouble() * .09);
  }
}

/// The verifier the app uses; swap it in tests or when wiring up a backend.
FaceVerifier faceVerifier = const MockFaceVerifier();

enum CameraAccess { granted, denied, blocked }

/// Camera permission, normalised across platforms. Platforms without a permission plugin
/// (e.g. desktop) report [CameraAccess.granted] and let the camera itself prompt or fail.
class CameraPermission {
  static Future<CameraAccess> status() => _map(() => Permission.camera.status);
  static Future<CameraAccess> request() => _map(() => Permission.camera.request());
  static Future<bool> openSettings() async {
    try { return await openAppSettings(); } on MissingPluginException { return false; }
  }

  static Future<CameraAccess> _map(Future<PermissionStatus> Function() read) async {
    try {
      final s = await read();
      if (s.isGranted || s.isLimited) return CameraAccess.granted;
      return s.isPermanentlyDenied || s.isRestricted ? CameraAccess.blocked : CameraAccess.denied;
    } on MissingPluginException {
      return CameraAccess.granted;
    } on UnimplementedError {
      return CameraAccess.granted;
    } on PlatformException {
      return CameraAccess.granted;
    }
  }
}
