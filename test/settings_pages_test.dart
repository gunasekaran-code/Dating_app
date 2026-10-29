import 'package:amour/data/account_store.dart';
import 'package:amour/data/mock.dart';
import 'package:amour/screens/settings/blocked_profiles_screen.dart';
import 'package:amour/screens/settings/contact_details_screen.dart';
import 'package:amour/screens/settings/help_screen.dart';
import 'package:amour/screens/settings/safety_centre_screen.dart';
import 'package:amour/screens/settings/terms_privacy_screen.dart';
import 'package:amour/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'helpers/localized_app.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  setUp(() {
    account..reset()..signIn(email: 'guna@example.com')..seedDemo();
  });

  Future<void> pump(WidgetTester tester, Widget home) async {
    tester.view..physicalSize = const Size(360, 640)..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(localizedApp(home: home));
    await tester.pumpAndSettle();
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.scrollUntilVisible(find.text(text), 150, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  testWidgets('every settings link opens its page without overflow', (tester) async {
    await pump(tester, const SettingsScreen());
    for (final (label, page) in const [
      ('Email & phone', ContactDetailsScreen), ('Blocked profiles', BlockedProfilesScreen),
      ('Safety centre', SafetyCentreScreen), ('Help', HelpScreen), ('Terms & privacy', TermsPrivacyScreen),
    ]) {
      await tapText(tester, label);
      expect(find.byType(page), findsOneWidget, reason: label);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
    }
  });

  testWidgets('change email with a code', (tester) async {
    await pump(tester, const ContactDetailsScreen());
    expect(find.text('guna@example.com'), findsOneWidget);
    await tester.tap(find.text('guna@example.com'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'not-an-email');
    await tester.tap(find.text('Send code'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid email address'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'guna.new@example.com');
    await tester.tap(find.text('Send code'));
    await tester.pumpAndSettle();
    expect(find.text('Enter the code'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '123456');
    await tester.pumpAndSettle();
    expect(account.email, 'guna.new@example.com');
    expect(find.byType(ContactDetailsScreen), findsOneWidget);
    expect(find.text('guna.new@example.com'), findsOneWidget);
  });

  testWidgets('unblock with undo', (tester) async {
    await pump(tester, const BlockedProfilesScreen());
    expect(find.text('${profiles[2].name}, ${profiles[2].age}'), findsOneWidget);
    await tester.tap(find.text('Unblock'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Unblock').last);
    await tester.pumpAndSettle();
    expect(account.blocked, isEmpty);
    expect(find.text('No one blocked'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(account.blocked, hasLength(1));
  });

  testWidgets('help search and categories filter FAQs', (tester) async {
    await pump(tester, const HelpScreen());
    await tester.enterText(find.byType(TextField), 'refund');
    await tester.pumpAndSettle();
    expect(find.text('1 RESULT'), findsOneWidget);
    await tester.tap(find.text('Can I get a refund?'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Refunds are handled'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'zzzz');
    await tester.pumpAndSettle();
    expect(find.textContaining('No articles match'), findsOneWidget);
  });

  testWidgets('terms toggle switches to privacy', (tester) async {
    await pump(tester, const TermsPrivacyScreen());
    expect(find.text('Terms of service'), findsOneWidget);
    await tester.tap(find.text('Privacy'));
    await tester.pumpAndSettle();
    expect(find.text('Privacy policy'), findsOneWidget);
    await tapText(tester, 'Download my data');
  });

  testWidgets('safety centre report flow', (tester) async {
    await pump(tester, const SafetyCentreScreen());
    await tester.tap(find.text('Report'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fake profile or scam'));
    await tester.pumpAndSettle();
    await tapText(tester, 'Submit report');
    expect(find.textContaining('safety team will review'), findsOneWidget);
  });
}
