import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:helper_animation/sound_manager/sound_controller.dart';
import 'package:helper_animation/sound_manager/sound_manager.dart'
    as sound_manager;
import 'package:helper_animation/sound_manager/sound_enums.dart';
import 'package:helper_animation/sound_manager/sound_paths.dart';
import 'dart:async';
/* ──────────────────────────────────────────────────────────────
 *  >>> paste di sini kode SoundController, SoundManager,
 *  >>> SoundExtension, SoundRouteObserver, enum-enum, dll.
 *  (yang sudah Anda punya persis se=erti sebelumnya)
 * ────────────────────────────────────────────────────────────── */

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlameAudio.audioCache.prefix = '';
  // Optional: preload all assets to avoid first click delay
  await FlameAudio.audioCache.loadAll(
    SoundPaths.instance.getAllSoundPaths(),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ducking Test',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.light,
      ),
      home: const DuckingTestPage(),
    );
  }
}

/* ────────────────────────── HOME ────────────────────────── */

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _masterVol = 1.0;
  double _bgmVol = 0.4;
  double _sfxVol = 1.0;
  bool _muted = false;
  bool _bgmPlaying = true;

  final _bgmController = SoundController(
    autoPlay: true,
    volume: 0.4,
    loop: true,
  );

  @override
  void dispose() {
    _bgmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sound Demo'),
        actions: [
          IconButton(
            icon: Icon(_muted ? Icons.volume_off : Icons.volume_up),
            onPressed: () async {
              setState(() => _muted = !_muted);
              await sound_manager.SoundManager.instance.setMuted(_muted);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMasterVolumeSection(),
          const Divider(height: 32),
          _buildBGMSection(),
          const Divider(height: 32),
          _buildSFXSection(),
          const Divider(height: 32),
          _buildNavigationSection(context),
        ],
      ),
    ).addBGM(
      sound: BGMSound.birdsSinging,
      controller: _bgmController,
      global: true,
      volume: _bgmVol,
    );
  }

  Widget _buildMasterVolumeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Master Volume',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.volume_up),
            Expanded(
              child: Slider(
                value: _masterVol,
                onChanged: (v) async {
                  setState(() => _masterVol = v);
                  await sound_manager.SoundManager.instance.setMasterVolume(v);
                },
              ),
            ),
            SizedBox(
              width: 50,
              child: Text(
                '${(_masterVol * 100).round()}%',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBGMSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Background Music',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              icon: Icon(_bgmPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: () {
                setState(() => _bgmPlaying = !_bgmPlaying);
                if (_bgmPlaying) {
                  _bgmController.play();
                } else {
                  _bgmController.pause();
                }
              },
            ),
            Expanded(
              child: Slider(
                value: _bgmVol,
                onChanged: (v) {
                  setState(() => _bgmVol = v);
                  _bgmController.setVolume(v);
                },
              ),
            ),
            SizedBox(
              width: 50,
              child: Text(
                '${(_bgmVol * 100).round()}%',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                _bgmController.playSound(
                  category: SoundCategory.bgm,
                  sound: BGMSound.birdsSinging,
                  volume: _bgmVol,
                );
              },
              child: const Text('Birds BGM'),
            ),
            ElevatedButton(
              onPressed: () {
                _bgmController.playSound(
                  category: SoundCategory.bgm,
                  sound: BGMSound.fluteMusic,
                  volume: _bgmVol,
                );
              },
              child: const Text('Flute BGM'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSFXSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sound Effects',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.music_note),
            Expanded(
              child: Slider(
                value: _sfxVol,
                onChanged: (v) => setState(() => _sfxVol = v),
              ),
            ),
            SizedBox(
              width: 50,
              child: Text(
                '${(_sfxVol * 100).round()}%',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ElevatedButton(
              onPressed: () => FlameAudio.play(
                SoundPaths.instance.getSoundPath(
                  SoundCategory.sfx,
                  SFXSound.airWoosh,
                )!,
                volume: _sfxVol,
              ),
              child: const Text('Air Woosh'),
            ).addSound(sound: ClickSound.selectClick),
            ElevatedButton(
              onPressed: () => FlameAudio.play(
                SoundPaths.instance.getSoundPath(
                  SoundCategory.notification,
                  NotificationSound.retroArcade,
                )!,
                volume: _sfxVol,
              ),
              child: const Text('Retro Arcade'),
            ).addSound(sound: ClickSound.selectClick),
            ElevatedButton(
              onPressed: () => FlameAudio.play(
                SoundPaths.instance.getSoundPath(
                  SoundCategory.notification,
                  NotificationSound.mysteryAlert,
                )!,
                volume: _sfxVol,
              ),
              child: const Text('Mystery Alert'),
            ).addSound(sound: ClickSound.selectClick),
          ],
        ),
      ],
    );
  }

  Widget _buildNavigationSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Navigation Test',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Center(
          child: FilledButton.icon(
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Go to Second Page'),
            onPressed: () => Navigator.pushNamed(context, '/second'),
          ).addSound(),
        ),
      ],
    );
  }
}

/* ─────────────────────── SECOND PAGE ─────────────────────── */

