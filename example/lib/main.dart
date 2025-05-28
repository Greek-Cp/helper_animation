import 'package:flutter/material.dart';
import 'package:helper_animation/sound_manager/bgm_manager.dart';
import 'package:helper_animation/sound_manager/sound_enums.dart';

/// Inisialisasi helper animation (opsional, untuk preload)
Future<void> initHelperAnimation() async {
  try {
    debugPrint('[INIT] Starting helper animation initialization...');

    // Preload semua sound files
    await BgmManager.instance.preloadAll();

    debugPrint('[INIT] Helper animation initialized successfully');
  } catch (e) {
    debugPrint('[INIT] Error initializing helper animation: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi helper animation
  await initHelperAnimation();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Helper Animation Example',
      navigatorObservers: [routeObserver], // Penting untuk BGM navigation
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Helper Animation Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {},
              child: const Text('Click Me'),
            ).addSound(ClickSound.gameClick, SoundType.click),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Debug BGM state
                BgmManager.instance.debugState();
                BgmManager.instance.checkPlayerState();
              },
              child: const Text('Debug BGM State'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SecondPage()),
                );
              },
              child: const Text('Go to Page with BGM'),
            ),
          ],
        ),
      ),
    ).addBGMGlobal([BGMSound.birdsSinging, BGMSound.fluteMusic]);
  }
}

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page with Specific BGM'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('This page has specific BGM'),
            Text('BGM will change when you enter this page'),
          ],
        ),
      ),
    ).addBGM(BGMSound.fluteMusic);
  }
}
