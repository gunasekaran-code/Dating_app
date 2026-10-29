import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/haptics.dart';
import '../../services/face_verifier.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/buttons.dart';
import '../../widgets/verification_widgets.dart';
import 'verifying_screen.dart';

enum _Phase { starting, ready, countdown, recording, error }
enum _Error { permission, unavailable, recording }

/// Records a short front-camera selfie video while prompting small head movements
/// (a simple liveness cue), then hands the file to [VerifyingScreen].
class SelfieCaptureScreen extends StatefulWidget {
  static const recordDuration = Duration(seconds: 6);
  const SelfieCaptureScreen({super.key});
  @override
  State<SelfieCaptureScreen> createState() => _SelfieCaptureScreenState();
}

class _SelfieCaptureScreenState extends State<SelfieCaptureScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  static const _prompts = [
    (0.0, null, 'Look straight at the camera'),
    (0.28, Icons.chevron_left_rounded, 'Slowly turn your head left'),
    (0.54, Icons.chevron_right_rounded, 'Now slowly turn right'),
    (0.8, null, 'Look back and smile 😊'),
  ];

  late final _progress = AnimationController(vsync: this, duration: SelfieCaptureScreen.recordDuration);
  CameraController? _camera;
  var _phase = _Phase.starting;
  _Error? _error;
  int _count = 3, _session = 0;
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _session++;
    _progress.dispose();
    _camera?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The camera must be released while backgrounded and re-created on return.
    if (state == AppLifecycleState.inactive && _camera != null) {
      _session++;
      _progress.reset();
      final c = _camera;
      _camera = null;
      _paused = true;
      c?.dispose();
      if (_phase != _Phase.error) setState(() => _phase = _Phase.starting);
    } else if (state == AppLifecycleState.resumed && (_paused || _error == _Error.permission)) {
      _paused = false;
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    setState(() { _phase = _Phase.starting; _error = null; });
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return _fail(_Error.unavailable);
      final front = cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.front, orElse: () => cameras.first);
      final c = CameraController(front, ResolutionPreset.medium, enableAudio: false);
      await c.initialize();
      if (!mounted) { await c.dispose(); return; }
      try { await c.lockCaptureOrientation(DeviceOrientation.portraitUp); } catch (_) {/* not supported everywhere */}
      await _camera?.dispose();
      _camera = c;
      setState(() => _phase = _Phase.ready);
    } on CameraException catch (e) {
      final code = e.code.toLowerCase();
      _fail(code.contains('denied') || code.contains('restricted') || code.contains('permission') || code.contains('notallowed')
          ? _Error.permission : _Error.unavailable);
    } catch (_) {
      _fail(_Error.unavailable); // e.g. no camera plugin on this platform
    }
  }

  void _fail(_Error error) {
    if (!mounted) return;
    _session++;
    _progress.reset();
    setState(() { _phase = _Phase.error; _error = error; });
  }

  Future<void> _start() async {
    final session = ++_session;
    bool live() => mounted && session == _session;
    for (var i = 3; i > 0; i--) {
      setState(() { _phase = _Phase.countdown; _count = i; });
      Haptics.selection();
      await Future.delayed(const Duration(seconds: 1));
      if (!live()) return;
    }
    final c = _camera;
    if (c == null) return;
    try {
      await c.startVideoRecording();
    } on CameraException {
      return _fail(_Error.recording);
    }
    if (!live()) { _discard(c); return; }
    Haptics.medium();
    setState(() => _phase = _Phase.recording);
    try {
      await _progress.forward(from: 0).orCancel;
    } on TickerCanceled {
      return;
    }
    if (!live()) return;
    final XFile video;
    try {
      video = await c.stopVideoRecording();
    } on CameraException {
      return _fail(_Error.recording);
    }
    if (!mounted) return;
    Haptics.light();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => VerifyingScreen(video: video)));
  }

  void _cancel() {
    _session++;
    _progress.reset();
    final c = _camera;
    if (c != null && c.value.isRecordingVideo) _discard(c);
    setState(() => _phase = _Phase.ready);
  }

  void _discard(CameraController c) => c.stopVideoRecording().then((_) {}, onError: (_) {});

  (IconData?, String, String) get _prompt => switch (_phase) {
    _Phase.starting => (null, 'Getting your camera ready…', 'This only takes a moment.'),
    _Phase.ready => (null, 'Position your face in the oval', 'Hold your phone at eye level, in good light.'),
    _Phase.countdown => (null, 'Get ready…', 'Keep your face inside the oval.'),
    _Phase.recording => () {
      final p = _prompts.lastWhere((p) => _progress.value >= p.$1);
      return (p.$2, p.$3, 'Move slowly and keep your face in the oval.');
    }(),
    _Phase.error => (null, '', ''),
  };

  @override
  Widget build(BuildContext context) {
    if (_phase == _Phase.error) return _ErrorView(error: _error!, onRetry: _initCamera);
    final busy = _phase == _Phase.countdown || _phase == _Phase.recording;
    return VerificationPage.fixed(title: 'Selfie video', close: true,
      child: AnimatedBuilder(animation: _progress, builder: (context, _) {
        final (arrow, title, hint) = _prompt;
        return Column(children: [
          const SizedBox(height: AppSpacing.md),
          AnimatedSwitcher(duration: AppDurations.base,
              child: Text(title, key: ValueKey(title), style: AppText.h3, textAlign: TextAlign.center)),
          const SizedBox(height: AppSpacing.xs),
          Text(hint, style: AppText.bodySmall, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.lg),
          Expanded(child: LayoutBuilder(builder: (context, box) {
            final w = min(box.maxWidth * .74, box.maxHeight / 1.3), h = w * 1.3;
            return Center(child: SizedBox(width: w + 2 * 44, height: h, child: Stack(alignment: Alignment.center, children: [
              SizedBox(width: w, height: h, child: ClipOval(child: ColoredBox(color: AppColors.secondary,
                  child: _camera?.value.isInitialized == true
                      ? _Preview(_camera!)
                      : const Center(child: CircularProgressIndicator())))),
              IgnorePointer(child: CustomPaint(size: Size(w + 12, h + 12),
                  painter: _RingPainter(_phase == _Phase.recording ? _progress.value : 0))),
              if (_phase == _Phase.countdown) ClipOval(child: Container(width: w, height: h,
                color: AppColors.primary.withValues(alpha: .35), alignment: Alignment.center,
                child: AnimatedSwitcher(duration: AppDurations.base,
                  transitionBuilder: (c, a) => ScaleTransition(scale: a, child: FadeTransition(opacity: a, child: c)),
                  child: Text('$_count', key: ValueKey(_count),
                      style: AppText.displayLarge.copyWith(fontSize: 72, color: AppColors.onPrimary))))),
              if (arrow != null) Align(
                  alignment: arrow == Icons.chevron_left_rounded ? Alignment.centerLeft : Alignment.centerRight,
                  child: _Nudge(arrow)),
            ])));
          })),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(height: 132, child: busy ? _RecordingStatus(
              recording: _phase == _Phase.recording, progress: _progress.value, onCancel: _cancel)
            : _RecordButton(enabled: _phase == _Phase.ready, onTap: _start)),
        ]);
      }));
  }
}

