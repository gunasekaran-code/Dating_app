import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data/account_store.dart';
import '../data/match_engine.dart';
import '../data/mock.dart';
import '../data/perks_store.dart';
import '../data/preferences_store.dart';
import '../services/haptics.dart';
import '../l10n/match_text.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import '../widgets/buttons.dart';
import '../widgets/gold_border.dart';
import '../widgets/match_insights.dart';
import '../widgets/perk_art.dart';
import '../widgets/perk_card.dart';
import '../widgets/profile_bits.dart';
import '../widgets/skeletons.dart';
import '../widgets/states.dart';
import '../widgets/swipe_deck.dart';
import '../widgets/teaser_widgets.dart';
import 'match_screen.dart';
import 'preferences_screen.dart';
import 'profile_detail_screen.dart';
import 'saved_profiles_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});
  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  /// Cards already on screen keep their place when the deck is re-ranked.
  static const _stableCards = 3;
  final deck = <Profile>[];
  /// Swiped profiles and which way they went, for Rewind.
  final history = <(Profile, SwipeDirection)>[];
  final _deckKey = GlobalKey<SwipeDeckState<Profile>>();
  /// −1 (pass) … +1 (like) while dragging; the matching button grows with it.
  final _drag = ValueNotifier(0.0);

  @override
  void initState() {
    super.initState();
    _applyFilters();
    discoveryPrefs.addListener(_applyFilters);
    account.addListener(_applyFilters);
  }

  @override
  void dispose() {
    discoveryPrefs.removeListener(_applyFilters);
    account.removeListener(_applyFilters);
    _drag.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final ages = discoveryPrefs.ageRange;
    setState(() {
      deck
        ..clear()
        ..addAll(matchEngine.rank(
            profiles.where((p) => p.age >= ages.start && p.age <= ages.end && !account.isBlocked(p))));
      history.clear();
    });
  }

  void _swipe(SwipeDirection dir) => _deckKey.currentState?.swipe(dir);

  void _superCrush() {
    if (deck.isEmpty) return;
    if (!perks.useSuperCrush()) {
      openPerkPurchase(context, PerkKind.superCrush);
      return;
    }
    _swipe(SwipeDirection.up);
  }

  void _onSwiped(Profile p, SwipeDirection dir) {
    matchEngine.record(p, switch (dir) {
      SwipeDirection.left => MatchSignal.skip,
      SwipeDirection.right => MatchSignal.like,
      SwipeDirection.up => MatchSignal.superCrush,
    });
    setState(() {
      deck.remove(p);
      history.add((p, dir));
      // Let what was just learned reorder the cards that aren't visible yet.
      if (deck.length > _stableCards) {
        deck.replaceRange(_stableCards, deck.length, matchEngine.rank(deck.skip(_stableCards)));
      }
    });
    if (dir == SwipeDirection.up) {
      showToast(context, context.l10n.superCrushSent(p.name, perks.superCrushes), type: ToastType.success);
    }
    if (dir != SwipeDirection.left && matchEngine.insight(p).score > 85) {
      Haptics.success();
      Navigator.push(context, PageRouteBuilder(
        opaque: false,
        transitionDuration: AppDurations.slow,
        pageBuilder: (_, a, __) => FadeTransition(opacity: a, child: MatchScreen(profile: p))
      ));
    }
  }

  void _rewind() {
    if (history.isEmpty) return;
    final (p, dir) = history.removeLast();
    matchEngine.undo(p);
    setState(() => deck.insert(0, p));
    _deckKey.currentState?.rewind(dir);
  }

  void _openPreferences() =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => const PreferencesScreen()));

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return SafeArea(
    child: Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.sm, AppSpacing.sm, AppSpacing.sm),
        child: Row(children: [
          Text('Amour', style: AppText.displaySmall.copyWith(color: AppColors.primary)),
          const Spacer(),
          AppIconButton(Icons.bookmark_border_rounded, tooltip: l.saved, onPressed: () =>
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedProfilesScreen()))),
          AppIconButton(Icons.tune_rounded, tooltip: l.preferences, onPressed: _openPreferences),
        ])
      ),
      Expanded(child: SkeletonLoader(skeleton: const DiscoverSkeleton(), child: Column(children: [
        Expanded(child: deck.isEmpty
          ? EmptyState(
              icon: Icons.favorite_border_rounded,
              title: l.caughtUpTitle,
              message: l.caughtUpMessage,
              action: l.editPreferences,
              onAction: _openPreferences,
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              child: SwipeDeck<Profile>(key: _deckKey, items: deck, keyOf: (p) => p.id, progress: _drag,
                style: SwipeDeckStyle.cylinder,
                cardBuilder: (_, p) => _ProfileCard(p),
                onSwiped: _onSwiped,
                onTap: (p) => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => ProfileDetailScreen(profile: p)))))),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ValueListenableBuilder<double>(valueListenable: _drag, builder: (_, drag, __) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _Action(Icons.replay_rounded, l.rewind, AppColors.warning, 48, _rewind),
              _Action(Icons.close_rounded, l.pass, AppColors.muted, 50, () => _swipe(SwipeDirection.left),
                  emphasis: math.max(0, -drag)),
              _Action(Icons.favorite_rounded, l.like, AppColors.primary, 50, () => _swipe(SwipeDirection.right),
                  emphasis: math.max(0, drag)),
              _Action(Icons.star_rounded, 'SuperCrush', AppColors.primary, 48, _superCrush, useGoldBorder: true,
                  image: const PerkArt(superCrushStarAsset, size: 28)),
            ]
          ))
        ),
      ]))),
    ])
  );
  }
}

