import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration_flutter/vibration_flutter.dart';
import 'package:vibration_platform_interface/vibration_platform_interface.dart';

// A mock storage for testing custom adapters
class MockHapticStorage implements HapticStorage {
  bool enabled = true;
  int getCalls = 0;
  int setCalls = 0;

  @override
  Future<bool> getEnabled() async {
    getCalls++;
    return enabled;
  }

  @override
  Future<void> setEnabled(bool enabled) async {
    setCalls++;
    this.enabled = enabled;
  }
}

// A mock platform interface to bypass device-info physical check and Platform checks in unit tests
class MockVibrationPlatform extends VibrationPlatform {
  final List<Map<String, dynamic>> calls = [];
  bool vibratorAvailable = true;
  bool amplitudeControlAvailable = true;

  @override
  Future<bool> hasVibrator() async => vibratorAvailable;

  @override
  Future<bool> hasAmplitudeControl() async => amplitudeControlAvailable;

  @override
  Future<bool> hasCustomVibrationsSupport() async => true;

  @override
  Future<void> vibrate({
    int duration = 500,
    List<int> pattern = const [],
    int repeat = -1,
    List<int> intensities = const [],
    int amplitude = -1,
    double sharpness = 0.5,
  }) async {
    calls.add({
      'method': 'vibrate',
      'duration': duration,
      'pattern': pattern,
      'repeat': repeat,
      'intensities': intensities,
      'amplitude': amplitude,
      'sharpness': sharpness,
    });
  }

  @override
  Future<void> cancel() async {
    calls.add({'method': 'cancel'});
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Setup platform channel mocks
  const MethodChannel hapticFeedbackChannel = SystemChannels.platform;
  final List<MethodCall> hapticFeedbackLog = <MethodCall>[];
  late MockVibrationPlatform mockVibration;

  setUp(() {
    hapticFeedbackLog.clear();
    mockVibration = MockVibrationPlatform();
    VibrationPlatform.instance = mockVibration;

    // Standardized channel mocking for native iOS HapticFeedback
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(hapticFeedbackChannel, (MethodCall methodCall) async {
      if (methodCall.method.startsWith('HapticFeedback.')) {
        hapticFeedbackLog.add(methodCall);
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(hapticFeedbackChannel, null);
  });

  group('HapticService Configuration & Storage', () {
    test('Should initialize with custom storage driver', () async {
      final mockStorage = MockHapticStorage();
      mockStorage.enabled = false;

      await HapticService.init(storage: mockStorage);

      expect(HapticService.isEnabled, isFalse);
      expect(HapticService.isInitialized, isTrue);
      expect(mockStorage.getCalls, 1);
    });

    test('Should toggle status and persist state in storage', () async {
      final mockStorage = MockHapticStorage();
      mockStorage.enabled = true;

      await HapticService.init(storage: mockStorage);
      expect(HapticService.isEnabled, isTrue);

      await HapticService.toggle();
      expect(HapticService.isEnabled, isFalse);
      expect(mockStorage.enabled, isFalse);
      expect(mockStorage.setCalls, 1);

      await HapticService.setEnabled(true);
      expect(HapticService.isEnabled, isTrue);
      expect(mockStorage.enabled, isTrue);
      expect(mockStorage.setCalls, 2);
    });

    test('Should default to SharedPreferences storage if none is supplied', () async {
      SharedPreferences.setMockInitialValues({'haptic_enabled': false});
      
      await HapticService.init();
      expect(HapticService.isEnabled, isFalse);
      expect(HapticService.isInitialized, isTrue);
    });
  });

  group('HapticService Core Player Operations', () {
    setUp(() async {
      final mockStorage = MockHapticStorage();
      mockStorage.enabled = true;
      await HapticService.init(storage: mockStorage);
    });

    test('Should trigger native HapticFeedback for system presets', () async {
      await HapticService.play(HapticPreset.selection);
      expect(hapticFeedbackLog.length, 1);
      expect(hapticFeedbackLog.first.method, 'HapticFeedback.vibrate');
      expect(hapticFeedbackLog.first.arguments, 'HapticFeedbackType.selectionClick');

      await HapticService.play(HapticPreset.lightImpact);
      expect(hapticFeedbackLog.length, 2);
      expect(hapticFeedbackLog.last.method, 'HapticFeedback.vibrate');
      expect(hapticFeedbackLog.last.arguments, 'HapticFeedbackType.lightImpact');
    });

    test('Should trigger custom Vibration pattern on platform for game presets', () async {
      await HapticService.play(HapticPreset.success);
      expect(mockVibration.calls.isNotEmpty, isTrue);
      
      final hasVibrateCall = mockVibration.calls.any((call) => call['method'] == 'vibrate');
      expect(hasVibrateCall, isTrue);

      final vibrateCall = mockVibration.calls.firstWhere((call) => call['method'] == 'vibrate');
      expect(vibrateCall['pattern'], [0, 40, 30, 80]);
    });

    test('Should support custom patterns with intensities', () async {
      const customPattern = HapticPattern(
        timings: [0, 100, 50, 200],
        amplitudes: [0, 120, 0, 240],
      );

      await HapticService.playPattern(customPattern);

      expect(mockVibration.calls.length, 1);
      final vibrateCall = mockVibration.calls.first;
      expect(vibrateCall['pattern'], [0, 100, 50, 200]);
      expect(vibrateCall['intensities'], [0, 120, 0, 240]);
    });

    test('Should do nothing if disabled', () async {
      await HapticService.setEnabled(false);
      mockVibration.calls.clear();
      hapticFeedbackLog.clear();

      await HapticService.play(HapticPreset.selection);
      await HapticService.play(HapticPreset.success);

      expect(mockVibration.calls.isEmpty, isTrue);
      expect(hapticFeedbackLog.isEmpty, isTrue);
    });
  });
}