/// Camera preview cropped to fill its (oval) box.
class _Preview extends StatelessWidget {
  final CameraController camera;
  const _Preview(this.camera);
  @override
  Widget build(BuildContext context) {
    final v = camera.value;
    final o = v.lockedCaptureOrientation ?? v.deviceOrientation;
    final landscape = o == DeviceOrientation.landscapeLeft || o == DeviceOrientation.landscapeRight;
    final ratio = landscape ? v.aspectRatio : 1 / v.aspectRatio; // width / height, as CameraPreview lays out
    return FittedBox(fit: BoxFit.cover,
        child: SizedBox(width: 300 * ratio, height: 300, child: CameraPreview(camera)));
  }
}

/// Oval guide; fills clockwise from the top while recording.
class _RingPainter extends CustomPainter {
  final double progress;
  const _RingPainter(this.progress);
  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(3);
    canvas.drawOval(rect, Paint()..style = PaintingStyle.stroke..strokeWidth = 6..color = AppColors.glassBorder);
    if (progress > 0) {
      canvas.drawArc(rect, -pi / 2, 2 * pi * progress, false, Paint()
        ..style = PaintingStyle.stroke..strokeWidth = 6..strokeCap = StrokeCap.round
        ..shader = const LinearGradient(colors: [AppColors.accent, AppColors.primary]).createShader(rect));
    }
  }
  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

