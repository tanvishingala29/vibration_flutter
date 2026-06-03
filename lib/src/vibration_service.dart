import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

/// An abstract interface for persisting the haptic status.
///
/// Implement this to use custom key-value databases like Hive, Isar, or secure storage.
abstract class HapticStorage {
  /// Fetches whether haptic feedback is currently enabled.
  Future<bool> getEnabled();

  /// Persists the enabled/disabled state of haptic feedback.
  Future<void> setEnabled(bool enabled);
}

/// The default implementation of [HapticStorage] using [SharedPreferences].
class SharedPrefsHapticStorage implements HapticStorage {
  /// The key used to store the preference in [SharedPreferences].
  final String key;

  /// Creates a new [SharedPrefsHapticStorage] with an optional custom storage [key].
  const SharedPrefsHapticStorage({this.key = 'haptic_enabled'});

  @override
  Future<bool> getEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(key) ?? true;
    } catch (_) {
      return true;
    }
  }

  @override
  Future<void> setEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, enabled);
    } catch (_) {
      // Fail silently if preferences are unavailable.
    }
  }
}

/// A representation of a custom vibration pattern with timed pulses and amplitudes.
class HapticPattern {
  /// A list of durations in milliseconds.
  /// The pattern starts by waiting for the first value, then vibrating for the second,
  /// waiting for the third, vibrating for the fourth, etc.
  ///
  /// Example: `[0, 100, 50, 100]` -> vibrate instantly for 100ms, wait 50ms, vibrate 100ms.
  final List<int> timings;

  /// The vibration intensities corresponding to active vibration pulses.
  /// Values range from 1 to 255.
  final List<int>? amplitudes;

  /// Creates a custom [HapticPattern].
  const HapticPattern({required this.timings, this.amplitudes});

  /// A pre-made double tap pattern.
  static const HapticPattern doubleTap = HapticPattern(
    timings: [0, 40, 30, 80],
    amplitudes: [0, 80, 0, 160],
  );

  /// A pre-made triple pulse pattern.
  static const HapticPattern triplePulse = HapticPattern(
    timings: [0, 60, 40, 60, 40, 80],
    amplitudes: [0, 120, 0, 160, 0, 240],
  );
}

/// Predefined feedback presets designed for standard game events and UI interactions.
enum HapticPreset {
  /// A light tap, ideal for item selection or focus changes (uses native iOS/Android).
  selection,

  /// Crisp native light impact.
  lightImpact,

  /// Crisp native medium impact.
  mediumImpact,

  /// Crisp native heavy impact.
  heavyImpact,

  /// A bright double-pulse signifying success.
  success,

  /// A heavy rhythmic triple-pulse signifying error.
  error,

  /// A rising rhythmic pattern for game milestones and achievements.
  levelUp,

  /// A high-pitched, short double-tap signifying coin collection.
  coin,

  /// A physical heart-beat pulse pattern (heavy-light pulse).
  heartbeat,

  /// A long, decaying rumble representing an explosion.
  explosion,

  /// A rapid, high-frequency series of pulses representing laser fire.
  laser,

  /// A single sharp shock representing a hit or collision.
  collision,
}

/// A premium, highly customizable vibration and haptic feedback manager.
///
/// Designed with standard defaults, static helper methods, and custom storage adapters.
class HapticService {
  HapticService._();

  static HapticStorage _storage = const SharedPrefsHapticStorage();
  static bool _enabled = true;
  static bool _initialized = false;

  /// Initializes the service. Optional [storage] allows injecting custom persistence modules.
  ///
  /// Example:
  /// ```dart
  /// await HapticService.init(storage: MyCustomHiveStorage());
  /// ```
  static Future<void> init({HapticStorage? storage}) async {
    _storage = storage ?? const SharedPrefsHapticStorage();
    try {
      _enabled = await _storage.getEnabled();
      _initialized = true;
    } catch (_) {
      _enabled = true;
      _initialized = true;
    }
  }

  /// Sets the global enablement state.
  static Future<void> setEnabled(bool enabled) async {
    _enabled = enabled;
    try {
      await _storage.setEnabled(enabled);
    } catch (_) {
      // Fail silently if storage has issues
    }
  }

  /// Toggles the vibration option globally and persists the preference.
  static Future<void> toggle() async {
    await setEnabled(!_enabled);
  }

  /// Checks if haptics are enabled globally.
  static bool get isEnabled => _enabled;

  /// Checks if the service has been initialized.
  static bool get isInitialized => _initialized;

  // ───────────────────────── CORE INTERNALS ─────────────────────────

