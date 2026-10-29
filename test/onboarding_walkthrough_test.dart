import 'dart:typed_data';

import 'package:amour/data/profile_store.dart';
import 'package:amour/screens/manage_photos_screen.dart';
import 'package:amour/screens/my_profile_screen.dart';
import 'package:amour/screens/onboarding/all_set_screen.dart';
import 'package:amour/screens/onboarding/onboarding_flow.dart';
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

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  for (final size in const [Size(390, 844), Size(360, 640)]) {
    testWidgets('full onboarding walkthrough without overflow at $size', (tester) async {
      tester.view..physicalSize = size..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      currentUser.reset();

      await tester.pumpWidget(localizedApp(home: const OnboardingFlow()));
      await tester.pump();

      Future<void> pick(String label) async {
        await tester.ensureVisible(find.text(label));
        await tester.pumpAndSettle();
        await tester.tap(find.text(label));
      }
      Future<void> next() async { await tester.pump(); await tester.tap(find.text('Continue')); await tester.pumpAndSettle(); }

      await tester.enterText(find.byType(TextField), 'Priya');
      await tester.pump();
      await next();
      expect(find.textContaining('You’re '), findsOneWidget); // birthday age card
      await next();
      await tester.tap(find.text('Woman'));
      await tester.tap(find.text('More options'));
      await tester.pumpAndSettle();
      await next();
      await tester.tap(find.text('Men'));
      await next();
      expect(find.text('How tall are you?'), findsOneWidget);
      await tester.tap(find.text('ft / in'));
      await tester.pumpAndSettle();
      await next();
      await pick("Master's degree");
      await next();
      await pick('New friends');
      await next();
      for (final i in ['☕ Coffee', '🥾 Hiking', '✈️ Travel']) { await pick(i); }
      await tester.pump();
      await next();

      expect(find.text('Add your first photos'), findsOneWidget);
      expect(find.text('Add 2 more photos'), findsOneWidget);
      currentUser.photos.addAll([_png, _png, _png]);
      await tester.pump();
      expect(find.text('Uploading photos…'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(find.text('Finish'), findsOneWidget);

      await tester.tap(find.text('Finish'));
      await tester.pumpAndSettle();
      expect(find.byType(AllSetScreen), findsOneWidget);
      expect(find.text('You’re all set, Priya!'), findsOneWidget);
      expect(currentUser.heightCm, isNotNull);
      expect(currentUser.education, "Master's degree");
    });
  }

  testWidgets('manage photos and profile render with photos', (tester) async {
    tester.view..physicalSize = const Size(390, 844)..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    currentUser.reset();
    currentUser.update(() => currentUser.name = 'Priya');
    currentUser.photos.addAll([_png, _png]);
    await tester.pump(const Duration(seconds: 5));

    await tester.pumpWidget(localizedApp(home: const Scaffold(body: MyProfileScreen())));
    await tester.pumpAndSettle();
    expect(find.text('My photos'), findsOneWidget);

    await tester.pumpWidget(localizedApp(home: const ManagePhotosScreen()));
    await tester.pumpAndSettle();
    expect(find.text('2/6'), findsOneWidget);

    // Removing is blocked at the minimum: no confirm dialog, a toast instead.
    await tester.tap(find.bySemanticsLabel('Remove photo').first);
    await tester.pumpAndSettle();
    expect(find.text('Remove this photo?'), findsNothing);
    expect(find.textContaining('needs at least 2 photos'), findsOneWidget);
    expect(currentUser.photos.count, 2);

    // With a third photo, removal goes through after confirming.
    currentUser.photos.addAll([_png]);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Remove photo').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    expect(currentUser.photos.count, 2);
  });
}
