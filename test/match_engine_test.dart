import 'package:amour/data/match_engine.dart';
import 'package:amour/data/mock.dart';
import 'package:amour/data/preferences_store.dart';
import 'package:amour/data/profile_store.dart';
import 'package:amour/l10n/app_localizations.dart';
import 'package:amour/l10n/match_text.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Profile _profile(String id, {List<String> interests = const [], String lookingFor = 'Long-term partner',
    Map<String, String> lifestyle = const {}, int distanceKm = 8, bool verified = false,
    List<String> languages = const []}) =>
    Profile(id: id, name: 'P$id', age: 27, city: 'Pune', job: 'Job', bio: '', distanceKm: distanceKm,
        lookingFor: lookingFor, verified: verified, online: false, photos: const ['x'], interests: interests,
        lifestyle: lifestyle, languages: languages);

Iterable<MatchReasonKind> _kinds(MatchInsight m) => m.reasons.map((r) => r.kind);

void main() {
  late UserProfileStore user;
  late MatchEngine engine;

  setUp(() {
    user = UserProfileStore()
      ..interests.addAll(['☕ Coffee', '🥾 Hiking', '✈️ Travel'])
      ..lookingFor = 'Long-term partner'
      ..lifestyle.addAll({'Smoking': 'Never'});
    engine = MatchEngine(user: user, prefs: DiscoveryPreferences());
  });

  test('shared interests, goals and lifestyle raise the score and explain it', () {
    final close = _profile('1', interests: ['Coffee', 'Hiking', 'Travel'], lifestyle: {'Smoking': 'Never'});
    final far = _profile('2', interests: ['Gaming'], lookingFor: 'Short-term fun',
        lifestyle: {'Smoking': 'On a regular basis'});
    final a = engine.insight(close), b = engine.insight(far);
    expect(a.score, greaterThan(b.score));
    expect(a.score, inInclusiveRange(40, 99));
    expect(a.sharedInterests, {'Coffee', 'Hiking', 'Travel'});
    expect(_kinds(a), containsAll([MatchReasonKind.interests, MatchReasonKind.goals, MatchReasonKind.lifestyle]));
    final en = lookupAppLocalizations(const Locale('en'));
    expect([for (final r in a.reasons) en.reasonTitle(r)],
        containsAll(['3 interests in common', 'Same relationship goals', 'Similar lifestyle']));
    expect(b.reasons, isEmpty);
    expect(engine.rank([far, close]), [close, far]);
  });

  test('learns from likes and skips, and rewind undoes it', () {
    final liked = _profile('1', interests: ['Jazz', 'Film']);
    final similar = _profile('2', interests: ['Jazz', 'Film']);
    final before = engine.insight(similar).score;

    engine.record(liked, MatchSignal.like);
    final after = engine.insight(similar);
    expect(after.score, greaterThan(before));
    expect(_kinds(after), contains(MatchReasonKind.taste));
    expect(engine.learnedInterests(), containsAll(['Jazz', 'Film']));
    // A profile's own signal doesn't inflate its own score.
    expect(engine.insight(liked).score, before);

    engine.undo(liked);
    expect(engine.insight(similar).score, before);

    engine.record(liked, MatchSignal.skip);
    expect(engine.insight(similar).score, lessThan(before));
  });

  test('saving teaches the engine and survives a learning reset', () {
    final p = _profile('1', interests: ['Yoga']), other = _profile('2', interests: ['Yoga']);
    final before = engine.insight(other).score;
    expect(engine.toggleSave(p), isTrue);
    expect(engine.isSaved(p), isTrue);
    expect(engine.insight(other).score, greaterThan(before));

    engine..record(other, MatchSignal.skip)..resetLearning();
    expect(engine.count(MatchSignal.skip), 0);
    expect(engine.saved, [p]);

    expect(engine.toggleSave(p), isFalse);
    expect(engine.insight(other).score, before);
  });

  test('fits Discover filters and nearby distance', () {
    final prefs = DiscoveryPreferences()..filters = {'Smoking': {'Never'}};
    engine = MatchEngine(user: UserProfileStore(), prefs: prefs);
    final m = engine.insight(_profile('1', lifestyle: {'Smoking': 'Never'}, distanceKm: 2));
    expect(_kinds(m), containsAll([MatchReasonKind.preferences, MatchReasonKind.nearby]));
  });

  test('a shared regional language counts more than sharing only English', () {
    user.languages.addAll(['Tamil', 'English']);
    final tamil = _profile('1', languages: ['Tamil', 'English']);
    final englishOnly = _profile('2', languages: ['Hindi', 'English']);
    final none = _profile('3', languages: ['Marathi']);
    final t = engine.insight(tamil);
    expect(t.score, greaterThan(engine.insight(englishOnly).score));
    expect(engine.insight(englishOnly).score, greaterThan(engine.insight(none).score));
    expect(t.sharedLanguages, {'Tamil', 'English'});
    final reason = t.reasons.firstWhere((r) => r.kind == MatchReasonKind.languages);
    expect(reason.subjects, ['Tamil'], reason: 'English alone is not a reason');
    expect(_kinds(engine.insight(englishOnly)), isNot(contains(MatchReasonKind.languages)));

    // Each interface names the language its own way.
    expect(lookupAppLocalizations(const Locale('en')).reasonTitle(reason), 'You both speak Tamil');
    expect(lookupAppLocalizations(const Locale('ta')).reasonTitle(reason), 'நீங்கள் இருவரும் தமிழ் பேசுவீர்கள்');
    expect(lookupAppLocalizations(const Locale('hi')).reasonTitle(reason), 'आप दोनों தமிழ் बोलते हैं');
  });

  test('every reason has words in every language', () {
    user..languages.addAll(['Tamil'])..city = 'Pune';
    final p = _profile('1', interests: ['Coffee', 'Hiking', 'Travel'], lifestyle: {'Smoking': 'Never'},
        languages: ['Tamil'], distanceKm: 2, verified: true);
    engine.toggleSave(_profile('2', interests: ['Coffee']));
    final reasons = engine.insight(p).reasons;
    for (final code in ['en', 'ta', 'ml', 'hi']) {
      final l = lookupAppLocalizations(Locale(code));
      for (final r in reasons) {
        expect(l.reasonTitle(r), isNotEmpty);
        expect(l.reasonDetail(r, p), isNot(contains('{')), reason: '$code ${r.kind}');
      }
    }
  });

  test('interest labels match with or without emoji', () {
    expect(MatchEngine.interestKey('🍜 Street food'), MatchEngine.interestKey('Street food'));
  });
}
