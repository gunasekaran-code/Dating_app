import 'package:flutter/material.dart';
import '../../data/profile_store.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/buttons.dart';
import '../../widgets/onboarding_widgets.dart';
import 'all_set_screen.dart';
import 'onboarding_steps.dart';

class _Step {
  final Widget page; final bool Function() isValid;
  final VoidCallback? onEnter, onSkip;
  const _Step(this.page, this.isValid, {this.onEnter, this.onSkip});
}

/// Post sign-up profile setup: one question per page, validated before moving on.
class OnboardingFlow extends StatefulWidget {
  final int initialStep;
  const OnboardingFlow({super.key, this.initialStep = 0});
  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  late final pc = PageController(initialPage: widget.initialStep);
  final user = currentUser;
  late int step = widget.initialStep;

  @override
  void initState() {
    super.initState();
    steps[step].onEnter?.call();
  }

  late final List<_Step> steps = [
    _Step(NameStep(onSubmit: _next), () => user.name.trim().length >= 2),
    _Step(const BirthdayStep(), () => (user.age ?? 0) >= 18,
        onEnter: () => user.birthday ??= DateTime(DateTime.now().year - 25, 6, 15)),
    _Step(const GenderStep(), () => user.gender != null),
    _Step(const ShowMeStep(), () => user.showMe != null),
    _Step(const HeightStep(), () => user.heightCm != null,
        onEnter: () => user.heightCm ??= 170, onSkip: () => user.heightCm = null),
    _Step(const EducationStep(), () => user.education != null, onSkip: () => user.education = null),
    _Step(const LookingForStep(), () => user.lookingFor != null),
    _Step(const InterestsStep(), () => user.interests.length >= InterestsStep.min, onSkip: user.interests.clear),
    _Step(const PhotosStep(), () => user.photos.meetsMinimum),
  ];

  bool get _isLast => step == steps.length - 1;

  void _goTo(int i) {
    FocusScope.of(context).unfocus();
    user.update(() => steps[i].onEnter?.call());
    setState(() => step = i);
    pc.animateToPage(i, duration: AppDurations.slow, curve: Curves.easeOutCubic);
  }

  void _next() {
    if (!steps[step].isValid()) return;
    if (_isLast) {
      Navigator.pushAndRemoveUntil(context, PageRouteBuilder(transitionDuration: AppDurations.slow,
          pageBuilder: (_, __, ___) => const AllSetScreen(),
          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c)), (_) => false);
    } else {
      _goTo(step + 1);
    }
  }

  void _skip() {
    user.update(() => steps[step].onSkip?.call());
    _goTo(step + 1);
  }

  void _back() => step == 0 ? Navigator.maybePop(context) : _goTo(step - 1);

  @override
  void dispose() { pc.dispose(); super.dispose(); }

  String _ctaLabel() {
    if (!_isLast) return 'Continue';
    final p = user.photos;
    if (p.isUploading) return 'Uploading photos…';
    final missing = PhotoManager.minPhotos - p.uploadedCount;
    return missing > 0 ? 'Add $missing more photo${missing == 1 ? '' : 's'}' : 'Finish';
  }

  @override
  Widget build(BuildContext context) => PopScope(canPop: step == 0,
    onPopInvokedWithResult: (didPop, _) { if (!didPop) _back(); },
    child: Scaffold(body: SafeArea(child: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.sm, AppSpacing.md, 0), child: Row(children: [
        step > 0 || Navigator.canPop(context)
            ? AppIconButton(Icons.arrow_back_ios_new_rounded, tooltip: 'Back', onPressed: _back)
            : const SizedBox(width: 44, height: 44),
        const SizedBox(width: AppSpacing.xs),
        Expanded(child: SegmentedProgress(total: steps.length, current: step)),
        const SizedBox(width: AppSpacing.md),
        SizedBox(width: 44, child: steps[step].onSkip != null
            ? GestureDetector(onTap: _skip, child: Text('Skip', textAlign: TextAlign.end,
                style: AppText.labelLarge.copyWith(color: AppColors.muted)))
            : Text('${step + 1}/${steps.length}', textAlign: TextAlign.end,
                style: AppText.labelMedium.copyWith(color: AppColors.muted))),
      ])),
      Expanded(child: PageView(controller: pc, physics: const NeverScrollableScrollPhysics(),
          children: [for (final s in steps) s.page])),
      Padding(padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.md),
        child: ListenableBuilder(listenable: Listenable.merge([user, user.photos]),
          builder: (_, __) => AppButton(_ctaLabel(), icon: _isLast && user.photos.meetsMinimum
              ? Icons.check_rounded : null, onPressed: steps[step].isValid() ? _next : null))),
    ]))));
}
