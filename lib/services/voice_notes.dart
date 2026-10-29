import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import '../data/teaser.dart';

enum MicAccess { granted, denied, blocked }

/// Microphone permission. Platforms without a permission plugin report [MicAccess.granted]
/// and let the recorder itself prompt or fail.
class MicPermission {
  static Future<MicAccess> request() async {
    try {
      final s = await Permission.microphone.request();
      if (s.isGranted || s.isLimited) return MicAccess.granted;
      return s.isPermanentlyDenied || s.isRestricted ? MicAccess.blocked : MicAccess.denied;
    } on MissingPluginException {
      return MicAccess.granted;
    } on UnimplementedError {
      return MicAccess.granted;
    } on PlatformException {
      return MicAccess.granted;
    }
  }

  static Future<bool> openSettings() async {
    try { return await openAppSettings(); } on MissingPluginException { return false; }
  }
}

/// Records one voice note. Upload seam: hand the finished [VoiceNote.path] to your storage
/// (presigned S3 URL, Firebase Storage, …) and keep the returned URL with [VoiceSource.url].
abstract class VoiceRecorder {
  /// Live loudness, 0..1, about ten times a second while recording.
  Stream<double> get levels;
  Future<void> start();
  /// Finishes the recording; null if nothing usable was captured.
  Future<VoiceNote?> stop();
  Future<void> cancel();
  Future<void> dispose();
}

/// [VoiceRecorder] backed by the `record` plugin: mono AAC, small enough to upload quickly.
class DeviceVoiceRecorder implements VoiceRecorder {
  final _recorder = AudioRecorder();
  final _levels = StreamController<double>.broadcast();
  final _samples = <double>[];
  StreamSubscription<Amplitude>? _sub;
  final _clock = Stopwatch();

  @override
  Stream<double> get levels => _levels.stream;

  @override
  Future<void> start() async {
    // On the web there's no documents folder: the browser records into memory (the path is
    // ignored) and stop() hands back a blob: URL. Browsers differ in what they can encode.
    var encoder = AudioEncoder.aacLc;
    var path = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    if (kIsWeb) {
      for (final e in const [AudioEncoder.aacLc, AudioEncoder.opus, AudioEncoder.wav]) {
        if (await _recorder.isEncoderSupported(e)) { encoder = e; break; }
      }
    } else {
      path = '${(await getApplicationDocumentsDirectory()).path}/$path';
    }
    _samples.clear();
    await _recorder.start(RecordConfig(encoder: encoder, bitRate: 64000, numChannels: 1,
        autoGain: true, noiseSuppress: true), path: path);
    _clock..reset()..start();
    _sub = _recorder.onAmplitudeChanged(const Duration(milliseconds: 100)).listen((a) {
      // dBFS: about −50 is near silence, 0 is as loud as it gets.
      final v = ((a.current + 50) / 50).clamp(0.0, 1.0);
      _samples.add(v);
      _levels.add(v);
    });
  }

  @override
  Future<VoiceNote?> stop() async {
    await _sub?.cancel();
    _clock.stop();
    final path = await _recorder.stop();
    if (path == null) return null;
    return VoiceNote(path, source: kIsWeb ? VoiceSource.url : VoiceSource.file, duration: _clock.elapsed,
        waveform: VoiceNote.waveformFrom(_samples));
  }

  @override
  Future<void> cancel() async { await _sub?.cancel(); _clock.stop(); await _recorder.cancel(); }

  @override
  Future<void> dispose() async { await _sub?.cancel(); await _levels.close(); await _recorder.dispose(); }
}

/// Swap for a fake in tests.
VoiceRecorder Function() createVoiceRecorder = DeviceVoiceRecorder.new;

/// What [VoicePlayback] needs from an audio player.
abstract class VoicePlayerBackend {
  Future<void> load(VoiceNote note);
  void play();
  Future<void> pause();
  Future<void> stop();
  Stream<Duration> get position;
  /// Fires when a note plays to the end.
  Stream<void> get completed;
}

class JustAudioBackend implements VoicePlayerBackend {
  final _player = AudioPlayer();

  @override
  Future<void> load(VoiceNote note) => switch (note.source) {
    VoiceSource.file => _player.setFilePath(note.path),
    VoiceSource.asset => _player.setAsset(note.path),
    VoiceSource.url => _player.setUrl(note.path),
  };
  // just_audio's play() completes only when playback stops, so it isn't awaited.
  @override
  void play() => unawaited(_player.play());
  @override
  Future<void> pause() => _player.pause();
  @override
  Future<void> stop() => _player.stop();
  @override
  Stream<Duration> get position => _player.positionStream;
  @override
  Stream<void> get completed =>
      _player.processingStateStream.where((s) => s == ProcessingState.completed);
}

/// Plays one voice note at a time across the app: starting another stops the current one.
class VoicePlayback extends ChangeNotifier {
  VoicePlayerBackend Function() createBackend = JustAudioBackend.new;
  VoicePlayerBackend? _backend;

  VoiceNote? _current;
  bool _playing = false;
  Duration _position = Duration.zero;

  bool isPlaying(VoiceNote note) => _playing && identical(_current, note);
  /// 0..1 through [note]; 0 unless it's the one loaded.
  double progressOf(VoiceNote note) => !identical(_current, note) || note.duration == Duration.zero ? 0
      : (_position.inMilliseconds / note.duration.inMilliseconds).clamp(0.0, 1.0);
  Duration positionOf(VoiceNote note) => identical(_current, note) ? _position : Duration.zero;

  VoicePlayerBackend get _player => _backend ??= createBackend()
    ..position.listen((p) { _position = p; notifyListeners(); })
    ..completed.listen((_) => _finish());

  Future<void> toggle(VoiceNote note) async {
    if (isPlaying(note)) {
      _playing = false;
      notifyListeners();
      await _player.pause();
      return;
    }
    final resume = identical(_current, note) && _position < note.duration;
    _current = note; _playing = true;
    if (!resume) _position = Duration.zero;
    notifyListeners();
    try {
      if (!resume) await _player.load(note);
      _player.play();
    } catch (e) {
      debugPrint('Voice note failed to play: $e');
      _finish();
      rethrow;
    }
  }

  /// Stops [note] if it's the one playing (e.g. when its widget goes away); stops anything when null.
  Future<void> stop([VoiceNote? note]) async {
    if (_current == null || (note != null && !identical(_current, note))) return;
    _finish();
    await _backend?.stop();
  }

  void _finish() {
    _playing = false; _current = null; _position = Duration.zero;
    notifyListeners();
  }
}

final voicePlayback = VoicePlayback();
