import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helper_animation/constants/app_size.dart';
import 'package:helper_animation/widgets/effect_animation.dart';
import 'package:helper_animation/widgets/game_instruction_set_widget.dart';
import 'package:helper_animation_example/animation_demo.dart';

void main() {
  runApp(const AnimationDemoApp());
}

class AnimationDemoApp extends StatelessWidget {
  const AnimationDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Animation Demo',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                    padding: AppSizeMinigame.paddingGlobalMinigame,
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
                          text: "Solve or build expression in the right order.",
                          textScale: 0.6,
                        ),
                      ],
                    ),
                  ),
                )
              ],
            )),
      ),
    );
  }

  @override
  void dispose() {}
}
