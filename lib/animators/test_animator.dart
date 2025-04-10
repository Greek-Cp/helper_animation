import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:helper_animation/animators/effect_animator.dart';
import 'package:helper_animation/constants/enums.dart';

class DualParticleRayAnimator implements EffectAnimator {
  // Konfigurasi parameter untuk kedua jenis animasi
  final int rayCount;
  final double rayLength;
  final double rayWidth;
  final double distanceFactor;
  final bool randomizeRays;
  final double glowIntensity;
  final double glowRadius;
  final bool enableImplosion;
  final bool enableExplosion;
  final double speedFactor; // Faktor kecepatan animasi
  final Random _random = Random();

  // Untuk menyimpan data rays
  late List<_RayData> _implosionRays;
  late List<_RayData> _explosionRays;

  DualParticleRayAnimator({
    this.rayCount = 16,
    this.rayLength = 70.0,
    this.rayWidth = 2.2,
    this.distanceFactor = 1.8, // Seberapa jauh rays dari tepi widget
    this.randomizeRays = true,
    this.glowIntensity = 0.8,
    this.glowRadius = 4.0,
    this.enableImplosion = true,
    this.enableExplosion = true,
    this.speedFactor = 1.5, // 1.5x lebih cepat dari normal
  }) {
    _initRays();
  }

  void _initRays() {
    // PENTING: Hilangkan semua delay antar ray agar muncul serempak

    // Inisialisasi data rays untuk implosion
    _implosionRays = List.generate(rayCount, (index) {
      // Sudut dengan offset sedikit agar tidak tumpang tindih dengan explosion rays
      final baseAngle =
          (index / rayCount) * 2 * math.pi + (math.pi / rayCount / 2);

      // Randomisasi diminimalkan
      final angle = randomizeRays
          ? baseAngle +
              (_random.nextDouble() * 0.08 - 0.04) // Lebih kecil variasi sudut
          : baseAngle;

      final lengthFactor = randomizeRays
          ? 0.95 + _random.nextDouble() * 0.15 // Kurangi variasi panjang
          : 1.0;

      final widthFactor = randomizeRays
          ? 0.95 + _random.nextDouble() * 0.15 // Kurangi variasi lebar
          : 1.0;

      // Randomisasi variasi warna
      final hueOffset = randomizeRays
          ? -8 + _random.nextInt(16) // Kurangi variasi warna
          : 0;

      return _RayData(
        angle: angle,
        lengthFactor: lengthFactor,
        widthFactor: widthFactor,
        hueOffset: hueOffset,
      );
    });

    // Inisialisasi data rays untuk explosion dengan cara yang sama
    _explosionRays = List.generate(rayCount, (index) {
      final baseAngle = (index / rayCount) * 2 * math.pi;

      final angle = randomizeRays
          ? baseAngle + (_random.nextDouble() * 0.08 - 0.04)
          : baseAngle;

      final lengthFactor =
          randomizeRays ? 0.95 + _random.nextDouble() * 0.15 : 1.0;

      final widthFactor =
          randomizeRays ? 0.95 + _random.nextDouble() * 0.15 : 1.0;

      final hueOffset = randomizeRays ? -8 + _random.nextInt(16) : 0;

      return _RayData(
        angle: angle,
        lengthFactor: lengthFactor,
        widthFactor: widthFactor,
        hueOffset: hueOffset,
      );
    });
  }

  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    // Mempercepat progress dengan speedFactor
    // Ketika speedFactor = 1.5, akan mencapai progress 1.0 saat actual progress 0.67
    final adjustedProgress = math.min(1.0, progress * speedFactor);

    final adjustedCenter = center + positionOffset;

    // Menentukan radius widget
    final widgetRadius = math.min(size.width, size.height) * 0.5;

    // Menggambar core glow
    _drawCoreGlow(
        canvas, adjustedCenter, widgetRadius, color, adjustedProgress);

    // Gambar implosion rays (dari luar ke dalam)
    if (enableImplosion) {
      _drawImplosionRays(canvas, adjustedCenter, widgetRadius, color,
          adjustedProgress, radiusMultiplier);
    }

