import 'package:flutter/material.dart';
import '../../data/profile_options.dart';
import '../../data/profile_store.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/buttons.dart';
import '../../widgets/content_frame.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/photo_grid.dart';
import '../../widgets/profile_bits.dart';
import '../app_shell.dart';

class AllSetScreen extends StatelessWidget {
  const AllSetScreen({super.key});

  Widget _pop({required int delayMs, required Widget child}) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1), duration: Duration(milliseconds: 600 + delayMs),
    builder: (_, v, c) {
      final t = Curves.easeOutCubic.transform(((v * (600 + delayMs) - delayMs) / 600).clamp(0.0, 1.0));
      return Opacity(opacity: t, child: Transform.translate(offset: Offset(0, 24 * (1 - t)), child: c));
    }, child: child);

  @override
  Widget build(BuildContext context) {
    final u = currentUser, main = u.photos.main;
    final details = [
      if (u.age != null) (Icons.cake_outlined, '${u.age}'),
      if (u.heightCm != null) (Icons.height_rounded, formatHeight(u.heightCm!, metric: u.metricHeight)),
      if (u.education != null) (Icons.school_outlined, u.education!),
      if (u.lookingFor != null) (Icons.favorite_border_rounded, u.lookingFor!),
    ];
    
    return Scaffold(body: GlassBackground(
      child: ContentFrame(child: SafeArea(child: LayoutBuilder(builder: (context, box) => SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ConstrainedBox(constraints: BoxConstraints(minHeight: box.maxHeight - AppSpacing.xl * 2),
          child: IntrinsicHeight(child: Column(children: [
        const Spacer(),
        _pop(delayMs: 0, child: Stack(clipBehavior: Clip.none, children: [
          Container(padding: const EdgeInsets.all(5), decoration: const BoxDecoration(shape: BoxShape.circle,
              gradient: SweepGradient(colors: [AppColors.accent, AppColors.primary, AppColors.accent])),
            child: Container(padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: AppColors.background, shape: BoxShape.circle),
              child: ClipOval(child: main == null
                  ? Container(width: 140, height: 140, color: AppColors.secondary,
                      child: const Icon(Icons.person_rounded, size: 64, color: AppColors.accent))
                  : PhotoImage(main, width: 140, height: 140)))),
          Positioned(right: -2, bottom: 6, child: Container(width: 44, height: 44,
            decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle,
                border: Border.all(color: AppColors.background, width: 3)),
            child: const Icon(Icons.favorite_rounded, color: AppColors.onPrimary, size: 20))),
        ])),
        const SizedBox(height: AppSpacing.xl),
        _pop(delayMs: 150, child: Column(children: [
          Text('You’re all set${u.name.isEmpty ? '' : ', ${u.name.trim()}'}!',
              style: AppText.displayMedium, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          Text('Your profile is ready. Let’s find someone worth meeting.',
              style: AppText.bodyLarge.copyWith(color: AppColors.muted), textAlign: TextAlign.center),
        ])),
        const SizedBox(height: AppSpacing.xl),
        _pop(delayMs: 300, child: Wrap(alignment: WrapAlignment.center, spacing: AppSpacing.sm, runSpacing: AppSpacing.sm,
          children: [for (final (icon, label) in details) Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.mdSm, vertical: 6),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(color: AppColors.border)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 16, color: AppColors.accent), const SizedBox(width: 6),
              Text(label, style: AppText.labelMedium.copyWith(color: AppColors.primary)),
            ]))])),
        if (u.interests.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.mdSm),
          _pop(delayMs: 400, child: Wrap(alignment: WrapAlignment.center, spacing: AppSpacing.sm, runSpacing: AppSpacing.sm,
              children: [for (final i in u.interests) InterestChip(i)])),
        ],
        const Spacer(flex: 2),
        const SizedBox(height: AppSpacing.xl),
        
        // Replaced AppButton with the new SwipeToStartButton
        _pop(delayMs: 500, child: SwipeToStartButton(
          text: 'Start exploring',
          onComplete: () => Navigator.pushAndRemoveUntil(
            context, 
            MaterialPageRoute(builder: (_) => const AppShell()), 
            (_) => false
          ),
        )),
        
      ])))))))));
  }
}


class SwipeToStartButton extends StatefulWidget {
  final VoidCallback onComplete;
  final String text;

  const SwipeToStartButton({
    super.key, 
    required this.onComplete, 
    this.text = 'Start exploring',
  });

  @override
  State<SwipeToStartButton> createState() => _SwipeToStartButtonState();
}

class _SwipeToStartButtonState extends State<SwipeToStartButton> {
  double _dragPosition = 0;
  bool _isCompleted = false;
  final double _thumbWidth = 56.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Forces full width without needing LayoutBuilder
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.primary, 
        borderRadius: BorderRadius.circular(100),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedOpacity(
            opacity: _isCompleted ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Padding(
              padding: const EdgeInsets.only(right: 32.0), 
              child: Text(
                widget.text,
                style: AppText.bodyLarge.copyWith(
                  color: AppColors.background,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          
          Positioned(
            right: _dragPosition,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                if (_isCompleted) return;
                
                // Dynamically fetch the width during the drag, avoiding layout phase errors
                final RenderBox box = context.findRenderObject() as RenderBox;
                final maxDrag = box.size.width - _thumbWidth;

                setState(() {
                  _dragPosition -= details.delta.dx; 
                  _dragPosition = _dragPosition.clamp(0.0, maxDrag);
                });
              },
              onHorizontalDragEnd: (details) {
                if (_isCompleted) return;
                
                final RenderBox box = context.findRenderObject() as RenderBox;
                final maxDrag = box.size.width - _thumbWidth;
                
                if (_dragPosition > maxDrag * 0.75) {
                  setState(() {
                    _dragPosition = maxDrag;
                    _isCompleted = true;
                  });
                  Future.delayed(const Duration(milliseconds: 250), widget.onComplete);
                } else {
                  setState(() {
                    _dragPosition = 0.0;
                  });
                }
              },
              child: AnimatedContainer(
                duration: _dragPosition == 0.0 ? const Duration(milliseconds: 300) : Duration.zero,
                curve: Curves.easeOutBack,
                margin: const EdgeInsets.all(4),
                width: _thumbWidth - 8,
                height: 56 - 8,
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_rounded, 
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}