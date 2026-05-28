// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration_flutter/vibration_flutter.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the professional Haptic Service (uses default SharedPreferences storage)
  await HapticService.init();

  // Run the demonstration application
  runApp(const VibrationDemoApp());
}

class VibrationDemoApp extends StatelessWidget {
  const VibrationDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vibration Flutter Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F1017),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1), // Cyber Purple/Indigo
          secondary: Color(0xFF06B6D4), // Cyan Glow
          surface: Color(0xFF1E1F2E),
          background: Color(0xFF0F1017),
        ),
        useMaterial3: true,
      ),
      home: const VibrationLabScreen(),
    );
  }
}

class VibrationLabScreen extends StatefulWidget {
  const VibrationLabScreen({super.key});

  @override
  State<VibrationLabScreen> createState() => _VibrationLabScreenState();
}

class _VibrationLabScreenState extends State<VibrationLabScreen> {
  // Toggle status
  bool _hapticsEnabled = HapticService.isEnabled;

  // Custom Pattern Studio Parameters
  double _pulse1Duration = 120.0;
  double _pulse1Intensity = 180.0;
  double _pauseDuration = 80.0;
  double _pulse2Duration = 240.0;
  double _pulse2Intensity = 255.0;

  // Copy status feedback
  bool _codeCopied = false;

  void _toggleService() async {
    await HapticService.toggle();
    setState(() {
      _hapticsEnabled = HapticService.isEnabled;
    });
    // Trigger a light haptic to confirm toggling
    if (_hapticsEnabled) {
      await HapticService.play(HapticPreset.selection);
    }
  }

  // Helper to build action/preset buttons
  Widget _buildPresetCard({
    required String title,
    required IconData icon,
    required Color accentColor,
    required HapticPreset preset,
    required String subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.surface.withOpacity(0.8),
            Theme.of(context).colorScheme.surface.withOpacity(0.4),
          ],
        ),
        border: Border.all(
          color: accentColor.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            await HapticService.play(preset);
          },
          splashColor: accentColor.withOpacity(0.15),
          highlightColor: accentColor.withOpacity(0.08),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withOpacity(0.2),
                        blurRadius: 12,
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: accentColor,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Get current custom pattern object based on slider states
  HapticPattern _getCustomPattern() {
    return HapticPattern(
      timings: [
        0,
        _pulse1Duration.round(),
        _pauseDuration.round(),
        _pulse2Duration.round(),
      ],
      amplitudes: [
        0,
        _pulse1Intensity.round(),
        0,
        _pulse2Intensity.round(),
      ],
    );
  }

  // Play the custom slider pattern
  void _playCustomPattern() async {
    await HapticService.playPattern(_getCustomPattern());
  }

