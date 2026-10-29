import 'dart:async';

import 'package:amour/data/match_engine.dart';
import 'package:amour/data/mock.dart';
import 'package:amour/data/preferences_store.dart';
import 'package:amour/data/profile_store.dart';
import 'package:amour/screens/edit_profile/edit_pages.dart';
import 'package:amour/screens/profile_detail_screen.dart';
import 'package:amour/services/voice_notes.dart';
import 'package:amour/widgets/buttons.dart';
import 'package:amour/widgets/teaser_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'helpers/localized_app.dart';

class _FakeBackend implements VoicePlayerBackend {
  final loaded = <VoiceNote>[];
  var plays = 0, pauses = 0;
  final positions = StreamController<Duration>.broadcast(), done = StreamController<void>.broadcast();
  @override
  Future<void> load(VoiceNote note) async => loaded.add(note);
  @override
  void play() => plays++;
  @override
  Future<void> pause() async => pauses++;
  @override
  Future<void> stop() async {}
  @override
  Stream<Duration> get position => positions.stream;
  @override
  Stream<void> get completed => done.stream;
}

class _FakeRecorder implements VoiceRecorder {
  final Duration length;
  _FakeRecorder(this.length);
  final _levels = StreamController<double>.broadcast();
  @override
  Stream<double> get levels => _levels.stream;
  @override
  Future<void> start() async => _levels.add(.6);
  @override
  Future<VoiceNote?> stop() async => VoiceNote('/voice/test.m4a', source: VoiceSource.file, duration: length,
      waveform: VoiceNote.waveformFrom(const [.2, .9, .5]));
  @override
  Future<void> cancel() async {}
  @override
  Future<void> dispose() async => _levels.close();
}

