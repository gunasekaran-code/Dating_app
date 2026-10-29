import 'package:flutter/material.dart';
import 'data/locale_store.dart';
import 'l10n/app_localizations.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() => runApp(const AmourApp());

class AmourApp extends StatelessWidget {
  const AmourApp({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: appLocale, builder: (_, __) => MaterialApp(
    title: 'Amour', debugShowCheckedModeBanner: false,
    theme: AppTheme.light(), scrollBehavior: const AppScrollBehavior(),
    // null follows the phone's language; unsupported languages fall back to English.
    locale: appLocale.locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const SplashScreen()));
}
