import '../constants/enums.dart';
import 'dart:math' as math;
import 'dart:math';
import 'effect_animator.dart';
import 'package:flutter/material.dart';


class OrbitalAnimator implements EffectAnimator {
  final List<_OrbitalParticle> _particles = [];
  final Random _random = Random();

  OrbitalAnimator() {
    // Buat beberapa partikel
    for (int i = 0; i < 12; i++) {
      _particles.add(_OrbitalParticle(_random));
    }
  }

  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    // Aplikasikan offset ke center
    final adjustedCenter = center + positionOffset;

    // Base radius
    final baseRadius = size.width * 0.6 * radiusMultiplier;

    // Gambar partikel orbital
    for (var particle in _particles) {
      // Rotasi berdasarkan progress dan kecepatan partikel
      final angle =
          particle.initialAngle + (progress * particle.speed * 2 * math.pi);

      // Jarak dari pusat
      final distance = baseRadius * particle.distanceFactor;

      // Posisi partikel
      final x = adjustedCenter.dx + math.cos(angle) * distance;
      final y = adjustedCenter.dy + math.sin(angle) * distance;

      // Ukuran partikel (pulsasi kecil)
      final particleSize = particle.size *
          (1 + 0.2 * math.sin(progress * 2 * math.pi * particle.pulsateSpeed));

      // Gambar partikel
      final particlePaint = Paint()
        ..color = HSLColor.fromColor(color)
            .withLightness(0.6 + 0.4 * particle.brightnessFactor)
            .toColor()
            .withOpacity(0.6 + 0.4 * math.sin(progress * math.pi));

      // Bentuk partikel (lingkaran)
      canvas.drawCircle(Offset(x, y), particleSize, particlePaint);

      // Gambar jejak (tail)
      if (particle.hasTail) {
        final tailLength =
            0.3; // Berapa jauh ke belakang (sebagai fraksi dari 2π)
        final tailSteps = 5; // Berapa banyak titik untuk jejak

        for (int i = 1; i <= tailSteps; i++) {
          final tailProgress = i / tailSteps;
          final tailAngle = angle - (tailLength * tailProgress * 2 * math.pi);
          final tailX = adjustedCenter.dx + math.cos(tailAngle) * distance;
          final tailY = adjustedCenter.dy + math.sin(tailAngle) * distance;
          final tailOpacity = (1 - tailProgress) * 0.7;
          final tailSize = particleSize * (1 - tailProgress * 0.8);

          final tailPaint = Paint()
            ..color = HSLColor.fromColor(color)
                .withLightness(0.7)
                .toColor()
                .withOpacity(tailOpacity);

          canvas.drawCircle(Offset(tailX, tailY), tailSize, tailPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(EffectAnimator oldAnimator) {
    return true;
  }

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  @override
  double getDefaultRadiusMultiplier() => 1.3;

  @override
  double getOuterPadding() => 10.0;
}


class _OrbitalParticle {
  final double initialAngle; // Sudut awal
  final double speed; // Kecepatan rotasi
  final double
      distanceFactor; // Jarak dari pusat (sebagai faktor dari radius dasar)
  final double size; // Ukuran partikel
  final double brightnessFactor; // Faktor kecerahan (0-1)
  final double pulsateSpeed; // Kecepatan pulsasi
  final bool hasTail; // Apakah memiliki jejak

  _OrbitalParticle(Random random)
      : initialAngle = random.nextDouble() * 2 * math.pi,
        speed = 0.5 + random.nextDouble() * 1.5, // 0.5x - 2x kecepatan
        distanceFactor = 0.5 + random.nextDouble() * 0.5, // 50-100% dari radius
        size = 3 + random.nextDouble() * 5, // 3-8px
        brightnessFactor = random.nextDouble(),
        pulsateSpeed = 0.5 + random.nextDouble() * 1.5,
        hasTail = random.nextDouble() < 0.7; // 70% chance to have tail
}

