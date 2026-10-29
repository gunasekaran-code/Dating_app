import 'dart:typed_data';

import 'package:amour/data/profile_options.dart';
import 'package:amour/data/profile_store.dart';
import 'package:amour/screens/onboarding/onboarding_flow.dart';
import 'package:amour/screens/splash_screen.dart';
import 'package:amour/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'helpers/localized_app.dart';

class _InstantUploader implements PhotoUploader {
  bool fail;
  _InstantUploader({this.fail = false});
  @override
  Future<String> upload(Uint8List bytes, {required void Function(double) onProgress}) async {
    onProgress(.5);
    if (fail) throw Exception('nope');
    onProgress(1);
    return 'https://cdn.test/${bytes.first}.jpg';
  }
}

Uint8List _img(int tag) => Uint8List.fromList([tag]);

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  group('PhotoManager', () {
    test('uploads added photos and caps at the maximum', () async {
      final m = PhotoManager(uploader: _InstantUploader());
      expect(m.addAll([for (var i = 0; i < 8; i++) _img(i)]), PhotoManager.maxPhotos);
      expect(m.isFull, isTrue);
      expect(m.isUploading, isTrue);
      await pumpEventQueue();
      expect(m.uploadedCount, PhotoManager.maxPhotos);
      expect(m.photos.first.url, 'https://cdn.test/0.jpg');
      expect(m.meetsMinimum, isTrue);
    });

    test('reorders, sets main photo and removes', () async {
      final m = PhotoManager(uploader: _InstantUploader())..addAll([_img(0), _img(1), _img(2)]);
      await pumpEventQueue();
      final ids = m.photos.map((p) => p.id).toList();
      m.move(0, 2);
      expect(m.photos.map((p) => p.id), [ids[1], ids[2], ids[0]]);
      m.makeMain(ids[0]);
      expect(m.main!.id, ids[0]);
      m.remove(ids[0]);
      expect(m.main!.id, ids[1]);
      expect(m.count, 2);
    });

    test('failed uploads can be retried and block the minimum', () async {
      final up = _InstantUploader(fail: true);
      final m = PhotoManager(uploader: up)..addAll([_img(0), _img(1)]);
      await pumpEventQueue();
      expect(m.hasFailures, isTrue);
      expect(m.meetsMinimum, isFalse);
      up.fail = false;
      for (final p in m.photos) { m.retry(p.id); }
      await pumpEventQueue();
      expect(m.hasFailures, isFalse);
      expect(m.meetsMinimum, isTrue);
    });

    test('replace keeps the position', () async {
      final m = PhotoManager(uploader: _InstantUploader())..addAll([_img(0), _img(1)]);
      await pumpEventQueue();
      m.replace(m.photos.last.id, _img(9));
      await pumpEventQueue();
      expect(m.photos.last.url, 'https://cdn.test/9.jpg');
      expect(m.count, 2);
    });
  });

  test('formatHeight converts to feet and inches', () {
    expect(formatHeight(175), '175 cm');
    expect(formatHeight(175, metric: false), '5′ 9″');
  });

  testWidgets('splash hands off to the welcome screen', (tester) async {
    await tester.pumpWidget(localizedApp(home: const SplashScreen(hold: Duration(milliseconds: 300))));
    expect(find.text('Amour'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(WelcomeScreen), findsOneWidget);
  });

  testWidgets('onboarding requires a name before continuing', (tester) async {
    currentUser.reset();
    await tester.pumpWidget(localizedApp(home: const OnboardingFlow()));
    await tester.pump();
    expect(find.text('What’s your first name?'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(find.text('What’s your first name?'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Priya');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('When’s your birthday?'), findsOneWidget);
    expect(currentUser.age, greaterThanOrEqualTo(18));
  });
}
