import 'package:amour/data/icebreakers.dart';
import 'package:amour/data/match_engine.dart';
import 'package:amour/data/mock.dart';
import 'package:amour/data/preferences_store.dart';
import 'package:amour/data/profile_store.dart';
import 'package:amour/l10n/app_localizations.dart';
import 'package:amour/l10n/match_text.dart';
import 'package:amour/screens/chat_screen.dart';
import 'package:amour/widgets/icebreakers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'helpers/localized_app.dart';

const _ananya = Profile(id: 'a', name: 'Ananya', age: 27, city: 'Bengaluru', job: 'Product Designer', bio: '',
    distanceKm: 3, lookingFor: 'Long-term partner', verified: true, online: true, photos: ['x'],
    interests: ['Hiking', 'Coffee', 'Design'], lifestyle: {'Sport': 'Regularly'},
    languages: ['Kannada', 'Tamil', 'English']);

final _en = lookupAppLocalizations(const Locale('en'));

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  MatchEngine engineFor(UserProfileStore u) => MatchEngine(user: u, prefs: DiscoveryPreferences());

  test('openers come from why you match, strongest first, with the match’s city', () {
    final engine = engineFor(UserProfileStore()
      ..interests.addAll(['🥾 Hiking', '☕ Coffee'])
      ..lookingFor = 'Long-term partner'
      ..lifestyle['Sport'] = 'Regularly');
    final ideas = icebreakersFor(_ananya, _en, engine: engine);
    expect(ideas, hasLength(4));
    expect(ideas.first.label, _en.reasonTitle(engine.insight(_ananya).top!));
    expect(ideas.map((b) => b.label), containsAll(['You both love Hiking', 'You both love Coffee',
      'Same relationship goals']));
    expect(ideas.firstWhere((b) => b.label == 'You both love Hiking').text, contains('trek'));
    expect(ideas.map((b) => b.text).toSet(), hasLength(ideas.length), reason: 'no duplicate lines');
  });

  test('more ideas rotates to different lines', () {
    final engine = engineFor(UserProfileStore()..interests.addAll(['🥾 Hiking', '☕ Coffee']));
    final a = icebreakersFor(_ananya, _en, engine: engine).map((b) => b.text);
    final b = icebreakersFor(_ananya, _en, engine: engine, variant: 1).map((b) => b.text);
    expect(b, isNot(equals(a)));
  });

  test('openers follow the app language, including one about a shared language', () {
    final engine = engineFor(UserProfileStore()
      ..interests.add('☕ Coffee')
      ..languages.addAll(['Tamil', 'English']));
    final ta = icebreakersFor(_ananya, lookupAppLocalizations(const Locale('ta')), engine: engine, limit: 6);
    expect(ta.map((b) => b.text), contains('ஃபில்டர் காபியா, டீயா — உங்க சாய்ஸ் என்ன?'));
    expect(ta.map((b) => b.label), contains('நீங்கள் இருவரும் தமிழ் பேசுவீர்கள்'));
    expect(ta.map((b) => b.text), contains('உங்களுக்கு ரொம்பப் பிடிச்ச தமிழ் படம் அல்லது பாட்டு எது?'));
    for (final code in ['ml', 'hi']) {
      final ideas = icebreakersFor(_ananya, lookupAppLocalizations(Locale(code)), engine: engine, limit: 6);
      expect(ideas, isNotEmpty);
      expect(ideas.every((b) => !b.text.contains('{')), isTrue, reason: code);
    }
  });

  test('falls back to their profile when there is little in common', () {
    final ideas = icebreakersFor(_ananya, _en, engine: engineFor(UserProfileStore()));
    expect(ideas, isNotEmpty);
    expect(ideas.map((b) => b.label), contains('Ananya loves Hiking'));
  });

  testWidgets('new match chat suggests icebreakers that fill the composer', (tester) async {
    tester.view..physicalSize = const Size(360, 640)..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    currentUser..reset()..seedDemo();
    matchEngine.reset();
    final p = profiles.first;
    await tester.pumpWidget(localizedApp(home: ChatScreen(profile: p, newMatch: true)));
    await tester.pumpAndSettle();

    expect(find.text('You matched with ${p.name}'), findsOneWidget);
    final first = icebreakersFor(p, _en).first;
    await tester.scrollUntilVisible(find.text(first.text), 200, scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text(first.text));
    await tester.pump();
    expect(find.widgetWithText(TextField, first.text), findsOneWidget);

    await tester.tap(find.byTooltip('Send'));
    await tester.pumpAndSettle();
    expect(find.byType(IcebreakerPanel), findsNothing);
    expect(find.text(first.text), findsOneWidget); // now a sent message

    // Once the chat has started, icebreakers move behind the lightbulb.
    await tester.tap(find.byTooltip('Icebreakers'));
    await tester.pumpAndSettle();
    expect(find.byType(IcebreakerPanel), findsOneWidget);
    await tester.tap(find.byType(IcebreakerCard).first);
    await tester.pumpAndSettle();
    expect(find.byType(IcebreakerPanel), findsNothing);
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, isNotEmpty);
  });
}
