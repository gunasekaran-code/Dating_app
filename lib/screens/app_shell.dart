import 'package:flutter/material.dart';
import '../services/haptics.dart';
import '../l10n/match_text.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import '../widgets/glass_card.dart';
import 'discover_screen.dart';
import 'matches_screen.dart';
import 'my_profile_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}
class _AppShellState extends State<AppShell> {
  int i = 0;
  static const _icons = [
    (Icons.explore_outlined, Icons.explore_rounded),
    (Icons.favorite_outline_rounded, Icons.favorite_rounded),
    (Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded),
    (Icons.person_outline_rounded, Icons.person_rounded),
  ];

  void _select(int k) {
    if (k == i) return;
    Haptics.selection();
    setState(() => i = k);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final labels = [l.tabDiscover, l.tabMatches, l.tabChats, l.tabProfile];
    return Scaffold(
    // Tabs lay out above the floating bar (via SafeArea) while the glass shows the backdrop through it.
    extendBody: true,
    body: IndexedStack(index: i, children: const [
      DiscoverScreen(), MatchesScreen(), MatchesScreen(chatsOnly: true), MyProfileScreen()]),
    bottomNavigationBar: SafeArea(minimum: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(padding: const EdgeInsets.fromLTRB(AppSpacing.page, 0, AppSpacing.page, AppSpacing.xs),
        child: Center(heightFactor: 1, child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppLayout.tabBarMaxWidth),
          child: GlassCard(radius: AppRadius.pill, padding: const EdgeInsets.all(AppSpacing.xs),
          child: SizedBox(height: 56, child: Row(children: [
            for (var k = 0; k < _icons.length; k++)
              Expanded(child: _TabItem(icon: i == k ? _icons[k].$2 : _icons[k].$1, label: labels[k],
                  selected: i == k, onTap: () => _select(k))),
          ]))))))));
  }
}

class _TabItem extends StatelessWidget {
  final IconData icon; final String label; final bool selected; final VoidCallback onTap;
  const _TabItem({required this.icon, required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.muted;
    return Semantics(selected: selected, button: true, label: label, child: GestureDetector(
      behavior: HitTestBehavior.opaque, onTap: onTap,
      child: AnimatedContainer(duration: AppDurations.base, curve: Curves.easeOutCubic,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.pill),
            color: selected ? AppColors.secondary.withValues(alpha: .8) : Colors.transparent),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          AnimatedScale(scale: selected ? 1.08 : 1, duration: AppDurations.base, curve: Curves.easeOutBack,
              child: Icon(icon, size: 22, color: color)),
          const SizedBox(height: 2),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 2), child: FittedBox(fit: BoxFit.scaleDown,
              child: Text(label, maxLines: 1, style: AppText.labelSmall.copyWith(fontSize: 10, color: color)))),
        ]))));
  }
}