class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  double _sfxVol = 1.0;
  bool _rapidTest = false;
  Timer? _rapidTimer;

  @override
  void dispose() {
    _rapidTimer?.cancel();
    super.dispose();
  }

  void _startRapidTest() {
    if (_rapidTest) {
      _rapidTimer?.cancel();
      setState(() => _rapidTest = false);
      return;
    }

    setState(() => _rapidTest = true);

    // Play sounds rapidly every 200ms to test ducking behavior
    _rapidTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (!_rapidTest) return;

      // Just play a single type of sound for the rapid test
      FlameAudio.play(
        SoundPaths.instance.getSoundPath(
          SoundCategory.notification,
          NotificationSound.retroArcade,
        )!,
        volume: _sfxVol,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sound Ducking Test'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ).addSound(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sound Ducking Test Page',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• This page has its own BGM (Flute Music)\n'
                    '• Tap any sound button to test ducking\n'
                    '• BGM volume automatically reduces when other sounds play\n'
                    '• Try the Rapid Test to see how ducking handles multiple sounds',
                    style: TextStyle(height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Volume Control
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SFX Volume',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.volume_up),
                  Expanded(
                    child: Slider(
                      value: _sfxVol,
                      onChanged: (v) => setState(() => _sfxVol = v),
                    ),
                  ),
                  SizedBox(
                    width: 50,
                    child: Text(
                      '${(_sfxVol * 100).round()}%',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Individual Sound Buttons
          const Text(
            'Tap Any Sound to Test Ducking',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.air),
                    const SizedBox(width: 8),
                    const Text('Air Woosh'),
                  ],
                ),
              ).addSound(
                category: SoundCategory.sfx,
                sound: SFXSound.airWoosh,
                volume: _sfxVol,
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.games),
                    const SizedBox(width: 8),
                    const Text('Retro Arcade'),
                  ],
                ),
              ).addSound(
                category: SoundCategory.notification,
                sound: NotificationSound.retroArcade,
                volume: _sfxVol,
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.notification_important),
                    const SizedBox(width: 8),
                    const Text('Mystery Alert'),
                  ],
                ),
              ).addSound(
                category: SoundCategory.notification,
                sound: NotificationSound.mysteryAlert,
                volume: _sfxVol,
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Rapid Test Section
          const Text(
            'Rapid Sound Test',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _startRapidTest,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _rapidTest
                    ? Colors.red
                    : Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _rapidTest ? Icons.stop : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _rapidTest ? 'Stop Rapid Test' : 'Start Rapid Test',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          if (_rapidTest) ...[
            const SizedBox(height: 8),
            const Text(
              'Playing random sounds every 200ms\n'
              'Watch how the BGM volume stays reduced',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red),
            ),
          ],
        ],
      ),
    ).addBGM(
      sound: BGMSound.fluteMusic,
      volume: 0.5,
      loop: true,
      route: '/second',
    );
  }
}

class DuckingTestPage extends StatefulWidget {
  const DuckingTestPage({super.key});

  @override
  State<DuckingTestPage> createState() => _DuckingTestPageState();
}

class _DuckingTestPageState extends State<DuckingTestPage> {
  bool _bgmPlaying = true;
  double _bgmVolume = 0.8;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ducking Test'),
        actions: [
          // BGM Play/Pause
          IconButton(
            icon: Icon(_bgmPlaying ? Icons.music_note : Icons.music_off),
            onPressed: () => setState(() => _bgmPlaying = !_bgmPlaying),
          ),
        ],
      ),
      body: Column(
        children: [
          // Info Card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BGM Volume Test',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Current BGM Volume: ${(_bgmVolume * 100).round()}%\n'
                    '• Ducking will reduce to 10%\n'
                    '• Tap any sound to test\n'
                    '• Watch BGM volume change',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),

          // Sound Buttons
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildSoundButton(
                  'Air Woosh',
                  Icons.air,
                  Colors.blue,
                  SoundCategory.sfx,
                  SFXSound.airWoosh,
                ),
                _buildSoundButton(
                  'Retro Arcade',
                  Icons.games,
                  Colors.purple,
                  SoundCategory.notification,
                  NotificationSound.retroArcade,
                ),
                _buildSoundButton(
                  'Mystery Alert',
                  Icons.notification_important,
                  Colors.orange,
                  SoundCategory.notification,
                  NotificationSound.mysteryAlert,
                ),
                _buildSoundButton(
                  'Game Click',
                  Icons.mouse,
                  Colors.green,
                  SoundCategory.clickEvent,
                  ClickSound.gameClick,
                ),
              ],
            ),
          ),

          // Volume Slider
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BGM Volume',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.volume_up),
                    Expanded(
                      child: Slider(
                        value: _bgmVolume,
                        onChanged: (v) => setState(() => _bgmVolume = v),
                      ),
                    ),
                    SizedBox(
                      width: 50,
                      child: Text(
                        '${(_bgmVolume * 100).round()}%',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).addBGM(
      sound: BGMSound.birdsSinging,
      volume: _bgmVolume,
      autoPlay: _bgmPlaying,
    );
  }

  Widget _buildSoundButton(
    String label,
    IconData icon,
    Color color,
    SoundCategory category,
    dynamic sound,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Tap to play',
              style: TextStyle(
                color: color.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    ).addSound(
      category: category,
      sound: sound,
    );
  }
}

class _WidgetSoundData {
  final SoundController controller;
  final bool isExternalController;
  final SoundCategory? category;
  final dynamic sound;

  _WidgetSoundData({
    required this.controller,
    this.isExternalController = false,
    this.category,
    this.sound,
  });
}

class SoundRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name != null) {
      sound_manager.SoundManager.instance.setCurrentRoute(route.settings.name!);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute?.settings.name != null) {
      sound_manager.SoundManager.instance
          .setCurrentRoute(previousRoute!.settings.name!);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute?.settings.name != null) {
      sound_manager.SoundManager.instance
          .setCurrentRoute(newRoute!.settings.name!);
    }
  }
}