  // Generate real-time responsive code snippet for UI display
  String _generateCodeSnippet() {
    return '''
// 1. Define custom game vibration profile
const customPattern = HapticPattern(
  timings: [0, ${_pulse1Duration.round()}, ${_pauseDuration.round()}, ${_pulse2Duration.round()}],
  amplitudes: [0, ${_pulse1Intensity.round()}, 0, ${_pulse2Intensity.round()}],
);

// 2. Play pattern dynamically
await HapticService.playPattern(customPattern);''';
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _generateCodeSnippet()));
    setState(() {
      _codeCopied = true;
    });
    // Trigger feedback click
    HapticService.play(HapticPreset.selection);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _codeCopied = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final customPatternCode = _generateCodeSnippet();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF141522),
              Color(0xFF0A0B10),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER WITH METADATA
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF6366F1).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.bolt, color: Color(0xFF6366F1), size: 12),
                                SizedBox(width: 4),
                                Text(
                                  'PRO LEVEL UTILITY',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.0,
                                    color: Color(0xFF6366F1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Vibration Flutter',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      // POWER TOGGLE BUTTON
                      GestureDetector(
                        onTap: _toggleService,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: _hapticsEnabled
                                ? const LinearGradient(
                                    colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
                                  )
                                : null,
                            color: _hapticsEnabled ? null : const Color(0xFF2E303F),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: _hapticsEnabled
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF06B6D4).withOpacity(0.4),
                                      blurRadius: 15,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _hapticsEnabled ? Icons.vibration : Icons.portable_wifi_off_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _hapticsEnabled ? 'ACTIVE' : 'MUTED',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 0.5,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // SYSTEM FEEDBACK PRESETS
                  const Text(
                    'System Haptic Presets',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.25,
                    children: [
                      _buildPresetCard(
                        title: 'Selection',
                        icon: Icons.ads_click,
                        accentColor: const Color(0xFF10B981),
                        preset: HapticPreset.selection,
                        subtitle: 'Crisp micro-click',
                      ),
                      _buildPresetCard(
                        title: 'Light Impact',
                        icon: Icons.touch_app_outlined,
                        accentColor: const Color(0xFF06B6D4),
                        preset: HapticPreset.lightImpact,
                        subtitle: 'Subtle notification',
                      ),
                      _buildPresetCard(
                        title: 'Medium Impact',
                        icon: Icons.touch_app,
                        accentColor: const Color(0xFFF59E0B),
                        preset: HapticPreset.mediumImpact,
                        subtitle: 'Standard confirmation',
                      ),
                      _buildPresetCard(
                        title: 'Heavy Impact',
                        icon: Icons.fingerprint_rounded,
                        accentColor: const Color(0xFFEF4444),
                        preset: HapticPreset.heavyImpact,
                        subtitle: 'Alert/Warning pulse',
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // INTERACTIVE GAME EVENT PRESETS
                  const Text(
                    'Gaming Event Presets',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.25,
                    children: [
                      _buildPresetCard(
                        title: 'Success',
                        icon: Icons.sports_esports_rounded,
                        accentColor: const Color(0xFF10B981),
                        preset: HapticPreset.success,
                        subtitle: 'Double energetic pulse',
                      ),
                      _buildPresetCard(
                        title: 'Level Up',
                        icon: Icons.military_tech_rounded,
                        accentColor: const Color(0xFF8B5CF6),
                        preset: HapticPreset.levelUp,
                        subtitle: 'Rising dynamic rhythm',
                      ),
                      _buildPresetCard(
                        title: 'Collect Coin',
                        icon: Icons.monetization_on,
                        accentColor: const Color(0xFFFFD700),
                        preset: HapticPreset.coin,
                        subtitle: 'Bright high-freq tap',
                      ),
                      _buildPresetCard(
                        title: 'Collision Hit',
                        icon: Icons.flash_on_rounded,
                        accentColor: const Color(0xFFF97316),
                        preset: HapticPreset.collision,
                        subtitle: 'Sudden sharp shock',
                      ),
                      _buildPresetCard(
                        title: 'Heartbeat',
                        icon: Icons.favorite_rounded,
                        accentColor: const Color(0xFFEC4899),
                        preset: HapticPreset.heartbeat,
                        subtitle: 'Double low-freq cycle',
                      ),
                      _buildPresetCard(
                        title: 'Explosion',
                        icon: Icons.brightness_high_outlined,
                        accentColor: const Color(0xFFEF4444),
                        preset: HapticPreset.explosion,
                        subtitle: 'Decaying heavy rumble',
                      ),
                      _buildPresetCard(
                        title: 'Laser Fire',
                        icon: Icons.gps_fixed_outlined,
                        accentColor: const Color(0xFF06B6D4),
                        preset: HapticPreset.laser,
                        subtitle: 'Rapid high-pitch burst',
                      ),
                      _buildPresetCard(
                        title: 'Critical Failure',
                        icon: Icons.cancel_presentation_rounded,
                        accentColor: const Color(0xFFEF4444),
                        preset: HapticPreset.error,
                        subtitle: 'Triple warning pulse',
                      ),
                    ],
                  ),
                  const SizedBox(height: 35),

                  // INTERACTIVE CUSTOM PATTERN STUDIO
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: const Color(0xFF181A25),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFF6366F1).withOpacity(0.15),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.02),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.tune_rounded,
                                color: Color(0xFF6366F1),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Custom Pattern Studio',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Design, compile, and instantly test custom multi-pulse vibrations using timed durations and intensities.',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // SLIDER 1: PULSE 1 DURATION
                        _buildSliderRow(
                          title: 'Pulse 1 Duration',
                          value: _pulse1Duration,
                          min: 10,
                          max: 500,
                          suffix: 'ms',
                          activeColor: const Color(0xFF6366F1),
                          onChanged: (val) => setState(() => _pulse1Duration = val),
                        ),
                        const SizedBox(height: 16),

                        // SLIDER 2: PULSE 1 INTENSITY
                        _buildSliderRow(
                          title: 'Pulse 1 Amplitude',
                          value: _pulse1Intensity,
                          min: 10,
                          max: 255,
                          suffix: '/255',
                          activeColor: const Color(0xFF6366F1),
                          onChanged: (val) => setState(() => _pulse1Intensity = val),
                        ),
                        const SizedBox(height: 16),

                        // SLIDER 3: PAUSE DURATION
                        _buildSliderRow(
                          title: 'Inter-pulse Delay',
                          value: _pauseDuration,
                          min: 10,
                          max: 500,
                          suffix: 'ms',
                          activeColor: const Color(0xFF9CA3AF),
                          onChanged: (val) => setState(() => _pauseDuration = val),
                        ),
                        const SizedBox(height: 16),

                        // SLIDER 4: PULSE 2 DURATION
                        _buildSliderRow(
                          title: 'Pulse 2 Duration',
                          value: _pulse2Duration,
                          min: 10,
                          max: 500,
                          suffix: 'ms',
                          activeColor: const Color(0xFF06B6D4),
                          onChanged: (val) => setState(() => _pulse2Duration = val),
                        ),
                        const SizedBox(height: 16),

                        // SLIDER 5: PULSE 2 INTENSITY
                        _buildSliderRow(
                          title: 'Pulse 2 Amplitude',
                          value: _pulse2Intensity,
                          min: 10,
                          max: 255,
                          suffix: '/255',
                          activeColor: const Color(0xFF06B6D4),
                          onChanged: (val) => setState(() => _pulse2Intensity = val),
                        ),
                        const SizedBox(height: 26),

                        // RUN BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: _playCustomPattern,
                            icon: const Icon(Icons.play_arrow_rounded, size: 24),
                            label: const Text(
                              'TRIGGER CUSTOM PATTERN',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                                fontSize: 13,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              foregroundColor: Colors.white,
                              elevation: 8,
                              shadowColor: const Color(0xFF6366F1).withOpacity(0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // EXPORT CODE Snippet CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A0C16),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.grey.shade800,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.code_rounded, color: Colors.grey, size: 20),
                                SizedBox(width: 10),
                                Text(
                                  'Real-Time Integration Code',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: _copyToClipboard,
                              icon: Icon(
                                _codeCopied ? Icons.check_circle_outline_rounded : Icons.copy_rounded,
                                color: _codeCopied ? const Color(0xFF10B981) : Colors.grey,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            customPatternCode,
                            style: const TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 11,
                              color: Color(0xFFA5B4FC), // light blue code styling
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliderRow({
    required String title,
    required double value,
    required double min,
    required double max,
    required String suffix,
    required Color activeColor,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Text(
              '${value.round()}$suffix',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: activeColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: activeColor,
            inactiveTrackColor: Colors.grey.shade800,
            thumbColor: Colors.white,
            overlayColor: activeColor.withOpacity(0.12),
            valueIndicatorColor: activeColor,
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
