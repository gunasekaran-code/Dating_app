import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'mock.dart';
import 'preferences_store.dart';
import 'profile_store.dart';

/// What the user did with a recommended profile in Discover. Saves are tracked
/// separately because they can be undone from the Saved screen.
enum MatchSignal { like, superCrush, skip }

enum MatchReasonKind { interests, goals, languages, lifestyle, preferences, sameCity, nearby, taste, voice, verified }

/// One line of "Why you match", e.g. "You both love Hiking & Coffee". Reasons are data —
/// `l10n/match_text.dart` turns them into words in the app's language.
class MatchReason {
  final IconData icon;
  final MatchReasonKind kind;
  /// What the reason is about, as stored on the profiles:
  /// - interests / taste: the interests
  /// - goals: [their goal, your goal]
  /// - languages: the shared regional languages
  /// - lifestyle / preferences: the lifestyle keys (Smoking, Sport, …)
  /// - sameCity / nearby: [city]
  final List<String> subjects;
  /// How much this reason moved the score (0..1); reasons are listed strongest first.
  final double strength;
  const MatchReason(this.icon, this.kind, this.strength, {this.subjects = const []});
}

/// A profile's compatibility with the signed-in user.
class MatchInsight {
  /// 40..99, shown as "92% match".
  final int score;
  final List<MatchReason> reasons;
  /// Interest labels (as written on the other profile) that both people share.
  final Set<String> sharedInterests;
  /// Languages (English names) both people speak, English included.
  final Set<String> sharedLanguages;
  const MatchInsight(this.score, this.reasons, this.sharedInterests, this.sharedLanguages);

  MatchReason? get top => reasons.isEmpty ? null : reasons.first;
}

/// Ranks Discover by how well each profile fits the user's own profile (interests, relationship
/// goals, languages, lifestyle), their Discover preferences, and a taste model learned from likes,
/// skips, SuperCrushes and saves. Frontend only — the same inputs could feed a server-side model.
class MatchEngine extends ChangeNotifier {
  static const _weights = (interests: .30, goals: .22, languages: .12, lifestyle: .13, prefs: .09, taste: .14);
  static const _signalWeight = {MatchSignal.like: 1.0, MatchSignal.superCrush: 1.6, MatchSignal.skip: -.6};
  static const _saveWeight = .8;
  /// Relationship goals from most to least committed; neighbours are compatible.
  static const _goalScale = ['Long-term partner', 'Long-term, open to short', 'Short-term, open to long',
    'Short-term fun'];
  static const _openGoal = 'Still figuring it out';
  static const _frequency = ['Never', 'Sometimes', 'Regularly'];

  final UserProfileStore user;
  final DiscoveryPreferences prefs;
  MatchEngine({UserProfileStore? user, DiscoveryPreferences? prefs})
      : user = user ?? currentUser, prefs = prefs ?? discoveryPrefs {
    this.user.addListener(notifyListeners);
    this.prefs.addListener(notifyListeners);
  }

  final List<(Profile, MatchSignal)> _signals = [];
  final List<Profile> _saved = [];

  List<Profile> get saved => List.unmodifiable(_saved);
  bool isSaved(Profile p) => _saved.any((s) => s.id == p.id);
  int count(MatchSignal s) => _signals.where((e) => e.$2 == s).length;
  bool get hasLearned => _signals.isNotEmpty || _saved.isNotEmpty;

  /// '☕ Coffee' and 'Coffee' are the same interest.
  static String interestKey(String label) => label.replaceFirst(RegExp(r'^[^A-Za-z]+'), '').trim().toLowerCase();

  void record(Profile p, MatchSignal s) { _signals.add((p, s)); notifyListeners(); }

  /// Forgets the latest signal for [p], e.g. after a Rewind.
  void undo(Profile p) {
    final i = _signals.lastIndexWhere((e) => e.$1.id == p.id);
    if (i < 0) return;
    _signals.removeAt(i);
    notifyListeners();
  }

