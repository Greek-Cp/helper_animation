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
      title: 'BGM Transition Test',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.light,
      ),
      // Add route observer for BGM transitions
      navigatorObservers: [
        sound_manager.SoundRouteObserver(),
      ],
      // Define named routes
      routes: {
        '/': (context) => const FirstPage(),
        '/second': (context) => const SecondPage(),
      },
    );
  }
}

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  bool _bgmPlaying = true;
  double _bgmVolume = 0.8;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('First Page - Birds BGM'),
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
                    'BGM: Birds Singing',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Current BGM Volume: ${(_bgmVolume * 100).round()}%\n'
                    '• Tap the button below to go to second page\n'
                    '• Listen to the smooth BGM transition',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),

          // Navigation Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.icon(
              icon: const Icon(Icons.music_note),
              label: const Text('Go to Flute Music Page'),
              onPressed: () => Navigator.pushNamed(context, '/second'),
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
      route: '/',
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

class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  bool _bgmPlaying = true;
  double _bgmVolume = 0.8;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Page - Flute BGM'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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
                    'BGM: Flute Music',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Current BGM Volume: ${(_bgmVolume * 100).round()}%\n'
                    '• Press back to return to first page\n'
                    '• Listen to the smooth BGM transition',
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
      sound: BGMSound.fluteMusic,
      volume: _bgmVolume,
      autoPlay: _bgmPlaying,
      route: '/second',
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
