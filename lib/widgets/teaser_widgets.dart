import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/haptics.dart';
import '../data/teaser.dart';
import '../l10n/match_text.dart';
import '../services/voice_notes.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'buttons.dart';
import 'profile_bits.dart';
import 'states.dart';

/// An answered prompt: small muted question over the voice note and/or written answer.
class TeaserCard extends StatelessWidget {
  final Teaser teaser; final VoidCallback? onTap;
  const TeaserCard(this.teaser, {super.key, this.onTap});
  @override
  Widget build(BuildContext context) {
    final voice = teaser.voice, answer = teaser.answer;
    return Semantics(button: onTap != null, child: GestureDetector(onTap: onTap,
      child: AppCard(padding: const EdgeInsets.all(AppSpacing.lg), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(teaser.prompt, style: AppText.labelMedium.copyWith(color: AppColors.accent)),
          const SizedBox(height: AppSpacing.xs),
          if (voice != null) ...[
            const SizedBox(height: AppSpacing.xs),
            VoiceNotePlayer(voice),
            if (answer.isNotEmpty) const SizedBox(height: AppSpacing.sm),
          ],
          // With a voice note the written answer reads as a caption.
          if (answer.isNotEmpty)
            Text(answer, style: voice != null ? AppText.bodyMedium : AppText.h4.copyWith(fontWeight: FontWeight.w500)),
        ])),
        if (onTap != null) ...[const SizedBox(width: AppSpacing.sm),
          const Icon(Icons.edit_outlined, size: 18, color: AppColors.muted)],
      ]))));
  }
}

/// Rounded loudness bars; bars before [progress] (0..1) are drawn in full colour.
class Waveform extends StatelessWidget {
  final List<double> values; final double progress, height; final Color color;
  const Waveform(this.values, {super.key, this.progress = 0, this.height = 28, this.color = AppColors.primary});
  @override
  Widget build(BuildContext context) => SizedBox(height: height, width: double.infinity,
      child: CustomPaint(painter: _WaveformPainter(values, progress, color)));
}

class _WaveformPainter extends CustomPainter {
  final List<double> values; final double progress; final Color color;
  const _WaveformPainter(this.values, this.progress, this.color);
  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    const gap = 2.0;
    final w = math.max(1.5, (size.width - gap * (values.length - 1)) / values.length);
    final played = Paint()..color = color, rest = Paint()..color = color.withValues(alpha: .28);
    for (var i = 0; i < values.length; i++) {
      final h = math.max(3.0, values[i].clamp(0.0, 1.0) * size.height);
      final r = RRect.fromRectAndRadius(
          Rect.fromLTWH(i * (w + gap), (size.height - h) / 2, w, h), Radius.circular(w / 2));
      canvas.drawRRect(r, (i + .5) / values.length <= progress ? played : rest);
    }
  }
  @override
  bool shouldRepaint(_WaveformPainter old) => old.progress != progress || old.values != values || old.color != color;
}

/// Play/pause, waveform with progress, and the time left. Only one note plays at a time.
class VoiceNotePlayer extends StatefulWidget {
  final VoiceNote note;
  const VoiceNotePlayer(this.note, {super.key});
  @override
  State<VoiceNotePlayer> createState() => _VoiceNotePlayerState();
}
class _VoiceNotePlayerState extends State<VoiceNotePlayer> {
  @override
  void dispose() {
    // Don't keep talking after the card is gone. Deferred: stopping notifies the other players,
    // which can't rebuild while the tree is being torn down.
    final note = widget.note;
    scheduleMicrotask(() => voicePlayback.stop(note));
    super.dispose();
  }

  Future<void> _toggle() async {
    Haptics.selection();
    try {
      await voicePlayback.toggle(widget.note);
    } catch (_) {
      if (mounted) showToast(context, context.l10n.playFailed, type: ToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: voicePlayback, builder: (context, _) {
    final n = widget.note, playing = voicePlayback.isPlaying(n), position = voicePlayback.positionOf(n);
    final left = position > Duration.zero ? n.duration - position : n.duration;
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xs, AppSpacing.xs, AppSpacing.mdSm, AppSpacing.xs),
      decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Row(children: [
        Semantics(button: true, label: playing ? context.l10n.pauseVoice : context.l10n.playVoice,
          child: AppIconButton(playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
              tooltip: playing ? context.l10n.pauseVoice : context.l10n.playVoice, size: 40,
              color: AppColors.onPrimary, background: AppColors.primary, onPressed: _toggle)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Waveform(n.waveform, progress: voicePlayback.progressOf(n))),
        const SizedBox(width: AppSpacing.sm),
        Text(formatClock(left.isNegative ? Duration.zero : left),
            style: AppText.labelMedium.copyWith(color: AppColors.primary, fontFeatures: const [FontFeature.tabularFigures()])),
      ]));
  });
}