  /// Returns true when [p] is now saved.
  bool toggleSave(Profile p) {
    final saved = isSaved(p);
    saved ? _saved.removeWhere((s) => s.id == p.id) : _saved.insert(0, p);
    notifyListeners();
    return !saved;
  }

  /// Clears likes, skips and SuperCrushes. Saved profiles stay (and keep teaching the model).
  void resetLearning() { _signals.clear(); notifyListeners(); }

  void reset() { _signals.clear(); _saved.clear(); notifyListeners(); }

  /// Best matches first; ties keep their original order.
  List<Profile> rank(Iterable<Profile> candidates) {
    final scored = [for (final (i, p) in candidates.indexed) (i, p, insight(p).score)];
    scored.sort((a, b) => b.$3 != a.$3 ? b.$3.compareTo(a.$3) : a.$1.compareTo(b.$1));
    return [for (final s in scored) s.$2];
  }

  /// Interests the user keeps responding to, strongest first, as display labels.
  List<String> learnedInterests({int limit = 4}) {
    final (weights, labels) = _taste();
    final top = weights.entries.where((e) => !e.key.startsWith('goal:') && e.value > .5).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return [for (final e in top.take(limit)) labels[e.key]!];
  }

  /// Taste weights per interest key (and 'goal:<label>') from every signal, ignoring [exclude]
  /// so a profile's own like or save never inflates its own score.
  (Map<String, double>, Map<String, String>) _taste({String? exclude}) {
    final w = <String, double>{}, labels = <String, String>{};
    void add(Profile p, double v) {
      if (p.id == exclude) return;
      for (final i in p.interests) {
        final k = interestKey(i);
        w[k] = (w[k] ?? 0) + v;
        labels[k] = i;
      }
      w['goal:${p.lookingFor}'] = (w['goal:${p.lookingFor}'] ?? 0) + v * .5;
    }
    for (final (p, s) in _signals) { add(p, _signalWeight[s]!); }
    for (final p in _saved) { add(p, _saveWeight); }
    return (w, labels);
  }


