import 'package:flutter/material.dart';
import 'profile_store.dart';

/// A language the app's interface is translated into.
class AppLanguage {
  final String code, nativeName;
  /// Matching entry in [spokenLanguages], e.g. 'Tamil'.
  final String spokenName;
  const AppLanguage(this.code, this.nativeName, this.spokenName);
  Locale get locale => Locale(code);
}

const appLanguages = [
  AppLanguage('en', 'English', 'English'),
  AppLanguage('ta', 'தமிழ்', 'Tamil'),
  AppLanguage('ml', 'മലയാളം', 'Malayalam'),
  AppLanguage('hi', 'हिन्दी', 'Hindi'),
];

/// The interface language. `null` follows the phone's language (falling back to English).
class LocaleStore extends ChangeNotifier {
  Locale? locale;

  AppLanguage? get language => locale == null ? null : appLanguages.firstWhere((l) => l.code == locale!.languageCode);

  /// Switches the interface to [language] (or back to the phone's language when null). Someone who
  /// picks Tamil almost certainly speaks it, so it's added to their spoken languages too; returns true
  /// when that happened.
  bool choose(AppLanguage? language, {UserProfileStore? user}) {
    locale = language?.locale;
    notifyListeners();
    final u = user ?? currentUser;
    if (language == null || u.languages.contains(language.spokenName)) return false;
    u.update(() => u.languages.add(language.spokenName));
    return true;
  }
}

final appLocale = LocaleStore();