/// Small "Voice" pill for cards of people who recorded a voice prompt.
class VoicePromptBadge extends StatelessWidget {
  const VoicePromptBadge({super.key});
  @override
  Widget build(BuildContext context) => Semantics(label: context.l10n.reasonVoice, child: Container(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
    decoration: BoxDecoration(color: AppColors.glassStrong, borderRadius: BorderRadius.circular(AppRadius.pill)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.graphic_eq_rounded, size: 14, color: AppColors.primary),
      const SizedBox(width: 3),
      Text(context.l10n.voiceBadge, style: AppText.labelSmall.copyWith(color: AppColors.primary)),
    ])));
}

enum _Phase { idle, recording, done }

/// Records a voice answer of up to [VoiceNote.maxLength]: tap to start, tap to stop (or it stops
/// itself at the limit), then listen back, re-record or delete. Reports every change to [onChanged].
class VoiceRecorderPanel extends StatefulWidget {
  final VoiceNote? initial; final ValueChanged<VoiceNote?> onChanged;
  const VoiceRecorderPanel({super.key, this.initial, required this.onChanged});
  @override
  State<VoiceRecorderPanel> createState() => _VoiceRecorderPanelState();
}
class _VoiceRecorderPanelState extends State<VoiceRecorderPanel> {
  late VoiceNote? _note = widget.initial;
  late var _phase = _note == null ? _Phase.idle : _Phase.done;
  VoiceRecorder? _recorder;
  StreamSubscription<double>? _levels;
  Timer? _ticker;
  final _clock = Stopwatch();
  final _live = <double>[];
  bool _starting = false;

  Duration get _elapsed => _clock.elapsed;

  @override
  void dispose() {
    _ticker?.cancel();
    _levels?.cancel();
    final r = _recorder;
    if (r != null) r.cancel().whenComplete(r.dispose);
    super.dispose();
  }

