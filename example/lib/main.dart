import 'package:flutter/material.dart';
import 'package:helper_animation/helper_animation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sound Manager Demo ${AppSizeMinigame.borderRadiusGlobalMinigame}',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Tambahkan SoundRouteObserver untuk mengelola BGM berdasarkan rute
      navigatorObservers: [SoundRouteObserver()],
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/detail': (context) => const DetailPage(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late SoundController bgmController;
  late SoundController buttonController;

  @override
  void initState() {
    super.initState();

    // // Inisialisasi SoundController untuk BGM
    // bgmController = SoundController(
    //   autoPlay: true,
    //   volume: 0.5,
    //   loop: true,
    // );

    // // Inisialisasi SoundController untuk button sound
    // buttonController = SoundController(
    //   volume: 1.0,
    //   autoPlay: true,
    // );
  }

  var defaultBackgroundColor = Color(0xFF285499);
  var defaultTextColor = Color.fromARGB(166, 216, 248, 255);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Tambahkan BGM ke scaffold dengan global = true agar diputar di semua halaman

      body: Center(
        child: Container(
            width: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                    decoration: ShapeDecoration(
                      color: Color(0xFFA1C0F2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            AppSizeMinigame.borderRadiusGlobalMinigame),
                        side: BorderSide(color: Color(0xFF4D77B9), width: 3.0),
                      ),
                      shadows: [
                        BoxShadow(
                          color: Color(0xFF4D77B9),
                          blurRadius: 0,
                          offset: const Offset(4, 4),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        GameInstructionSet(
                            text: "lorem ipsum dolor sit amet,  asds ."),
                      ],
                    ),
                  ),
                )
                // Tombol dengan suara saat diklik
                //               ElevatedButton(
                //                 onPressed: () {
                //                   Navigator.pushNamed(context, '/detail');
                //                 },
                //                 child: const Text('Ke Halaman Detail'),
                //               ).addSound(
                //                 category: SoundCategory.clickEvent,
                //                 sound: ClickSound.gameClick,
                //               ),
                // //             double maxFontSize = 100.0; // Absolute maximum size
                // //             double maxFontSize = 100.0; // Absolute maximum siz
                //               Container(
                //                 child: Text("Click Me"),
                //               ).addSound(
                //                 category: SoundCategory.notification,
                //                 sound: NotificationSound.retroArcade,
                //               ),
                //               const SizedBox(height: 20),

                //               // Tombol dengan suara custom dan controller eksternal
                //               ElevatedButton(
                //                 onPressed: () {
                //                   Navigator.pushNamed(context, '/settings');
                //                 },
                //                 child: const Text('Ke Halaman Settings'),
                //               ).addSound(
                //                 category: SoundCategory.notification,
                //                 sound: NotificationSound.retroArcade,
                //                 controller: buttonController,
                //               ),

                //               const SizedBox(height: 20),

                //               // Tombol toggle suara SFX
                //               ElevatedButton(
                //                 onPressed: () {
                //                   // Memutar suara SFX menggunakan controller langsung
                //                   buttonController.playSound(
                //                     category: SoundCategory.sfx,
                //                     sound: SFXSound.airWoosh,
                //                   );
                //                 },
                //                 child: const Text('Putar SFX Air Woosh'),
                //               ),
              ],
            )),
      ),
    );
  }

  @override
  void dispose() {
    // Pastikan controller dibuang dengan benar
    bgmController.dispose();
    buttonController.dispose();
    super.dispose();
  }
}

class DetailPage extends StatelessWidget {
  const DetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Widget dengan suara berbeda
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Kembali'),
            ).addSound(
              category: SoundCategory.clickEvent,
              sound: ClickSound.selectClick,
            ),
          ],
        ),
        // Tambahkan BGM khusus untuk halaman ini
      ).addBGM(
        sound: BGMSound.fluteMusic,
        volume: 0.4,
        autoPlay: true,
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double masterVolume = 1.0;
  bool isMuted = false;

  @override
  void initState() {
    super.initState();
    masterVolume = SoundManager.instance.masterVolume;
    isMuted = SoundManager.instance.isMuted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Volume slider
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Master Volume:'),
                Slider(
                  value: masterVolume,
                  onChanged: (value) {
                    setState(() {
                      masterVolume = value;
                      SoundManager.instance.setMasterVolume(value);
                    });
                  },
                ),
                Text('${(masterVolume * 100).toInt()}%'),
              ],
            ),

            // Mute toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Muted:'),
                Switch(
                  value: isMuted,
                  onChanged: (value) {
                    setState(() {
                      isMuted = value;
                      SoundManager.instance.setMuted(value);
                    });
                  },
                ),
              ],
            ).addSound(
              category: SoundCategory.clickEvent,
              sound: ClickSound.selectClick,
            ),

            // Tombol kembali
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Kembali'),
            ).addSound(
              category: SoundCategory.clickEvent,
              sound: ClickSound.gameClick,
            ),
          ],
        ),
      ).addBGM(
        sound: BGMSound.birdsSinging,
        volume: 0.3,
        autoPlay: true,
      ),
    );
  }
}
