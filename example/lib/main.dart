import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helper_animation/widgets/effect_animation.dart';
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
      home: AnimationDemo(),
    );
  }
}
