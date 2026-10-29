import 'package:amour/l10n/app_localizations.dart';
import 'package:amour/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// The app's theme and translations around [home], as [AmourApp] sets them up.
MaterialApp localizedApp({required Widget home, Locale locale = const Locale('en')}) => MaterialApp(
    theme: AppTheme.light(), locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home);
