import 'package:flutter/material.dart';
import 'package:helper_animation/helper_animation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Helper Animation Sound Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SoundDemoPage(),
    );
  }
}

class SoundDemoPage extends StatefulWidget {
  const SoundDemoPage({super.key});

  @override
  State<SoundDemoPage> createState() => _SoundDemoPageState();
}

class _SoundDemoPageState extends State<SoundDemoPage> {
  final SoundManager soundManager = SoundManager();
  double _masterVolume = 1.0;
  double _bgmVolume = 1.0;
  double _sfxVolume = 1.0;
  double _clickVolume = 1.0;
  double _notificationVolume = 1.0;

  @override
  void initState() {
    super.initState();
    // Initialize volumes
    _updateVolumes();
  }

  void _updateVolumes() {
    soundManager.setBgmVolume(_bgmVolume);
    soundManager.setSfxVolume(_sfxVolume);
    soundManager.setClickVolume(_clickVolume);
    soundManager.setNotificationVolume(_notificationVolume);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sound Manager Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Volume Controls Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Volume Controls',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    _buildVolumeSlider(
                      'Master Volume',
                      _masterVolume,
                      (value) {
                        setState(() {
                          _masterVolume = value;
                          _bgmVolume = value;
                          _sfxVolume = value;
                          _clickVolume = value;
                          _notificationVolume = value;
                        });
                        soundManager.setMasterVolume(value);
                      },
                    ),
                    _buildVolumeSlider(
                      'BGM Volume',
                      _bgmVolume,
                      (value) {
                        setState(() => _bgmVolume = value);
                        soundManager.setBgmVolume(value);
                      },
                    ),
                    _buildVolumeSlider(
                      'SFX Volume',
                      _sfxVolume,
                      (value) {
                        setState(() => _sfxVolume = value);
                        soundManager.setSfxVolume(value);
                      },
                    ),
                    _buildVolumeSlider(
                      'Click Volume',
                      _clickVolume,
                      (value) {
                        setState(() => _clickVolume = value);
                        soundManager.setClickVolume(value);
                      },
                    ),
                    _buildVolumeSlider(
                      'Notification Volume',
                      _notificationVolume,
                      (value) {
                        setState(() => _notificationVolume = value);
                        soundManager.setNotificationVolume(value);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // BGM Controls Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Background Music (BGM)',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Current BGM: ${soundManager.currentBgm ?? "None"}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton(
                          onPressed: () => soundManager
                              .playBgmFromEnum(BgmSound.childrenLearning),
                          child: const Text('Children Learning'),
                        ),
                        ElevatedButton(
                          onPressed: () => soundManager
                              .playBgmFromEnum(BgmSound.cozyLofiFireside),
                          child: const Text('Cozy Lofi'),
                        ),
                        ElevatedButton(
                          onPressed: () =>
                              soundManager.playBgmFromEnum(BgmSound.curious),
                          child: const Text('Curious'),
                        ),
                        ElevatedButton(
                          onPressed: () => soundManager
                              .playBgmFromEnum(BgmSound.birdsSinging),
                          child: const Text('Birds Singing'),
                        ),
                        ElevatedButton(
                          onPressed: () => soundManager.pauseBgm(),
                          child: const Text('Pause BGM'),
                        ),
                        ElevatedButton(
                          onPressed: () => soundManager.resumeBgm(),
                          child: const Text('Resume BGM'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            soundManager.stopBgm();
                            setState(
                                () {}); // Refresh to update current BGM display
                          },
                          child: const Text('Stop BGM'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Click Sounds Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Click Sounds',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton(
                          onPressed: () => soundManager
                              .playClickFromEnum(ClickSound.gameClick),
                          child: const Text('Game Click'),
                        ),
                        ElevatedButton(
                          onPressed: () => soundManager
                              .playClickFromEnum(ClickSound.selectClick),
                          child: const Text('Select Click'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Utility Functions Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Utility Functions',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            soundManager.stopAllSounds();
                            setState(
                                () {}); // Refresh to update current BGM display
                          },
                          child: const Text('Stop All Sounds'),
                        ),
                        ElevatedButton(
                          onPressed: () => soundManager.clearCache(),
                          child: const Text('Clear Cache'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            // Preload some sounds for better performance
                            await soundManager
                                .preloadBgmFromEnum(BgmSound.childrenLearning);
                            await soundManager
                                .preloadBgmFromEnum(BgmSound.cozyLofiFireside);
                            await soundManager
                                .preloadClickFromEnum(ClickSound.gameClick);
                            await soundManager
                                .preloadClickFromEnum(ClickSound.selectClick);

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Sounds preloaded successfully!'),
                                ),
                              );
                            }
                          },
                          child: const Text('Preload Sounds'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Instructions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instructions',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Use enum-based methods for easy sound loading:\n'
                      '  - soundManager.playBgmFromEnum(BgmSound.childrenLearning)\n'
                      '  - soundManager.playClickFromEnum(ClickSound.gameClick)\n'
                      '• Available BGM sounds: childrenLearning, cozyLofiFireside, curious, birdsSinging\n'
                      '• Available Click sounds: gameClick, selectClick\n'
                      '• Supported formats: MP3, WAV, OGG, M4A\n'
                      '• Use SoundManager() singleton to access all sound functions\n'
                      '• The library automatically handles asset paths with "packages/helper_animation/" prefix\n'
                      '• Add new sounds to sound_enums.dart for easy access',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeSlider(
    String label,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${(value * 100).round()}%'),
        Slider(
          value: value,
          onChanged: onChanged,
          min: 0.0,
          max: 1.0,
          divisions: 10,
        ),
      ],
    );
  }
}
