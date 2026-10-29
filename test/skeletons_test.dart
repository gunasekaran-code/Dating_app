import 'package:amour/screens/app_shell.dart';
import 'package:amour/widgets/skeletons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'helpers/localized_app.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  for (final size in const [Size(390, 844), Size(360, 640)]) {
    testWidgets('main tabs show skeletons, then content, without overflow at $size', (tester) async {
      tester.view..physicalSize = size..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(localizedApp(home: const AppShell()));
      await tester.pump();

      final loaders = find.byType(SkeletonLoader, skipOffstage: false);
      expect(loaders, findsNWidgets(4));
      expect(find.byType(DiscoverSkeleton), findsOneWidget);
      expect(find.byType(MatchesSkeleton, skipOffstage: false), findsNWidgets(2));
      expect(find.byType(ProfileSkeleton, skipOffstage: false), findsOneWidget);
      expect(find.text('Amour'), findsOneWidget); // headers stay live while loading

      await tester.pump(kMockLoadDelay);
      await tester.pumpAndSettle();
      expect(find.byType(DiscoverSkeleton), findsNothing);
      expect(find.byType(MatchesSkeleton, skipOffstage: false), findsNothing);
      expect(find.byType(ProfileSkeleton, skipOffstage: false), findsNothing);
      expect(find.text('New matches', skipOffstage: false), findsOneWidget);
      expect(find.text('My photos', skipOffstage: false), findsOneWidget);
    });
  }
}