  Future<void> _start() async {
    if (_starting) return;
    final l = context.l10n;
    setState(() => _starting = true);
    final access = await MicPermission.request();
    if (!mounted) return;
    setState(() => _starting = false);
    if (access == MicAccess.blocked) {
      if (await showConfirmDialog(context, title: l.micBlockedTitle, message: l.micBlockedMessage,
          confirm: l.openSettings)) { await MicPermission.openSettings(); }
      return;
    }
    if (access == MicAccess.denied) {
      showToast(context, l.micNeeded, type: ToastType.error);
      return;
    }
    await voicePlayback.stop();
    final r = createVoiceRecorder();
    try {
      await r.start();
    } catch (_) {
      await r.dispose();
      if (mounted) showToast(context, l.recordFailed, type: ToastType.error);
      return;
    }
    if (!mounted) { await r.cancel(); await r.dispose(); return; }
    Haptics.medium();
    _recorder = r;
    _live.clear();
    _levels = r.levels.listen((v) => _live..add(v)..removeRange(0, math.max(0, _live.length - VoiceNote.bars)));
    _clock..reset()..start();
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_elapsed >= VoiceNote.maxLength) { _stop(); } else { setState(() {}); }
    });
    setState(() => _phase = _Phase.recording);
  }

  Future<VoiceNote?> _finish({required bool keep}) async {
    final r = _recorder;
    if (r == null) return null;
    _recorder = null;
    _ticker?.cancel();
    _levels?.cancel(); // no need to wait for the level stream to wind down
    _levels = null;
    _clock.stop();
    VoiceNote? note;
    try {
      if (keep) { note = await r.stop(); } else { await r.cancel(); }
    } catch (_) {
      note = null;
    } finally {
      await r.dispose();
    }
    return note;
  }

  Future<void> _stop() async {
    if (_recorder == null) return;
    final l = context.l10n;
    final note = await _finish(keep: true);
    if (!mounted) return;
    Haptics.light();
    if (note == null || note.duration < VoiceNote.minLength) {
      showToast(context, note == null ? l.recordFailed : l.voiceTooShort, type: ToastType.error);
      setState(() => _phase = _note == null ? _Phase.idle : _Phase.done);
      return;
    }
    setState(() { _note = note; _phase = _Phase.done; });
    widget.onChanged(note);
  }

  Future<void> _cancel() async {
    await _finish(keep: false);
    if (mounted) setState(() => _phase = _note == null ? _Phase.idle : _Phase.done);
  }

  void _delete() {
    voicePlayback.stop(_note);
    setState(() { _note = null; _phase = _Phase.idle; });
    widget.onChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.mic_rounded, size: 20, color: AppColors.primary),
        const SizedBox(width: AppSpacing.xs),
        Expanded(child: Text(l.voicePromptTitle, style: AppText.h4)),
      ]),
      const SizedBox(height: AppSpacing.xs),
      Text(l.voicePromptSubtitle(VoiceNote.maxLength.inSeconds), style: AppText.bodySmall),
      const SizedBox(height: AppSpacing.lg),
      AnimatedSwitcher(duration: AppDurations.base, child: switch (_phase) {
        _Phase.idle => Center(key: const ValueKey('idle'), child: Column(children: [
            _RecordButton(icon: Icons.mic_rounded, tooltip: l.tapToRecord, busy: _starting, onTap: _start),
            const SizedBox(height: AppSpacing.sm),
            Text(l.tapToRecord, style: AppText.labelLarge.copyWith(color: AppColors.primary)),
          ])),
        _Phase.recording => Column(key: const ValueKey('recording'), children: [
            Row(children: [
              AppIconButton(Icons.close_rounded, tooltip: l.cancel, size: 40, onPressed: _cancel),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Waveform([...List.filled(VoiceNote.bars - _live.length, .05), ..._live],
                  progress: 1, height: 36)),
              const SizedBox(width: AppSpacing.sm),
              Text('${formatClock(_elapsed)} / ${formatClock(VoiceNote.maxLength)}',
                  style: AppText.labelMedium.copyWith(color: AppColors.primary,
                      fontFeatures: const [FontFeature.tabularFigures()])),
            ]),
            const SizedBox(height: AppSpacing.md),
            _RecordButton(icon: Icons.stop_rounded, tooltip: l.stopRecording, color: AppColors.error,
                progress: _elapsed.inMilliseconds / VoiceNote.maxLength.inMilliseconds, onTap: _stop),
            const SizedBox(height: AppSpacing.sm),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const _PulsingDot(),
              const SizedBox(width: AppSpacing.xs),
              Text(l.recordingNow, style: AppText.labelLarge.copyWith(color: AppColors.error)),
            ]),
          ]),
        _Phase.done => Column(key: const ValueKey('done'), children: [
            VoiceNotePlayer(_note!),
            const SizedBox(height: AppSpacing.sm),
            Row(children: [
              TextButton.icon(onPressed: _start,
                  icon: const Icon(Icons.refresh_rounded, size: 18, color: AppColors.primary),
                  label: Text(l.reRecord, style: AppText.labelLarge.copyWith(color: AppColors.primary))),
              const Spacer(),
              AppIconButton(Icons.delete_outline_rounded, tooltip: l.deleteVoice, color: AppColors.error,
                  onPressed: _delete),
            ]),
          ]),
      }),
    ]));
  }
}

/// Round record/stop button; while recording, a ring fills towards the time limit.
class _RecordButton extends StatelessWidget {
  final IconData icon; final String tooltip; final VoidCallback onTap; final Color color;
  final double? progress; final bool busy;
  const _RecordButton({required this.icon, required this.tooltip, required this.onTap,
      this.color = AppColors.primary, this.progress, this.busy = false});
  @override
  Widget build(BuildContext context) => SizedBox.square(dimension: 84, child: CustomPaint(
    painter: progress == null ? null : _RingPainter(progress!.clamp(0.0, 1.0), color),
    child: Center(child: Container(
      decoration: BoxDecoration(shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color.withValues(alpha: .3), blurRadius: 20, offset: const Offset(0, 6))]),
      child: AppIconButton(icon, tooltip: tooltip, size: 68, color: AppColors.onPrimary, background: color,
          onPressed: busy ? null : onTap,
          child: busy ? const SizedBox.square(dimension: 22,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary)) : null)))));
}

class _RingPainter extends CustomPainter {
  final double value; final Color color;
  const _RingPainter(this.value, this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(2);
    final p = Paint()..style = PaintingStyle.stroke..strokeWidth = 3..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, p..color = color.withValues(alpha: .15));
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * value, false, p..color = color);
  }
  @override
  bool shouldRepaint(_RingPainter old) => old.value != value;
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}
class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..repeat(reverse: true);
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => FadeTransition(opacity: Tween(begin: .3, end: 1.0).animate(_c),
    child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle)));
}
