import 'dart:typed_data';

import 'package:amour/data/profile_store.dart';
import 'package:amour/screens/my_profile_screen.dart';
import 'package:amour/screens/verification/verification_flow.dart';
import 'package:amour/screens/verification/verification_result_screen.dart';
import 'package:amour/screens/verification/verifying_screen.dart';
import 'package:amour/services/face_verifier.dart';
import 'package:amour/widgets/profile_bits.dart';
import 'package:camera/camera.dart' show XFile;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'helpers/localized_app.dart';

// 1×1 transparent PNG so Image.memory can decode it.
final _png = Uint8List.fromList(const [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01,
  0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82]);

class _FakeVerifier implements FaceVerifier {
  final VerificationResult result;
  _FakeVerifier(this.result);
  @override
  Future<VerificationResult> verify({required XFile video, required List<ProfilePhoto> photos,
      void Function(VerificationStage)? onStage}) async {
    for (final s in VerificationStage.values) {
      onStage?.call(s);
      await Future.delayed(const Duration(milliseconds: 100));
    }
    return result;
  }
}

Future<void> _signedIn(WidgetTester tester, {bool photos = true}) async {
  currentUser.reset();
  currentUser.update(() => currentUser.name = 'Priya');
  if (photos) {
    currentUser.photos.addAll([_png, _png]);
    await tester.pump(const Duration(seconds: 5));
  }
}

Future<void> _openProfile(WidgetTester tester) async {
  await tester.pumpWidget(localizedApp(home: const Scaffold(body: MyProfileScreen())));
  await tester.pumpAndSettle();
}

/// Lets platform-channel calls (which fail under test) complete. Pumps rather than settles,
/// since the camera page shows a spinner until they do.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 20)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  tearDown(() => faceVerifier = const MockFaceVerifier());

  test('mock verifier fails without uploaded profile photos', () async {
    final r = await const MockFaceVerifier(failureRate: 0, stepDelay: Duration.zero)
        .verify(video: XFile('selfie.mp4'), photos: const []);
    expect(r.failure, VerificationFailure.noProfilePhotos);
  });

  testWidgets('verify star next to the name opens verification', (tester) async {
    tester.view..physicalSize = const Size(390, 844)..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await _signedIn(tester);
    await _openProfile(tester);

    expect(find.byType(VerifiedBadge), findsNothing);
    await tester.tap(find.byType(VerifyStarButton));
    await tester.pumpAndSettle();
    expect(find.text('Get verified'), findsOneWidget);
    expect(find.text('How it works'), findsOneWidget);
  });

  for (final size in const [Size(390, 844), Size(360, 640)]) {
    testWidgets('intro → camera without overflow at $size', (tester) async {
      tester.view..physicalSize = size..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await _signedIn(tester);
      await tester.pumpWidget(localizedApp(home: Builder(builder: (context) =>
          Scaffold(body: Center(child: TextButton(onPressed: () => openVerification(context), child: const Text('open')))))));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Make sure you’re the only one in the frame'), 200);
      expect(find.text('Start verification'), findsOneWidget);

      // No camera plugin under test, so the capture page lands on its error state.
      await tester.tap(find.text('Start verification'));
      await _settle(tester);
      expect(find.text('Camera not available'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });
  }

  testWidgets('intro asks for photos when there are none', (tester) async {
    tester.view..physicalSize = const Size(390, 844)..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await _signedIn(tester, photos: false);
    await _openProfile(tester);
    await tester.tap(find.byType(VerifyStarButton));
    await tester.pumpAndSettle();
    expect(find.text('Start verification'), findsNothing);
    expect(find.text('Add photos'), findsOneWidget);
  });

  testWidgets('successful verification shows the result and the blue star on the profile', (tester) async {
    tester.view..physicalSize = const Size(390, 844)..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await _signedIn(tester);
    faceVerifier = _FakeVerifier(const VerificationResult.verified(similarity: .95));
    await _openProfile(tester);

    // Enter the flow from the star, then jump past the camera (unavailable under test).
    await tester.tap(find.byType(VerifyStarButton));
    await tester.pumpAndSettle();
    tester.state<NavigatorState>(find.byType(Navigator))
        .push(MaterialPageRoute(builder: (_) => VerifyingScreen(video: XFile('selfie.mp4'))));
    await tester.pump(); // first frame of a push is offstage
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.text('Checking it’s you'), findsOneWidget);
    expect(find.text('Comparing with your photos'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text('You’re verified!'), findsOneWidget);
    expect(find.text('Verified'), findsOneWidget);
    expect(currentUser.verified, isTrue);

    await tester.tap(find.text('Back to profile'));
    await tester.pumpAndSettle();
    expect(find.byType(MyProfileScreen), findsOneWidget);
    expect(find.byType(VerifyStarButton), findsNothing);
    expect(find.byType(VerifiedBadge), findsOneWidget);
  });

  for (final failure in VerificationFailure.values) {
    testWidgets('not verified ($failure) offers a way forward', (tester) async {
      tester.view..physicalSize = const Size(360, 640)..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await _signedIn(tester);
      await tester.pumpWidget(localizedApp(home: VerificationResultScreen(result: VerificationResult.failed(failure))));
      await tester.pumpAndSettle();
      expect(find.text('Not verified'), findsOneWidget);
      expect(find.text(failure == VerificationFailure.noProfilePhotos ? 'Add photos' : 'Try again'), findsOneWidget);
      expect(find.text('Not now'), findsOneWidget);
      expect(currentUser.verified, isFalse);
    });
  }
}
