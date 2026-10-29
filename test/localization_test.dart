import 'package:amour/data/locale_store.dart';
import 'package:amour/data/match_engine.dart';
import 'package:amour/data/mock.dart';
import 'package:amour/data/profile_store.dart';
import 'package:amour/l10n/app_localizations.dart';
import 'package:amour/screens/app_shell.dart';
import 'package:amour/screens/auth/create_account_screen.dart';
import 'package:amour/screens/chat_screen.dart';
import 'package:amour/screens/edit_profile/edit_pages.dart';
import 'package:amour/screens/language_screen.dart';
import 'package:amour/screens/profile_detail_screen.dart';
import 'package:amour/screens/saved_profiles_screen.dart';
import 'package:amour/screens/settings_screen.dart';
import 'package:amour/screens/welcome_screen.dart';
import 'package:amour/widgets/skeletons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'helpers/localized_app.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  setUp(() {
    currentUser..reset()..seedDemo();
    matchEngine.reset();
    appLocale.locale = null;
  });

  Future<void> small(WidgetTester tester) async {
    tester.view..physicalSize = const Size(360, 640)..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  for (final code in ['en', 'ta', 'ml', 'hi']) {
    final locale = Locale(code), l = lookupAppLocalizations(locale);

    testWidgets('main screens render in $code without overflow', (tester) async {
      await small(tester);
      final screens = <Widget>[
        const WelcomeScreen(), const CreateAccountScreen(), const SettingsScreen(), const SavedProfilesScreen(),
        ProfileDetailScreen(profile: profiles.first), ChatScreen(profile: profiles.first, newMatch: true),
        const LanguagesEditPage(), const TeaserAnswerPage(prompt: 'My ideal first date…'),
      ];
      for (final s in screens) {
        await tester.pumpWidget(localizedApp(home: s, locale: locale));
        await tester.pumpAndSettle();
      }
      expect(find.text(l.voicePromptTitle), findsOneWidget); // the last screen pumped

      await tester.pumpWidget(localizedApp(home: const AppShell(), locale: locale));
      await tester.pump(kMockLoadDelay);
      await tester.pumpAndSettle();
      expect(find.text(l.tabDiscover), findsOneWidget);
      // The top card (and possibly the one stacked behind it) shows the best score.
      expect(find.text(l.percentMatch(matchEngine.insight(matchEngine.rank(profiles).first).score)), findsWidgets);
    });
  }

  testWidgets('choosing Tamil switches the app and adds Tamil to spoken languages', (tester) async {
    currentUser.languages.clear();
    await tester.pumpWidget(ListenableBuilder(listenable: appLocale,
        builder: (_, __) => localizedApp(home: const LanguageScreen(), locale: appLocale.locale ?? const Locale('en'))));
    expect(find.text('App language'), findsOneWidget);

    await tester.tap(find.text('தமிழ்'));
    await tester.pumpAndSettle();
    expect(find.text('ஆப் மொழி'), findsOneWidget);
    expect(currentUser.languages, contains('Tamil'));
    expect(find.text('நான் பேசும் மொழிகளில் தமிழ் சேர்க்கப்பட்டது'), findsOneWidget);

    await tester.tap(find.text('போனின் மொழி'));
    await tester.pumpAndSettle();
    expect(appLocale.locale, isNull);
  });

  testWidgets('languages I speak can be edited', (tester) async {
    currentUser.languages.clear();
    await tester.pumpWidget(localizedApp(home: const LanguagesEditPage()));
    await tester.tap(find.text('മലയാളം · Malayalam'));
    await tester.pump();
    expect(currentUser.languages, {'Malayalam'});
    expect(find.text('1 selected'), findsOneWidget);
  });
}