class _Action extends StatelessWidget {
  final IconData icon; final String label; final Color color; final double size; final VoidCallback onTap;
  final bool useGoldBorder; // New parameter
  final Widget? image;
  /// 0..1 — how strongly the current drag points at this action; the button grows with it.
  final double emphasis;

  const _Action(this.icon, this.label, this.color, this.size, this.onTap,
      {this.useGoldBorder = false, this.image, this.emphasis = 0});

  @override
  Widget build(BuildContext context) => Transform.scale(scale: 1 + .2 * emphasis, child: _button());

  Widget _button() {
    final button = AppIconButton(icon, tooltip: label, onPressed: onTap, size: size, color: color, background: Colors.transparent,
        child: image);

    if (useGoldBorder) {
      return CustomPaint(
        painter: GradientBorderPainter(
          radius: size, // Passing the size ensures it stays a perfect circle
          width: 2.0,
          colors: GoldPriceCard.defaultGradient, 
          background: AppColors.glassStrong,
        ),
        child: button,
      );
    }

    return Container(
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.glassBorder),
          boxShadow: AppShadows.card),
      child: AppIconButton(icon, tooltip: label, onPressed: onTap, size: size, color: color, background: AppColors.glassStrong),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final Profile p;
  const _ProfileCard(this.p);

  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: matchEngine, builder: (context, _) {
    final m = matchEngine.insight(p);
    // Shared interests first, highlighted.
    final interests = [...m.sharedInterests, ...p.interests.where((i) => !m.sharedInterests.contains(i))];
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Stack(fit: StackFit.expand, children: [
        AppImage(p.photos.first),
        const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter, stops: [.5, 1],
            colors: [Colors.transparent, Color(0xCC241C1E)]))),
        Positioned(top: AppSpacing.md, left: AppSpacing.md,
            child: CompatibilityPill(m.score, onTap: () => showWhyYouMatch(context, p))),
        Positioned(top: AppSpacing.sm, right: AppSpacing.sm, child: SaveProfileButton(p, size: 40)),
        Positioned(
          left: AppSpacing.lg, right: AppSpacing.lg, bottom: AppSpacing.lg,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Flexible(child: Text('${p.name}, ${p.age}', overflow: TextOverflow.ellipsis,
                  style: AppText.h2.copyWith(color: AppColors.onPrimary))),
              const SizedBox(width: AppSpacing.sm),
              if (p.verified) const VerifiedBadge(),
              if (p.online) ...[const SizedBox(width: AppSpacing.sm), const OnlineDot()],
              if (p.hasVoicePrompt) ...[const SizedBox(width: AppSpacing.sm), const VoicePromptBadge()],
            ]),
            const SizedBox(height: AppSpacing.xs),
            Text('${p.job} · ${context.l10n.kmAway(p.distanceKm)}',
                style: AppText.bodyMedium.copyWith(color: AppColors.secondary)),
            if (m.top != null) ...[
              const SizedBox(height: AppSpacing.sm),
              GestureDetector(onTap: () => showWhyYouMatch(context, p), child: MatchHighlight(m.top!)),
            ],
            const SizedBox(height: AppSpacing.mdSm),
            Wrap(
              spacing: AppSpacing.sm, runSpacing: AppSpacing.sm,
              children: interests.take(3).map((e) => InterestChip(e, selected: m.sharedInterests.contains(e))).toList()
            ),
          ])
        ),
      ])
    );
  });
}
