import '../constants/enums.dart';
import 'package:flutter/material.dart';

abstract class EffectAnimator {
  // Parameter baru untuk mengontrol posisi dan ukuran animasi
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero});

  bool shouldRepaint(EffectAnimator oldAnimator);

  // Setiap animator dapat menentukan posisi default relatif terhadap widget
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  // Setiap animator dapat menentukan radius default
  double getDefaultRadiusMultiplier() => 1.0;

  // Untuk menghitung padding antara widget dan animasi
  double getOuterPadding() => 20.0;
}
