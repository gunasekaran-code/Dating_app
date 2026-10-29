import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/content_frame.dart';
import '../widgets/glass_card.dart';
import 'glass_theme.dart';
import 'tokens.dart';
import 'typography.dart';

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(useMaterial3: true);
    const pageTransitions = GlassPageTransitionsBuilder();
    return base.copyWith(
      // iOS look & feel everywhere: centred titles, chevron back button, swipe-back, adaptive widgets.
      platform: TargetPlatform.iOS,
      // Pages are transparent; [GlassPageTransitionsBuilder] paints the glass backdrop behind every route.
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: AppColors.background,
      extensions: [GlassTheme.light],
      splashFactory: NoSplash.splashFactory,
      highlightColor: AppColors.primary.withValues(alpha: .04),
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary, onPrimary: AppColors.onPrimary,
        secondary: AppColors.secondary, onSecondary: AppColors.primary,
        tertiary: AppColors.accent, surface: AppColors.card, onSurface: AppColors.text,
        error: AppColors.error, outline: AppColors.border,
      ),
      cupertinoOverrideTheme: const CupertinoThemeData(primaryColor: AppColors.primary),
      textTheme: GoogleFonts.dmSansTextTheme(base.textTheme).apply(
          bodyColor: AppColors.text, displayColor: AppColors.text),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent, surfaceTintColor: Colors.transparent,
        elevation: 0, scrolledUnderElevation: 0,
        foregroundColor: AppColors.text, centerTitle: true, titleTextStyle: AppText.h4,
      ),
      actionIconTheme: ActionIconThemeData(
        backButtonIconBuilder: (_) => const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        closeButtonIconBuilder: (_) => const Icon(Icons.close_rounded, size: 22),
      ),
      dividerTheme: DividerThemeData(color: AppColors.border.withValues(alpha: .7), thickness: .5, space: .5),
      listTileTheme: const ListTileThemeData(iconColor: AppColors.text, minVerticalPadding: 12),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating, elevation: 0,
        backgroundColor: AppColors.text.withValues(alpha: .9),
        contentTextStyle: AppText.bodyMedium.copyWith(color: AppColors.onPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.glassStrong, surfaceTintColor: Colors.transparent,
        modalBarrierColor: Color(0x33241C1E), elevation: 0,
        showDragHandle: true, dragHandleColor: AppColors.border, dragHandleSize: Size(36, 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet))),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.glassStrong, surfaceTintColor: Colors.transparent, elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.modal)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(AppColors.onPrimary),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? AppColors.primary : AppColors.border),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.primary),
      textSelectionTheme: TextSelectionThemeData(cursorColor: AppColors.primary,
          selectionColor: AppColors.accent.withValues(alpha: .35), selectionHandleColor: AppColors.primary),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: pageTransitions, TargetPlatform.iOS: pageTransitions,
        TargetPlatform.macOS: pageTransitions, TargetPlatform.windows: pageTransitions,
        TargetPlatform.linux: pageTransitions, TargetPlatform.fuchsia: pageTransitions,
      }),
    );
  }
}

/// iOS slide + swipe-back transition, with the glass backdrop painted under each page
/// so routes stay opaque while their scaffolds are transparent. Page content is framed
/// to a readable width on tablets ([ContentFrame]). The home route (splash) is left
/// full-bleed so it fills wide windows.
class GlassPageTransitionsBuilder extends PageTransitionsBuilder {
  const GlassPageTransitionsBuilder();
  @override
  Widget buildTransitions<T>(PageRoute<T> route, BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) =>
      const CupertinoPageTransitionsBuilder().buildTransitions(route, context, animation, secondaryAnimation,
          route.settings.name == Navigator.defaultRouteName ? child : GlassBackground(child: ContentFrame(child: child)));
}

/// iOS rubber-band scrolling on every platform, no Material glow, mouse drag enabled.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) => child;
  @override
  Set<PointerDeviceKind> get dragDevices => PointerDeviceKind.values.toSet();
}
