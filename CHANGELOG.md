## 1.1.0

- **Hybrid Haptics Engine**: Combined Flutter SDK's native, crisp system-level haptics (`HapticFeedback`) with the `vibration` plugin's heavy-duty amplitude controls for a flawless cross-platform feel.
- **Custom Haptic Pattern Studio**: Added the `HapticPattern` object supporting multi-pulse timings and customized amplitude configurations.
- **Storage Driver Abstraction**: Added the `HapticStorage` interface, allowing developers to swap out the default `SharedPreferences` for Hive, Isar, or secure key-value databases.
- **Tactile Presets Board**: Pre-configured 12 highly requested game-style haptic effects, including `heartbeat`, `explosion`, `laser`, `collision`, and standard `selection`.
- **Full Test Suite Coverage**: Implemented rigorous unit and mock tests using subclassed platform-interface interfaces, validating storage fallback safety and execution calls.
- **Stunning Demo App**: Shipped a modern, responsive showcase application featuring visual preset boards, custom sliders, and real-time integration code exporters.

## 1.0.1

- Initial release
- Game-style vibration system
- Success, error, level-up patterns
- Toggle support