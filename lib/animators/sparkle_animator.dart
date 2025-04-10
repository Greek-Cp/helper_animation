import 'dart:math' as math;
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/enums.dart';
import 'effect_animator.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/enums.dart';
import 'effect_animator.dart';

import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/enums.dart';
import 'effect_animator.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/enums.dart';
import 'effect_animator.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/enums.dart';
import 'effect_animator.dart';

class SparkleStarburstAnimator implements EffectAnimator {
  final int particleCount;
  final List<StarburstParticle> _particles = [];
  final Random _random = Random();

  SparkleStarburstAnimator({this.particleCount = 20});

  void _ensureParticlesInitialized() {
    if (_particles.isEmpty) {
      for (int i = 0; i < particleCount; i++) {
        // Create evenly distributed angles with some randomness
        final baseAngle = (i / particleCount) * math.pi * 2;
        final angle = baseAngle + (_random.nextDouble() * 0.2 - 0.1);

        _particles.add(StarburstParticle(
          angle: angle,
          maxDistance: _random.nextDouble() * 15 + 25,
          size: _random.nextDouble() * 4 + 1,
          pulseRate: _random.nextDouble() * 3 + 1,
          speed: _random.nextDouble() * 0.3 + 0.7,
        ));
      }
    }
  }

  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final adjustedCenter = center + positionOffset;

    _ensureParticlesInitialized();

    // Calculate base orbit radius (similar to FireworkAnimator)
    final orbitRadius = size.width * 0.7 * radiusMultiplier;

    // Calculate distance progression - starts from 0, goes to max at middle, back to 0
    double distanceProgress;
    if (progress < 0.5) {
      // First half: expand from center (0->1)
      distanceProgress = _easeOutQuad(progress * 2);
    } else {
      // Second half: contract back to center (1->0)
      distanceProgress = _easeInQuad(2 - progress * 2);
    }

    // Draw sparkling particles
    for (final particle in _particles) {
      // Calculate current distance based on animation progress
      final currentDistance =
          particle.maxDistance * distanceProgress * orbitRadius / 30;

      // Calculate position
      final x = adjustedCenter.dx + math.cos(particle.angle) * currentDistance;
      final y = adjustedCenter.dy + math.sin(particle.angle) * currentDistance;

      // Pulsing size for twinkling effect
      final pulseEffect =
          0.5 + 0.5 * math.sin(progress * math.pi * 2 * particle.pulseRate);
      final particleSize = particle.size * pulseEffect * radiusMultiplier;

      // Set opacity based on distance - fade in/out at start/end
      double opacity = 1.0;
      if (distanceProgress < 0.2) {
        opacity = distanceProgress / 0.2;
      } else if (distanceProgress > 0.8) {
        opacity = (1 - distanceProgress) / 0.2;
      }

      // Draw star with adjusted opacity
      _drawStar(
          canvas, Offset(x, y), particleSize, color.withOpacity(opacity), 4);
    }

    // Draw connecting lines from center to particles when they're extending out
    if (progress < 0.6) {
      final linePaint = Paint()
        ..color = color.withOpacity(0.3 * (1 - progress / 0.6))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      for (final particle in _particles) {
        if (_random.nextDouble() > 0.7) {
          // Only draw lines for some particles
          final currentDistance =
              particle.maxDistance * distanceProgress * orbitRadius / 30;
          final x =
              adjustedCenter.dx + math.cos(particle.angle) * currentDistance;
          final y =
              adjustedCenter.dy + math.sin(particle.angle) * currentDistance;

          canvas.drawLine(adjustedCenter, Offset(x, y), linePaint);
        }
      }
    }
  }

  // Helper method to draw a star shape
  void _drawStar(
      Canvas canvas, Offset center, double size, Color color, int points) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven ? size : size * 0.4;
      final angle = (i * math.pi) / points;

      final x = center.dx + math.cos(angle) * radius;
      final y = center.dy + math.sin(angle) * radius;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  // Easing functions for smooth animation
  double _easeOutQuad(double t) {
    return t * (2 - t);
  }

  double _easeInQuad(double t) {
    return t * t;
  }

  @override
  bool shouldRepaint(EffectAnimator oldAnimator) => true;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  @override
  double getDefaultRadiusMultiplier() => 1.0;

  @override
  double getOuterPadding() => 15.0;
}

class StarburstParticle {
  final double angle;
  final double maxDistance;
  final double size;
  final double pulseRate;
  final double speed;

  StarburstParticle({
    required this.angle,
    required this.maxDistance,
    required this.size,
    required this.pulseRate,
    required this.speed,
  });
}
