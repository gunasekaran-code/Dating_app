import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Ordered weakest to strongest: when several fire together, the strongest wins.
enum _Kind { selection, light, medium, success, warning, error }

/// The app's one way to play haptics, named for what happened rather than how it feels:
///
/// * [selection] — picking an option, a chip, a tab, a toggle, a wheel or slider step.
/// * [light] — tapping a primary button or a small commit (send, add, swipe away).
/// * [medium] — a bigger moment (start recording, pick up a photo to drag).
/// * [success] / [warning] / [error] — an outcome: saved, about to do something
///   destructive, failed or invalid.
///
/// Uses the platform's own generators (UIFeedbackGenerator on iOS, performHapticFeedback on
/// Android), so the phone's System Haptics / Touch feedback setting still switches it off.
/// [enabled] is the in-app switch on top of that.
///
/// Calls made in the same tap are merged into the strongest one (Save + "Saved" toast is one
/// success, not a click then a success), and repeats of the same or weaker kind within
/// [_gap] are dropped so fast scrolls and double taps don't buzz.
abstract final class Haptics {
  static final enabled = ValueNotifier(true);

  static void selection() => _play(_Kind.selection);
  static void light() => _play(_Kind.light);
  static void medium() => _play(_Kind.medium);
  static void success() => _play(_Kind.success);
  static void warning() => _play(_Kind.warning);
  static void error() => _play(_Kind.error);

  static const _gap = Duration(milliseconds: 60);
  static _Kind? _pending, _last;
  static final _sinceLast = Stopwatch();

  static void _play(_Kind kind) {
    if (!enabled.value) return;
    final p = _pending;
    if (p == null) {
      _pending = kind;
      scheduleMicrotask(_flush);
    } else if (kind.index > p.index) {
      _pending = kind;
    }
  }

  static void _flush() {
    final kind = _pending!;
    _pending = null;
    if (_last != null && _sinceLast.isRunning && _sinceLast.elapsed < _gap && kind.index <= _last!.index) return;
    _last = kind;
    _sinceLast..reset()..start();
    unawaited(switch (kind) {
      _Kind.selection => HapticFeedback.selectionClick(),
      _Kind.light => HapticFeedback.lightImpact(),
      _Kind.medium => HapticFeedback.mediumImpact(),
      _Kind.success => HapticFeedback.successNotification(),
      _Kind.warning => HapticFeedback.warningNotification(),
      _Kind.error => HapticFeedback.errorNotification(),
    });
  }
}
