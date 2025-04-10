import '../constants/enums.dart';
import 'effect_animator.dart';
import 'package:flutter/material.dart';


class RippleAnimator implements EffectAnimator {
  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    // Aplikasikan offset ke center
    final adjustedCenter = center + positionOffset;

    // Animasi riak air dengan beberapa lingkaran konsentris
    final int numRings = 3;
    final double maxRadius = size.width * 0.8 * radiusMultiplier;

    for (int i = 0; i < numRings; i++) {
      // Menghitung fase untuk lingkaran ini
      double ringPhase = (progress + (i / numRings)) % 1.0;

      // Radius lingkaran berdasarkan fase
      double radius = maxRadius * ringPhase;

      // Opacity menurun seiring dengan bertambahnya radius
      double opacity = 1.0 - ringPhase;

      Paint ringPaint = Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0;

      canvas.drawCircle(adjustedCenter, radius, ringPaint);
    }
  }

  @override
  bool shouldRepaint(EffectAnimator oldAnimator) {
    return true;
  }

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.top;

  @override
  double getDefaultRadiusMultiplier() => 1.2;

  @override
  double getOuterPadding() => 5.0;
}

