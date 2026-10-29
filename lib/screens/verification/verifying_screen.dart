import 'dart:math';
import 'package:camera/camera.dart' show XFile;
import 'package:flutter/material.dart';
import '../../data/profile_store.dart';
import '../../services/face_verifier.dart';
import '../../services/haptics.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/photo_grid.dart';
import '../../widgets/profile_bits.dart';
import '../../widgets/verification_widgets.dart';
import 'verification_result_screen.dart';

/// Sends the selfie video to [faceVerifier] and shows its progress, then the result.
class VerifyingScreen extends StatefulWidget {
  final XFile video;
  const VerifyingScreen({super.key, required this.video});
  @override
  State<VerifyingScreen> createState() => _VerifyingScreenState();
}

class _VerifyingScreenState extends State<VerifyingScreen> {
  static const _labels = {
    VerificationStage.uploading: 'Uploading your video',
    VerificationStage.detectingFace: 'Detecting your face',
    VerificationStage.comparing: 'Comparing with your photos',
  };
  var _stage = VerificationStage.uploading;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    VerificationResult result;
    try {
      result = await faceVerifier.verify(video: widget.video, photos: currentUser.photos.photos,
          onStage: (s) { if (mounted) setState(() => _stage = s); });
    } catch (_) {
      result = const VerificationResult.failed(VerificationFailure.network);
    }
    if (!mounted) return;
    if (result.isVerified) currentUser.update(() => currentUser.verified = true);
    result.isVerified ? Haptics.success() : Haptics.error();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => VerificationResultScreen(result: result)));
  }

  @override
  Widget build(BuildContext context) => PopScope(canPop: false, child: VerificationPage(showLeading: false, children: [
    const SizedBox(height: AppSpacing.xl),
    const _FaceScan(),
    const SizedBox(height: AppSpacing.xxl),
    Text('Checking it’s you', style: AppText.displaySmall, textAlign: TextAlign.center),
    const SizedBox(height: AppSpacing.sm),
    Text('This only takes a few seconds — please keep the app open.',
        style: AppText.bodyLarge.copyWith(color: AppColors.muted), textAlign: TextAlign.center),
    const SizedBox(height: AppSpacing.xl),
    AppCard(child: Column(children: [
      for (final s in VerificationStage.values) _StageRow(_labels[s]!,
          done: s.index < _stage.index, active: s == _stage),
    ])),
  ]));
}

class _StageRow extends StatelessWidget {
  final String label; final bool done, active;
  const _StageRow(this.label, {required this.done, required this.active});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
    child: Row(children: [
      SizedBox(width: 24, height: 24, child: AnimatedSwitcher(duration: AppDurations.base, child: done
          ? const Icon(Icons.check_circle_rounded, key: ValueKey('done'), color: AppColors.success, size: 24)
          : active
              ? const Padding(key: ValueKey('active'), padding: EdgeInsets.all(3),
                  child: CircularProgressIndicator(strokeWidth: 2.5))
              : const Icon(Icons.radio_button_unchecked_rounded, key: ValueKey('todo'), color: AppColors.border, size: 24))),
      const SizedBox(width: AppSpacing.mdSm),
      Expanded(child: Text(label, style: AppText.bodyLarge.copyWith(
          color: done || active ? AppColors.text : AppColors.muted,
          fontWeight: active ? FontWeight.w600 : FontWeight.w400))),
    ]));
}

/// The user's photo with a rotating ring and a scan line sweeping over it.
class _FaceScan extends StatefulWidget {
  const _FaceScan();
  @override
  State<_FaceScan> createState() => _FaceScanState();
}

class _FaceScanState extends State<_FaceScan> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat();
  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    const size = 168.0, inner = size - 28;
    final main = currentUser.photos.main;
    return Center(child: SizedBox.square(dimension: size, child: AnimatedBuilder(animation: _c, builder: (_, __) {
      final scanY = (sin(_c.value * 2 * pi) + 1) / 2; // 0..1..0
      return Stack(alignment: Alignment.center, children: [
        Transform.rotate(angle: _c.value * 2 * pi,
            child: const CustomPaint(size: Size.square(size), painter: _SweepRingPainter())),
        ClipOval(child: SizedBox.square(dimension: inner, child: Stack(children: [
          Positioned.fill(child: main == null
              ? Container(color: AppColors.secondary, child: const Icon(Icons.person_rounded, size: 64, color: AppColors.accent))
              : PhotoImage(main)),
          Positioned.fill(child: ColoredBox(color: AppColors.primary.withValues(alpha: .12))),
          Positioned(left: 0, right: 0, top: scanY * (inner - 4), child: Container(height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.accent.withValues(alpha: 0), AppColors.onPrimary,
                  AppColors.accent.withValues(alpha: 0)]),
              boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: .9), blurRadius: 12, spreadRadius: 2)]))),
        ]))),
      ]);
    })));
  }
}

class _SweepRingPainter extends CustomPainter {
  const _SweepRingPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(4);
    canvas
      ..drawOval(rect, Paint()..style = PaintingStyle.stroke..strokeWidth = 5..color = AppColors.secondary)
      ..drawArc(rect, 0, pi * 1.4, false, Paint()
        ..style = PaintingStyle.stroke..strokeWidth = 5..strokeCap = StrokeCap.round
        ..shader = SweepGradient(endAngle: pi * 1.4,
            colors: [AppColors.accent.withValues(alpha: 0), AppColors.primary]).createShader(rect));
  }
  @override
  bool shouldRepaint(_SweepRingPainter old) => false;
}