    // Gambar explosion rays (dari dalam ke luar)
    if (enableExplosion) {
      _drawExplosionRays(canvas, adjustedCenter, widgetRadius, color,
          adjustedProgress, radiusMultiplier);
    }
  }

  // Menggambar implosion rays (dari luar ke dalam)
  void _drawImplosionRays(Canvas canvas, Offset center, double widgetRadius,
      Color color, double progress, double radiusMultiplier) {
    for (final ray in _implosionRays) {
      // Menghitung posisi awal ray (di luar widget)
      final startDistance = widgetRadius * distanceFactor;
      final startPos = Offset(
        center.dx + math.cos(ray.angle) * startDistance,
        center.dy + math.sin(ray.angle) * startDistance,
      );

      // Menentukan posisi akhir (pusat widget)
      final endPos = center;

      // Kurva ease-in untuk gerakan lebih cepat di awal
      // Power curve membuat gerakan lebih cepat di bagian awal
      final easedProgress = math.pow(progress, 0.7).toDouble();

      // Interpolasi posisi dengan easing
      final currentPos = Offset.lerp(startPos, endPos, easedProgress)!;

      // Variasikan warna untuk setiap ray
      final rayColor = _adjustColor(color, ray.hueOffset);

      // Hitung opacity
      final opacity = _calculateOpacity(progress);

      // Hitung panjang ray tersisa (dengan easing)
      final remainingProgress = 1.0 - easedProgress;
      final remainingLength =
          rayLength * ray.lengthFactor * remainingProgress * radiusMultiplier;

      // Posisi ujung ray
      final tipPos = Offset(
        currentPos.dx + math.cos(ray.angle) * remainingLength,
        currentPos.dy + math.sin(ray.angle) * remainingLength,
      );

      // Gambar ray
      _drawGlowingRay(
        canvas,
        currentPos,
        tipPos,
        rayWidth * ray.widthFactor * radiusMultiplier,
        rayColor.withOpacity(opacity),
        progress,
        true, // Implosion ray (gradient dari luar ke dalam)
      );

      // Gambar partikel
      _drawGlowingParticles(
        canvas,
        currentPos,
        ray.angle,
        remainingLength,
        progress,
        rayColor,
      );
    }
  }

  // Menggambar explosion rays (dari dalam ke luar)
  void _drawExplosionRays(Canvas canvas, Offset center, double widgetRadius,
      Color color, double progress, double radiusMultiplier) {
    for (final ray in _explosionRays) {
      // Menentukan posisi awal (pusat widget)
      final startPos = center;

      // Kurva ease-out untuk gerakan lebih cepat di awal
      final easedProgress = math.pow(progress, 0.6).toDouble();

      // Hitung panjang ray saat ini
      final currentLength =
          rayLength * ray.lengthFactor * easedProgress * radiusMultiplier;

      // Posisi ujung ray berdasarkan arah dan progress
      final tipPos = Offset(
        startPos.dx + math.cos(ray.angle) * currentLength,
        startPos.dy + math.sin(ray.angle) * currentLength,
      );

      // Variasikan warna untuk setiap ray
      final rayColor = _adjustColor(color, ray.hueOffset);

      // Hitung opacity (dengan fade-out lebih cepat)
      final opacity = _calculateOpacity(progress);

      // Gambar ray
      _drawGlowingRay(
        canvas,
        startPos,
        tipPos,
        rayWidth * ray.widthFactor * radiusMultiplier,
        rayColor.withOpacity(opacity),
        progress,
        false, // Explosion ray (gradient dari dalam ke luar)
      );

      // Gambar partikel
      _drawGlowingParticles(
        canvas,
        startPos,
        ray.angle,
        currentLength,
        progress,
        rayColor,
      );
    }
  }

  // Menggambar core glow di pusat
  void _drawCoreGlow(Canvas canvas, Offset center, double widgetRadius,
      Color color, double progress) {
    // Central flash pada awal animasi
    if (progress < 0.25) {
      // Lebih cepat menghilang
      final flashProgress = progress / 0.25;
      final flashOpacity = (1 - flashProgress) * 0.8 * glowIntensity;

      final flashPaint = Paint()
        ..color = Colors.white.withOpacity(flashOpacity)
        ..maskFilter = MaskFilter.blur(
            BlurStyle.normal, 8 * glowRadius * (1 - flashProgress * 0.5));

      canvas.drawCircle(
          center, widgetRadius * 0.4 * (1 - flashProgress * 0.5), flashPaint);
    }

    // Ambient glow yang muncul sepanjang animasi
    final ambientPaint = Paint()
      ..color =
          color.withOpacity(0.2 * glowIntensity * math.sin(progress * math.pi))
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 15 * glowRadius);

    canvas.drawCircle(center, widgetRadius * 0.5, ambientPaint);
  }

  // Fungsi untuk menggambar ray dengan glow
  void _drawGlowingRay(Canvas canvas, Offset start, Offset end, double width,
      Color color, double progress, bool isImplosion) {
    // Layer 1: Glow luar (blur lebih besar)
    if (glowIntensity > 0) {
      final outerGlowPaint = Paint()
        ..color = color.withOpacity(0.3 * glowIntensity)
        ..strokeWidth = width * 2.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowRadius * 2.0);

      canvas.drawLine(start, end, outerGlowPaint);

      // Layer 2: Glow tengah
      final midGlowPaint = Paint()
        ..color = color.withOpacity(0.5 * glowIntensity)
        ..strokeWidth = width * 1.7
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowRadius);

      canvas.drawLine(start, end, midGlowPaint);
    }

    // Layer 3: Garis utama ray dengan gradient yang sesuai arah
    final rayPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withOpacity(0.9),
          color.withOpacity(0.7),
          color.withOpacity(0.0),
        ],
        stops: const [0.0, 0.3, 1.0],
        begin: isImplosion ? Alignment.centerLeft : Alignment.centerRight,
        end: isImplosion ? Alignment.centerRight : Alignment.centerLeft,
      ).createShader(Rect.fromPoints(start, end))
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(start, end, rayPaint);

    // Efek highlight di ujung ray
    final tipHighlightPos = isImplosion ? end : end;
    final tipPaint = Paint()
      ..color = Colors.white.withOpacity(0.8 * (1 - progress * 0.5))
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1.5);

    canvas.drawCircle(tipHighlightPos, width * 1.0, tipPaint);
  }

  // Fungsi untuk menggambar partikel dengan glow di sepanjang ray
  void _drawGlowingParticles(Canvas canvas, Offset base, double angle,
      double length, double progress, Color color) {
    // Jumlah partikel sepanjang ray - lebih sedikit partikel untuk performa lebih baik
    final particleCount = math.max(2, (length / 20).round());

    for (int i = 1; i < particleCount; i++) {
      // Jarak dari titik awal
      final distance = (i / particleCount) * length;

      // Posisi partikel
      final particlePos = Offset(
        base.dx + math.cos(angle) * distance,
        base.dy + math.sin(angle) * distance,
      );

      // Ukuran partikel
      final particleSize = 1.8 * (1 - (i / particleCount) * 0.3);

      // Opacity partikel
      final particleOpacity = 0.8 * (1 - (i / particleCount) * 0.5);

      // Efek flicker partikel dibuat konsisten berdasarkan posisi, bukan waktu
      final flicker = 0.7 + math.sin((i * 0.7) + (angle * 5)) * 0.3;

      // Gambar glow partikel
      if (glowIntensity > 0) {
        final glowPaint = Paint()
          ..color =
              color.withOpacity(particleOpacity * 0.5 * glowIntensity * flicker)
          ..style = PaintingStyle.fill
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowRadius * 0.8);

        canvas.drawCircle(particlePos, particleSize * 2.5, glowPaint);
      }

      // Gambar partikel utama
      final particlePaint = Paint()
        ..color = color.withOpacity(particleOpacity * flicker)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(particlePos, particleSize, particlePaint);

      // Highlight di tengah partikel
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(particleOpacity * 0.7 * flicker)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(particlePos, particleSize * 0.3, highlightPaint);
    }
  }

  // Fungsi untuk menyesuaikan warna dengan offset hue
  Color _adjustColor(Color baseColor, int hueOffset) {
    if (hueOffset == 0) return baseColor;

    // Convert to HSL untuk menyesuaikan hue
    final hsl = HSLColor.fromColor(baseColor);
    return hsl.withHue((hsl.hue + hueOffset) % 360).toColor();
  }

  // Fungsi untuk menghitung opacity berdasarkan progress
  double _calculateOpacity(double progress) {
    // Fade-in di awal (sangat cepat)
    if (progress < 0.08) {
      return progress / 0.08; // Mencapai full opacity di 8% progress
    }
    // Fade-out di akhir (lebih awal)
    else if (progress > 0.7) {
      return (1.0 - progress) / 0.3;
    }
    // Opacity penuh di tengah
    else {
      return 1.0;
    }
  }

  @override
  bool shouldRepaint(EffectAnimator oldAnimator) {
    if (oldAnimator is DualParticleRayAnimator) {
      return oldAnimator.rayCount != rayCount ||
          oldAnimator.rayLength != rayLength ||
          oldAnimator.glowIntensity != glowIntensity ||
          oldAnimator.enableImplosion != enableImplosion ||
          oldAnimator.enableExplosion != enableExplosion ||
          oldAnimator.speedFactor != speedFactor;
    }
    return true;
  }

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  @override
  double getDefaultRadiusMultiplier() => 1.2;

  @override
  double getOuterPadding() => rayLength * 0.5;
}

// Kelas helper untuk menyimpan data ray individu
class _RayData {
  final double angle;
  final double lengthFactor;
  final double widthFactor;
  final int hueOffset;

  _RayData({
    required this.angle,
    required this.lengthFactor,
    required this.widthFactor,
    required this.hueOffset,
  });
}