  /// Generic core vibration execution with device feature checks.
  static Future<void> _vibrate({
    int duration = 50,
    int amplitude = 120,
    List<int>? pattern,
    List<int>? intensities,
  }) async {
    if (!_enabled) return;

    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (!hasVibrator) return;

      if (pattern != null) {
        if (intensities != null) {
          await Vibration.vibrate(pattern: pattern, intensities: intensities);
        } else {
          await Vibration.vibrate(pattern: pattern);
        }
        return;
      }

      final hasAmplitude = await Vibration.hasAmplitudeControl();
      if (hasAmplitude) {
        await Vibration.vibrate(duration: duration, amplitude: amplitude);
      } else {
        await Vibration.vibrate(duration: duration);
      }
    } catch (_) {
      // Catch platform channel errors gracefully.
    }
  }

  // ───────────────────────── NEW PRO PLAYERS ─────────────────────────

  /// Triggers a specific predefined haptic preset.
  ///
  /// This automatically selects the most optimal strategy between Flutter's
  /// high-fidelity hardware-level haptics (`HapticFeedback`) and custom timing patterns.
  static Future<void> play(HapticPreset preset) async {
    if (!_enabled) return;

    switch (preset) {
      case HapticPreset.selection:
        await HapticFeedback.selectionClick();
        break;
      case HapticPreset.lightImpact:
        await HapticFeedback.lightImpact();
        break;
      case HapticPreset.mediumImpact:
        await HapticFeedback.mediumImpact();
        break;
      case HapticPreset.heavyImpact:
        await HapticFeedback.heavyImpact();
        break;
      case HapticPreset.success:
        await success();
        break;
      case HapticPreset.error:
        await error();
        break;
      case HapticPreset.levelUp:
        await levelUp();
        break;
      case HapticPreset.coin:
        await coin();
        break;
      case HapticPreset.heartbeat:
        await _vibrate(
          pattern: [0, 80, 120, 50, 300, 80, 120, 50],
          intensities: [0, 180, 0, 80, 0, 180, 0, 80],
        );
        break;
      case HapticPreset.explosion:
        await _vibrate(
          pattern: [0, 250, 50, 150, 50, 80, 30, 40],
          intensities: [0, 255, 0, 160, 0, 90, 0, 40],
        );
        break;
      case HapticPreset.laser:
        await _vibrate(
          pattern: [0, 30, 20, 30, 20, 30, 20, 40],
          intensities: [0, 140, 0, 100, 0, 80, 0, 60],
        );
        break;
      case HapticPreset.collision:
        await _vibrate(duration: 60, amplitude: 220);
        break;
    }
  }

  /// Plays a custom user-defined [HapticPattern].
  static Future<void> playPattern(HapticPattern pattern) async {
    if (!_enabled) return;

    assert(
      pattern.amplitudes == null ||
          pattern.amplitudes!.length == pattern.timings.length,
      "Timings and amplitudes must match",
    );

    await _vibrate(pattern: pattern.timings, intensities: pattern.amplitudes);
  }
  // ───────────────────────── UI FEEDBACK (BACKWARD COMPATIBLE) ─────────────────────────

  /// Triggers a short, high-fidelity light vibration (e.g. key press).
  static Future<void> light() async {
    await play(HapticPreset.lightImpact);
  }

  /// Triggers a medium vibration.
  static Future<void> medium() async {
    await play(HapticPreset.mediumImpact);
  }

  /// Triggers a strong vibration.
  static Future<void> heavy() async {
    await play(HapticPreset.heavyImpact);
  }

  /// Triggers a delicate click effect.
  static Future<void> click() async {
    await play(HapticPreset.selection);
  }

  // ───────────────────────── GAME EVENTS (BACKWARD COMPATIBLE) ─────────────────────────

  /// Event feedback for successful operations.
  static Future<void> success() async {
    await _vibrate(pattern: [0, 40, 30, 80], intensities: [0, 100, 0, 200]);
  }

  /// Event feedback for failed operations or errors.
  static Future<void> error() async {
    await _vibrate(
      pattern: [0, 80, 40, 80, 40, 120],
      intensities: [0, 150, 0, 150, 0, 255],
    );
  }

  /// Rising event feedback for level completions or dynamic progression.
  static Future<void> levelUp() async {
    await _vibrate(
      pattern: [0, 50, 40, 100, 40, 150, 30, 200],
      intensities: [0, 60, 0, 120, 0, 180, 0, 255],
    );
  }

  /// Rhythmic bounce feedback for coin collect items.
  static Future<void> coin() async {
    await _vibrate(pattern: [0, 30, 20, 60], intensities: [0, 120, 0, 255]);
  }
}
