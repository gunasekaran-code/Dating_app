import 'package:flutter/widgets.dart';
import '../data/match_engine.dart';
import '../data/mock.dart';
import '../data/profile_options.dart';
import 'app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Words for the match engine's reasons, in the app's language. Profile data (interests,
/// goals, cities) is shown as people wrote it.
extension MatchText on AppLocalizations {
  bool get _english => localeName == 'en';

  /// "A, B and C" with the language's own "and".
  String joinList(List<String> xs) =>
      xs.length <= 1 ? xs.join() : listAnd(xs.sublist(0, xs.length - 1).join(', '), xs.last);

  String matchLabel(int score) => score >= 90 ? matchExceptional : score >= 80 ? matchGreat
      : score >= 70 ? matchGood : matchWorthALook;

  /// English names in the English UI; otherwise each language in its own script (தமிழ், हिन्दी).
  String languageName(String english) => _english ? english : nativeLanguageName(english);
  String languageList(Iterable<String> languages) => joinList([for (final l in languages) languageName(l)]);

  String topic(String lifestyleKey) => switch (lifestyleKey) {
    'Kids' => topicKids, 'Smoking' => topicSmoking, 'Sport' => topicSport,
    'Drinking' => topicDrinking, 'Food habits' => topicFood, _ => lifestyleKey,
  };

  String _goal(String g) => _english ? g.toLowerCase() : g;

  String reasonTitle(MatchReason r) => switch (r.kind) {
    MatchReasonKind.interests => r.subjects.length <= 2
        ? reasonInterestsFew(r.subjects.join(' & ')) : reasonInterestsMany(r.subjects.length),
    MatchReasonKind.goals => r.subjects[0] == r.subjects[1] ? reasonGoalsSame : reasonGoalsSimilar,
    MatchReasonKind.languages => reasonLanguages(languageList(r.subjects)),
    MatchReasonKind.lifestyle => reasonLifestyle,
    MatchReasonKind.preferences => reasonPreferences,
    MatchReasonKind.sameCity => reasonSameCity(r.subjects.first),
    MatchReasonKind.nearby => reasonNearby,
    MatchReasonKind.taste => reasonTaste,
    MatchReasonKind.voice => reasonVoice,
    MatchReasonKind.verified => reasonVerified,
  };

  String reasonDetail(MatchReason r, Profile p) => switch (r.kind) {
    MatchReasonKind.interests => r.subjects.length <= 2
        ? reasonInterestsFewDetail : reasonInterestsManyDetail(joinList(r.subjects)),
    MatchReasonKind.goals => r.subjects[0] == r.subjects[1]
        ? reasonGoalsSameDetail(_goal(r.subjects[0]))
        : reasonGoalsSimilarDetail(_goal(r.subjects[1]), p.name, _goal(r.subjects[0])),
    MatchReasonKind.languages => reasonLanguagesDetail,
    MatchReasonKind.lifestyle => reasonLifestyleDetail(joinList([for (final k in r.subjects) topic(k)])),
    MatchReasonKind.preferences => reasonPreferencesDetail(joinList([for (final k in r.subjects) topic(k)])),
    MatchReasonKind.sameCity => reasonSameCityDetail(p.distanceKm),
    MatchReasonKind.nearby => reasonNearbyDetail(p.distanceKm, p.city),
    MatchReasonKind.taste => reasonTasteDetail(joinList(r.subjects)),
    MatchReasonKind.voice => reasonVoiceDetail,
    MatchReasonKind.verified => reasonVerifiedDetail,
  };
}
