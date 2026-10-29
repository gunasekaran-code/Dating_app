import 'dart:math' as math;

enum VoiceSource { file, asset, url }

/// A spoken answer to a teaser prompt, up to [maxLength] long.
class VoiceNote {
  static const maxLength = Duration(seconds: 30), minLength = Duration(seconds: 2);
  static const bars = 40;

  /// A recorded file on this device, a bundled asset (demo profiles) or an uploaded URL.
  final String path;
  final VoiceSource source;
  final Duration duration;
  /// Loudness per bar (0..1, [bars] long), drawn as the waveform.
  final List<double> waveform;

  const VoiceNote(this.path, {required this.source, required this.duration, required this.waveform});
  const VoiceNote.asset(this.path, {required this.duration, required this.waveform}) : source = VoiceSource.asset;

  /// Squeezes live recording levels (one every ~100 ms) into [bars] waveform bars.
  static List<double> waveformFrom(List<double> levels) {
    if (levels.isEmpty) return List.filled(bars, .08);
    return [
      for (var i = 0; i < bars; i++)
        () {
          final from = i * levels.length ~/ bars, to = math.max(from + 1, (i + 1) * levels.length ~/ bars);
          final chunk = levels.sublist(math.min(from, levels.length - 1), math.min(to, levels.length));
          return chunk.reduce(math.max).clamp(.08, 1.0);
        }(),
    ];
  }
}

/// A prompt the user answered on their profile, e.g. "My ideal first date…" — in writing,
/// with their voice, or both.
class Teaser {
  final String prompt, answer;
  final VoiceNote? voice;
  const Teaser(this.prompt, this.answer, {this.voice});
}

/// "0:09"
String formatClock(Duration d) => '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
