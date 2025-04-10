import '../animators/effect_animator.dart';
import 'package:flutter/material.dart';


class EffectPainter extends CustomPainter {
  final double progress;
  final Offset center;
  final Color color;
  final Size childSize;
  final EffectAnimator animator;
  final double radiusMultiplier;
  final Offset positionOffset;

  EffectPainter({
    required this.progress,
    required this.center,
    required this.color,
    required this.childSize,
    required this.animator,
    required this.radiusMultiplier,
    required this.positionOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    animator.paint(
      canvas,
      childSize,
      progress,
      center,
      color,
      radiusMultiplier: radiusMultiplier,
      positionOffset: positionOffset,
    );
  }

  @override
  bool shouldRepaint(covariant EffectPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        animator.shouldRepaint(oldDelegate.animator);
  }
}