VoiceNote _note(int seconds) => VoiceNote('/v$seconds.m4a', source: VoiceSource.file,
    duration: Duration(seconds: seconds), waveform: List.filled(VoiceNote.bars, .5));

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  final backend = _FakeBackend();
  voicePlayback.createBackend = () => backend;

  setUp(() async {
    // Answer permission_handler's platform call: every requested permission is granted (1).
    TestWidgetsFlutterBinding.ensureInitialized().defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('flutter.baseflow.com/permissions/methods'),
        (call) async => {for (final p in call.arguments as List) p: 1});
    await voicePlayback.stop();
    currentUser..reset()..seedDemo();
    matchEngine.reset();
  });

  test('live levels squeeze into a fixed number of waveform bars', () {
    final bars = VoiceNote.waveformFrom([for (var i = 0; i < 300; i++) i.isEven ? 0.0 : 1.0]);
    expect(bars, hasLength(VoiceNote.bars));
    expect(bars.every((b) => b >= .08 && b <= 1), isTrue);
    expect(VoiceNote.waveformFrom([.5]), hasLength(VoiceNote.bars));
    expect(formatClock(const Duration(seconds: 9)), '0:09');
    expect(formatClock(const Duration(seconds: 30)), '0:30');
  });

  test('only one voice note plays at a time, and pause resumes where it left off', () async {
    final a = _note(10), b = _note(6);
    await voicePlayback.toggle(a);
    expect(voicePlayback.isPlaying(a), isTrue);
    backend.positions.add(const Duration(seconds: 5));
    await pumpEventQueue();
    expect(voicePlayback.progressOf(a), .5);

    await voicePlayback.toggle(a);
    expect(voicePlayback.isPlaying(a), isFalse);
    final loads = backend.loaded.length;
    await voicePlayback.toggle(a);
    expect(backend.loaded.length, loads, reason: 'resuming does not reload');

    await voicePlayback.toggle(b);
    expect(voicePlayback.isPlaying(a), isFalse);
    expect(voicePlayback.isPlaying(b), isTrue);
    backend.done.add(null);
    await pumpEventQueue();
    expect(voicePlayback.isPlaying(b), isFalse);
    expect(voicePlayback.progressOf(b), 0);
  });

  test('a voice prompt is a trust signal in why you match', () {
    final engine = MatchEngine(user: UserProfileStore(), prefs: DiscoveryPreferences());
    Profile p({List<Teaser> teasers = const []}) => Profile(id: 'x', name: 'X', age: 27, city: 'Pune', job: 'Job',
        bio: '', distanceKm: 8, lookingFor: 'Long-term partner', verified: false, online: false, photos: const ['x'],
        interests: const [], teasers: teasers);
    final withVoice = p(teasers: [Teaser('My ideal first date…', '', voice: _note(8))]);
    final textOnly = p(teasers: const [Teaser('My ideal first date…', 'Coffee')]);
    expect(engine.insight(withVoice).reasons.map((r) => r.kind), contains(MatchReasonKind.voice));
    expect(engine.insight(withVoice).score, greaterThan(engine.insight(textOnly).score));
    expect(engine.insight(textOnly).reasons.map((r) => r.kind), isNot(contains(MatchReasonKind.voice)));
  });

  testWidgets('record a voice answer, listen back and save it without writing anything', (tester) async {
    tester.view..physicalSize = const Size(360, 640)..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    createVoiceRecorder = () => _FakeRecorder(const Duration(seconds: 8));
    await tester.pumpWidget(localizedApp(home: const TeaserAnswerPage(prompt: 'My ideal first date…')));
    await tester.pumpAndSettle();

    final save = find.widgetWithText(AppButton, 'Save');
    expect(tester.widget<AppButton>(save).onPressed, isNull, reason: 'nothing to save yet');

    await tester.tap(find.byTooltip('Tap to record'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Recording…'), findsOneWidget);

    await tester.tap(find.byTooltip('Stop recording'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(VoiceNotePlayer), findsOneWidget);
    expect(find.text('0:08'), findsOneWidget);
    expect(find.text('Add a written answer (optional)'), findsOneWidget);

    await tester.tap(find.byTooltip('Play voice prompt'));
    await tester.pump();
    expect(backend.loaded.last.path, '/voice/test.m4a');
    expect(find.byTooltip('Pause voice prompt'), findsOneWidget);

    await tester.tap(save);
    await tester.pump();
    final t = currentUser.teasers.single;
    expect(t.prompt, 'My ideal first date…');
    expect(t.answer, isEmpty);
    expect(t.voice?.duration, const Duration(seconds: 8));
  });

  testWidgets('a playing note stops when its player goes away, without disturbing other players', (tester) async {
    final a = _note(10), b = _note(6);
    Widget players(List<VoiceNote> notes) => localizedApp(home: Scaffold(body: Column(children: [
      for (final n in notes) VoiceNotePlayer(n, key: ValueKey(n.path)),
    ])));
    await tester.pumpWidget(players([a, b]));
    await tester.tap(find.byTooltip('Play voice prompt').first);
    await tester.pump();
    expect(voicePlayback.isPlaying(a), isTrue);

    await tester.pumpWidget(players([b])); // like popping back to a page that shows another note
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(voicePlayback.isPlaying(a), isFalse);
  });

  testWidgets('recordings under two seconds are rejected', (tester) async {
    createVoiceRecorder = () => _FakeRecorder(const Duration(milliseconds: 900));
    await tester.pumpWidget(localizedApp(home: const TeaserAnswerPage(prompt: 'My ideal first date…')));
    await tester.tap(find.byTooltip('Tap to record'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byTooltip('Stop recording'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Too short — say a little more'), findsOneWidget);
    expect(find.byType(VoiceNotePlayer), findsNothing);
    expect(find.byTooltip('Tap to record'), findsOneWidget);
  });

  testWidgets('other people’s voice prompts play from their profile', (tester) async {
    final kavya = profiles.firstWhere((p) => p.name == 'Kavya');
    await tester.pumpWidget(localizedApp(home: ProfileDetailScreen(profile: kavya)));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byType(VoiceNotePlayer), 200, scrollable: find.byType(Scrollable).first);
    expect(find.text(kavya.teasers.single.prompt), findsOneWidget);
    await tester.tap(find.byTooltip('Play voice prompt'));
    await tester.pump();
    expect(backend.loaded.last.path, 'assets/voice/kavya.m4a');
  });
}
