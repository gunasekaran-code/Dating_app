import 'package:amour/data/match_engine.dart';
import 'package:amour/data/mock.dart';
import 'package:amour/data/profile_store.dart';
import 'package:amour/screens/profile_detail_screen.dart';
import 'package:amour/screens/saved_profiles_screen.dart';
import 'package:amour/widgets/match_insights.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'helpers/localized_app.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  setUp(() {
    currentUser..reset()..seedDemo();
    matchEngine.reset();
  });

  testWidgets('profile detail explains the match and saves the profile', (tester) async {
    tester.view..physicalSize = const Size(360, 640)..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final p = profiles.first;
    final score = matchEngine.insight(p).score;
    await tester.pumpWidget(localizedApp(home: ProfileDetailScreen(profile: p)));
    await tester.pumpAndSettle();

    // The pill opens the "Why you match" sheet.
    await tester.tap(find.text('$score% match'));
    await tester.pumpAndSettle();
    expect(find.text('You & ${p.name}'), findsOneWidget);
    Navigator.pop(tester.element(find.text('You & ${p.name}')));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Why you match'), 200, scrollable: find.byType(Scrollable).first);
    expect(find.byType(MatchReasonTile), findsWidgets);

    await tester.tap(find.byTooltip('Save profile'));
    await tester.pump();
    expect(matchEngine.isSaved(p), isTrue);
    expect(find.byTooltip('Remove from saved'), findsOneWidget);
    // Saving a profile teaches the engine about others, never inflates its own score.
    expect(matchEngine.insight(p).score, score);
  });

  testWidgets('saved screen lists saved profiles and learning stats', (tester) async {
    matchEngine
      ..toggleSave(profiles[1])
      ..record(profiles[4], MatchSignal.like)
      ..record(profiles[6], MatchSignal.skip);
    await tester.pumpWidget(localizedApp(home: const SavedProfilesScreen()));
    await tester.pumpAndSettle();

    expect(find.text('${profiles[1].name}, ${profiles[1].age}'), findsOneWidget);
    expect(find.text('Liked'), findsOneWidget);
    expect(find.text('You’re drawn to'), findsOneWidget);

    await tester.tap(find.text('Reset picks'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset').last);
    await tester.pumpAndSettle();
    expect(matchEngine.count(MatchSignal.like), 0);
    expect(matchEngine.saved, [profiles[1]]);
  });
}
