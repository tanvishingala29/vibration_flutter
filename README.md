# Vibration Flutter Pro 🎮

[![Pub Version](https://img.shields.io/pub/v/vibration_flutter?color=blue&style=flat-square)](https://pub.dev/packages/vibration_flutter)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](https://opensource.org/licenses/MIT)
[![Platform Support](https://img.shields.io/badge/platform-android%20%7C%20ios%20%7C%20web%20%7C%20macos-lightgrey?style=flat-square)](#)

A high-performance, hybrid vibration and haptic feedback system for Flutter apps and games. It blends native system-level haptics (crisp, zero-latency via Flutter SDK) with custom timing patterns and customized amplitudes (via the `vibration` plugin) to deliver the ultimate cross-platform tactile feel.

---

## ⚡ Key Features

* **Hybrid Haptic Engine**: Automatically selects the most optimized route—native, crisp micro-impacts for UI selections, or deep, rich rumble patterns for gaming events.
* **Predefined Tactile Board**: 12 pre-calibrated presets including **UI Feedbacks** (`selection`, `lightImpact`, `mediumImpact`, `heavyImpact`) and **Game Events** (`success`, `error`, `levelUp`, `coin`, `heartbeat`, `explosion`, `laser`, `collision`).
* **Custom Pattern Studio**: Design complex timed pulse sequences with customized millisecond durations and individual vibration intensities (`1` to `255`).
* **Storage Driver Abstraction**: Completely decouple how haptic preferences are saved. Easily swap out the default `SharedPreferences` engine for `Hive`, `Isar`, `SecureStorage`, or in-memory configs.
* **Global Muting Toggle**: Turn haptic response on or off globally across your application with immediate state persistence.
* **Safe Platform Fallback**: Built-in exception handlers and mockable platform-interfaces ensure tests run flawlessly without breaking on emulators or desktop architectures.

---

## 🚀 Installation

Add `vibration_flutter` to your `pubspec.yaml` dependencies:

```yaml
dependencies:
  vibration_flutter: ^1.1.0
```

### 📱 Platform Configuration

#### Android Setup
Add the `VIBRATE` permission to your `AndroidManifest.xml` (located under `android/app/src/main/AndroidManifest.xml`):

```xml
<uses-permission android:name="android.permission.VIBRATE"/>
```

#### iOS Setup
No configuration is required! Standard UI impacts work out of the box, and custom patterns fall back gracefully on devices lacking custom haptic motors.

---

## 📖 Usage Guide

### 1. Initialization

Initialize the haptic manager during your application's bootstrap phase (typically inside `main()`):

```dart
import 'package:flutter/material.dart';
import 'package:vibration_flutter/vibration_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize with default SharedPreferences persistence
  await HapticService.init();

  runApp(const MyApp());
}
```

---

### 2. Playing Presets

Trigger beautifully balanced pre-configured tactile events with a single line of code:

```dart
// Standard UI Click Selection
HapticService.play(HapticPreset.selection);

// Standard UI Light/Medium/Heavy impacts
HapticService.play(HapticPreset.lightImpact);
HapticService.play(HapticPreset.heavyImpact);

// Rhythmic Gaming Events
HapticService.play(HapticPreset.success);     // Double energetic tap
HapticService.play(HapticPreset.levelUp);     // Rising progression rumble
HapticService.play(HapticPreset.coin);        // Bright, crisp item collection
HapticService.play(HapticPreset.heartbeat);   // Double-pulse cardiac rhythm
HapticService.play(HapticPreset.explosion);   // Decaying strong rumble
HapticService.play(HapticPreset.laser);       // High-frequency rapid burst
HapticService.play(HapticPreset.collision);   // Sudden high-intensity shock
```

*Note: The legacy backward-compatible helper methods like `HapticService.light()`, `HapticService.success()`, etc., are still fully supported.*

---

### 3. Custom Timing & Amplitude Studio

Compile custom vibration sequences. Patterns use alternating pause/pulse durations, combined with precise vibration amplitudes (intensities ranging from `1` to `255`):

```dart
// Define the timings and active intensities
const customizedImpact = HapticPattern(
  timings: [0, 150, 80, 250],        // Wait 0ms -> Vibrate 150ms -> Wait 80ms -> Vibrate 250ms
  amplitudes: [0, 120, 0, 255],      // Pulse 1 intensity = 120, Pulse 2 intensity = 255 (Full Power)
);

// Trigger the custom pattern
await HapticService.playPattern(customizedImpact);
```

---

### 4. Global Enable/Disable Toggle

Easily expose a haptics toggling switch in your application settings. The status is saved automatically:

```dart
// Fetch the current setting (true/false)
bool isVibrationOn = HapticService.isEnabled;

// Toggle setting (persists in storage automatically)
await HapticService.toggle();

// Or explicitly configure state
await HapticService.setEnabled(false); // Mutes all haptic outputs
```

---

### 5. Advanced: Custom Database Persistence (Hive, SecureStorage)

Pro-level architectures avoid polluting SharedPreferences. Simply implement the `HapticStorage` interface to hook up your own state management database:

```dart
import 'package:hive/hive.dart';
import 'package:vibration_flutter/vibration_flutter.dart';

class HiveHapticStorage implements HapticStorage {
  final _boxName = 'settings';
  final _keyName = 'is_haptic_enabled';

  @override
  Future<bool> getEnabled() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_keyName, defaultValue: true) as bool;
  }

  @override
  Future<void> setEnabled(bool enabled) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_keyName, enabled);
  }
}

// Inject your custom adapter during initialization
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await HapticService.init(
    storage: HiveHapticStorage(),
  );

  runApp(const MyApp());
}
```

---

## 🎨 Interactive Demonstration Application

The repository contains a gorgeous, game-inspired dark-mode showcase application under the `example/` folder. It lets you:
* Test all **12 haptic presets** side-by-side with tactile action cards.
* Design and test patterns live with five **interactive sliders** (Durations & Amplitudes).
* Copy clean, production-ready Dart code directly from the **Real-Time Integration Code Exporter**.

To launch the example app:
```bash
cd example
flutter run
```

---

## 🧪 Testing Support

`vibration_flutter` includes native mocking support for testing suites, preventing device platform channels from throwing uncaught errors on CI servers or local testing machines:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:vibration_flutter/vibration_flutter.dart';
import 'package:vibration_platform_interface/vibration_platform_interface.dart';

// Create a custom mock for the Vibration plugin
class MockVibrationPlatform extends VibrationPlatform {
  @override
  Future<bool> hasVibrator() async => true;
  
  @override
  Future<void> vibrate({ ... }) async {
    // Record calls for validation
  }
}

void main() {
  setUp(() {
    VibrationPlatform.instance = MockVibrationPlatform();
  });
}
```

---

## 👨‍💻 Author

**Tanvi Shingala**
* 📧 Email: [tanvishingala29@gmail.com](mailto:tanvishingala29@gmail.com)
* 💼 Flutter App Developer
