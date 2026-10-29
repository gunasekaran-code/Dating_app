import 'dart:typed_data';

import 'package:amour/data/profile_store.dart';
import 'package:amour/screens/edit_profile/edit_profile_screen.dart';
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

  setUp(() {
    currentUser..reset()..update(() {
      currentUser..name = 'Guna'..birthday = DateTime(DateTime.now().year - 23, 1, 1)..gender = 'Man'
        ..job = 'App Developer'..city = 'Thoothukudi'..heightCm = 175
        ..relationships.add('Short-term relationship')..lifestyle['Smoking'] = 'Never'
        ..places.add(const FavouritePlace('🍗', 'KFC'));
    });
    currentUser.photos.addAll([_png, _png]);
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    tester.view..physicalSize = const Size(360, 640)..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(localizedApp(home: const EditProfileScreen()));
    await tester.pumpAndSettle();
  }

  Future<void> scrollTo(WidgetTester tester, Finder f) async {
    await tester.scrollUntilVisible(f, 200, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
  }

  /// Scrolls to [heading], taps it (or, for a card section, its "Edit/Add ›" link) and comes back.
  Future<void> openAndBack(WidgetTester tester, String heading, String expectTitle, {bool card = false}) async {
    await scrollTo(tester, find.text(heading));
    final target = card
        ? find.descendant(of: find.ancestor(of: find.text(heading), matching: find.byType(Column)).first,
            matching: find.byIcon(Icons.chevron_right_rounded))
        : find.text(heading);
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    await tester.tap(target);
    await tester.pumpAndSettle();
    expect(find.text(expectTitle), findsWidgets, reason: 'opening $target');
    await tester.tap(find.byTooltip('Back').first);
    await tester.pumpAndSettle();
  }

  testWidgets('every section opens its editor without overflow', (tester) async {
    await pumpScreen(tester);
    expect(find.text('Guna, 23'), findsOneWidget);
    expect(find.text('Build trust'), findsOneWidget);

    for (final (row, title) in const [
      ('My Teasers (0/3)', 'My Teasers'), ('Relationships', 'What are you looking for?'),
      ('Hobbies (0/10)', 'What are your hobbies?'), ('Places (1/10)', 'Your favourite places'),
      ('My bio', 'Complete your profile'), ('Age', 'When’s your birthday?'), ('Gender', 'How do you identify?'),
      ('City', 'Find a Crush in your city'), ('Work', 'What do you do?'), ('Education', 'What did you study?'),
      ('Kids', 'What about kids?'), ('Smoking', 'Do you smoke?'), ('Height', 'How tall are you?'),
      ('Sport', 'How often do you play sport?'), ('Drinking', 'Do you drink?'),
      ('Food habits', 'What are your food habits?'),
    ]) {
      await openAndBack(tester, row, title,
          card: row.startsWith('My ') || row.contains('(') || row == 'Relationships');
    }
  });

  testWidgets('edits flow back to the profile', (tester) async {
    await pumpScreen(tester);

    // Bio
    await scrollTo(tester, find.textContaining('Tell us a bit more'));
    await tester.tap(find.textContaining('Tell us a bit more'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Coffee, code and cricket.');
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(currentUser.bio, 'Coffee, code and cricket.');
    expect(find.text('Coffee, code and cricket.'), findsOneWidget);

    // Lifestyle single choice auto-returns
    await scrollTo(tester, find.text('Sport'));
    await tester.tap(find.text('Sport'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Regularly'));
    await tester.pumpAndSettle();
    expect(currentUser.lifestyle['Sport'], 'Regularly');
    expect(find.text('Regularly'), findsOneWidget);

    // Delete clears the answer
    await scrollTo(tester, find.text('Smoking'));
    await tester.tap(find.text('Smoking'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(currentUser.lifestyle.containsKey('Smoking'), isFalse);

    // Preview
    await tester.tap(find.text('View my profile'));
    await tester.pumpAndSettle();
    expect(find.text('Preview'), findsOneWidget);
  });
}
