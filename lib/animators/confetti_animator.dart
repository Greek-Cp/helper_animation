import 'dart:math';

import '../constants/enums.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'effect_animator.dart';
import 'package:flutter/material.dart';

class ConfettiAnimator implements EffectAnimator {
  final List<_ConfettiParticle> _particles = [];
  final Random _random = Random();

  // Menambahkan variasi bentuk confetti
  final List<_ConfettiShape> _shapes = [
    _ConfettiShape.rectangle,
    _ConfettiShape.circle,
    _ConfettiShape.oval,
    _ConfettiShape.star,
    _ConfettiShape.heart,
  ];

  ConfettiAnimator() {
    // Meningkatkan jumlah partikel untuk efek yang lebih kaya
    for (int i = 0; i < 50; i++) {
      _particles.add(
          _ConfettiParticle(_random, _shapes[_random.nextInt(_shapes.length)]));
    }
  }

  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    // Aplikasikan offset ke center
    final adjustedCenter = center + positionOffset;

    // Faktor untuk membuat animasi lebih dinamis
    final fadeInFactor = math.min(1.0, progress * 2); // Fade in lebih cepat
    final fadeOutFactor =
        math.max(0.0, 1.0 - (progress - 0.7) * 3.33); // Fade out di akhir

    // Update dan gambar setiap partikel
    for (var particle in _particles) {
      // Warna lebih cerah dan variatif untuk anak-anak
      final particleColor = HSLColor.fromAHSL(
        fadeInFactor * fadeOutFactor, // Opacity berdasarkan fase animasi
        particle.hue,
        1.0,
        0.6 + _random.nextDouble() * 0.3,
      ).toColor();

      // Menambahkan twist dan swirl pada pergerakan confetti
      final swirl = math.sin(progress * math.pi * 2 * particle.swirlFrequency) *
          particle.swirlAmplitude;

      // Posisi dengan gerakan yang lebih menarik
      final x = adjustedCenter.dx +
          (particle.initialX + swirl) *
              progress *
              size.width *
              0.9 *
              radiusMultiplier;

      // Menambahkan variasi kecepatan jatuh untuk setiap partikel
      final fallSpeed = particle.fallSpeed * progress * progress * size.height;
      final y = adjustedCenter.dy +
          particle.initialY * progress * size.height * 0.5 * radiusMultiplier +
          fallSpeed;

      // Rotasi yang lebih variatif
      final rotation = particle.rotation * progress * 6 * math.pi;

      // Ukuran berdasarkan partikel dengan sedikit bouncing effect
      final sizeMultiplier = 1.0 + math.sin(progress * math.pi * 2) * 0.2;
      final baseSize = particle.size * sizeMultiplier;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      // Gambar bentuk confetti sesuai dengan tipe
      final paint = Paint()
        ..color = particleColor
        ..style = PaintingStyle.fill;

      // Tambahkan efek shimmer/glitter
      if (particle.hasGlitter && math.sin(progress * 30) > 0.7) {
        paint.color =
            Colors.white.withOpacity(fadeInFactor * fadeOutFactor * 0.8);
      }

      switch (particle.shape) {
        case _ConfettiShape.rectangle:
          canvas.drawRect(
              Rect.fromCenter(
                  center: Offset.zero, width: baseSize, height: baseSize * 0.5),
              paint);
          break;
        case _ConfettiShape.circle:
          canvas.drawCircle(Offset.zero, baseSize / 2, paint);
          break;
        case _ConfettiShape.oval:
          canvas.drawOval(
              Rect.fromCenter(
                  center: Offset.zero, width: baseSize, height: baseSize * 0.6),
              paint);
          break;
        case _ConfettiShape.star:
          _drawStar(canvas, baseSize / 2, paint);
          break;
        case _ConfettiShape.heart:
          _drawHeart(canvas, baseSize / 2, paint);
          break;
      }

      canvas.restore();
    }
  }

  // Fungsi untuk menggambar bentuk bintang
  void _drawStar(Canvas canvas, double radius, Paint paint) {
    final path = Path();
    final outerRadius = radius;
    final innerRadius = radius * 0.4;
    final centerX = 0.0;
    final centerY = 0.0;

    for (int i = 0; i < 10; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = i * math.pi / 5;
      final x = centerX + radius * math.cos(angle - math.pi / 2);
      final y = centerY + radius * math.sin(angle - math.pi / 2);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  // Fungsi untuk menggambar bentuk hati
  void _drawHeart(Canvas canvas, double radius, Paint paint) {
    final path = Path();
    final size = radius * 2;

    path.moveTo(0, size * 0.3);
    path.cubicTo(size * -0.55, size * -0.3, size * -0.85, size * 0.6, 0, size);
    path.cubicTo(
        size * 0.85, size * 0.6, size * 0.55, size * -0.3, 0, size * 0.3);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(EffectAnimator oldAnimator) {
    return true;
  }

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.top;

  @override
  double getDefaultRadiusMultiplier() => 1.8; // Memperbesar area confetti

  @override
  double getOuterPadding() =>
      40.0; // Meningkatkan padding untuk efek yang lebih luas
}

// Definisi bentuk confetti
enum _ConfettiShape {
  rectangle,
  circle,
  oval,
  star,
  heart,
}

class _ConfettiParticle {
  final double initialX;
  final double initialY;
  final double fallSpeed;
  final double rotation;
  final double hue;
  final double size;
  final _ConfettiShape shape;
  final bool hasGlitter;
  final double swirlAmplitude;
  final double swirlFrequency;

  _ConfettiParticle(Random random, _ConfettiShape shape)
      : initialX = (random.nextDouble() * 2 - 1) *
            0.8, // -0.8 to 0.8 untuk penyebaran yang lebih baik
        initialY = -0.5 - random.nextDouble() * 0.5, // Mulai dari atas
        fallSpeed = random.nextDouble() * 0.7 +
            0.4, // 0.4 to 1.1 untuk variasi kecepatan jatuh
        rotation = random.nextDouble() * 4 - 2, // -2 to 2
        hue = random.nextDouble() * 360, // Warna acak
        size = random.nextDouble() * 8 + 7, // 7-15 ukuran yang lebih variatif
        shape = shape,
        hasGlitter =
            random.nextDouble() > 0.6, // 40% partikel memiliki efek glitter
        swirlAmplitude =
            random.nextDouble() * 0.1, // Amplitudo gerakan melingkar
        swirlFrequency =
            random.nextDouble() * 2 + 1; // Frekuensi gerakan melingkar
}
