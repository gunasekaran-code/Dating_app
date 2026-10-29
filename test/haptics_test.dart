import 'package:amour/services/haptics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final played = <String>[];

  setUp(() {
    played.clear();
    Haptics.enabled.value = true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform,
        (call) async { if (call.method == 'HapticFeedback.vibrate') played.add(call.arguments as String? ?? ''); return null; });
  });

  Future<void> settle() => Future.delayed(const Duration(milliseconds: 80));

  test('haptics fired in the same tap merge into the strongest', () async {
    Haptics.light();
    Haptics.success();
    Haptics.selection();
    await settle();
    expect(played, ['HapticFeedbackType.successNotification']);
  });

  test('rapid repeats of the same kind are throttled, stronger ones still play', () async {
    Haptics.selection();
    await Future<void>.delayed(Duration.zero);
    Haptics.selection();
    await Future<void>.delayed(Duration.zero);
    Haptics.error();
    await settle();
    expect(played, ['HapticFeedbackType.selectionClick', 'HapticFeedbackType.errorNotification']);
  });

  test('the in-app switch silences everything', () async {
    Haptics.enabled.value = false;
    Haptics.success();
    Haptics.light();
    await settle();
    expect(played, isEmpty);
  });
}