  MatchInsight insight(Profile p) {
    final reasons = <MatchReason>[];
    const w = _weights;

    // Shared interests.
    final mine = {for (final i in user.interests) interestKey(i)};
    final shared = {...p.interests.where((i) => mine.contains(interestKey(i)))};
    final interests = mine.isEmpty ? .5 : .15 + .85 * math.min(1, shared.length / 3);
    if (shared.isNotEmpty) {
      reasons.add(MatchReason(Icons.interests_rounded, MatchReasonKind.interests, w.interests * interests,
          subjects: shared.toList()));
    }

    // Relationship goals.
    final goal = user.lookingFor;
    final goals = goal == null ? .5 : _goalFit(goal, p.lookingFor);
    if (goal != null && goals >= .75) {
      reasons.add(MatchReason(Icons.favorite_rounded, MatchReasonKind.goals, w.goals * goals,
          subjects: [p.lookingFor, goal]));
    }

    // Languages: sharing a regional language counts far more than sharing only English.
    final spoken = {...p.languages.where(user.languages.contains)};
    final regional = [for (final l in spoken) if (l != 'English') l];
    final languages = user.languages.isEmpty || p.languages.isEmpty ? .5
        : regional.isNotEmpty ? 1.0 : spoken.isNotEmpty ? .6 : .1;
    if (regional.isNotEmpty) {
      reasons.add(MatchReason(Icons.translate_rounded, MatchReasonKind.languages, w.languages * languages,
          subjects: regional));
    }

    // Lifestyle answers both people gave.
    final common = [for (final k in user.lifestyle.keys) if (p.lifestyle.containsKey(k)) k];
    final aligned = <String>[];
    var lifestyle = .5;
    if (common.isNotEmpty) {
      var sum = 0.0;
      for (final k in common) {
        final fit = _lifestyleFit(user.lifestyle[k]!, p.lifestyle[k]!);
        sum += fit;
        if (fit == 1) aligned.add(k);
      }
      lifestyle = sum / common.length;
    }
    if (aligned.isNotEmpty) {
      reasons.add(MatchReason(Icons.spa_rounded, MatchReasonKind.lifestyle, w.lifestyle * lifestyle,
          subjects: aligned));
    }

    // Fit with the user's Discover preferences: age, distance and lifestyle filters.
    final ages = prefs.ageRange;
    final inAge = p.age >= ages.start && p.age <= ages.end;
    final near = p.distanceKm <= 5 ? 1.0 : p.distanceKm <= 10 ? .7 : p.distanceKm <= 25 ? .4 : .2;
    final filtered = [for (final e in prefs.filters.entries) if (p.lifestyle.containsKey(e.key)) e];
    final hits = [for (final e in filtered) if (e.value.contains(p.lifestyle[e.key])) e.key];
    final prefsFit = ((inAge ? 1 : .3) + near + (filtered.isEmpty ? .6 : hits.length / filtered.length))
        / 3;
    if (hits.isNotEmpty) {
      reasons.add(MatchReason(Icons.tune_rounded, MatchReasonKind.preferences, w.prefs * prefsFit, subjects: hits));
    }
    if (user.city.isNotEmpty && user.city == p.city) {
      reasons.add(MatchReason(Icons.location_on_rounded, MatchReasonKind.sameCity, w.prefs * near,
          subjects: [p.city]));
    } else if (p.distanceKm <= 5) {
      reasons.add(MatchReason(Icons.location_on_rounded, MatchReasonKind.nearby, w.prefs * near * .8,
          subjects: [p.city]));
    }

    // Learned taste: how much this profile resembles people the user liked, saved or skipped.
    final (taste, _) = _taste(exclude: p.id);
    var pull = taste['goal:${p.lookingFor}'] ?? 0;
    final drawn = <(String, double)>[];
    for (final i in p.interests) {
      final v = taste[interestKey(i)] ?? 0;
      pull += v;
      if (v > .5) drawn.add((i, v));
    }
    final learned = .5 + .5 * _tanh(pull / 3);
    if (learned > .6 && drawn.isNotEmpty) {
      drawn.sort((a, b) => b.$2.compareTo(a.$2));
      reasons.add(MatchReason(Icons.auto_awesome_rounded, MatchReasonKind.taste, w.taste * learned,
          subjects: [for (final d in drawn.take(2)) d.$1]));
    }

    // Trust: photo verification, and a voice prompt — a real voice is much harder to fake than photos.
    if (p.hasVoicePrompt) reasons.add(const MatchReason(Icons.graphic_eq_rounded, MatchReasonKind.voice, .025));
    if (p.verified) reasons.add(const MatchReason(Icons.verified_rounded, MatchReasonKind.verified, .02));

    final s = w.interests * interests + w.goals * goals + w.languages * languages + w.lifestyle * lifestyle
        + w.prefs * prefsFit + w.taste * learned + (p.verified ? .03 : 0) + (p.hasVoicePrompt ? .02 : 0);
    reasons.sort((a, b) => b.strength.compareTo(a.strength));
    return MatchInsight((45 + 54 * s).round().clamp(40, 99), reasons, shared, spoken);
  }

  static double _goalFit(String a, String b) {
    if (a == b) return 1;
    if (a == _openGoal || b == _openGoal) return .6;
    final i = _goalScale.indexOf(a), j = _goalScale.indexOf(b);
    if (i < 0 || j < 0) return .3; // friendship vs dating
    return const [1.0, .75, .4, .15][(i - j).abs()];
  }

  static double _lifestyleFit(String a, String b) {
    if (a == b) return 1;
    if (a == "It doesn't bother me" || b == "It doesn't bother me") return .7;
    final i = _frequency.indexOf(a), j = _frequency.indexOf(b);
    return i >= 0 && j >= 0 && (i - j).abs() == 1 ? .5 : 0;
  }

  static double _tanh(double x) { final e = math.exp(2 * x); return (e - 1) / (e + 1); }
}

final matchEngine = MatchEngine();