/// Pulsing arrow beside the oval showing which way to turn.
class _Nudge extends StatefulWidget {
  final IconData icon;
  const _Nudge(this.icon);
  @override
  State<_Nudge> createState() => _NudgeState();
}

class _NudgeState extends State<_Nudge> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..repeat(reverse: true);
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final dir = widget.icon == Icons.chevron_left_rounded ? -1.0 : 1.0;
    return AnimatedBuilder(animation: _c, builder: (_, child) =>
        Transform.translate(offset: Offset(dir * 6 * _c.value, 0), child: child),
      child: Container(width: 40, height: 40,
        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, boxShadow: AppShadows.elevated),
        child: Icon(widget.icon, color: AppColors.onPrimary, size: 28)));
  }
}

class _RecordButton extends StatelessWidget {
  final bool enabled; final VoidCallback onTap;
  const _RecordButton({required this.enabled, required this.onTap});
  @override
  Widget build(BuildContext context) => Column(children: [
    Semantics(button: true, label: 'Start recording', enabled: enabled, child: GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(duration: AppDurations.fast, opacity: enabled ? 1 : .4, child: Container(
        width: 80, height: 80, padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primary, width: 3)),
        child: Container(
          decoration: BoxDecoration(shape: BoxShape.circle,
              gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [AppColors.accent, AppColors.primary]),
              boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: .3), blurRadius: 20, offset: const Offset(0, 6))]),
          child: const Icon(Icons.videocam_rounded, color: AppColors.onPrimary, size: 32)))))),
    const SizedBox(height: AppSpacing.mdSm),
    Text('Tap to record', style: AppText.labelLarge.copyWith(color: AppColors.primary)),
    Text('About ${SelfieCaptureScreen.recordDuration.inSeconds} seconds', style: AppText.bodySmall),
  ]);
}

class _RecordingStatus extends StatelessWidget {
  final bool recording; final double progress; final VoidCallback onCancel;
  const _RecordingStatus({required this.recording, required this.progress, required this.onCancel});
  @override
  Widget build(BuildContext context) {
    final total = SelfieCaptureScreen.recordDuration.inSeconds;
    final left = (total * (1 - progress)).ceil();
    return Column(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(color: AppColors.glassStrong, borderRadius: BorderRadius.circular(AppRadius.pill),
            boxShadow: AppShadows.card),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle,
              color: recording ? AppColors.error : AppColors.disabledText)),
          const SizedBox(width: AppSpacing.sm),
          Text(recording ? 'Recording · ${left}s left' : 'Starting soon',
              style: AppText.labelLarge.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
        ])),
      const SizedBox(height: AppSpacing.md),
      AppButton('Cancel', variant: AppButtonVariant.ghost, expanded: false, onPressed: onCancel),
    ]);
  }
}

class _ErrorView extends StatelessWidget {
  final _Error error; final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    final (icon, title, body) = switch (error) {
      _Error.permission => (Icons.no_photography_outlined, 'Camera access is off',
          'Turn on camera access for Amour in Settings to record your selfie video.'),
      _Error.unavailable => (Icons.videocam_off_outlined, 'Camera not available',
          'We couldn’t start your camera. Close any other app that may be using it, then try again.'),
      _Error.recording => (Icons.error_outline_rounded, 'Recording stopped',
          'Something interrupted your video. Let’s give it another go.'),
    };
    return VerificationPage(title: 'Selfie video', close: true,
      actions: [
        if (error == _Error.permission)
          const AppButton('Open Settings', icon: Icons.settings_outlined, onPressed: CameraPermission.openSettings),
        AppButton('Try again', icon: Icons.refresh_rounded, onPressed: onRetry,
            variant: error == _Error.permission ? AppButtonVariant.secondary : AppButtonVariant.primary),
      ],
      children: [
        const SizedBox(height: AppSpacing.xxl),
        VerificationIcon(icon: icon, color: AppColors.error, background: AppColors.error.withValues(alpha: .1)),
        const SizedBox(height: AppSpacing.xl),
        Text(title, style: AppText.displaySmall, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.sm),
        Text(body, style: AppText.bodyLarge.copyWith(color: AppColors.muted), textAlign: TextAlign.center),
      ]);
  }
}
