// ... Continuing ParticleSwarmAnimator

import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:helper_animation/animators/effect_animator.dart';
import '../constants/enums.dart';

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Animator untuk efek firework radial yang super energetik dan menarik bagi anak-anak
class RadialFireworkAnimator implements EffectAnimator {
  // Parameter untuk mengontrol timing relatif dari setiap fase
  final double fadeInRelativeDuration;
  final double stretchRelativeDuration;
  final double closeRelativeDuration;
  final double fadeOutRelativeDuration;

  // Parameter untuk mengontrol penampilan
  final int elementCount;
  final double circleRadius;
  final double lineLength;
  final double finalScale;
  final bool enableSparkles;
  final bool enableColorShift;
  final bool enableExtraBounce;

  RadialFireworkAnimator({
    this.fadeInRelativeDuration = 0.15,
    this.stretchRelativeDuration = 0.25,
    this.closeRelativeDuration = 0.20,
    this.fadeOutRelativeDuration = 0.40,
    this.elementCount = 12, // Ditambah jadi 12 untuk full coverage
    this.circleRadius = 5.0, // Sedikit lebih besar
    this.lineLength = 40.0, // Lebih panjang agar lebih bertenaga
    this.finalScale = 1.6, // Lebih besar agar terlihat lebih wow
    this.enableSparkles = true, // Penambahan efek sparkle
    this.enableColorShift = true, // Penambahan perubahan warna
    this.enableExtraBounce = true, // Penambahan efek bounce
  });

  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    // PENTING: Selalu gunakan center yang sudah disesuaikan dengan offset
    final adjustedCenter = center + positionOffset;

    // Hitung titik transisi antara fase
    final fadeInEnd = fadeInRelativeDuration;
    final stretchEnd = fadeInEnd + stretchRelativeDuration;
    final closeEnd = stretchEnd + closeRelativeDuration;
    // fadeOutEnd = 1.0

    // Sesuaikan ukuran berdasarkan radiusMultiplier
    final adjustedRadius = circleRadius * radiusMultiplier;
    final adjustedLineLength = lineLength * radiusMultiplier;

    // Random generator untuk efek sparkle dan variasi
    final random = math.Random(42); // Fixed seed untuk konsistensi

    // Gambar efek sparkle background jika diaktifkan (di bawah elemen utama)
    if (enableSparkles && progress > fadeInEnd) {
      _drawSparkles(
          canvas, adjustedCenter, progress, color, random, adjustedLineLength);
    }

    // Untuk setiap elemen dalam animasi radial
    for (int i = 0; i < elementCount; i++) {
      // Sudut untuk elemen ini (dalam radian)
      final angle = (i * (2 * math.pi / elementCount));

      // Warna dasar untuk elemen ini
      Color elementColor = color;

      // Jika color shift diaktifkan, variasikan warna sedikit
      if (enableColorShift) {
        // Hue shift berdasarkan posisi dan progress
        final hueShift = (i / elementCount * 0.3) + (progress * 0.2);
        final saturation = 0.8 + (math.sin(progress * math.pi * 2) * 0.2);

        // Buat warna dengan HSV untuk variasi yang lebih menarik
        final hslColor = HSLColor.fromColor(color);
        elementColor = hslColor
            .withHue((hslColor.hue + hueShift * 360) % 360)
            .withSaturation(math.min(1.0, hslColor.saturation * saturation))
            .toColor();
      }

      // Tentukan fase animasi berdasarkan progress
      if (progress < fadeInEnd) {
        // ===== FASE 1: FADE-IN dengan extra bounce =====
        _paintFadeInPhase(canvas, adjustedCenter, angle, progress / fadeInEnd,
            adjustedRadius, elementColor, enableExtraBounce);
      } else if (progress < stretchEnd) {
        // ===== FASE 2: STRETCH-OUT yang lebih energetik =====
        _paintStretchPhase(
            canvas,
            adjustedCenter,
            angle,
            (progress - fadeInEnd) / (stretchEnd - fadeInEnd),
            adjustedRadius,
            adjustedLineLength,
            elementColor,
            enableExtraBounce);
      } else if (progress < closeEnd) {
        // ===== FASE 3: CLOSE CIRCLE dengan gerakan dinamis =====
        _paintClosePhase(
            canvas,
            adjustedCenter,
            angle,
            (progress - stretchEnd) / (closeEnd - stretchEnd),
            adjustedRadius,
            adjustedLineLength,
            elementColor);
      } else {
        // ===== FASE 4: SUPER BLOOM & FADE dengan efek lebih wow =====
        _paintBloomFadePhase(
            canvas,
            adjustedCenter,
            angle,
            (progress - closeEnd) / (1.0 - closeEnd),
            adjustedRadius,
            adjustedLineLength,
            finalScale,
            elementColor,
            enableExtraBounce);
      }
    }

    // Gambar efek sparkle foreground jika diaktifkan (di atas elemen utama)
    if (enableSparkles && progress > stretchEnd) {
      _drawForegroundSparkles(
          canvas, adjustedCenter, progress, color, random, adjustedLineLength);
    }
  }

  /// Menggambar efek sparkle di background
  void _drawSparkles(Canvas canvas, Offset center, double progress,
      Color baseColor, math.Random random, double maxDistance) {
    // Jumlah sparkle
    final sparkleCount = 20;

    // Opacity berdasarkan fase
    double opacity = 0.7;
    if (progress > 0.7) {
      opacity = 0.7 - ((progress - 0.7) / 0.3) * 0.7;
    }

    // Untuk setiap sparkle
    for (int i = 0; i < sparkleCount; i++) {
      // Posisi acak di sekitar center
      final distance = random.nextDouble() * maxDistance * 1.2;
      final angle = random.nextDouble() * math.pi * 2;
      final x = center.dx + math.cos(angle) * distance;
      final y = center.dy + math.sin(angle) * distance;

      // Ukuran acak
      final size = random.nextDouble() * 3 + 1;

      // Warna dengan sedikit variasi
      final sparkleColor = HSLColor.fromColor(baseColor)
          .withLightness(0.7 + random.nextDouble() * 0.3)
          .withSaturation(0.8 + random.nextDouble() * 0.2)
          .toColor()
          .withOpacity(opacity * (0.3 + random.nextDouble() * 0.7));

      // Gambar sparkle (titik kecil)
      canvas.drawCircle(Offset(x, y), size, Paint()..color = sparkleColor);
    }
  }

  /// Menggambar efek sparkle di foreground (yang lebih menonjol)
  void _drawForegroundSparkles(Canvas canvas, Offset center, double progress,
      Color baseColor, math.Random random, double maxDistance) {
    // Hanya aktif di fase akhir
    if (progress < 0.65) return;

    // Jumlah sparkle yang lebih sedikit tapi lebih menonjol
    final sparkleCount = 10;

    // Opacity naik lalu turun
    double opacity = 1.0;
    if (progress > 0.85) {
      opacity = 1.0 - ((progress - 0.85) / 0.15);
    }

    // Untuk setiap sparkle
    for (int i = 0; i < sparkleCount; i++) {
      // Posisi acak lebih jauh di sekitar center
      final distance = random.nextDouble() * maxDistance * 1.5;
      final angle = random.nextDouble() * math.pi * 2;
      final x = center.dx + math.cos(angle) * distance;
      final y = center.dy + math.sin(angle) * distance;

      // Ukuran lebih besar
      final size = random.nextDouble() * 4 + 2;

      // Warna lebih terang
      final sparkleColor = HSLColor.fromColor(baseColor)
          .withLightness(0.8 + random.nextDouble() * 0.2)
          .withSaturation(0.7 + random.nextDouble() * 0.3)
          .toColor()
          .withOpacity(opacity * (0.5 + random.nextDouble() * 0.5));

      // Gambar sparkle dengan efek bintang
      _drawStar(canvas, Offset(x, y), size, sparkleColor);
    }
  }

  /// Gambar bintang kecil untuk sparkle yang lebih menarik
  void _drawStar(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Gunakan Path untuk menggambar bintang
    final path = Path();

    // Simpel saja, gambar saja lingkaran
    canvas.drawCircle(center, size, paint);

    // Tambahkan 4 titik kecil di sekitarnya
    for (int i = 0; i < 4; i++) {
      final angle = i * (math.pi / 2);
      final x = center.dx + math.cos(angle) * size * 1.5;
      final y = center.dy + math.sin(angle) * size * 1.5;
      canvas.drawCircle(Offset(x, y), size * 0.3, paint);
    }
  }

  /// Fase 1: Fade-In - Elemen muncul dari pusat dan bergerak keluar
  void _paintFadeInPhase(Canvas canvas, Offset center, double angle,
      double phaseProgress, double radius, Color color, bool enableBounce) {
    // Gunakan kurva bounce untuk pergerakan yang lebih menarik
    double curvedProgress;
    if (enableBounce) {
      curvedProgress = _bouncyEaseOut(phaseProgress);
    } else {
      curvedProgress = _easeOut(phaseProgress);
    }

    // Hitung posisi saat ini (bergerak dari pusat keluar) dengan jarak yang lebih panjang
    final moveDistance = radius * 4 * curvedProgress;
    final currentX = center.dx + math.cos(angle) * moveDistance;
    final currentY = center.dy + math.sin(angle) * moveDistance;
    final currentPos = Offset(currentX, currentY);

    // Interpolasi warna untuk efek fade-in
    final currentColor = Color.lerp(
        color.withOpacity(0), color.withOpacity(1.0), _easeOut(phaseProgress))!;

    // Gambar lingkaran dengan ukuran yang bervariasi untuk efek bouncy
    final effectiveRadius = radius *
        (1.0 + (enableBounce ? math.sin(phaseProgress * math.pi) * 0.2 : 0));

    final paint = Paint()
      ..color = currentColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(currentPos, effectiveRadius, paint);
  }

  /// Fase 2: Stretch-Out - Lingkaran memanjang menjadi garis
  void _paintStretchPhase(
      Canvas canvas,
      Offset center,
      double angle,
      double phaseProgress,
      double radius,
      double targetLength,
      Color color,
      bool enableBounce) {
    // Gunakan kurva yang lebih energetik
    final curvedProgress =
        enableBounce ? _elasticOut(phaseProgress) : _easeInOut(phaseProgress);

    // Posisi inner end (tetap)
    final innerX = center.dx + math.cos(angle) * (radius * 4);
    final innerY = center.dy + math.sin(angle) * (radius * 4);
    final innerPos = Offset(innerX, innerY);

    // Posisi outer end (bergerak keluar dengan overshoot untuk efek lebih bertenaga)
    double stretchFactor = curvedProgress;
    if (enableBounce && phaseProgress > 0.8) {
      // Extra stretch pada akhir untuk efek overshoot
      stretchFactor = curvedProgress + (phaseProgress - 0.8) * 0.5;
    }

    final stretchLength = stretchFactor * (targetLength - radius * 4);
    final outerX = innerX + math.cos(angle) * stretchLength;
    final outerY = innerY + math.sin(angle) * stretchLength;
    final outerPos = Offset(outerX, outerY);

    // Buat paint dengan efek glow untuk energi ekstra
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Variasi ukuran untuk efek lebih dinamis
    final dynamic =
        enableBounce ? 1.0 + math.sin(phaseProgress * math.pi * 3) * 0.15 : 1.0;

    // Gambar lingkaran di kedua ujung
    canvas.drawCircle(innerPos, radius * dynamic, paint);
    canvas.drawCircle(outerPos, radius * 1.1 * dynamic, paint);

    // Gambar garis penghubung yang sedikit lebih lebar
    if (stretchLength > 0) {
      paint.strokeWidth = radius * 2 * dynamic;
      paint.strokeCap = StrokeCap.round;
      paint.style = PaintingStyle.stroke;
      canvas.drawLine(innerPos, outerPos, paint);
    }
  }

  /// Fase 3: Close Circle - Garis berubah kembali menjadi lingkaran
  void _paintClosePhase(Canvas canvas, Offset center, double angle,
      double phaseProgress, double radius, double lineLength, Color color) {
    // Gunakan kurva untuk gerakan yang lebih dinamis
    final curvedProgress = _elasticInOut(phaseProgress);

    // Posisi akhir outer (tetap)
    final outerX = center.dx + math.cos(angle) * lineLength;
    final outerY = center.dy + math.sin(angle) * lineLength;
    final outerPos = Offset(outerX, outerY);

    // Posisi inner bergerak dari fixed point menuju titik akhir
    final baseDistance = radius * 4 * (1.0 - curvedProgress);
    final innerX = center.dx + math.cos(angle) * baseDistance;
    final innerY = center.dy + math.sin(angle) * baseDistance;
    final innerPos = Offset(innerX, innerY);

    // Ukuran lingkaran sedikit bervariasi untuk efek lebih hidup
    final dynamic = 1.0 + math.sin(phaseProgress * math.pi * 2) * 0.1;

    // Buat paint
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Gambar lingkaran di outer point sedikit lebih besar
    canvas.drawCircle(outerPos, radius * 1.2 * dynamic, paint);

    // Jika masih dalam fase transisi, gambar juga inner circle dan line
    if (curvedProgress < 0.95) {
      // Gambar inner circle
      canvas.drawCircle(innerPos, radius * dynamic, paint);

      // Gambar line
      paint.strokeWidth = radius * 2 * dynamic;
      paint.strokeCap = StrokeCap.round;
      paint.style = PaintingStyle.stroke;
      canvas.drawLine(innerPos, outerPos, paint);
    }
  }

  /// Fase 4: Bloom & Fade - Lingkaran akhir membesar dan memudar
  void _paintBloomFadePhase(
      Canvas canvas,
      Offset center,
      double angle,
      double phaseProgress,
      double radius,
      double lineLength,
      double maxScale,
      Color color,
      bool enableBounce) {
    // Gunakan kurva elastic untuk bloom yang lebih bertenaga
    final bloomCurve = enableBounce
        ? _elasticOut(math.min(1.0, phaseProgress * 1.5))
        : _easeInOut(phaseProgress);

    // Gunakan kurva terpisah untuk fade
    final fadeProgress = _easeInOut(phaseProgress);

    // Hitung scale factor - membesar dengan "bounce" kemudian mengecil
    double scaleFactor;
    if (phaseProgress < 0.4) {
      // 0-40%: Membesar hingga maxScale dengan bounce
      scaleFactor = 1.0 + (maxScale - 1.0) * bloomCurve;
    } else {
      // 40-100%: Sedikit mengecil dari maxScale
      scaleFactor = maxScale - ((phaseProgress - 0.4) / 0.6) * (maxScale * 0.3);
    }

    // Posisi akhir dengan sedikit "dance" untuk efek lebih hidup
    double finalX, finalY;
    if (enableBounce) {
      // Tambahkan sedikit gerakan circular pada fase akhir
      final wiggle = math.sin(phaseProgress * math.pi * 4) * radius * 0.4;
      final wiggleAngle = angle + (math.pi / 2); // Orthogonal to radius

      finalX = center.dx +
          math.cos(angle) * lineLength +
          math.cos(wiggleAngle) * wiggle;
      finalY = center.dy +
          math.sin(angle) * lineLength +
          math.sin(wiggleAngle) * wiggle;
    } else {
      finalX = center.dx + math.cos(angle) * lineLength;
      finalY = center.dy + math.sin(angle) * lineLength;
    }

    final finalPos = Offset(finalX, finalY);

    // Opacity menurun dari 1 ke 0 dengan kurva yang lebih menarik
    final opacity =
        phaseProgress < 0.4 ? 1.0 : 1.0 - ((phaseProgress - 0.4) / 0.6);

    // Buat paint dengan opacity
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    // Gambar lingkaran dengan radius yang disesuaikan
    canvas.drawCircle(finalPos, radius * scaleFactor, paint);

    // Tambahkan efek "echo" untuk lingkaran yang lebih besar
    if (phaseProgress > 0.2 && phaseProgress < 0.8) {
      final echoProgress = (phaseProgress - 0.2) / 0.6;
      final echoOpacity = 0.3 * (1.0 - echoProgress);
      final echoScale = scaleFactor * (1.0 + echoProgress * 0.5);

      canvas.drawCircle(
          finalPos,
          radius * echoScale,
          Paint()
            ..color = color.withOpacity(echoOpacity)
            ..style = PaintingStyle.stroke
            ..strokeWidth = radius * 0.3);
    }
  }

  // Fungsi ease untuk animasi yang lebih halus dan menarik
  double _easeOut(double t) {
    return 1.0 - (1.0 - t) * (1.0 - t) * (1.0 - t);
  }

  double _easeIn(double t) {
    return t * t * t;
  }

  double _easeInOut(double t) {
    return t < 0.5 ? 4 * t * t * t : 1 - math.pow(-2 * t + 2, 3) / 2;
  }

  // Bouncy elastic functions for more energetic animation
  double _elasticOut(double t) {
    const c4 = (2 * math.pi) / 3;

    if (t == 0 || t == 1) return t;
    return math.pow(2, -10 * t) * math.sin((t * 10 - 0.75) * c4) + 1;
  }

  double _elasticInOut(double t) {
    const c5 = (2 * math.pi) / 4.5;

    if (t == 0 || t == 1) return t;

    if (t < 0.5) {
      return -(math.pow(2, 20 * t - 10) * math.sin((20 * t - 11.125) * c5)) / 2;
    }
    return (math.pow(2, -20 * t + 10) * math.sin((20 * t - 11.125) * c5)) / 2 +
        1;
  }

  double _bouncyEaseOut(double t) {
    if (t < 4 / 11) {
      return (121 * t * t) / 16;
    } else if (t < 8 / 11) {
      return (363 / 40 * t * t) - (99 / 10 * t) + 17 / 5;
    } else if (t < 9 / 10) {
      return (4356 / 361 * t * t) - (35442 / 1805 * t) + 16061 / 1805;
    } else {
      return (54 / 5 * t * t) - (513 / 25 * t) + 268 / 25;
    }
  }

  @override
  bool shouldRepaint(EffectAnimator oldAnimator) {
    return oldAnimator is! RadialFireworkAnimator ||
        oldAnimator.elementCount != elementCount ||
        oldAnimator.circleRadius != circleRadius ||
        oldAnimator.lineLength != lineLength ||
        oldAnimator.finalScale != finalScale ||
        oldAnimator.enableSparkles != enableSparkles ||
        oldAnimator.enableColorShift != enableColorShift ||
        oldAnimator.enableExtraBounce != enableExtraBounce;
  }

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  @override
  double getDefaultRadiusMultiplier() => 1.0;

  @override
  double getOuterPadding() =>
      lineLength * 1.5 + (circleRadius * finalScale * 2);
}

// 1. Ray Animator - animasi pancaran cahaya bergaya kartun
class RayAnimator implements EffectAnimator {
  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final adjustedCenter = center + positionOffset;
    final maxRadius =
        math.min(size.width, size.height) * 0.7 * radiusMultiplier;

    // Jumlah pancaran
    final rayCount = 12;
    final rayLength = maxRadius * progress;
    final innerRadius = maxRadius * 0.3 * (1 - progress);

    // Paint untuk ray
    final rayPaint = Paint()
      ..color = color.withOpacity((1 - progress) * 0.9)
      ..strokeWidth = 4.0 * (1 - progress * 0.5) // Lebih tebal di awal
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Gambar rays dengan gaya kartun (tidak rata)
    for (int i = 0; i < rayCount; i++) {
      final angle = (i * 2 * math.pi / rayCount);
      final zigzag = math.sin(angle * 8) * 5; // Efek zig-zag kartun

      // Titik awal dan akhir ray
      final startX = adjustedCenter.dx + innerRadius * math.cos(angle);
      final startY = adjustedCenter.dy + innerRadius * math.sin(angle);
      final endX = adjustedCenter.dx + (rayLength + zigzag) * math.cos(angle);
      final endY = adjustedCenter.dy + (rayLength + zigzag) * math.sin(angle);

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        rayPaint,
      );

      // Titik bulat di ujung untuk gaya kartun
      if (progress < 0.7) {
        canvas.drawCircle(
          Offset(endX, endY),
          3.0 * (1 - progress),
          Paint()..color = color.withOpacity((1 - progress) * 0.9),
        );
      }
    }

    // Efek "blink" cepat - lingkaran yang muncul dan menghilang
    if (progress < 0.3) {
      canvas.drawCircle(
        adjustedCenter,
        maxRadius * 0.2 * (1 - progress / 0.3),
        Paint()..color = color.withOpacity(0.7 * (1 - progress / 0.3)),
      );
    }
  }

  @override
  bool shouldRepaint(EffectAnimator oldAnimator) => true;

  @override
  AnimationPosition getDefaultPosition() {
    return AnimationPosition.outside;
  }

  @override
  double getDefaultRadiusMultiplier() => 1.5;

  @override
  double getOuterPadding() => 20.0;
}

// 2. Whirlpool Animator - animasi pusaran air
class WhirlpoolAnimator implements EffectAnimator {
  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final adjustedCenter = center + positionOffset;
    final maxRadius =
        math.min(size.width, size.height) * 0.6 * radiusMultiplier;

    // Pengaturan pusaran
    final rotations = 2 + progress * 3; // Berputar semakin cepat
    final spiralCount = 1; // Jumlah spiral

    // Paint untuk pusaran
    final spiralPaint = Paint()
      ..color = color.withOpacity(math.max(0, 1 - progress * 1.3))
      ..strokeWidth = 6 * (1 - progress * 0.5) // Tebal di awal, tipis di akhir
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int s = 0; s < spiralCount; s++) {
      final path = Path();
      final startAngle = s * (math.pi * 2 / spiralCount);

      // Mulai dari tengah
      bool first = true;

      // Gambar spiral dengan variasi ketebalan untuk efek kartun
      for (double t = 0.01; t < 1.0; t += 0.01) {
        final scale = t * progress * 2.0; // Scale dari 0 ke progress*2
        final r = maxRadius * scale;
        final angle = startAngle + rotations * math.pi * 2 * t;

        // Tambahkan variasi pada radius untuk efek kartun tidak rata
        final radiusVariation = math.sin(t * 20) * 5.0;
        final adjustedRadius = r + radiusVariation;

        final x = adjustedCenter.dx + math.cos(angle) * adjustedRadius;
        final y = adjustedCenter.dy + math.sin(angle) * adjustedRadius;

        if (first) {
          path.moveTo(x, y);
          first = false;
        } else {
          path.lineTo(x, y);
        }
      }

      canvas.drawPath(path, spiralPaint);
    }

    // Tambahkan gelembung untuk efek kartun
    if (progress < 0.7) {
      final bubblePaint = Paint()
        ..color = color.withOpacity(0.6 * (1 - progress))
        ..style = PaintingStyle.fill;

      // Beberapa gelembung acak
      final random = math.Random(
          42); // Seed tetap agar gelembung muncul di tempat yang sama
      for (int i = 0; i < 8; i++) {
        final bubbleProgress = (progress + i / 20) % 1.0;
        final startAngle = 0.0; // Define a default starting angle
        final angle = startAngle + rotations * math.pi * 2 * bubbleProgress;
        final r = maxRadius * bubbleProgress * 0.8;

        final bubbleX = adjustedCenter.dx + math.cos(angle) * r;
        final bubbleY = adjustedCenter.dy + math.sin(angle) * r;
        final bubbleSize =
            5.0 * (1.0 - bubbleProgress) * (1 + random.nextDouble());

        canvas.drawCircle(
          Offset(bubbleX, bubbleY),
          bubbleSize,
          bubblePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(EffectAnimator oldAnimator) => true;

  @override
  AnimationPosition getDefaultPosition() {
    return AnimationPosition.outside;
  }

  @override
  double getDefaultRadiusMultiplier() => 1.4;

  @override
  double getOuterPadding() => 15.0;
}

// 3. Landing Thud Lines Animator - garis getaran saat mendarat
class LandingThudLinesAnimator implements EffectAnimator {
  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final adjustedCenter = center + positionOffset;
    final maxRadius =
        math.min(size.width, size.height) * 0.5 * radiusMultiplier;

    // Hanya gambar di setengah bagian akhir animasi
    final thudProgress = math.max(0, (progress - 0.5) * 2);
    if (thudProgress <= 0) return;

    // Efek getaran - hilang cepat di akhir
    final opacity = math.max(0, 1 - thudProgress * 2);

    // Paint untuk garis
    final linePaint = Paint()
      ..color = color.withOpacity(opacity as double)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Gambar garis horizontal getaran di sekitar
    final lineCount = 12;
    final maxLineLength = maxRadius * 0.5;

    for (int i = 0; i < lineCount; i++) {
      final angle = (i * 2 * math.pi / lineCount);
      final distance = maxRadius * (0.8 + 0.2 * math.sin(progress * 10));

      // Titik awal garis
      final centerX = adjustedCenter.dx + distance * math.cos(angle);
      final centerY = adjustedCenter.dy + distance * math.sin(angle);

      // Garis horizontal bergelombang
      final wobble = math.sin(progress * 30) * 5 * (1 - thudProgress);
      final lineLength = maxLineLength * (1 - thudProgress);

      // Gambar garis dengan efek bergetar
      canvas.drawLine(
        Offset(centerX - lineLength / 2, centerY + wobble),
        Offset(centerX + lineLength / 2, centerY - wobble),
        linePaint,
      );
    }

    // Tambah teks "THUD!" jika progress di awal efek
    if (thudProgress < 0.3) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'THUD!',
          style: TextStyle(
            color: color.withOpacity(opacity * 1.5),
            fontSize: 16 * (1 - thudProgress / 0.3),
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          adjustedCenter.dx + maxRadius * 0.5,
          adjustedCenter.dy - maxRadius * 0.3,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(EffectAnimator oldAnimator) => true;

  @override
  AnimationPosition getDefaultPosition() {
    return AnimationPosition.bottom;
  }

  @override
  double getDefaultRadiusMultiplier() => 1.5;

  @override
  double getOuterPadding() => 25.0;
}

// 4. Cushion Bounce Animator - efek widget mendarat di bantal
class CushionBounceAnimator implements EffectAnimator {
  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final adjustedCenter = center + positionOffset;

    // Ukuran bantalan sedikit lebih besar dari widget
    final cushionWidth = size.width * 1.3 * radiusMultiplier;
    final cushionHeight = size.height * 0.4 * radiusMultiplier;

    // Animasi bantalan - tertekan lalu memantul
    double compression;
    double yOffset;

    if (progress < 0.4) {
      // Fase 1: Tekanan awal - bantalan tertekan
      compression = progress / 0.4; // 0 -> 1
      yOffset = compression * cushionHeight * 0.6;
    } else if (progress < 0.7) {
      // Fase 2: Pemulihan - bantalan memantul
      final bounceProgress = (progress - 0.4) / 0.3; // 0 -> 1
      compression = 1 - bounceProgress * 1.2; // 1 -> -0.2 (overshoot)
      yOffset = compression * cushionHeight * 0.6;
    } else {
      // Fase 3: Penstabilan - getaran kecil
      final settleProgress = (progress - 0.7) / 0.3; // 0 -> 1
      compression = -0.2 +
          math.sin(settleProgress * math.pi * 3) * 0.15 * (1 - settleProgress);
      yOffset = compression * cushionHeight * 0.6;
    }

    // Bantalan berada di bawah widget
    final cushionTop = adjustedCenter.dy + size.height / 2 - cushionHeight / 2;

    // Paint untuk bantalan
    final cushionPaint = Paint()
      ..color = color.withOpacity(math.max(0, 1 - progress * 1.2))
      ..style = PaintingStyle.fill;

    // Gambar bantalan yang bergelombang
    final cushionPath = Path();

    // Titik kontrol untuk kurva bantalan
    final leftX = adjustedCenter.dx - cushionWidth / 2;
    final rightX = adjustedCenter.dx + cushionWidth / 2;
    final topY = cushionTop + yOffset * 0.5;
    final bottomY = cushionTop + cushionHeight;
    final midY = topY + (compression * cushionHeight * 0.5);

    // Buat kurva bantalan dengan efek kartun yang dilebih-lebihkan
    cushionPath.moveTo(leftX, topY);
    cushionPath.quadraticBezierTo(
        adjustedCenter.dx - cushionWidth / 4, midY, adjustedCenter.dx, topY);
    cushionPath.quadraticBezierTo(
        adjustedCenter.dx + cushionWidth / 4, midY, rightX, topY);

    // Bagian bawah bantalan
    cushionPath.lineTo(rightX, bottomY);
    cushionPath.lineTo(leftX, bottomY);
    cushionPath.close();

    canvas.drawPath(cushionPath, cushionPaint);

    // Tambahkan garis-garis bergelombang pada bantalan untuk efek kartun
    if (progress < 0.8) {
      final linePaint = Paint()
        ..color = color.withOpacity(0.3 * (1 - progress))
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      // Garis-garis horizontal yang bergelombang
      final lineCount = 3;
      final lineSpacing = cushionHeight / (lineCount + 1);

      for (int i = 1; i <= lineCount; i++) {
        final lineY = cushionTop + i * lineSpacing;
        final wavePath = Path();

        wavePath.moveTo(leftX, lineY);

        // Buat gelombang dengan ampiltudo berdasarkan kompresi
        final waveCount = 5;
        final waveWidth = cushionWidth / waveCount;

        for (int j = 0; j <= waveCount; j++) {
          final waveX = leftX + j * waveWidth;
          final waveY = lineY + math.sin(j * math.pi) * compression * 10;

          if (j == 0) {
            wavePath.moveTo(waveX, waveY);
          } else {
            wavePath.lineTo(waveX, waveY);
          }
        }

        canvas.drawPath(wavePath, linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(EffectAnimator oldAnimator) => true;

  @override
  AnimationPosition getDefaultPosition() {
    return AnimationPosition.bottom;
  }

  @override
  double getDefaultRadiusMultiplier() => 1.3;

  @override
  double getOuterPadding() => 30.0;
}

// 1. PULSE WAVE ANIMATOR
class PulseWaveAnimator implements EffectAnimator {
  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final adjustedCenter = center + positionOffset;

    // Jumlah gelombang
    final int waveCount = 3;

    for (int i = 0; i < waveCount; i++) {
      // Stagger waves (menunda awal setiap gelombang)
      double waveProgress = progress - (i * 0.3);
      if (waveProgress < 0 || waveProgress > 1) continue;

      final Paint wavePaint = Paint()
        ..color = color.withOpacity(1.0 - waveProgress)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0 * (1.0 - waveProgress);

      // Radius yang membesar seiring waktu
      double radius = size.width * radiusMultiplier * waveProgress;

      canvas.drawCircle(adjustedCenter, radius, wavePaint);
    }
  }

  @override
  bool shouldRepaint(EffectAnimator oldAnimator) => true;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  @override
  double getDefaultRadiusMultiplier() => 1.0;

  @override
  double getOuterPadding() => 20.0;
}

// 2. SPARKLE EFFECT ANIMATOR
class SparkleEffectAnimator implements EffectAnimator {
  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final adjustedCenter = center + positionOffset;
    final random = math.Random(42); // Seed tetap untuk konsistensi

    // Jumlah sparkle
    final int sparkleCount = 20;
    final double radius = size.width * 0.5 * radiusMultiplier;

    for (int i = 0; i < sparkleCount; i++) {
      // Membuat variasi waktu muncul/hilang untuk setiap sparkle
      double sparkleOffset = random.nextDouble() * 0.5;
      double sparkleProgress = (progress - sparkleOffset) * 2;

      // Hanya muncul pada progress tertentu
      if (sparkleProgress < 0 || sparkleProgress > 1) continue;

      // Opacity yang naik lalu turun (berbentuk kurva)
      double opacity = math.sin(sparkleProgress * math.pi);

      // Koordinat sparkle - acak dalam radius tertentu dan pergerakan
      double angle = random.nextDouble() * math.pi * 2;
      double distance = radius * (0.6 + random.nextDouble() * 0.4);
      double movement = 0.2 * math.sin(progress * math.pi * 4 + i);

      final Offset sparklePos = Offset(
        adjustedCenter.dx + math.cos(angle) * (distance + movement * 10),
        adjustedCenter.dy + math.sin(angle) * (distance + movement * 10),
      );

      // Ukuran sparkle bervariasi
      double sparkleSize = 2.0 + random.nextDouble() * 2.0;

      // Warna sparkle - sedikit variasi dari warna dasar
      final Color sparkleColor = color
          .withRed(math.min(255, color.red + random.nextInt(30)))
          .withGreen(math.min(255, color.green + random.nextInt(30)))
          .withBlue(math.min(255, color.blue + random.nextInt(30)))
          .withOpacity(opacity);

      // Menggambar sparkle
      canvas.drawCircle(sparklePos, sparkleSize * sparkleProgress,
          Paint()..color = sparkleColor);

      // Tambahkan highlight jika opacity cukup tinggi
      if (opacity > 0.7) {
        canvas.drawCircle(sparklePos, sparkleSize * 0.5 * sparkleProgress,
            Paint()..color = Colors.white.withOpacity(opacity));
      }
    }
  }

  @override
  bool shouldRepaint(EffectAnimator oldAnimator) => true;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  @override
  double getDefaultRadiusMultiplier() => 1.1;

  @override
  double getOuterPadding() => 12.0;
}

// 3. LIGHTNING ANIMATOR
class LightningAnimator implements EffectAnimator {
  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final adjustedCenter = center + positionOffset;
    final random = math.Random(42); // Konsistensi antar frame

    // Jumlah petir
    final int lightningCount = 8;

    for (int i = 0; i < lightningCount; i++) {
      // Membuat pergerakan petir - muncul cepat, hilang perlahan
      double lightningTiming = progress * 1.2;
      if (lightningTiming < 0.1 + (i * 0.05) || lightningTiming > 0.9) continue;

      // Opacity tertinggi di tengah proses animasi
      double opacity = 1.0;
      if (lightningTiming > 0.6) {
        opacity = 1.0 - ((lightningTiming - 0.6) / 0.4);
      }

      // Paint untuk petir
      final Paint lightningPaint = Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;

      // Sudut untuk setiap petir
      final double angle = (i * (360 / lightningCount)) * (math.pi / 180);

      // Menggambar petir dengan path
      final Path lightningPath = Path();

      // Titik awal di dekat widget
      lightningPath.moveTo(
          adjustedCenter.dx + math.cos(angle) * size.width * 0.4,
          adjustedCenter.dy + math.sin(angle) * size.width * 0.4);

      // Jumlah segmen zigzag
      final int segments = 4;
      double currentLength = size.width * 0.4;
      double targetLength = size.width * 0.6 * radiusMultiplier;

      double currentAngle = angle;

      for (int j = 0; j < segments; j++) {
        // Variasi sudut dengan zigzag
        currentAngle += (random.nextDouble() - 0.5) * math.pi / 4;

        // Panjang segmen berikutnya
        double segmentLength = (targetLength - currentLength) / (segments - j);
        currentLength += segmentLength;

        // Titik berikutnya
        final Offset nextPoint = Offset(
            adjustedCenter.dx + math.cos(currentAngle) * currentLength,
            adjustedCenter.dy + math.sin(currentAngle) * currentLength);

        lightningPath.lineTo(nextPoint.dx, nextPoint.dy);
      }

      // Menggambar petir
      canvas.drawPath(lightningPath, lightningPaint);

      // Menambahkan glow effect
      canvas.drawPath(
          lightningPath,
          Paint()
            ..color = color.withOpacity(opacity * 0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4.0
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4.0));
    }
  }

  @override
  bool shouldRepaint(EffectAnimator oldAnimator) => true;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  @override
  double getDefaultRadiusMultiplier() => 1.1;

  @override
  double getOuterPadding() => 15.0;
}

// 5. ROTATING ORBS ANIMATOR
class RotatingOrbsAnimator implements EffectAnimator {
  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final adjustedCenter = center + positionOffset;

    // Jumlah orbs
    final int orbCount = 5;

    // Radius orbit
    final double orbitRadius = size.width * 0.65 * radiusMultiplier;

    // Pengaturan fade-in dan fade-out
    double opacity = 1.0;
    if (progress < 0.2) {
      opacity = progress / 0.2; // Fade in
    } else if (progress > 0.8) {
      opacity = 1.0 - ((progress - 0.8) / 0.2); // Fade out
    }

    for (int i = 0; i < orbCount; i++) {
      // Sudut awal berbeda untuk setiap orb
      final double startAngle = (i * (360 / orbCount)) * (math.pi / 180);

      // Kecepatan rotasi bervariasi
      final double rotationSpeed = 1.0 + (i * 0.2);

      // Sudut saat ini (rotasi)
      final double currentAngle =
          startAngle + (progress * math.pi * 2 * rotationSpeed);

      // Radius orb bervariasi dan berubah seiring waktu
      final double orbRadius = 3.0 + math.sin(progress * math.pi * 4 + i) * 2.0;

      // Posisi orb saat ini
      final Offset orbPosition = Offset(
          adjustedCenter.dx + math.cos(currentAngle) * orbitRadius,
          adjustedCenter.dy + math.sin(currentAngle) * orbitRadius);

      // Paint untuk orb
      final Paint orbPaint = Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      // Paint untuk glow
      final Paint glowPaint = Paint()
        ..color = color.withOpacity(opacity * 0.5)
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4.0);

      // Menggambar glow dan orb
      canvas.drawCircle(orbPosition, orbRadius * 1.5, glowPaint);
      canvas.drawCircle(orbPosition, orbRadius, orbPaint);

      // Menambahkan jejak cahaya (trail)
      final int trailCount = 5;
      for (int j = 1; j <= trailCount; j++) {
        final double trailOpacity = opacity * (1.0 - (j / trailCount));
        final double trailAngle = currentAngle - (j * 0.1);

        final Offset trailPosition = Offset(
            adjustedCenter.dx + math.cos(trailAngle) * orbitRadius,
            adjustedCenter.dy + math.sin(trailAngle) * orbitRadius);

        canvas.drawCircle(
            trailPosition,
            orbRadius * (1.0 - (j / trailCount) * 0.5),
            Paint()..color = color.withOpacity(trailOpacity));
      }
    }
  }

  @override
  bool shouldRepaint(EffectAnimator oldAnimator) => true;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  @override
  double getDefaultRadiusMultiplier() => 1.2;

  @override
  double getOuterPadding() => 18.0;
}

// 6. EXPLODING STARS ANIMATOR
class ExplodingStarsAnimator implements EffectAnimator {
  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final adjustedCenter = center + positionOffset;
    final random = math.Random(42); // Konsistensi antar frame

    // Jumlah bintang
    final int starCount = 15;

    // Fase 1: Concentrating (0-0.2)
    // Fase 2: Explosion (0.2-0.6)
    // Fase 3: Fading (0.6-1.0)

    for (int i = 0; i < starCount; i++) {
      // Sudut yang random tapi konsisten
      final double angle = random.nextDouble() * math.pi * 2;

      // Ukuran bintang yang bervariasi
      final double starSize = 3.0 + random.nextDouble() * 5.0;

      // Jarak maksimum untuk eksplosii
      final double maxDistance = size.width * 0.7 * radiusMultiplier;

      // Posisi awal dan akhir
      final Offset startPos = adjustedCenter;

      double currentDistance;
      double opacity;

      if (progress < 0.2) {
        // Fase 1: Bergerak ke pusat
        currentDistance = maxDistance * 0.2;
        opacity = progress / 0.2;
      } else if (progress < 0.6) {
        // Fase 2: Explosion
        double explosionProgress = (progress - 0.2) / 0.4;
        currentDistance = maxDistance * explosionProgress;
        opacity = 1.0;
      } else {
        // Fase 3: Fading out
        double fadeProgress = (progress - 0.6) / 0.4;
        currentDistance = maxDistance;
        opacity = 1.0 - fadeProgress;
      }

      // Posisi bintang saat ini
      final Offset starPos = Offset(
          adjustedCenter.dx +
              math.cos(angle) *
                  currentDistance *
                  (0.5 + random.nextDouble() * 0.5),
          adjustedCenter.dy +
              math.sin(angle) *
                  currentDistance *
                  (0.5 + random.nextDouble() * 0.5));

      // Menggambar bintang
      _drawStar(
          canvas,
          starPos,
          starSize,
          5, // jumlah titik bintang
          color.withOpacity(opacity));
    }
  }

  // Helper untuk menggambar bintang
  void _drawStar(
      Canvas canvas, Offset center, double size, int points, Color color) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final double outerRadius = size;
    final double innerRadius = size * 0.5;
    final double step = math.pi / points;

    final Path path = Path();

    for (int i = 0; i < points * 2; i++) {
      final double radius = i % 2 == 0 ? outerRadius : innerRadius;
      final double angle = i * step;

      final double x = center.dx + math.cos(angle) * radius;
      final double y = center.dy + math.sin(angle) * radius;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(EffectAnimator oldAnimator) => true;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  @override
  double getDefaultRadiusMultiplier() => 1.2;

  @override
  double getOuterPadding() => 20.0;
}

// 7. RIPPLE RINGS ANIMATOR
class RippleRingsAnimator implements EffectAnimator {
  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final adjustedCenter = center + positionOffset;

    // Jumlah gelombang/cincin
    final int ringCount = 4;

    for (int i = 0; i < ringCount; i++) {
      // Variasi waktu muncul untuk setiap cincin
      double ringOffset = i * 0.2;
      double ringProgress = (progress - ringOffset);

      // Hanya gambar cincin yang sudah dimulai
      if (ringProgress <= 0 || ringProgress >= 1) continue;

      // Opacity tertinggi di awal, lalu memudar
      double opacity = 1.0 - ringProgress;

      // Lebar garis gelombang - semakin tipis seiring waktu
      double strokeWidth = 3.0 * (1.0 - ringProgress * 0.7);

      // Radius cincin yang membesar seiring waktu
      double radius = size.width * radiusMultiplier * 0.8 * ringProgress;

      // Menggambar cincin
      canvas.drawCircle(
          adjustedCenter,
          radius,
          Paint()
            ..color = color.withOpacity(opacity)
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth);

      // Menggambar efek percikan (ripple distortion)
      if (ringProgress > 0.1 && ringProgress < 0.9) {
        final int splashCount = 6;
        for (int j = 0; j < splashCount; j++) {
          final double splashAngle =
              (j * (360 / splashCount)) * (math.pi / 180);
          final double distortion = 4.0 * math.sin(ringProgress * math.pi + j);

          final Offset splashPos = Offset(
              adjustedCenter.dx + math.cos(splashAngle) * (radius + distortion),
              adjustedCenter.dy +
                  math.sin(splashAngle) * (radius + distortion));

          canvas.drawCircle(splashPos, 2.0 * (1.0 - ringProgress),
              Paint()..color = color.withOpacity(opacity * 0.7));
        }
      }
    }
  }

  @override
  bool shouldRepaint(EffectAnimator oldAnimator) => true;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  @override
  double getDefaultRadiusMultiplier() => 1.2;

  @override
  double getOuterPadding() => 22.0;
}

// 8. ENERGY FIELD ANIMATOR
class EnergyFieldAnimator implements EffectAnimator {
  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    // Aplikasikan offset ke center
    final adjustedCenter = center + positionOffset;

    // Menentukan radius bidang energi
    final double energyFieldRadius = size.width * 0.55 * radiusMultiplier;

    // Menentukan jumlah garis energi
    final int lineCount = 24;

    // Variasi amplitudo gelombang
    final double baseAmplitude = 8.0;
    final double amplitudeVariation = 4.0 * math.sin(progress * math.pi * 4);

    // Warna dengan opacity yang berdasarkan progress
    final Paint energyPaint = Paint()
      ..color = color.withOpacity(0.8 - 0.5 * math.sin(progress * math.pi))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Menggambar bidang energi dasar (lingkaran)
    canvas.drawCircle(
        adjustedCenter,
        energyFieldRadius * (0.9 + 0.1 * math.sin(progress * math.pi * 2)),
        Paint()
          ..color = color.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0);

    // Menggambar garis-garis energi
    for (int i = 0; i < lineCount; i++) {
      final double angle = (i * (360 / lineCount)) * (math.pi / 180);
      final double rotation = angle + (progress * math.pi * 2);

      // Titik awal dan akhir untuk path
      final Offset startPoint = Offset(
        adjustedCenter.dx + math.cos(rotation) * energyFieldRadius * 0.8,
        adjustedCenter.dy + math.sin(rotation) * energyFieldRadius * 0.8,
      );

      final Offset endPoint = Offset(
        adjustedCenter.dx + math.cos(rotation) * energyFieldRadius * 1.2,
        adjustedCenter.dy + math.sin(rotation) * energyFieldRadius * 1.2,
      );

      // Membuat path zigzag untuk garis energi
      final Path energyPath = Path()..moveTo(startPoint.dx, startPoint.dy);

      // Jumlah segmen zigzag
      final int segments = 6;
      final double segmentLength = 1.0 / segments;

      for (int j = 1; j <= segments; j++) {
        final double t = j * segmentLength;
        final double lerpX = _lerp(startPoint.dx, endPoint.dx, t);
        final double lerpY = _lerp(startPoint.dy, endPoint.dy, t);

        // Menambahkan variasi berdasarkan waktu dan posisi
        final double waveOffset = math.sin(progress * math.pi * 8 + i) *
            (baseAmplitude + amplitudeVariation);

        // Tegak lurus terhadap garis utama untuk efek zigzag
        final double perpX =
            -math.sin(rotation) * waveOffset * (j % 2 == 0 ? 1 : -1);
        final double perpY =
            math.cos(rotation) * waveOffset * (j % 2 == 0 ? 1 : -1);

        energyPath.lineTo(lerpX + perpX, lerpY + perpY);
      }

      // Menggambar garis energi
      canvas.drawPath(energyPath, energyPaint);

      // Menambahkan titik-titik energi pada beberapa sudut
      if (i % 4 == 0) {
        final double pointRadius =
            2.0 + math.sin(progress * math.pi * 6 + i) * 1.5;
        final Offset pointPosition = Offset(
          adjustedCenter.dx +
              math.cos(rotation) *
                  energyFieldRadius *
                  (1.0 + 0.2 * math.sin(progress * math.pi * 3 + i)),
          adjustedCenter.dy +
              math.sin(rotation) *
                  energyFieldRadius *
                  (1.0 + 0.2 * math.sin(progress * math.pi * 3 + i)),
        );

        canvas.drawCircle(
            pointPosition,
            pointRadius,
            Paint()
              ..color = color.withOpacity(0.7)
              ..style = PaintingStyle.fill);
      }
    }

    // Menggambar efek pulsa dalam
    final double innerPulseRadius = energyFieldRadius *
        0.5 *
        (0.8 + 0.2 * math.sin(progress * math.pi * 6));

    canvas.drawCircle(
        adjustedCenter,
        innerPulseRadius,
        Paint()
          ..color = color.withOpacity(0.2)
          ..style = PaintingStyle.fill);
  }

  // Helper untuk linear interpolation
  double _lerp(double a, double b, double t) {
    return a + (b - a) * t;
  }

  @override
  bool shouldRepaint(EffectAnimator oldAnimator) => true;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  @override
  double getDefaultRadiusMultiplier() => 1.2;

  @override
  double getOuterPadding() => 25.0;
}

class ParticleSwarmAnimator implements EffectAnimator {
  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final adjustedCenter = center + positionOffset;
    final random = math.Random(42); // Konsistensi antar frame

    // Jumlah partikel
    final int particleCount = 30;

    // Radius orbit
    final double swarmRadius = size.width * 0.6 * radiusMultiplier;

    // Pengaturan fase
    final bool isFormingPhase = progress < 0.3;
    final bool isOrbitPhase = progress >= 0.3 && progress < 0.7;
    final bool isDispersalPhase = progress >= 0.7;

    for (int i = 0; i < particleCount; i++) {
      // Seed untuk partikel ini
      final int particleSeed = i * 1000;

      // Sudut dasar dan noise
      final double baseAngle = (i * (360 / particleCount)) * (math.pi / 180);
      final double noiseAngle = math.sin(progress * math.pi * 2 + i) * 0.5;

      // Posisi dan ukuran partikel
      Offset particlePos;
      double particleSize;
      double opacity;

      if (isFormingPhase) {
        // Fase 1: Partikel bergerak dari luar menuju formasi
        double formingProgress = progress / 0.3;

        // Mulai dari posisi acak di luar, bergerak menuju posisi orbit
        double startDistance = swarmRadius * 1.5 * (1.0 - (i % 3) * 0.2);
        double currentDistance =
            _lerp(startDistance, swarmRadius, formingProgress);

        particlePos = Offset(
            adjustedCenter.dx +
                math.cos(baseAngle + noiseAngle) * currentDistance,
            adjustedCenter.dy +
                math.sin(baseAngle + noiseAngle) * currentDistance);

        particleSize = 2.0 + formingProgress * 2.0;
        opacity = formingProgress;
      } else if (isOrbitPhase) {
        // Fase 2: Bergerak dalam formasi orbit
        double orbitProgress = (progress - 0.3) / 0.4;

        // Orbit dengan variasi
        double orbitNoise = math.sin(orbitProgress * math.pi * 4 + i) * 0.2;
        double currentAngle =
            baseAngle + (orbitProgress * math.pi * 2) + orbitNoise;
        double currentDistance = swarmRadius *
            (0.9 + math.sin(orbitProgress * math.pi * 3 + i) * 0.2);

        particlePos = Offset(
            adjustedCenter.dx + math.cos(currentAngle) * currentDistance,
            adjustedCenter.dy + math.sin(currentAngle) * currentDistance);

        particleSize = 3.0 + math.sin(orbitProgress * math.pi * 3 + i) * 1.0;
        opacity = 1.0;
      } else {
        // Fase 3: Dispersal - partikel menyebar keluar
        double dispersalProgress = (progress - 0.7) / 0.3;

        // Menyebar dengan kecepatan berbeda
        double endDistance = swarmRadius * 2.0 * (1.0 + (i % 5) * 0.1);
        double currentDistance =
            _lerp(swarmRadius, endDistance, dispersalProgress);

        particlePos = Offset(
            adjustedCenter.dx +
                math.cos(baseAngle + noiseAngle) * currentDistance,
            adjustedCenter.dy +
                math.sin(baseAngle + noiseAngle) * currentDistance);

        particleSize = 3.0 * (1.0 - dispersalProgress * 0.7);
        opacity = 1.0 - dispersalProgress;
      }

      // Warna partikel dengan sedikit variasi
      final Color particleColor = color.withOpacity(opacity);

      // Menggambar partikel
      canvas.drawCircle(
          particlePos, particleSize, Paint()..color = particleColor);

      // Menambahkan blur/glow pada beberapa partikel
      if (i % 3 == 0) {
        canvas.drawCircle(
            particlePos,
            particleSize * 2.0,
            Paint()
              ..color = particleColor.withOpacity(opacity * 0.3)
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3.0));
      }
    }
  }

  // Helper untuk linear interpolation
  double _lerp(double a, double b, double t) {
    return a + (b - a) * t;
  }

  @override
  bool shouldRepaint(EffectAnimator oldAnimator) => true;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  @override
  double getDefaultRadiusMultiplier() => 1.3;

  @override
  double getOuterPadding() => 25.0;
}

// 10. SHOCKWAVE ANIMATOR
class ShockwaveAnimator implements EffectAnimator {
  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final adjustedCenter = center + positionOffset;

    // Fase animasi:
    // 1. Impact (0-0.2): Fokus ke dalam, distorsi minimal
    // 2. Ekspansi (0.2-0.7): Gelombang kejut menyebar
    // 3. Dissipation (0.7-1.0): Memudar perlahan

    // Radius maksimum untuk efek
    final double maxRadius = size.width * 0.7 * radiusMultiplier;

    if (progress < 0.2) {
      // FASE 1: Impact - kompresi
      double impactProgress = progress / 0.2;

      // Lingkaran dalam yang mengecil (menuju kompresi)
      double innerRadius = maxRadius * 0.3 * (1.0 - impactProgress);

      canvas.drawCircle(
          adjustedCenter,
          innerRadius,
          Paint()
            ..color = color.withOpacity(0.7 * impactProgress)
            ..style = PaintingStyle.fill);
    } else if (progress < 0.7) {
      // FASE 2: Ekspansi shockwave
      double expansionProgress = (progress - 0.2) / 0.5;

      // Radius yang membesar
      double waveRadius = maxRadius * expansionProgress;

      // Lebar gelombang - semakin lebar di awal lalu menyempit
      double waveThickness =
          15.0 * (1.0 - math.pow(expansionProgress, 2) as double);

      // Menggambar ring untuk shockwave
      canvas.drawCircle(
          adjustedCenter,
          waveRadius,
          Paint()
            ..color = color.withOpacity(0.8 * (1.0 - expansionProgress))
            ..style = PaintingStyle.stroke
            ..strokeWidth = waveThickness);

      // Menambahkan glow/blur efek
      canvas.drawCircle(
          adjustedCenter,
          waveRadius,
          Paint()
            ..color = color.withOpacity(0.5 * (1.0 - expansionProgress))
            ..style = PaintingStyle.stroke
            ..strokeWidth = waveThickness * 2
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8.0));

      // Menambahkan distorsi visual dengan pola zigzag
      final int distortionCount = 36;
      final double distortionAmount = 10.0 * (1.0 - expansionProgress);

      final Path distortionPath = Path();

      for (int i = 0; i < distortionCount; i++) {
        final double angle = (i * (360 / distortionCount)) * (math.pi / 180);

        double distanceVariation = distortionAmount *
            math.sin(angle * 3 + expansionProgress * math.pi * 4);

        final Offset pointPos = Offset(
            adjustedCenter.dx +
                math.cos(angle) * (waveRadius + distanceVariation),
            adjustedCenter.dy +
                math.sin(angle) * (waveRadius + distanceVariation));

        if (i == 0) {
          distortionPath.moveTo(pointPos.dx, pointPos.dy);
        } else {
          distortionPath.lineTo(pointPos.dx, pointPos.dy);
        }
      }

      // Menutup path
      distortionPath.close();

      canvas.drawPath(
          distortionPath,
          Paint()
            ..color = color.withOpacity(0.3 * (1.0 - expansionProgress))
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5);
    } else {
      // FASE 3: Dissipation - efek setelah shockwave
      double fadeProgress = (progress - 0.7) / 0.3;

      // Efek lingkaran luar yang memudar
      double fadeRadius = maxRadius * 1.1;

      canvas.drawCircle(
          adjustedCenter,
          fadeRadius,
          Paint()
            ..color = color.withOpacity(0.2 * (1.0 - fadeProgress))
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.5);

      // Particles/sparkles di sekitar area
      final int particleCount = 12;
      for (int i = 0; i < particleCount; i++) {
        final double angle = (i * (360 / particleCount)) * (math.pi / 180);
        final double particleDistance = fadeRadius * (0.8 + (i % 3) * 0.1);

        final Offset particlePos = Offset(
            adjustedCenter.dx + math.cos(angle) * particleDistance,
            adjustedCenter.dy + math.sin(angle) * particleDistance);

        // Partikel yang memudar
        canvas.drawCircle(particlePos, 2.0 * (1.0 - fadeProgress),
            Paint()..color = color.withOpacity(0.5 * (1.0 - fadeProgress)));
      }
    }
  }

  @override
  bool shouldRepaint(EffectAnimator oldAnimator) => true;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  @override
  double getDefaultRadiusMultiplier() => 1.2;

  @override
  double getOuterPadding() => 20.0;
}

class BubblePopAnimator implements EffectAnimator {
  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final adjustedCenter = center + positionOffset;
    final random = math.Random(42); // Konsistensi antar frame

    // Jumlah gelembung
    final int bubbleCount = 12;
    final double maxRadius = size.width * 0.6 * radiusMultiplier;

    for (int i = 0; i < bubbleCount; i++) {
      // Timing untuk setiap gelembung berbeda sedikit
      final double bubbleDelay = 0.05 * (i % 4);
      final double bubbleProgress = (progress - bubbleDelay).clamp(0.0, 1.0);

      // Skip jika belum waktunya muncul
      if (bubbleProgress <= 0) continue;

      // Posisi gelembung
      final double angle =
          (i * (360 / bubbleCount) + random.nextDouble() * 15) *
              (math.pi / 180);
      final double distance = maxRadius * (0.4 + random.nextDouble() * 0.6);

      final Offset bubblePos = Offset(
          adjustedCenter.dx + math.cos(angle) * distance,
          adjustedCenter.dy + math.sin(angle) * distance);

      // Lifecycle:
      // 0-0.7: Gelembung membesar
      // 0.7-0.8: Gelembung pecah
      // 0.8-1.0: Efek percikan

      if (bubbleProgress < 0.7) {
        // Fase Grow - gelembung membesar
        final double growProgress = bubbleProgress / 0.7;
        final double bubbleSize = 5.0 + (15.0 * growProgress);

        // Warna gelembung dengan opacity yang meningkat
        final double opacity = 0.3 + (0.5 * growProgress);

        // Menggambar gelembung
        canvas.drawCircle(
            bubblePos,
            bubbleSize,
            Paint()
              ..color = color.withOpacity(opacity)
              ..style = PaintingStyle.fill);

        // Highlight dalam gelembung
        final Offset highlightPos = Offset(
            bubblePos.dx - bubbleSize * 0.3, bubblePos.dy - bubbleSize * 0.3);

        canvas.drawCircle(highlightPos, bubbleSize * 0.25,
            Paint()..color = Colors.white.withOpacity(opacity * 0.8));
      } else if (bubbleProgress < 0.8) {
        // Fase Pop - gelembung pecah
        final double popProgress = (bubbleProgress - 0.7) / 0.1;

        // Membuat bentuk gelembung pecah dengan path
        final Path burstPath = Path();
        final double burstRadius = 15.0 + (5.0 * popProgress);

        final int fragments = 8;
        for (int j = 0; j < fragments; j++) {
          final double fragAngle = (j * (360 / fragments)) * (math.pi / 180);
          final double innerRadius = burstRadius * 0.5;
          final double outerRadius = burstRadius * (1.0 + 0.5 * popProgress);

          final Offset innerPoint = Offset(
              bubblePos.dx + math.cos(fragAngle) * innerRadius,
              bubblePos.dy + math.sin(fragAngle) * innerRadius);

          final Offset outerPoint = Offset(
              bubblePos.dx + math.cos(fragAngle) * outerRadius,
              bubblePos.dy + math.sin(fragAngle) * outerRadius);

          if (j == 0) {
            burstPath.moveTo(innerPoint.dx, innerPoint.dy);
          } else {
            burstPath.lineTo(innerPoint.dx, innerPoint.dy);
          }

          burstPath.lineTo(outerPoint.dx, outerPoint.dy);
          burstPath.lineTo(
              bubblePos.dx +
                  math.cos(fragAngle + (math.pi / fragments)) * innerRadius,
              bubblePos.dy +
                  math.sin(fragAngle + (math.pi / fragments)) * innerRadius);
        }

        burstPath.close();

        // Menggambar pecahan gelembung
        canvas.drawPath(
            burstPath,
            Paint()
              ..color = color.withOpacity(0.7 * (1.0 - popProgress))
              ..style = PaintingStyle.fill);
      } else {
        // Fase Splash - percikan setelah gelembung pecah
        final double splashProgress = (bubbleProgress - 0.8) / 0.2;

        // Menggambar percikan sebagai titik-titik kecil yang menyebar
        final int splashCount = 6;
        for (int s = 0; s < splashCount; s++) {
          final double splashAngle =
              (s * (360 / splashCount) + random.nextDouble() * 20) *
                  (math.pi / 180);
          final double splashDistance = 20.0 * splashProgress;

          final Offset splashPos = Offset(
              bubblePos.dx + math.cos(splashAngle) * splashDistance,
              bubblePos.dy + math.sin(splashAngle) * splashDistance);

          canvas.drawCircle(splashPos, 2.0 * (1.0 - splashProgress),
              Paint()..color = color.withOpacity(0.6 * (1.0 - splashProgress)));
        }
      }
    }
  }

  @override
  bool shouldRepaint(EffectAnimator oldAnimator) => true;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  @override
  double getDefaultRadiusMultiplier() => 1.2;

  @override
  double getOuterPadding() => 20.0;
}

// 2. DIGITAL GLITCH ANIMATOR
class DigitalGlitchAnimator implements EffectAnimator {
  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final adjustedCenter = center + positionOffset;
    final random = math.Random(42); // Konsistensi dasar

    // Jari-jari area untuk efek glitch
    final double glitchRadius = size.width * 0.6 * radiusMultiplier;

    // Menentukan jumlah "glitches" (distorsi kotak)
    final int glitchCount = 25;

    // Intensitas maksimum di tengah animasi, fade in/out di awal dan akhir
    double intensity = 1.0;
    if (progress < 0.15) {
      intensity = progress / 0.15; // Fade in
    } else if (progress > 0.85) {
      intensity = (1.0 - progress) / 0.15; // Fade out
    }

    // Pulsasi tambahan dengan fungsi sinus
    final double pulseIntensity = 0.7 + 0.3 * math.sin(progress * math.pi * 8);
    intensity *= pulseIntensity;

    // Menggambar kotak-kotak glitch
    for (int i = 0; i < glitchCount; i++) {
      // Mengubah seed random untuk setiap frame dan glitch
      final int currentSeed = (progress * 100).toInt() * 1000 + i;
      final random = math.Random(currentSeed);

      // Ukuran dan posisi kotak acak
      final double glitchSize = (5.0 + random.nextDouble() * 15.0) * intensity;

      // Posisi dalam area
      final double angle = random.nextDouble() * math.pi * 2;
      final double distance = random.nextDouble() * glitchRadius;

      final Offset glitchCenter = Offset(
          adjustedCenter.dx + math.cos(angle) * distance,
          adjustedCenter.dy + math.sin(angle) * distance);

      // Membuat kotak dengan sedikit rotasi
      final double rotation = random.nextDouble() * math.pi / 4;

      final Rect glitchRect = Rect.fromCenter(
          center: glitchCenter,
          width: glitchSize * (1.0 + random.nextDouble() * 2.0),
          height: glitchSize * (0.5 + random.nextDouble()));

      // Variasi warna untuk efek RGB shift
      Color glitchColor;
      final int colorVariant = random.nextInt(4);

      switch (colorVariant) {
        case 0:
          glitchColor = color; // Warna dasar
          break;
        case 1:
          glitchColor = Color.fromRGBO(
              255, // Red max
              color.green,
              color.blue,
              color.opacity); // Red shift
          break;
        case 2:
          glitchColor = Color.fromRGBO(
              color.red,
              255, // Green max
              color.blue,
              color.opacity); // Green shift
          break;
        case 3:
          glitchColor = Color.fromRGBO(
              color.red,
              color.green,
              255, // Blue max
              color.opacity); // Blue shift
          break;
        default:
          glitchColor = color;
      }

      // Opacity berdasarkan intensitas dan variasi acak
      final double opacity = (0.2 + random.nextDouble() * 0.6) * intensity;

      // Menggambar kotak glitch
      canvas.save();
      canvas.translate(glitchCenter.dx, glitchCenter.dy);
      canvas.rotate(rotation);
      canvas.translate(-glitchCenter.dx, -glitchCenter.dy);

      canvas.drawRect(
          glitchRect,
          Paint()
            ..color = glitchColor.withOpacity(opacity)
            ..style = PaintingStyle.fill
            ..blendMode = BlendMode.screen);

      canvas.restore();

      // Secara acak menggunakan efek scanline untuk beberapa kotak
      if (random.nextBool() && i % 3 == 0) {
        final int lineCount = 3 + random.nextInt(3);
        final double lineSpacing = glitchSize / lineCount;

        for (int l = 0; l < lineCount; l++) {
          final double yOffset = -glitchSize / 2 + (l * lineSpacing);

          canvas.save();
          canvas.translate(glitchCenter.dx, glitchCenter.dy);
          canvas.rotate(rotation);

          canvas.drawLine(
              Offset(-glitchSize, yOffset),
              Offset(glitchSize, yOffset),
              Paint()
                ..color = Colors.white.withOpacity(0.7 * opacity)
                ..strokeWidth = 1.0);

          canvas.restore();
        }
      }
    }

    // Menambahkan efek lingkaran "noise"
    final int noiseCount = 40;
    for (int i = 0; i < noiseCount; i++) {
      final int currentSeed = (progress * 100).toInt() * 2000 + i;
      final random = math.Random(currentSeed);

      final double noiseRadius = 1.0 + random.nextDouble() * 2.0;
      final double angle = random.nextDouble() * math.pi * 2;
      final double distance = random.nextDouble() * glitchRadius * 1.2;

      final Offset noisePos = Offset(
          adjustedCenter.dx + math.cos(angle) * distance,
          adjustedCenter.dy + math.sin(angle) * distance);

      canvas.drawCircle(
          noisePos,
          noiseRadius,
          Paint()
            ..color = Colors.white.withOpacity(0.3 * intensity)
            ..blendMode = BlendMode.screen);
    }
  }

  @override
  bool shouldRepaint(EffectAnimator oldAnimator) => true;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  @override
  double getDefaultRadiusMultiplier() => 1.3;

  @override
  double getOuterPadding() => 25.0;
}

// 3. GEOMETRIC BLOOM ANIMATOR
class GeometricBloomAnimator implements EffectAnimator {
  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final adjustedCenter = center + positionOffset;

    // Parameter radius
    final double maxRadius = size.width * 0.7 * radiusMultiplier;

    // Jumlah bentuk
    final int shapeCount = 12;

    // Variasi bentuk
    final List<int> shapeTypes = [
      3,
      4,
      5,
      6
    ]; // Segitiga, Persegi, Pentagon, Hexagon

    for (int i = 0; i < shapeCount; i++) {
      // Seed acak konsisten untuk setiap shape
      final random = math.Random(i * 100);

      // Waktu delay berbeda untuk setiap bentuk
      final double delayFactor =
          0.5; // 0.0 sampai 1.0, semakin tinggi semakin terpisah
      final double delay = (i / shapeCount) * delayFactor;

      // Progress untuk bentuk ini
      double shapeProgress = (progress - delay) / (1.0 - delayFactor);
      shapeProgress = shapeProgress.clamp(0.0, 1.0);

      // Untuk durasi pendek, skip jika belum waktunya muncul
      if (shapeProgress <= 0) continue;

      // Memilih tipe bentuk untuk shape ini
      final int shapeType = shapeTypes[i % shapeTypes.length];

      // Sudut dasar dan variasi
      final double baseAngle = (i * (360 / shapeCount)) * (math.pi / 180);
      final double angleVariation =
          random.nextDouble() * (math.pi / 12); // ±15 derajat
      final double angle = baseAngle + angleVariation;

      // Jarak dari pusat (dipengaruhi oleh progress)
      // Bentuk bergerak ke luar secara non-linear untuk efek yang lebih dinamis
      final double distanceFactor = math.pow(shapeProgress, 0.7)
          as double; // Memulai lebih cepat lalu melambat
      final double distance =
          maxRadius * distanceFactor * (0.3 + random.nextDouble() * 0.7);

      // Posisi bentuk
      final Offset shapeCenter = Offset(
          adjustedCenter.dx + math.cos(angle) * distance,
          adjustedCenter.dy + math.sin(angle) * distance);

      // Ukuran bentuk - membesar lalu mengecil
      double sizeFactor;
      if (shapeProgress < 0.7) {
        // Membesar hingga 70% progress
        sizeFactor = shapeProgress / 0.7;
      } else {
        // Mengecil setelahnya
        sizeFactor =
            1.0 - ((shapeProgress - 0.7) / 0.3) * 0.3; // Hanya mengecil 30%
      }

      final double shapeSize =
          10.0 + 20.0 * sizeFactor * (0.7 + random.nextDouble() * 0.3);

      // Rotation - berputar saat membesar
      final double rotation =
          shapeProgress * math.pi * (1.0 + random.nextDouble());

      // Opacity - meningkat lalu memudar
      double opacity;
      if (shapeProgress < 0.2) {
        opacity = shapeProgress / 0.2; // Fade in
      } else if (shapeProgress > 0.8) {
        opacity = 1.0 - ((shapeProgress - 0.8) / 0.2); // Fade out
      } else {
        opacity = 1.0;
      }

      // Warna bentuk dengan variasi
      final Color shapeColor = _adjustColor(color, random);

      // Menggambar bentuk geometris
      _drawShape(canvas, shapeCenter, shapeSize, shapeType, rotation,
          shapeColor.withOpacity(opacity * 0.8));

      // Menambahkan outline untuk beberapa bentuk
      if (i % 3 == 0) {
        _drawShape(
            canvas,
            shapeCenter,
            shapeSize * 1.1, // Sedikit lebih besar
            shapeType,
            rotation,
            shapeColor.withOpacity(opacity * 0.3),
            true // Outline
            );
      }
    }
  }

  // Fungsi untuk menyesuaikan warna dengan variasi acak
  Color _adjustColor(Color baseColor, math.Random random) {
    // Variasi kecil pada warna untuk keragaman
    final int rAdjust = (random.nextDouble() * 40 - 20).toInt();
    final int gAdjust = (random.nextDouble() * 40 - 20).toInt();
    final int bAdjust = (random.nextDouble() * 40 - 20).toInt();

    return Color.fromRGBO(
        (baseColor.red + rAdjust).clamp(0, 255),
        (baseColor.green + gAdjust).clamp(0, 255),
        (baseColor.blue + bAdjust).clamp(0, 255),
        baseColor.opacity);
  }

  // Fungsi untuk menggambar bentuk geometris
  void _drawShape(Canvas canvas, Offset center, double size, int sides,
      double rotation, Color color,
      [bool isOutline = false]) {
    final Paint paint = Paint()
      ..color = color
      ..style = isOutline ? PaintingStyle.stroke : PaintingStyle.fill
      ..strokeWidth = isOutline ? 2.0 : 1.0;

    final Path path = Path();

    for (int i = 0; i < sides; i++) {
      final double angle = rotation + (i * (2 * math.pi / sides));
      final double x = center.dx + math.cos(angle) * size;
      final double y = center.dy + math.sin(angle) * size;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(EffectAnimator oldAnimator) => true;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  @override
  double getDefaultRadiusMultiplier() => 1.2;

  @override
  double getOuterPadding() => 25.0;
}

// 4. SOUND WAVE ANIMATOR
class SoundWaveAnimator implements EffectAnimator {
  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final adjustedCenter = center + positionOffset;

    // Parameter untuk ukuran dan jangkauan
    final double waveWidth = size.width * 0.9 * radiusMultiplier;
    final double waveHeight = size.height * 0.4 * radiusMultiplier;

    // Jumlah "bar" dalam visualisasi
    final int barCount = 20;

    // Spacing antar bar
    final double barSpacing = waveWidth / barCount;
    final double barWidth = barSpacing * 0.7; // 70% dari spacing

    // Ketebalan garis dasar
    final double baseStrokeWidth = 3.0;

    // Opacity kontrol
    double opacity = 1.0;
    if (progress < 0.1) {
      opacity = progress / 0.1; // Fade in
    } else if (progress > 0.9) {
      opacity = (1.0 - progress) / 0.1; // Fade out
    }

    // Menggambar bars
    for (int i = 0; i < barCount; i++) {
      // Posisi X dari bar ini
      final double x = adjustedCenter.dx -
          (waveWidth / 2) +
          (i * barSpacing) +
          (barSpacing / 2);

      // Menentukan ketinggian dengan sinusoidal dan noise
      // Membuat frekuensi berbeda untuk variasi gerakan

      // Komponen sinus dasar
      double sinFactor = math.sin((progress * math.pi * 4) + (i * 0.3));

      // Komponen sinus kedua dengan frekuensi berbeda
      double sin2Factor = math.sin((progress * math.pi * 6) + (i * 0.5));

      // Height berdasarkan posisi dan waktu
      double normalizedHeight = (sinFactor * 0.7 + sin2Factor * 0.3).abs();

      // Tambahkan efek "beat"
      final double beat = math.sin(progress * math.pi * 2) * 0.3;
      normalizedHeight = normalizedHeight * (0.7 + beat);

      // Ketinggian final
      final double barHeight = normalizedHeight * waveHeight;

      // Base Y position (tengah)
      final double baseY = adjustedCenter.dy;

      // Membuat bar dengan warna variasi berdasarkan ketinggian
      final Color barColor =
          color.withOpacity(opacity * (0.5 + normalizedHeight * 0.5));

      // Menggambar bar (line)
      canvas.drawLine(
          Offset(x, baseY - barHeight / 2),
          Offset(x, baseY + barHeight / 2),
          Paint()
            ..color = barColor
            ..strokeWidth = barWidth
            ..strokeCap = StrokeCap.round);

      // Menambahkan highlight di ujung bar untuk beberapa bar
      if (i % 3 == 0 && normalizedHeight > 0.5) {
        canvas.drawCircle(
            Offset(x, baseY - barHeight / 2), // Ujung atas
            barWidth * 0.3,
            Paint()..color = Colors.white.withOpacity(opacity * 0.7));
      }
    }

    // Menggambar garis horizontal sebagai dasar
    canvas.drawLine(
        Offset(adjustedCenter.dx - waveWidth / 2, adjustedCenter.dy),
        Offset(adjustedCenter.dx + waveWidth / 2, adjustedCenter.dy),
        Paint()
          ..color = color.withOpacity(opacity * 0.3)
          ..strokeWidth = baseStrokeWidth / 2
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(EffectAnimator oldAnimator) => true;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  @override
  double getDefaultRadiusMultiplier() => 1.1;

  @override
  double getOuterPadding() => 15.0;
}

// 5. SMOKE PUFF ANIMATOR
class SmokePuffAnimator implements EffectAnimator {
  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final adjustedCenter = center + positionOffset;
    final random = math.Random(42); // Konsistensi dasar

    // Parameters
    final double puffRadius = size.width * 0.6 * radiusMultiplier;

    // Jumlah partikel asap
    final int particleCount = 50;

    // Fase animasi:
    // 1. Initial puff (0-0.2): Asap terkonsentrasi
    // 2. Dispersion (0.2-0.8): Menyebar
    // 3. Fade out (0.8-1.0): Memudar

    for (int i = 0; i < particleCount; i++) {
      // Seed untuk partikel ini
      final int particleSeed = i * 1000 + (progress * 1000).toInt();
      final random = math.Random(particleSeed);

      // Basic properties
      final double angle = random.nextDouble() * math.pi * 2;
      double distance, opacity, size;

      if (progress < 0.2) {
        // Fase 1: Konsentrasi asap di tengah
        final double initialProgress = progress / 0.2;

        distance = puffRadius * 0.2 * initialProgress * random.nextDouble();
        size = 5.0 + (initialProgress * 10.0 * random.nextDouble());
        opacity = initialProgress * (0.3 + random.nextDouble() * 0.3);
      } else if (progress < 0.8) {
        // Fase 2: Penyebaran asap
        final double dispersionProgress = (progress - 0.2) / 0.6;

        // Jarak meningkat dengan waktu (menyebar keluar)
        distance = puffRadius *
            (0.2 + 0.8 * dispersionProgress) *
            (0.2 + random.nextDouble() * 0.8);

        // Ukuran meningkat kemudian stabil
        final double sizeMultiplier = dispersionProgress < 0.5
            ? 1.0 + dispersionProgress
            : 1.5 - (dispersionProgress - 0.5) * 0.5;
        size = (10.0 + 15.0 * random.nextDouble()) * sizeMultiplier;

        // Opacity relatif stabil kemudian mulai menurun
        opacity = (0.4 + random.nextDouble() * 0.3) *
            (1.0 - dispersionProgress * 0.3);
      } else {
        // Fase 3: Fade out
        final double fadeProgress = (progress - 0.8) / 0.2;

        distance = puffRadius * (0.2 + random.nextDouble() * 0.8);
        size = (15.0 + 10.0 * random.nextDouble()) * (1.0 - fadeProgress * 0.3);
        opacity = (0.3 + random.nextDouble() * 0.2) * (1.0 - fadeProgress);
      }

      // Menambahkan pergerakan naik dengan gravitasi
      double yOffset = -distance * 0.3 * progress;

      // Posisi partikel asap
      final Offset particlePos = Offset(
          adjustedCenter.dx + math.cos(angle) * distance,
          adjustedCenter.dy + math.sin(angle) * distance + yOffset);

      // Menggambar partikel asap dengan blur
      canvas.drawCircle(
          particlePos,
          size,
          Paint()
            ..color = color.withOpacity(opacity)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, size * 0.5));
    }
  }

  @override
  bool shouldRepaint(EffectAnimator oldAnimator) => true;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  @override
  double getDefaultRadiusMultiplier() => 1.2;

  @override
  double getOuterPadding() => 20.0;
}

// 6. COLOR SPECTRUM ANIMATOR
class ColorSpectrumAnimator implements EffectAnimator {
  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final adjustedCenter = center + positionOffset;

    // Radius lingkaran spektrum
    final double spectrumRadius = size.width * 0.6 * radiusMultiplier;

    // Jumlah segmen warna
    final int segmentCount = 12;

    // Ketebalan lingkaran
    final double ringThickness = spectrumRadius * 0.15;

    // Rotasi dasar (berputar dengan progress)
    final double baseRotation = progress * math.pi * 2;

    // Pengaturan opacity untuk fade-in/out
    double opacity = 1.0;
    if (progress < 0.2) {
      opacity = progress / 0.2; // Fade in
    } else if (progress > 0.8) {
      opacity = (1.0 - progress) / 0.2; // Fade out
    }

    // Pulsasi ukuran
    final double sizePulse = 1.0 + 0.05 * math.sin(progress * math.pi * 6);

    // Menggambar segmen lingkaran dengan warna berbeda
    for (int i = 0; i < segmentCount; i++) {
      final double startAngle =
          baseRotation + (i * (2 * math.pi / segmentCount));
      final double sweepAngle = 2 * math.pi / segmentCount;

      // Warna untuk segmen ini - variasi dari warna dasar
      final Color segmentColor = _getColorFromHue(i, segmentCount, color);

      // Menggambar arc segmen
      final Paint segmentPaint = Paint()
        ..color = segmentColor.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringThickness * sizePulse
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
          Rect.fromCircle(center: adjustedCenter, radius: spectrumRadius),
          startAngle,
          sweepAngle,
          false,
          segmentPaint);
    }

    // Menambahkan efek blur/glow overlay
    canvas.drawCircle(
        adjustedCenter,
        spectrumRadius,
        Paint()
          ..color = color.withOpacity(0.2 * opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = ringThickness * 1.5 * sizePulse
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8.0));

    // Menambahkan highlight pada beberapa titik
    final int highlightCount = 6;
    for (int i = 0; i < highlightCount; i++) {
      final double highlightAngle =
          baseRotation + (i * (2 * math.pi / highlightCount));

      final Offset highlightPos = Offset(
          adjustedCenter.dx + math.cos(highlightAngle) * spectrumRadius,
          adjustedCenter.dy + math.sin(highlightAngle) * spectrumRadius);

      canvas.drawCircle(highlightPos, ringThickness * 0.25 * sizePulse,
          Paint()..color = Colors.white.withOpacity(0.8 * opacity));
    }
  }

  // Fungsi untuk mendapatkan warna berdasarkan hue
  Color _getColorFromHue(int index, int total, Color baseColor) {
    // Menggunakan HSV untuk rotasi warna
    HSVColor baseHsv = HSVColor.fromColor(baseColor);

    // Rotasi hue berdasarkan posisi
    double hueRotation = 360 * (index / total);
    double newHue = (baseHsv.hue + hueRotation) % 360;

    return HSVColor.fromAHSV(
            baseHsv.alpha, newHue, baseHsv.saturation, baseHsv.value)
        .toColor();
  }

  @override
  bool shouldRepaint(EffectAnimator oldAnimator) => true;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  @override
  double getDefaultRadiusMultiplier() => 1.1;

  @override
  double getOuterPadding() => 15.0;
}

// 9. NEON TRACE ANIMATOR
class NeonTraceAnimator implements EffectAnimator {
  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final adjustedCenter = center + positionOffset;

    // Parameters
    final double traceRadius = size.width * 0.5 * radiusMultiplier;

    // Lingkaran utama
    final bool isDrawingPhase = progress < 0.7;
    final bool isGlowingPhase = progress >= 0.7;

    if (isDrawingPhase) {
      // Fase 1: Menggambar lingkaran neon
      final double drawProgress = progress / 0.7; // Normalisasi dari 0-1

      // Pulsasi ukuran dengan fungsi sinus
      final double pulseFactor =
          1.0 + 0.05 * math.sin(drawProgress * math.pi * 8);

      // Sudut penutupan lingkaran (0 -> 2PI)
      final double sweepAngle = drawProgress * 2 * math.pi;

      // Menggambar "trace" - path yang digambar
      final Paint tracePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0 * pulseFactor
        ..strokeCap = StrokeCap.round;

      // Menggambar glow
      final Paint glowPaint = Paint()
        ..color = color.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9.0 * pulseFactor
        ..strokeCap = StrokeCap.round
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5.0);

      // Drawing outer glow
      canvas.drawArc(
          Rect.fromCircle(center: adjustedCenter, radius: traceRadius),
          -math.pi / 2, // Start from top
          sweepAngle,
          false,
          glowPaint);

      // Drawing primary neon trace
      canvas.drawArc(
          Rect.fromCircle(center: adjustedCenter, radius: traceRadius),
          -math.pi / 2, // Start from top
          sweepAngle,
          false,
          tracePaint);

      // Drawing leading bright point
      if (drawProgress < 0.99) {
        final double angle = -math.pi / 2 + sweepAngle;
        final Offset leadingPoint = Offset(
            adjustedCenter.dx + math.cos(angle) * traceRadius,
            adjustedCenter.dy + math.sin(angle) * traceRadius);

        // Bright leading point
        canvas.drawCircle(
            leadingPoint,
            5.0 * pulseFactor,
            Paint()
              ..color = Colors.white.withOpacity(0.9)
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2.0));
      }
    }

    if (isGlowingPhase || progress > 0.95) {
      // Fase 2: Glowing setelah lingkaran selesai
      final double glowProgress = isGlowingPhase ? (progress - 0.7) / 0.3 : 1.0;

      // Intensitas pulsasi
      final double pulseIntensity =
          0.7 + 0.3 * math.sin(glowProgress * math.pi * 6);

      // Menggambar lingkaran penuh dengan glow yang berpulsa

      // Variasi lebar stroke untuk efek neon yang hidup
      final double baseWidth = 4.0;
      final double glowWidth = 12.0 * pulseIntensity;

      // Outer glow (layer paling luar)
      canvas.drawCircle(
          adjustedCenter,
          traceRadius,
          Paint()
            ..color = color.withOpacity(0.1 * pulseIntensity)
            ..style = PaintingStyle.stroke
            ..strokeWidth = glowWidth * 1.5
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 12.0));

      // Mid glow
      canvas.drawCircle(
          adjustedCenter,
          traceRadius,
          Paint()
            ..color = color.withOpacity(0.3 * pulseIntensity)
            ..style = PaintingStyle.stroke
            ..strokeWidth = glowWidth
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6.0));

      // Core neon line
      canvas.drawCircle(
          adjustedCenter,
          traceRadius,
          Paint()
            ..color = color.withOpacity(0.9 * pulseIntensity)
            ..style = PaintingStyle.stroke
            ..strokeWidth = baseWidth * pulseIntensity);

      // Highlight spots
      final int spotCount = 6;
      for (int i = 0; i < spotCount; i++) {
        final double spotAngle =
            (i * (2 * math.pi / spotCount)) + (progress * math.pi);

        final Offset spotPos = Offset(
            adjustedCenter.dx + math.cos(spotAngle) * traceRadius,
            adjustedCenter.dy + math.sin(spotAngle) * traceRadius);

        // Pulsasi ukuran untuk spots
        final double spotSize =
            3.0 * (0.5 + 0.5 * math.sin(glowProgress * math.pi * 4 + i));

        canvas.drawCircle(
            spotPos,
            spotSize,
            Paint()
              ..color = Colors.white.withOpacity(0.8 * pulseIntensity)
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1.0));
      }
    }
  }

  @override
  bool shouldRepaint(EffectAnimator oldAnimator) => true;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  @override
  double getDefaultRadiusMultiplier() => 1.1;

  @override
  double getOuterPadding() => 15.0;
}

// 11. PORTAL EFFECT ANIMATOR
class PortalEffectAnimator implements EffectAnimator {
  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final adjustedCenter = center + positionOffset;

    // Parameters
    final double portalRadius = size.width * 0.5 * radiusMultiplier;

    // Jumlah spiral arms
    final int spiralCount = 6;

    // Jumlah segmen dalam spiral
    final int segmentCount = 12;

    // Kecepatan rotasi keseluruhan
    final double rotationSpeed = 1.5;

    // Rotasi dasar
    final double baseRotation = progress * math.pi * 2 * rotationSpeed;

    // Opacity kontrol
    double opacity = 1.0;
    if (progress < 0.2) {
      opacity = progress / 0.2; // Fade in
    } else if (progress > 0.8) {
      opacity = (1.0 - progress) / 0.2; // Fade out
    }

    // Pulsasi ukuran dengan fungsi sinus
    final double sizePulse = 1.0 + 0.1 * math.sin(progress * math.pi * 4);

    // Menggambar lingkaran pusat portal
    final double innerRadius = portalRadius * 0.3 * sizePulse;

    // Warna yang sedikit berbeda untuk lingkaran pusat
    final Color innerColor = HSVColor.fromColor(color)
        .withSaturation(
            (HSVColor.fromColor(color).saturation * 1.2).clamp(0.0, 1.0))
        .withValue((HSVColor.fromColor(color).value * 1.2).clamp(0.0, 1.0))
        .toColor();

    // Center circle dengan glow effect
    canvas.drawCircle(
        adjustedCenter,
        innerRadius,
        Paint()
          ..color = innerColor.withOpacity(opacity * 0.7)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10.0));

    canvas.drawCircle(adjustedCenter, innerRadius * 0.8,
        Paint()..color = Colors.white.withOpacity(opacity * 0.5));

    // Menggambar spiral arms
    for (int i = 0; i < spiralCount; i++) {
      // Sudut awal untuk spiral ini
      final double startAngle =
          baseRotation + (i * (2 * math.pi / spiralCount));

      // Panjang maksimum spiral
      final double maxArmLength = portalRadius - innerRadius;

      // Path untuk spiral arm
      final Path spiralPath = Path();

      // Membangun spiral dengan segmen
      for (int j = 0; j <= segmentCount; j++) {
        // Progress dalam spiral (0 = inner, 1 = outer)
        final double t = j / segmentCount;

        // Radius saat ini - non-linear untuk efek menarik
        final double currentRadius =
            innerRadius + (maxArmLength * math.pow(t, 0.8) as double);

        // Sudut tambahan berdasarkan jarak (menciptakan efek spiral)
        final double angleOffset =
            t * math.pi * 2 * (2 + math.sin(progress * math.pi * 3));

        // Sudut akhir
        final double angle = startAngle + angleOffset;

        // Coordinate
        final double x = adjustedCenter.dx + math.cos(angle) * currentRadius;
        final double y = adjustedCenter.dy + math.sin(angle) * currentRadius;

        if (j == 0) {
          spiralPath.moveTo(x, y);
        } else {
          spiralPath.lineTo(x, y);
        }
      }

      // Menggambar spiral dengan gradient
      final Gradient spiralGradient = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          color.withOpacity(0.0),
          color.withOpacity(opacity),
          Colors.white.withOpacity(opacity * 0.8),
          color.withOpacity(opacity * 0.5),
          color.withOpacity(0.0),
        ],
        stops: [0.0, 0.3, 0.5, 0.7, 1.0],
      );

      // Lebar spiral - menyempit di ujung
      final Paint spiralPaint = Paint()
        ..shader = spiralGradient.createShader(
            Rect.fromCircle(center: adjustedCenter, radius: portalRadius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.0 * (1.0 - (i % 2) * 0.3) // Alternating width
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(spiralPath, spiralPaint);

      // Menambahkan blur glow untuk beberapa spiral
      if (i % 2 == 0) {
        canvas.drawPath(
            spiralPath,
            Paint()
              ..color = color.withOpacity(opacity * 0.3)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 12.0 * (1.0 - (i % 2) * 0.3)
              ..strokeCap = StrokeCap.round
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8.0));
      }
    }

    // Menambahkan particle effect di sekitar portal
    final int particleCount = 15;
    final math.Random random = math.Random(42);

    for (int i = 0; i < particleCount; i++) {
      // Variasi posisi untuk setiap frame
      final int particleSeed = i * 100 + (progress * 100).toInt();
      final random = math.Random(particleSeed);

      // Sudut particle
      final double angle = random.nextDouble() * math.pi * 2;

      // Jarak - mayoritas di dekat portal
      final double distance = innerRadius +
              (portalRadius - innerRadius) * math.pow(random.nextDouble(), 2)
          as double;

      // Ukuran particle
      final double particleSize = 2.0 + random.nextDouble() * 3.0;

      // Posisi
      final Offset particlePos = Offset(
          adjustedCenter.dx + math.cos(angle) * distance,
          adjustedCenter.dy + math.sin(angle) * distance);

      // Menggambar particle dengan blur
      canvas.drawCircle(
          particlePos,
          particleSize,
          Paint()
            ..color = Colors.white
                .withOpacity(opacity * (0.5 + random.nextDouble() * 0.5))
            ..maskFilter =
                MaskFilter.blur(BlurStyle.normal, particleSize * 0.5));
    }

    // Menggambar outer ring
    canvas.drawCircle(
        adjustedCenter,
        portalRadius,
        Paint()
          ..color = color.withOpacity(opacity * 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0);

    // Menambahkan glow di outer ring
    canvas.drawCircle(
        adjustedCenter,
        portalRadius,
        Paint()
          ..color = color.withOpacity(opacity * 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8.0
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4.0));
  }

  @override
  bool shouldRepaint(EffectAnimator oldAnimator) => true;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  @override
  double getDefaultRadiusMultiplier() => 1.1;

  @override
  double getOuterPadding() => 15.0;
}

// 12. ELECTRIC ARC ANIMATOR
class ElectricArcAnimator implements EffectAnimator {
  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final adjustedCenter = center + positionOffset;

    // Parameters
    final double arcRadius = size.width * 0.6 * radiusMultiplier;

    // Jumlah titik arc (electrode)
    final int nodeCount = 5;

    // Jumlah arc yang muncul
    final int arcCount = 12;

    // Opacity kontrol
    double opacity = 1.0;
    if (progress < 0.1) {
      opacity = progress / 0.1; // Fade in
    } else if (progress > 0.9) {
      opacity = (1.0 - progress) / 0.1; // Fade out
    }

    // Menggambar node-node elektroda
    final List<Offset> nodes = [];
    for (int i = 0; i < nodeCount; i++) {
      final double angle = i * (2 * math.pi / nodeCount);

      final Offset nodePos = Offset(
          adjustedCenter.dx + math.cos(angle) * arcRadius,
          adjustedCenter.dy + math.sin(angle) * arcRadius);

      nodes.add(nodePos);

      // Menggambar node
      canvas.drawCircle(
          nodePos, 6.0, Paint()..color = color.withOpacity(opacity * 0.7));

      // Glow untuk node
      canvas.drawCircle(
          nodePos,
          10.0,
          Paint()
            ..color = color.withOpacity(opacity * 0.3)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6.0));

      // Highlight di node
      canvas.drawCircle(Offset(nodePos.dx - 2.0, nodePos.dy - 2.0), 2.0,
          Paint()..color = Colors.white.withOpacity(opacity * 0.8));
    }

    // Menggambar arc listrik
    final math.Random random = math.Random(42);

    for (int a = 0; a < arcCount; a++) {
      // Seed untuk arc ini
      final int arcSeed = a * 100 + (progress * 100).toInt();
      final random = math.Random(arcSeed);

      // Memilih node awal dan akhir
      final int startNodeIndex = random.nextInt(nodeCount);
      int endNodeIndex;
      do {
        endNodeIndex = random.nextInt(nodeCount);
      } while (endNodeIndex == startNodeIndex);

      // Posisi awal dan akhir
      final Offset startPos = nodes[startNodeIndex];
      final Offset endPos = nodes[endNodeIndex];

      // Menggambar arc hanya untuk beberapa yang aktif (tidak semua aktif bersamaan)
      final double arcThreshold = 0.3; // Probabilitas arc aktif
      if (random.nextDouble() > arcThreshold) continue;

      // Menggambar arc dengan path
      final Path arcPath = Path();
      arcPath.moveTo(startPos.dx, startPos.dy);

      // Menentukan jumlah segmen zigzag
      final int segmentCount = 8 + random.nextInt(6);

      // Arc length
      final double arcLength = (endPos - startPos).distance;

      // Menghitung segmen zigzag
      Offset prevPoint = startPos;

      for (int s = 1; s <= segmentCount; s++) {
        // Posisi segmen dalam path (0-1)
        final double t = s / segmentCount;

        // Posisi dasar pada garis lurus
        final double baseX = startPos.dx + (endPos.dx - startPos.dx) * t;
        final double baseY = startPos.dy + (endPos.dy - startPos.dy) * t;

        // Variasi perpendicular terhadap garis (zigzag)
        final double perpX = -(endPos.dy - startPos.dy);
        final double perpY = (endPos.dx - startPos.dx);
        final double perpLength = math.sqrt(perpX * perpX + perpY * perpY);

        // Jarak zigzag - lebih besar di tengah, lebih kecil di ujung
        final double normalizedOffset = math.sin(t * math.pi);
        final double offsetMagnitude = arcLength * 0.1 * normalizedOffset;

        // Random variation
        final double randomOffset =
            (random.nextDouble() * 2 - 1) * offsetMagnitude;

        final double nx = perpX / perpLength;
        final double ny = perpY / perpLength;

        // Final point dengan offset
        final Offset nextPoint =
            Offset(baseX + nx * randomOffset, baseY + ny * randomOffset);

        arcPath.lineTo(nextPoint.dx, nextPoint.dy);
        prevPoint = nextPoint;
      }

      // Pastikan ujung arc mencapai node tujuan
      arcPath.lineTo(endPos.dx, endPos.dy);

      // Variasi ketebalan berdasarkan waktu untuk efek flicker
      final double baseThickness = 2.0;
      final double flickerOffset = random.nextDouble() * 0.5;
      final double flickerPhase = progress * 20 + flickerOffset * 10;
      final double flickerFactor = 0.5 + 0.5 * math.sin(flickerPhase * math.pi);

      // Final thickness dengan flicker
      final double thickness = baseThickness * (0.7 + 0.3 * flickerFactor);

      // Menggambar arc core
      canvas.drawPath(
          arcPath,
          Paint()
            ..color = Colors.white.withOpacity(opacity * 0.9 * flickerFactor)
            ..style = PaintingStyle.stroke
            ..strokeWidth = thickness
            ..strokeCap = StrokeCap.round);

      // Menggambar glow
      canvas.drawPath(
          arcPath,
          Paint()
            ..color = color.withOpacity(opacity * 0.7 * flickerFactor)
            ..style = PaintingStyle.stroke
            ..strokeWidth = thickness * 3
            ..strokeCap = StrokeCap.round
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4.0));

      // Outer glow
      canvas.drawPath(
          arcPath,
          Paint()
            ..color = color.withOpacity(opacity * 0.3 * flickerFactor)
            ..style = PaintingStyle.stroke
            ..strokeWidth = thickness * 6
            ..strokeCap = StrokeCap.round
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8.0));

      // Menambahkan small sparks
      if (random.nextDouble() < 0.7) {
        final int sparkCount = 2 + random.nextInt(3);

        for (int sp = 0; sp < sparkCount; sp++) {
          // Posisi spark pada arc
          final double sparkT = random.nextDouble();
          final int sparkSegment = (sparkT * segmentCount).floor();

          // Approximate position
          final double sparkX =
              startPos.dx + (endPos.dx - startPos.dx) * sparkT;
          final double sparkY =
              startPos.dy + (endPos.dy - startPos.dy) * sparkT;

          // Variasi posisi
          final double sparkOffsetX = (random.nextDouble() * 2 - 1) * 5.0;
          final double sparkOffsetY = (random.nextDouble() * 2 - 1) * 5.0;

          final Offset sparkPos =
              Offset(sparkX + sparkOffsetX, sparkY + sparkOffsetY);

          // Ukuran spark
          final double sparkSize = 1.0 + random.nextDouble() * 2.0;

          // Menggambar spark
          canvas.drawCircle(
              sparkPos,
              sparkSize,
              Paint()
                ..color =
                    Colors.white.withOpacity(opacity * 0.9 * flickerFactor)
                ..maskFilter =
                    MaskFilter.blur(BlurStyle.normal, sparkSize * 0.5));
        }
      }
    }
  }

  @override
  bool shouldRepaint(EffectAnimator oldAnimator) => true;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  @override
  double getDefaultRadiusMultiplier() => 1.2;

  @override
  double getOuterPadding() => 20.0;
}

// 13. PAPER SHRED ANIMATOR
class PaperShredAnimator implements EffectAnimator {
  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final adjustedCenter = center + positionOffset;

    // Parameters
    final double maxShredLength = size.width * 0.6 * radiusMultiplier;

    // Jumlah strip kertas yang tersobek
    final int stripCount = 16;

    // Opacity kontrol
    double opacity = 1.0;
    if (progress < 0.1) {
      opacity = progress / 0.1; // Fade in
    } else if (progress > 0.9) {
      opacity = (1.0 - progress) / 0.9; // Fade out
    }

    // Menggambar border outline widget (simulasi kertas)
    final double paperSize = size.width * 0.5 * radiusMultiplier;

    // Warna background (kertas) - lighten dari warna dasar
    final Color paperColor = Color.lerp(Colors.white, color, 0.1)!;

    // Rect untuk kertas (sedikit lebih kecil dari widget)
    final Rect paperRect = Rect.fromCenter(
        center: adjustedCenter, width: paperSize, height: paperSize);

    // Style untuk kertas
    final Paint paperPaint = Paint()
      ..color = paperColor.withOpacity(opacity * 0.9)
      ..style = PaintingStyle.fill;

    // Menggambar kertas dengan sedikit rotasi
    canvas.save();
    canvas.translate(adjustedCenter.dx, adjustedCenter.dy);
    canvas.rotate(math.pi / 16); // Slight tilt
    canvas.translate(-adjustedCenter.dx, -adjustedCenter.dy);

    canvas.drawRect(paperRect, paperPaint);

    // Menggambar outline
    canvas.drawRect(
        paperRect,
        Paint()
          ..color = color.withOpacity(opacity * 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0);

    // Random untuk konsistensi
    final math.Random random = math.Random(42);

    // Menggambar shredding effect
    for (int i = 0; i < stripCount; i++) {
      // Random seed untuk strip ini
      final int stripSeed = i * 100;
      final random = math.Random(stripSeed);

      // ... continuing PaperShredAnimator
      // Posisi strip di tepi kertas
      final double normalizedPos = i / (stripCount - 1);

      // Pilih tepi mana yang tersobek (top, right, bottom, left)
      int edgeSide;
      if (i < stripCount / 4) {
        edgeSide = 0; // Top
      } else if (i < stripCount / 2) {
        edgeSide = 1; // Right
      } else if (i < 3 * stripCount / 4) {
        edgeSide = 2; // Bottom
      } else {
        edgeSide = 3; // Left
      }

      // Offset dalam edge berdasarkan posisi
      final double edgeNormalizedPos = (normalizedPos * 4) % 1.0;

      // Start point pada tepi kertas
      Offset startPoint;
      double shredAngle; // Sudut sobekan

      switch (edgeSide) {
        case 0: // Top edge
          startPoint = Offset(
              paperRect.left + paperRect.width * edgeNormalizedPos,
              paperRect.top);
          shredAngle =
              math.pi / 2 + (random.nextDouble() * math.pi / 4 - math.pi / 8);
          break;
        case 1: // Right edge
          startPoint = Offset(paperRect.right,
              paperRect.top + paperRect.height * edgeNormalizedPos);
          shredAngle =
              math.pi + (random.nextDouble() * math.pi / 4 - math.pi / 8);
          break;
        case 2: // Bottom edge
          startPoint = Offset(
              paperRect.right - paperRect.width * edgeNormalizedPos,
              paperRect.bottom);
          shredAngle = 3 * math.pi / 2 +
              (random.nextDouble() * math.pi / 4 - math.pi / 8);
          break;
        case 3: // Left edge
          startPoint = Offset(paperRect.left,
              paperRect.bottom - paperRect.height * edgeNormalizedPos);
          shredAngle = 0 + (random.nextDouble() * math.pi / 4 - math.pi / 8);
          break;
        default:
          startPoint = Offset(paperRect.left, paperRect.top);
          shredAngle = 0;
      }

      // Menghitung panjang sobekan berdasarkan progress
      // Muncul dengan cepat lalu stabil
      double shredProgress = progress < 0.4
          ? progress / 0.4
          : // Cepat di awal
          1.0; // Stabil setelahnya

      // Panjang strip
      final double stripLength =
          maxShredLength * shredProgress * (0.5 + random.nextDouble() * 0.5);

      // End point setelah sobekan
      final Offset endPoint = Offset(
          startPoint.dx + math.cos(shredAngle) * stripLength,
          startPoint.dy + math.sin(shredAngle) * stripLength);

      // Lebar strip
      final double stripWidth = 2.0 + random.nextDouble() * 3.0;

      // Path untuk strip
      final Path stripPath = Path();

      // Bentuk irregular untuk strip
      // Jalur zig-zag untuk sobekan kertas yang tidak rata
      stripPath.moveTo(startPoint.dx, startPoint.dy);

      // Jumlah segment zigzag
      final int zigzagCount = (stripLength / 10).round().clamp(3, 8);

      // Garis pertama lurus dari tepi
      final double straightLength = stripLength * 0.1;
      Offset currentPoint = Offset(
          startPoint.dx + math.cos(shredAngle) * straightLength,
          startPoint.dy + math.sin(shredAngle) * straightLength);
      stripPath.lineTo(currentPoint.dx, currentPoint.dy);

      // Menggambar zigzag
      for (int z = 1; z <= zigzagCount; z++) {
        final double segmentT = z / zigzagCount;

        // Posisi pada garis lurus
        final double baseX =
            startPoint.dx + (endPoint.dx - startPoint.dx) * segmentT;
        final double baseY =
            startPoint.dy + (endPoint.dy - startPoint.dy) * segmentT;

        // Vector perpendicular untuk zigzag
        final double perpX = -math.sin(shredAngle);
        final double perpY = math.cos(shredAngle);

        // Zigzag offset - alternate directions
        final double zigzagWidth = stripWidth * (1.0 + random.nextDouble());
        final double offset = (z % 2 == 0 ? 1 : -1) * zigzagWidth;

        // Final point dengan zigzag offset
        final Offset zigzagPoint =
            Offset(baseX + perpX * offset, baseY + perpY * offset);

        stripPath.lineTo(zigzagPoint.dx, zigzagPoint.dy);
        currentPoint = zigzagPoint;
      }

      // Memastikan akhir path mencapai endpoint
      stripPath.lineTo(endPoint.dx, endPoint.dy);

      // Menghitung titik kontrol untuk shadow jagged edge
      final List<Offset> jaggies = [];
      for (int j = 0; j <= 6; j++) {
        final double jT = j / 6.0;

        // Posisi pada garis
        final double jX = startPoint.dx + (endPoint.dx - startPoint.dx) * jT;
        final double jY = startPoint.dy + (endPoint.dy - startPoint.dy) * jT;

        // Perpendicular vector
        final double jPerpX = -math.sin(shredAngle);
        final double jPerpY = math.cos(shredAngle);

        // Random offset perpendicular
        final double jOffset = (random.nextDouble() * 2 - 1) * stripWidth;

        jaggies.add(Offset(jX + jPerpX * jOffset, jY + jPerpY * jOffset));
      }

      // Menggambar tepi sobek dengan shadow
      final Path shadowPath = Path();
      shadowPath.moveTo(startPoint.dx, startPoint.dy);

      // Menambahkan semua titik-titik jagged
      for (int j = 0; j < jaggies.length; j++) {
        shadowPath.lineTo(jaggies[j].dx, jaggies[j].dy);
      }

      // Menggambar shadow
      canvas.drawPath(
          shadowPath,
          Paint()
            ..color = Colors.black.withOpacity(opacity * 0.2)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2.0));

      // Menggambar strip dengan warna kertas
      canvas.drawPath(
          stripPath,
          Paint()
            ..color = paperColor.withOpacity(opacity)
            ..style = PaintingStyle.stroke
            ..strokeWidth = stripWidth
            ..strokeCap = StrokeCap.round);

      // Edge highlight
      canvas.drawPath(
          stripPath,
          Paint()
            ..color = color.withOpacity(opacity * 0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.5);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(EffectAnimator oldAnimator) => true;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  @override
  double getDefaultRadiusMultiplier() => 1.1;

  @override
  double getOuterPadding() => 15.0;
}

// 14. BOUNCING BALLS ANIMATOR
class BouncingBallsAnimator implements EffectAnimator {
  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final adjustedCenter = center + positionOffset;

    // Parameters
    final double maxDistance = size.width * 0.6 * radiusMultiplier;

    // Jumlah bola
    final int ballCount = 10;

    // Opacity kontrol
    double opacity = 1.0;
    if (progress < 0.1) {
      opacity = progress / 0.1; // Fade in
    } else if (progress > 0.9) {
      opacity = (1.0 - progress) / 0.1; // Fade out
    }

    // Random untuk konsistensi
    final math.Random random = math.Random(42);

    for (int i = 0; i < ballCount; i++) {
      // Random seed untuk bola ini
      final int ballSeed = i * 100;
      final random = math.Random(ballSeed);

      // Ukuran bola
      final double ballSize = 5.0 + random.nextDouble() * 8.0;

      // Kecepatan dan arah
      final double angle = random.nextDouble() * math.pi * 2;
      final double speed = 0.5 + random.nextDouble() * 0.5;

      // Velocity X and Y components
      final double vx = math.cos(angle) * speed;
      final double vy = math.sin(angle) * speed;

      // Time offset - bola mulai di waktu berbeda
      final double timeOffset = random.nextDouble() * 0.3;
      double ballProgress = (progress - timeOffset).clamp(0.0, 1.0);

      // Skip jika belum waktunya muncul
      if (ballProgress <= 0) continue;

      // Karakter fisika:
      // 1. Initial velocity
      // 2. Gravity
      // 3. Bouncing (elasticity)

      // Constants
      final double gravity = 1.2;
      final double elasticity = 0.7; // 0-1, 1 is perfect bounce

      // Initial position (relatif terhadap pusat)
      final double initialX = 0;
      final double initialY = 0;

      // Posisi saat ini dengan simulasi fisika
      double currentX, currentY;

      // Initial velocity
      double initialVelX = vx * maxDistance;
      double initialVelY = vy * maxDistance;

      // Menghitung posisi dengan fisika
      double totalTime = ballProgress * 1.5; // Scale waktu

      // Simulasi bouncing
      double x = initialX + initialVelX * totalTime;
      double y = initialY +
          initialVelY * totalTime +
          0.5 * gravity * totalTime * totalTime;

      // Boundaries - untuk bouncing
      final double boundarySize = maxDistance * 0.8;

      // Track the ball's state through multiple bounces
      double timeLeft = totalTime;
      double velX = initialVelX;
      double velY = initialVelY;
      double posX = initialX;
      double posY = initialY;

      // Iterate through bounces
      while (timeLeft > 0) {
        // Calculate time to next collision
        double timeToCollisionX = double.infinity;
        double timeToCollisionY = double.infinity;

        if (velX != 0) {
          double timeToRightWall = (boundarySize - posX) / velX;
          double timeToLeftWall = (-boundarySize - posX) / velX;
          timeToCollisionX = math.max(timeToRightWall, timeToLeftWall);
          if (timeToCollisionX < 0) {
            // Already past collision, use other wall
            timeToCollisionX = math.min(timeToRightWall, timeToLeftWall);
          }
        }

        if (velY != 0) {
          double timeToBottomWall = (boundarySize - posY) / velY;
          double timeToTopWall = (-boundarySize - posY) / velY;
          timeToCollisionY = math.max(timeToBottomWall, timeToTopWall);
          if (timeToCollisionY < 0) {
            // Already past collision, use other wall
            timeToCollisionY = math.min(timeToBottomWall, timeToTopWall);
          }
        }

        double timeToCollision = math.min(timeToCollisionX, timeToCollisionY);

        // No collision within remaining time
        if (timeToCollision >= timeLeft || timeToCollision.isInfinite) {
          // Final update without collision
          posX += velX * timeLeft;
          posY += velY * timeLeft + 0.5 * gravity * timeLeft * timeLeft;
          break;
        }

        // Update position to collision
        posX += velX * timeToCollision;
        posY += velY * timeToCollision +
            0.5 * gravity * timeToCollision * timeToCollision;

        // Update velocity (bounce)
        if (timeToCollision == timeToCollisionX) {
          velX = -velX * elasticity; // X-bounce
        } else {
          velY = -velY * elasticity; // Y-bounce
        }

        // Update time left
        timeLeft -= timeToCollision;

        // Apply gravity accumulated during this step
        velY += gravity * timeToCollision;
      }

      // Final positions
      currentX = posX;
      currentY = posY;

      // Adjust coordinate system to canvas
      final Offset ballPos =
          Offset(adjustedCenter.dx + currentX, adjustedCenter.dy + currentY);

      // Menggambar ball shadow
      canvas.drawCircle(
          Offset(ballPos.dx + 2, ballPos.dy + 3),
          ballSize,
          Paint()
            ..color = Colors.black.withOpacity(opacity * 0.2)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3.0));

      // Warna bola - variasi dari warna dasar
      final Color ballColor = _getBallColor(color, random);

      // Menggambar bola
      canvas.drawCircle(
          ballPos, ballSize, Paint()..color = ballColor.withOpacity(opacity));

      // Menambahkan highlight
      canvas.drawCircle(
          Offset(ballPos.dx - ballSize * 0.3, ballPos.dy - ballSize * 0.3),
          ballSize * 0.35,
          Paint()..color = Colors.white.withOpacity(opacity * 0.7));

      // Menambahkan motion blur jika bergerak cepat
      final double speed2D = math.sqrt(velX * velX + velY * velY);
      if (speed2D > 50) {
        // Direction of motion
        final double blurAngle = math.atan2(velY, velX);

        // Blur length based on speed
        final double blurLength = math.min(ballSize * 1.5, speed2D * 0.1);

        // Blur direction vector
        final double blurDx = -math.cos(blurAngle) * blurLength;
        final double blurDy = -math.sin(blurAngle) * blurLength;

        // Draw motion blur
        final Paint blurPaint = Paint()
          ..color = ballColor.withOpacity(opacity * 0.3)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3.0);

        // Path for blur
        final Path blurPath = Path();
        blurPath.moveTo(ballPos.dx, ballPos.dy);
        blurPath.lineTo(ballPos.dx + blurDx, ballPos.dy + blurDy);

        canvas.drawPath(
            blurPath,
            Paint()
              ..color = ballColor.withOpacity(opacity * 0.4)
              ..style = PaintingStyle.stroke
              ..strokeWidth = ballSize * 2
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4.0));
      }
    }
  }

  // Helper untuk variasi warna bola
  Color _getBallColor(Color baseColor, math.Random random) {
    // Chance of using a completely different color
    if (random.nextDouble() < 0.3) {
      // Generate some nice vibrant colors
      final List<Color> altColors = [
        Colors.red,
        Colors.blue,
        Colors.green,
        Colors.yellow,
        Colors.purple,
        Colors.orange,
        Colors.pink,
      ];

      return altColors[random.nextInt(altColors.length)];
    }

    // Base color with slight variation
    final int rAdjust = (random.nextDouble() * 40 - 20).toInt();
    final int gAdjust = (random.nextDouble() * 40 - 20).toInt();
    final int bAdjust = (random.nextDouble() * 40 - 20).toInt();

    return Color.fromRGBO(
        (baseColor.red + rAdjust).clamp(0, 255),
        (baseColor.green + gAdjust).clamp(0, 255),
        (baseColor.blue + bAdjust).clamp(0, 255),
        baseColor.opacity);
  }

  @override
  bool shouldRepaint(EffectAnimator oldAnimator) => true;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  @override
  double getDefaultRadiusMultiplier() => 1.2;

  @override
  double getOuterPadding() => 20.0;
}
/*
enum AnimationUndergroundType {
  firework,
  ripple,
  confetti,
  orbital,
  radialFirework,
  sparkel,
  breathAnimation,
  clickRay,
  // Tambahkan animasi baru di sini
  pulseWave,
  sparkleEffect,
  lightning,
  glowingOutline,
  rotatingOrbs,
  explodingStars,
  rippleRings,
  energyField,
  particleSwarm,
  shockwave,
}
*/

/*
class AnimatorFactory {
  static EffectAnimator createAnimator(AnimationUndergroundType type) {
    switch (type) {
      case AnimationUndergroundType.firework:
        return FireworkAnimator();
      case AnimationUndergroundType.ripple:
        return RippleAnimator();
      case AnimationUndergroundType.confetti:
        return ConfettiAnimator();
      case AnimationUndergroundType.orbital:
        return OrbitalAnimator();
      case AnimationUndergroundType.radialFirework:
        return SparkleStarburstAnimator();
      case AnimationUndergroundType.sparkel:
        return SparkleStarburstAnimator();
      case AnimationUndergroundType.breathAnimation:
        return BreathAnimator();
      case AnimationUndergroundType.clickRay:
        return ClickRayAnimator();
      // Tambahkan case untuk animator baru
      case AnimationUndergroundType.pulseWave:
        return PulseWaveAnimator();
      case AnimationUndergroundType.sparkleEffect:
        return SparkleEffectAnimator();
      case AnimationUndergroundType.lightning:
        return LightningAnimator();
      case AnimationUndergroundType.glowingOutline:
        return GlowingOutlineAnimator();
      case AnimationUndergroundType.rotatingOrbs:
        return RotatingOrbsAnimator();
      case AnimationUndergroundType.explodingStars:
        return ExplodingStarsAnimator();  
      case AnimationUndergroundType.rippleRings:
        return RippleRingsAnimator();
      case AnimationUndergroundType.energyField:
        return EnergyFieldAnimator();
      case AnimationUndergroundType.particleSwarm:
        return ParticleSwarmAnimator();
      case AnimationUndergroundType.shockwave:
        return ShockwaveAnimator();
      default:
        return FireworkAnimator(); // Default
    }
  }
}
*/

// RAIN DROPS ANIMATOR
class RainDropsAnimator implements EffectAnimator {
  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final adjustedCenter = center + positionOffset;

    // Parameters
    final double rainRadius = size.width * 0.6 * radiusMultiplier;

    // Jumlah tetesan
    final int dropCount = 15;

    // Opacity kontrol
    double opacity = 1.0;
    if (progress < 0.1) {
      opacity = progress / 0.1; // Fade in
    } else if (progress > 0.9) {
      opacity = (1.0 - progress) / 0.1; // Fade out
    }

    // Random untuk konsistensi
    final math.Random random = math.Random(42);

    // Gambar background effect (wet surface)
    _drawWetSurface(
        canvas, adjustedCenter, rainRadius, color, opacity, progress);

    // Gambar raindrops
    for (int i = 0; i < dropCount; i++) {
      // Random seed untuk drop ini
      final int dropSeed = i * 100;
      final random = math.Random(dropSeed);

      // Waktu offset per tetesan
      final double timeOffset = random.nextDouble() * 0.5;
      double dropProgress = (progress - timeOffset).clamp(0.0, 1.0);

      // Skip jika belum waktunya muncul
      if (dropProgress <= 0) continue;

      // Posisi awal (di atas area)
      final double startX =
          adjustedCenter.dx + (random.nextDouble() * 2 - 1) * rainRadius;
      final double startY =
          adjustedCenter.dy - rainRadius * (0.5 + random.nextDouble() * 0.5);

      // Ukuran tetesan
      final double dropSize = 3.0 + random.nextDouble() * 4.0;

      // Kecepatan jatuh (gravity simulation)
      final double fallSpeed = 0.5 + random.nextDouble() * 0.5;

      // Lifecycle drop:
      // 1. Falling
      // 2. Splash
      // 3. Ripples

      // Progress untuk fase-fase
      final double fallLimit = 0.6; // 0-0.6: Jatuh
      final double splashLimit = 0.75; // 0.6-0.75: Splash
      final double rippleLimit = 1.0; // 0.75-1.0: Riak

      if (dropProgress < fallLimit) {
        // Fase jatuh - simulate gravity
        final double fallProgress = dropProgress / fallLimit;

        // Non-linear untuk simulasi gravity
        final double distance =
            rainRadius * fallProgress * fallProgress * fallSpeed;

        // Posisi saat ini
        final Offset dropPos = Offset(startX, startY + distance);

        // Menggambar tetesan
        _drawRaindrop(canvas, dropPos, dropSize, color, opacity);

        // Menambahkan motion trail pada tetesan yang jatuh
        if (fallProgress > 0.3) {
          _drawDropTrail(canvas, dropPos, startX, startY + distance * 0.8,
              dropSize, color, opacity * 0.5);
        }
      } else if (dropProgress < splashLimit) {
        // Fase splash
        final double splashProgress =
            (dropProgress - fallLimit) / (splashLimit - fallLimit);

        // Posisi splash (di bawah)
        final Offset splashPos =
            Offset(startX, startY + rainRadius * fallSpeed);

        // Menggambar splash
        _drawSplash(
            canvas, splashPos, dropSize, color, opacity, splashProgress);
      } else {
        // Fase ripple
        final double rippleProgress =
            (dropProgress - splashLimit) / (rippleLimit - splashLimit);

        // Posisi ripple sama dengan splash
        final Offset ripplePos =
            Offset(startX, startY + rainRadius * fallSpeed);

        // Menggambar ripple
        _drawRipple(
            canvas, ripplePos, dropSize, color, opacity, rippleProgress);
      }
    }
  }

  // Menggambar tetesan hujan
  void _drawRaindrop(Canvas canvas, Offset position, double size, Color color,
      double opacity) {
    // Tetesan bentuk teardrop
    final Path dropPath = Path();

    // Atas rounded
    dropPath
        .addOval(Rect.fromCenter(center: position, width: size, height: size));

    // Ekor tetesan
    dropPath.moveTo(position.dx - size / 2, position.dy);
    dropPath.quadraticBezierTo(
        position.dx,
        position.dy + size * 1.5, // control point
        position.dx + size / 2,
        position.dy // end point
        );

    // Menggambar tetesan
    canvas.drawPath(
        dropPath,
        Paint()
          ..color = color.withOpacity(opacity * 0.8)
          ..style = PaintingStyle.fill);

    // Highlight pada tetesan
    canvas.drawCircle(
        Offset(position.dx - size * 0.2, position.dy - size * 0.2),
        size * 0.3,
        Paint()..color = Colors.white.withOpacity(opacity * 0.7));
  }

  // Menggambar trail untuk tetesan yang jatuh
  void _drawDropTrail(Canvas canvas, Offset dropPos, double startX,
      double startY, double size, Color color, double opacity) {
    final Paint trailPaint = Paint()
      ..color = color.withOpacity(opacity * 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.5
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, size * 0.5);

    // Trail path
    final Path trailPath = Path();
    trailPath.moveTo(startX, startY);
    trailPath.lineTo(dropPos.dx, dropPos.dy);

    canvas.drawPath(trailPath, trailPaint);
  }

  // Menggambar efek splash
  void _drawSplash(Canvas canvas, Offset position, double size, Color color,
      double opacity, double progress) {
    // Jumlah droplet kecil dalam splash
    final int splashCount = 8;

    for (int i = 0; i < splashCount; i++) {
      final double angle = i * (2 * math.pi / splashCount);

      // Jarak dari pusat - meningkat dengan progress
      final double distance =
          size * 2 * progress * (0.5 + 0.5 * math.cos(i * 0.7));

      // Ukuran droplet - mengecil dengan waktu
      final double dropletSize = size * 0.4 * (1.0 - progress * 0.8);

      // Posisi droplet
      final Offset dropletPos = Offset(position.dx + math.cos(angle) * distance,
          position.dy + math.sin(angle) * distance);

      // Menggambar droplet
      canvas.drawCircle(dropletPos, dropletSize,
          Paint()..color = color.withOpacity(opacity * (1.0 - progress * 0.5)));
    }

    // Center splash
    canvas.drawCircle(
        position,
        size * progress * 0.8,
        Paint()
          ..color = color.withOpacity(opacity * 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = size * 0.3 * (1.0 - progress));
  }

  // Menggambar ripple
  void _drawRipple(Canvas canvas, Offset position, double size, Color color,
      double opacity, double progress) {
    // Jumlah ripple rings
    final int ringCount = 2;

    for (int i = 0; i < ringCount; i++) {
      // Progress per ring
      final double ringProgress = (progress - (i * 0.3)).clamp(0.0, 1.0);
      if (ringProgress <= 0) continue;

      // Radius meningkat dengan waktu
      final double radius = size * 4 * ringProgress;

      // Stroke width - mengecil dengan waktu
      final double strokeWidth = size * 0.3 * (1.0 - ringProgress);

      // Opacity - menurun dengan waktu
      final double ringOpacity = opacity * (1.0 - ringProgress);

      // Menggambar ripple circle
      canvas.drawCircle(
          position,
          radius,
          Paint()
            ..color = color.withOpacity(ringOpacity)
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth);
    }
  }

  // Menggambar efek permukaan basah
  void _drawWetSurface(Canvas canvas, Offset center, double radius, Color color,
      double opacity, double progress) {
    // Warna permukaan
    final Color surfaceColor = color.withOpacity(opacity * 0.1);

    // Gradient untuk efek basah
    final RadialGradient wetGradient = RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: [
        color.withOpacity(opacity * 0.15),
        color.withOpacity(opacity * 0.05),
      ],
      stops: [0.7, 1.0],
    );

    // Menggambar permukaan basah dengan gradient
    canvas.drawCircle(
        center,
        radius * 0.8,
        Paint()
          ..shader = wetGradient.createShader(
              Rect.fromCircle(center: center, radius: radius * 0.8)));

    // Menambahkan efek puddle kecil
    final math.Random random = math.Random(42);
    final int puddleCount = 8;

    for (int i = 0; i < puddleCount; i++) {
      final int puddleSeed = i * 100;
      final random = math.Random(puddleSeed);

      // Posisi puddle
      final double angle = random.nextDouble() * math.pi * 2;
      final double distance = radius * 0.6 * random.nextDouble();

      final Offset puddlePos = Offset(center.dx + math.cos(angle) * distance,
          center.dy + math.sin(angle) * distance);

      // Ukuran puddle
      final double puddleSize = 5.0 + random.nextDouble() * 15.0;

      // Opacity puddle - berfluktuasi
      final double puddleOpacity =
          0.05 + 0.05 * math.sin(progress * math.pi * 4 + i);

      // Menggambar puddle
      canvas.drawCircle(
          puddlePos,
          puddleSize,
          Paint()
            ..color = color.withOpacity(opacity * puddleOpacity)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3.0));

      // Highlight pada puddle
      if (random.nextDouble() < 0.5) {
        canvas.drawCircle(
            Offset(puddlePos.dx - puddleSize * 0.2,
                puddlePos.dy - puddleSize * 0.2),
            puddleSize * 0.25,
            Paint()
              ..color =
                  Colors.white.withOpacity(opacity * puddleOpacity * 0.8));
      }
    }
  }

  @override
  bool shouldRepaint(EffectAnimator oldAnimator) => true;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  @override
  double getDefaultRadiusMultiplier() => 1.2;

  @override
  double getOuterPadding() => 20.0;
}

// WATER RIPPLE ANIMATOR
class WaterRippleAnimator implements EffectAnimator {
  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final adjustedCenter = center + positionOffset;

    // Parameters
    final double rippleRadius = size.width * 0.65 * radiusMultiplier;

    // Jumlah gelombang
    final int waveCount = 4;

    // Opacity dasar
    double baseOpacity = 1.0;
    if (progress < 0.1) {
      baseOpacity = progress / 0.1; // Fade in
    } else if (progress > 0.9) {
      baseOpacity = (1.0 - progress) / 0.1; // Fade out
    }

    // Menggambar overlay water effect seluruh area
    _drawWaterOverlay(
        canvas, adjustedCenter, rippleRadius, color, baseOpacity, progress);

    // Menggambar ripples
    for (int i = 0; i < waveCount; i++) {
      // Delay waktu untuk gelombang berurutan
      final double delay = i * 0.15;
      double waveProgress = (progress - delay).clamp(0.0, 1.0);

      // Skip jika belum waktunya muncul
      if (waveProgress <= 0.0) continue;

      // Radius yang semakin besar dengan waktu
      final double waveRadius = rippleRadius * waveProgress;

      // Opacity menurun dengan jarak
      final double opacity = baseOpacity * (1.0 - waveProgress) * 0.5;

      // Lebar stroke menurun dengan jarak
      final double strokeWidth = 5.0 * (1.0 - waveProgress * 0.7);

      // Membuat ripple dengan distorsi
      _drawDistortedRipple(canvas, adjustedCenter, waveRadius, strokeWidth,
          color.withOpacity(opacity), waveProgress, i);
    }

    // Menambahkan splash droplets untuk beberapa momen spesifik
    if (progress > 0.05 && progress < 0.4) {
      _drawSplashDroplets(
          canvas, adjustedCenter, rippleRadius, color, progress, baseOpacity);
    }
  }

  // Fungsi untuk menggambar overlay efek air
  void _drawWaterOverlay(Canvas canvas, Offset center, double radius,
      Color color, double opacity, double progress) {
    // Menggambar efek distorsi lensa air
    final double overlayRadius = radius * 1.2;

    // Membuat efek gradien untuk simulasi refleksi air
    final Gradient waterGradient = RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: [
        color.withOpacity(0.05 * opacity),
        color.withOpacity(0.02 * opacity),
      ],
      stops: [0.7, 1.0],
    );

    // Menggambar overlay
    canvas.drawCircle(
        center,
        overlayRadius,
        Paint()
          ..shader = waterGradient.createShader(
              Rect.fromCircle(center: center, radius: overlayRadius))
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10.0));

    // Menambahkan distorsi dengan pergerakan sinusoidal
    final int distortionCount = 8;
    final double maxDistortion =
        10.0 * (0.5 + 0.5 * math.sin(progress * math.pi * 3));

    final Path distortionPath = Path();

    for (int i = 0; i < distortionCount; i++) {
      final double angle =
          (i * (2 * math.pi / distortionCount)) + (progress * math.pi);

      // Distorsi dengan sinusoidal untuk pergerakan seperti air
      final double distortionAmount =
          maxDistortion * math.sin(angle * 2 + progress * math.pi * 6);

      final double x =
          center.dx + math.cos(angle) * (overlayRadius + distortionAmount);
      final double y =
          center.dy + math.sin(angle) * (overlayRadius + distortionAmount);

      if (i == 0) {
        distortionPath.moveTo(x, y);
      } else {
        distortionPath.lineTo(x, y);
      }
    }

    // Menutup path
    distortionPath.close();

    // Menggambar efek distorsi dengan blend mode untuk transparansi
    canvas.drawPath(
        distortionPath,
        Paint()
          ..color = color.withOpacity(0.1 * opacity)
          ..style = PaintingStyle.fill
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8.0)
          ..blendMode = BlendMode.screen);
  }

  // Fungsi untuk menggambar ripple dengan distorsi
  void _drawDistortedRipple(Canvas canvas, Offset center, double radius,
      double strokeWidth, Color color, double progress, int waveIndex) {
    // Menentukan jumlah distorsi
    final int distortionCount = 36;

    // Amplitude distorsi (variasi naik-turun)
    final double baseAmplitude = 3.0;
    final double timeBasedAmplitude = baseAmplitude * (1.0 - progress * 0.5);

    // Frekuensi variasi di sepanjang lingkaran
    final int frequency = 6 + waveIndex % 3;

    // Menggambar ripple dengan path untuk kontrol distorsi
    final Path ripplePath = Path();

    for (int i = 0; i < distortionCount; i++) {
      final double angle = (i * (2 * math.pi / distortionCount));

      // Membuat distorsi sinusoidal
      final double distortion = timeBasedAmplitude *
          math.sin(angle * frequency + progress * math.pi * 6 + waveIndex);

      final double adjustedRadius = radius + distortion;

      final double x = center.dx + math.cos(angle) * adjustedRadius;
      final double y = center.dy + math.sin(angle) * adjustedRadius;

      if (i == 0) {
        ripplePath.moveTo(x, y);
      } else {
        // Menggunakan cubic untuk lebih halus
        final double prevAngle = ((i - 1) * (2 * math.pi / distortionCount));
        final double prevDistortion = timeBasedAmplitude *
            math.sin(
                prevAngle * frequency + progress * math.pi * 6 + waveIndex);

        final double prevX =
            center.dx + math.cos(prevAngle) * (radius + prevDistortion);
        final double prevY =
            center.dy + math.sin(prevAngle) * (radius + prevDistortion);

        // Control points untuk kurva halus
        final double cp1x = prevX + (x - prevX) * 0.5 - (y - prevY) * 0.2;
        final double cp1y = prevY + (y - prevY) * 0.5 + (x - prevX) * 0.2;

        ripplePath.quadraticBezierTo(cp1x, cp1y, x, y);
      }
    }

    // Menutup path
    ripplePath.close();

    // Menggambar ripple dengan blur untuk efek air
    canvas.drawPath(
        ripplePath,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, strokeWidth * 0.5));
  }

  // Fungsi untuk menggambar titik-titik percikan air
  void _drawSplashDroplets(Canvas canvas, Offset center, double maxRadius,
      Color color, double progress, double baseOpacity) {
    // Fase percikan air di awal animasi
    final double splashProgress = (progress - 0.05) / 0.35;
    if (splashProgress <= 0) return;

    final math.Random random = math.Random(42);

    // Jumlah droplet
    final int dropletCount = 12;

    for (int i = 0; i < dropletCount; i++) {
      // Arah droplet
      final double angle = random.nextDouble() * math.pi * 2;

      // Jarak percikan dari pusat
      final double minDistance = maxRadius * 0.2;
      final double maxDistance = maxRadius * 0.4;

      // Jarak meningkat dengan waktu
      double distance;
      double dropletSize;
      double opacity;

      if (splashProgress < 0.5) {
        // Droplet naik
        distance =
            minDistance + (maxDistance - minDistance) * splashProgress * 2;
        dropletSize = 3.0 * (0.5 + splashProgress);
        opacity = baseOpacity * (0.5 + splashProgress);
      } else {
        // Droplet jatuh (setelah separuh waktu)
        final double fallProgress = (splashProgress - 0.5) * 2;

        // Efek gravitasi saat jatuh
        distance = maxDistance - minDistance * fallProgress * fallProgress;

        // Ukuran mengecil saat jatuh
        dropletSize = 3.0 * (1.0 - fallProgress * 0.7);

        // Opacity menurun di akhir
        opacity = baseOpacity * (1.0 - fallProgress * 0.7);
      }

      // Posisi droplet
      final Offset dropletPos = Offset(
          center.dx + math.cos(angle) * distance,
          center.dy +
              math.sin(angle) * distance -
              maxRadius * 0.1 * (1.0 - splashProgress));

      // Menggambar droplet dengan blur
      canvas.drawCircle(
          dropletPos,
          dropletSize,
          Paint()
            ..color = color.withOpacity(opacity)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1.0));

      // Menambahkan highlight di beberapa droplet
      if (i % 3 == 0) {
        canvas.drawCircle(
            Offset(dropletPos.dx - dropletSize * 0.3,
                dropletPos.dy - dropletSize * 0.3),
            dropletSize * 0.4,
            Paint()..color = Colors.white.withOpacity(opacity * 0.8));
      }
    }
  }

  @override
  bool shouldRepaint(EffectAnimator oldAnimator) => true;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  @override
  double getDefaultRadiusMultiplier() => 1.3;

  @override
  double getOuterPadding() => 22.0;
}

class StarburstParticlesAnimator implements EffectAnimator {
  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final adjustedCenter = center + positionOffset;
    final random = math.Random(42); // Konsistensi antar frame

    // Jumlah bintang
    final int starCount = 20;

    // Radius ledakan
    final double burstRadius = size.width * 0.7 * radiusMultiplier;

    // Ukuran bintang
    final double maxStarSize = size.width * 0.08;

    for (int i = 0; i < starCount; i++) {
      // Sudut dasar untuk menentukan arah
      final double angle = (i * (360 / starCount)) * (math.pi / 180);

      // Variasi untuk posisi awal acak
      final double angleVariation = random.nextDouble() * 0.2 - 0.1;
      final double finalAngle = angle + angleVariation;

      // Radius awal dan akhir untuk simulasi ledakan
      final double initialRadius = burstRadius * 0.1;
      double currentRadius;
      double starSize;
      double opacity;

      // Animasi ledakan dengan gaya bouncy/elastic
      if (progress < 0.6) {
        // Fase ledakan: bintang bergerak keluar dengan cepat
        double elasticProgress = _elasticOut(progress / 0.6);
        currentRadius =
            initialRadius + (burstRadius - initialRadius) * elasticProgress;
        starSize = maxStarSize * (0.5 + elasticProgress * 0.5);
        opacity = math.min(1.0, progress * 3);
      } else {
        // Fase menghilang: bintang berkilau dan memudar
        double fadeProgress = (progress - 0.6) / 0.4;
        currentRadius = burstRadius + (burstRadius * 0.2) * fadeProgress;
        starSize = maxStarSize * (1.0 - fadeProgress * 0.5);
        opacity = 1.0 - fadeProgress;

        // Pulsing effect saat menghilang
        starSize *= 1.0 + math.sin(fadeProgress * math.pi * 4) * 0.2;
      }

      // Posisi bintang
      final starPosition = Offset(
          adjustedCenter.dx + math.cos(finalAngle) * currentRadius,
          adjustedCenter.dy + math.sin(finalAngle) * currentRadius);

      // Menggambar bintang dengan shape yang lebih bintang (bukan lingkaran)
      _drawStar(
          canvas,
          starPosition,
          starSize,
          5, // 5-point star
          color.withOpacity(opacity),
          progress);

      // Menambahkan efek sparkle pada beberapa bintang
      if (i % 3 == 0) {
        final sparkleProgress = (progress * 3) % 1.0;
        final sparkleSize =
            starSize * (0.5 + math.sin(sparkleProgress * math.pi) * 0.5);

        canvas.drawCircle(
            starPosition,
            sparkleSize,
            Paint()
              ..color = Colors.white.withOpacity(opacity * 0.7)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0));
      }
    }
  }

  // Menggambar bintang
  void _drawStar(Canvas canvas, Offset center, double size, int points,
      Color color, double progress) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final double rotation = progress * math.pi; // Rotasi bintang selama animasi

    // Membuat bentuk bintang dengan inner dan outer points
    for (int i = 0; i < points * 2; i++) {
      final double radius = (i % 2 == 0) ? size : size * 0.4;
      final double angle = (i * math.pi / points) + rotation;

      final double x = center.dx + radius * math.cos(angle);
      final double y = center.dy + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);

    // Menambahkan outline untuk efek yang lebih menarik
    canvas.drawPath(
        path,
        Paint()
          ..color = Colors.white.withOpacity(color.opacity * 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = size * 0.1);
  }

  // Fungsi easing untuk efek elastic
  double _elasticOut(double t) {
    return math.sin(-13 * math.pi / 2 * (t + 1)) * math.pow(2, -10 * t) + 1;
  }

  @override
  bool shouldRepaint(EffectAnimator oldAnimator) => true;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  @override
  double getDefaultRadiusMultiplier() => 1.2;

  @override
  double getOuterPadding() => 30.0;
}

class FirefliesAnimator implements EffectAnimator {
  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final adjustedCenter = center + positionOffset;
    final random = math.Random(42); // Konsistensi antar frame

    // Jumlah kunang-kunang
    final int fireflyCount = 25;

    // Area bergerak
    final double moveRadius = size.width * 0.8 * radiusMultiplier;

    for (int i = 0; i < fireflyCount; i++) {
      // Seed untuk kunang-kunang ini
      final int fireflySeed = i * 1000;
      final localRandom = math.Random(fireflySeed);

      // Posisi awal acak
      final double initialAngle = localRandom.nextDouble() * math.pi * 2;
      final double initialDistance =
          localRandom.nextDouble() * moveRadius * 0.5;

      // Membuat jalur organik untuk kunang-kunang
      // Menggunakan beberapa fungsi sin dan cos untuk gerakan alami
      final double timeOffset = localRandom.nextDouble() * math.pi * 2;
      final double speed = 0.5 + localRandom.nextDouble() * 0.5;

      // Pergerakan orbit dengan variasi
      final double currentAngle = initialAngle +
          math.sin(progress * math.pi * speed + timeOffset) * 0.5 +
          progress * math.pi * speed * 0.2;

      final double currentDistance = initialDistance +
          math.sin(progress * math.pi * 2 + i) * moveRadius * 0.2 +
          progress * moveRadius * 0.3;

      // Posisi kunang-kunang
      final fireflyPos = Offset(
          adjustedCenter.dx + math.cos(currentAngle) * currentDistance,
          adjustedCenter.dy + math.sin(currentAngle) * currentDistance);

      // Efek berkedip dengan fase berbeda untuk setiap kunang-kunang
      final double blinkPhase = (progress * 5 + i * 0.2) % 1.0;
      final double blinkIntensity =
          math.pow(math.sin(blinkPhase * math.pi), 2).toDouble();

      // Ukuran bervariasi berdasarkan kedipan
      final double baseSize = 2.0 + localRandom.nextDouble() * 3.0;
      final double currentSize = baseSize * (0.7 + blinkIntensity * 0.6);

      // Opacity berdasarkan fase animasi
      double opacity;
      if (progress < 0.2) {
        // Fase awal: muncul perlahan
        opacity = progress / 0.2;
      } else if (progress > 0.8) {
        // Fase akhir: menghilang
        opacity = (1.0 - progress) / 0.2;
      } else {
        // Fase tengah: berkedip dengan opacity penuh
        opacity = 0.7 + blinkIntensity * 0.3;
      }

      // Warna dasar
      final Color baseColor = color.withOpacity(opacity);

      // Variasi warna untuk beberapa kunang-kunang
      final Color fireflyColor = i % 5 == 0
          ? HSLColor.fromColor(baseColor)
              .withLightness(0.8)
              .toColor()
              .withOpacity(opacity)
          : baseColor;

      // Menggambar kunang-kunang - inner glow
      canvas.drawCircle(
          fireflyPos,
          currentSize,
          Paint()
            ..color = fireflyColor
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0));

      // Menggambar titik pusat yang lebih terang
      canvas.drawCircle(fireflyPos, currentSize * 0.4,
          Paint()..color = Colors.white.withOpacity(opacity * blinkIntensity));

      // Menambahkan jejak untuk kunang-kunang yang bergerak cepat
      if (blinkIntensity > 0.7) {
        // Perhitungan posisi sebelumnya (pseudo motion trail)
        final double trailAngle = currentAngle - 0.1;
        final double trailDistance = currentDistance - 2.0;
        final Offset trailPos = Offset(
            adjustedCenter.dx + math.cos(trailAngle) * trailDistance,
            adjustedCenter.dy + math.sin(trailAngle) * trailDistance);

        // Gambar jejak dengan gradient
        final Paint trailPaint = Paint()
          ..shader = RadialGradient(
            colors: [
              fireflyColor,
              fireflyColor.withOpacity(0),
            ],
          ).createShader(Rect.fromCircle(
            center: fireflyPos,
            radius: currentSize * 2,
          ));

        // Gambar jejak sebagai path gradien
        final Path trailPath = Path()
          ..moveTo(fireflyPos.dx, fireflyPos.dy)
          ..lineTo(trailPos.dx, trailPos.dy);

        canvas.drawPath(
            trailPath,
            Paint()
              ..shader = trailPaint.shader
              ..style = PaintingStyle.stroke
              ..strokeWidth = currentSize * 0.8
              ..strokeCap = StrokeCap.round);
      }
    }
  }

  @override
  bool shouldRepaint(EffectAnimator oldAnimator) => true;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  @override
  double getDefaultRadiusMultiplier() => 1.5;

  @override
  double getOuterPadding() => 35.0;
}

class MagicSparklesAnimator implements EffectAnimator {
  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final adjustedCenter = center + positionOffset;
    final random = math.Random(42); // Konsistensi antar frame

    // Jumlah sparkles
    final int sparkleCount = 30;

    // Area di sekitar widget
    final double areaRadius = size.width * 0.7 * radiusMultiplier;

    // Ukuran maksimum sparkle
    final double maxSparkleSize = size.width * 0.06;

    // Warna-warna untuk sparkles (lebih menarik dengan beberapa warna)
    final List<Color> sparkleColors = [
      color,
      Colors.white,
      HSLColor.fromColor(color).withLightness(0.8).toColor(),
      HSLColor.fromColor(color).withSaturation(0.8).toColor(),
    ];

    for (int i = 0; i < sparkleCount; i++) {
      // Delay kemunculan per sparkle untuk efek bertahap
      final double sparkleDelay = (i / sparkleCount) * 0.3;
      final double adjustedProgress = math.max(0.0, progress - sparkleDelay);

      if (adjustedProgress <= 0) continue; // Sparkle belum muncul

      // Life cycle sparkle individual
      final double sparkleLifetime = math.min(1.0, adjustedProgress / 0.7);

      // Seed berdasarkan indeks
      final int sparkleSeed = i * 1000;
      final localRandom = math.Random(sparkleSeed);

      // Posisi acak di sekeliling widget
      final double angle = localRandom.nextDouble() * math.pi * 2;
      final double distance =
          areaRadius * (0.4 + localRandom.nextDouble() * 0.6);

      // Sparkle muncul di posisi acak, kemudian bergerak sedikit
      final double moveAngle =
          angle + math.sin(sparkleLifetime * math.pi * 2) * 0.3;
      final double moveDistance =
          distance * (1.0 + math.sin(sparkleLifetime * math.pi) * 0.2);

      final Offset sparklePos = Offset(
          adjustedCenter.dx + math.cos(moveAngle) * moveDistance,
          adjustedCenter.dy + math.sin(moveAngle) * moveDistance);

      // Ukuran sparkle - membesar kemudian mengecil
      final double sparkleSize = maxSparkleSize *
          math.sin(sparkleLifetime * math.pi) *
          (0.5 + localRandom.nextDouble() * 0.5);

      // Opacity - muncul kemudian menghilang
      double opacity;
      if (sparkleLifetime < 0.2) {
        // Muncul cepat
        opacity = sparkleLifetime / 0.2;
      } else if (sparkleLifetime > 0.8) {
        // Menghilang
        opacity = (1.0 - sparkleLifetime) / 0.2;
      } else {
        // Tetap terlihat maksimum
        opacity = 1.0;
      }

      // Pulsing selama fase terlihat
      final double pulseEffect =
          1.0 + math.sin(sparkleLifetime * math.pi * 6) * 0.2;
      final double finalSize = sparkleSize * pulseEffect;

      // Warna untuk sparkle ini
      final Color sparkleColor =
          sparkleColors[i % sparkleColors.length].withOpacity(opacity);

      // Menggambar sparkle
      _drawSparkle(canvas, sparklePos, finalSize, sparkleColor,
          sparkleLifetime * math.pi * 2);

      // Tambahkan efek glow
      if (localRandom.nextDouble() > 0.5) {
        canvas.drawCircle(
            sparklePos,
            finalSize * 2.0,
            Paint()
              ..color = sparkleColor.withOpacity(opacity * 0.3)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0));
      }
    }
  }

  // Menggambar sparkle berbentuk bintang kecil
  void _drawSparkle(
      Canvas canvas, Offset center, double size, Color color, double rotation) {
    if (size <= 0) return;

    // Membuat bentuk sparkle yang menarik
    // Bisa berupa bintang, bentuk plus/cross, atau bentuk khusus lainnya
    final int sparkleType = (center.dx.toInt() + center.dy.toInt()) % 3;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    switch (sparkleType) {
      case 0:
        // Sparkle bentuk bintang
        _drawStar(canvas, center, size, 4, rotation, paint);
        break;

      case 1:
        // Sparkle bentuk diamond/rhombus
        _drawDiamond(canvas, center, size, rotation, paint);
        break;

      case 2:
        // Sparkle bentuk plus/cross
        _drawCross(canvas, center, size, rotation, paint);
        break;
    }
  }

  // Menggambar sparkle bentuk bintang
  void _drawStar(Canvas canvas, Offset center, double size, int points,
      double rotation, Paint paint) {
    final path = Path();
    final double angleStep = math.pi / points;

    for (int i = 0; i < points * 2; i++) {
      final double radius = i.isEven ? size : size * 0.4;
      final double angle = (i * angleStep) + rotation;

      final double x = center.dx + radius * math.cos(angle);
      final double y = center.dy + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  // Menggambar sparkle bentuk diamond/rhombus
  void _drawDiamond(
      Canvas canvas, Offset center, double size, double rotation, Paint paint) {
    final path = Path();

    // Empat titik diamond dengan rotasi
    for (int i = 0; i < 4; i++) {
      final double angle = (i * (math.pi / 2)) + rotation;
      final double radius = i % 2 == 0 ? size * 1.2 : size * 0.8;

      final double x = center.dx + radius * math.cos(angle);
      final double y = center.dy + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  // Menggambar sparkle bentuk plus/cross
  void _drawCross(
      Canvas canvas, Offset center, double size, double rotation, Paint paint) {
    final double armWidth = size * 0.3;
    final double armLength = size * 1.2;

    final path = Path();

    // Horizontal arm
    path.addRect(
        Rect.fromCenter(center: center, width: armLength, height: armWidth));

    // Vertical arm
    path.addRect(
        Rect.fromCenter(center: center, width: armWidth, height: armLength));

    // Rotate the path
    final Matrix4 matrix = Matrix4.identity()
      ..translate(center.dx, center.dy)
      ..rotateZ(rotation)
      ..translate(-center.dx, -center.dy);

    path.transform(matrix.storage);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(EffectAnimator oldAnimator) => true;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  @override
  double getDefaultRadiusMultiplier() => 1.4;

  @override
  double getOuterPadding() => 40.0;
}

class NumberOrbitAnimator implements EffectAnimator {
  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final adjustedCenter = center + positionOffset;

    // Jumlah angka
    final int numberCount = 10; // Angka 0-9

    // Radius orbit
    final double orbitRadius = size.width * 0.6 * radiusMultiplier;

    // Ukuran angka
    final double numberSize = math.min(size.width, size.height) * 0.1;

    // Pengaturan text style
    final textStyle = TextStyle(
      color: color,
      fontSize: numberSize,
      fontWeight: FontWeight.bold,
    );

    // Ukuran warna dan opasitas
    final Color baseColor = color;
    final List<Color> mathColors = [
      baseColor,
      Colors.orangeAccent,
      Colors.greenAccent,
      Colors.purpleAccent,
      Colors.blueAccent,
    ];

    // Offset untuk efek perputaran orbit
    final double orbitOffset =
        progress * math.pi * 2 * 0.7; // 0.7 untuk kecepatan orbit

    // Ukuran angka akan berubah untuk efek "pulsing"
    final double sizePulse = 1.0 + math.sin(progress * math.pi * 3) * 0.2;

    // Tambahan untuk efek melayang/hovering orbit
    final double hoverOffset =
        math.sin(progress * math.pi * 1.5) * (orbitRadius * 0.1);

    for (int i = 0; i < numberCount; i++) {
      // Angka yang ditampilkan (0-9)
      final int displayNumber = i;

      // Posisi angka dalam orbit elips
      final double angle =
          (i * (360 / numberCount) * (math.pi / 180)) + orbitOffset;

      // Membuat orbit elips (bukan lingkaran sempurna)
      final double xRadius = orbitRadius;
      final double yRadius =
          orbitRadius * 0.8; // Sedikit lebih pendek di sumbu y

      // Delay munculnya angka berdasarkan indeks
      final double entryDelay = i * 0.03;
      final double adjustedProgress = math.max(0.0, progress - entryDelay);

      // Opasitas berdasarkan fase animasi dan delay
      double opacity;
      if (adjustedProgress < 0.2) {
        // Fase awal: muncul
        opacity = adjustedProgress / 0.2;
      } else if (adjustedProgress > 0.8) {
        // Fase akhir: menghilang
        opacity = (1.0 - adjustedProgress) / 0.2;
      } else {
        // Fase tengah: terlihat penuh
        opacity = 1.0;
      }

      // Scaling awal dan akhir
      double scale;
      if (adjustedProgress < 0.2) {
        // Fase awal: membesar
        scale = adjustedProgress / 0.2;
      } else if (adjustedProgress > 0.8) {
        // Fase akhir: mengecil
        scale = (1.0 - adjustedProgress) / 0.2;
      } else {
        // Fase tengah: ukuran normal dengan efek pulsing
        scale = 1.0 + math.sin((adjustedProgress - 0.2) * math.pi * 3) * 0.1;
      }

      // Menambahkan efek bounce pada skala
      final double bounceFactor = math.min(1.0, adjustedProgress * 3);
      final double bounceScale =
          1.0 + math.sin(bounceFactor * math.pi) * 0.3 * (1.0 - bounceFactor);

      // Skala final dengan efek gabungan
      final double finalScale = scale * bounceScale * sizePulse;

      // Posisi dengan hover offset dan efek orbit yang lebih dinamis
      final Offset numberPosition = Offset(
        adjustedCenter.dx +
            math.cos(angle) * xRadius * (1 + math.sin(angle) * 0.1) +
            math.sin(angle * 3) * hoverOffset,
        adjustedCenter.dy +
            math.sin(angle) * yRadius * (1 + math.cos(angle) * 0.1) +
            math.cos(angle * 3) * hoverOffset,
      );

      // Warna angka dengan variasi
      final Color numberColor =
          mathColors[i % mathColors.length].withOpacity(opacity);

      // Menggambar background lingkaran
      if (opacity > 0.1 && finalScale > 0.1) {
        canvas.drawCircle(
            numberPosition,
            numberSize * 0.7 * finalScale, // Radius background
            Paint()
              ..color = Colors.white.withOpacity(opacity * 0.7)
              ..style = PaintingStyle.fill);

        // Menambahkan border lingkaran
        canvas.drawCircle(
            numberPosition,
            numberSize * 0.7 * finalScale, // Radius border
            Paint()
              ..color = numberColor
              ..style = PaintingStyle.stroke
              ..strokeWidth = numberSize * 0.1 * finalScale);
      }

      // Update text style dengan opacity dan warna
      final currentTextStyle = textStyle.copyWith(
        color: numberColor,
        fontSize: numberSize * finalScale,
      );

      // Menggambar angka
      final textPainter = TextPainter(
        text: TextSpan(
          text: displayNumber.toString(),
          style: currentTextStyle,
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      // Menggambar angka dengan posisi tengah
      textPainter.paint(
          canvas,
          numberPosition.translate(
              -textPainter.width / 2, -textPainter.height / 2));

      // Menambahkan efek khusus pada beberapa angka
      if (i % 3 == 0 && opacity > 0.5) {
        // Efek pancaran untuk beberapa angka
        canvas.drawCircle(
            numberPosition,
            numberSize * finalScale * 1.2,
            Paint()
              ..color = numberColor.withOpacity(opacity * 0.3)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0));
      }
    }
  }

  @override
  bool shouldRepaint(EffectAnimator oldAnimator) => true;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  @override
  double getDefaultRadiusMultiplier() => 1.3;

  @override
  double getOuterPadding() => 50.0;
}

class EmoticonExplosionAnimator implements EffectAnimator {
  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final adjustedCenter = center + positionOffset;
    final random = math.Random(42); // Konsistensi antar frame

    // Jumlah emoticon
    final int emoticonCount = 15;

    // Radius ledakan
    final double explosionRadius = size.width * 0.7 * radiusMultiplier;

    // Daftar emoticon yang akan ditampilkan
    final List<String> emoticons = [
      '😊',
      '😃',
      '😄',
      '😁',
      '😆',
      '😍',
      '🤩',
      '😎',
      '👍',
      '💖',
      '🎉',
      '✨',
      '🌟',
      '⭐',
      '💫',
      '🎊',
      '🎈',
      '🎀',
      '🎁',
      '🏆',
    ];

    // Ukuran emoticon
    final double baseEmoticonSize = size.width * 0.12;

    for (int i = 0; i < emoticonCount; i++) {
      // Memilih emoticon secara acak tapi konsisten
      final String emoticon =
          emoticons[(i + random.nextInt(5)) % emoticons.length];

      // Delay untuk waktu kemunculan bervariasi
      final double delay = i * 0.02;
      final double adjustedProgress = math.max(0.0, progress - delay);

      if (adjustedProgress <= 0) continue; // Belum waktunya muncul

      // Menggunakan kurva untuk efek meledak keluar lalu gravitasi
      final double t = adjustedProgress;

      // Sudut acak untuk arah gerakan
      final double angle = random.nextDouble() * math.pi * 2;

      // Jarak berdasarkan kurva - meledak keluar lalu jatuh dengan gravitasi
      double distance;
      if (t < 0.6) {
        // Fase meledak keluar
        distance = explosionRadius * _easeOutBack(t / 0.6);
      } else {
        // Fase jatuh dengan gravitasi
        final double fallT = (t - 0.6) / 0.4;
        distance = explosionRadius + (fallT * fallT * 50); // Efek gravitasi
      }

      // Rotasi emoticon
      final double rotation = t * math.pi * (random.nextDouble() * 4 - 2);

      // Posisi emoticon
      double xPos, yPos;
      if (t < 0.6) {
        // Fase meledak keluar - gerakan radial
        xPos = adjustedCenter.dx + math.cos(angle) * distance;
        yPos = adjustedCenter.dy + math.sin(angle) * distance;
      } else {
        // Fase jatuh - gravitasi menarik ke bawah
        final double fallT = (t - 0.6) / 0.4;
        xPos = adjustedCenter.dx + math.cos(angle) * explosionRadius;
        yPos = adjustedCenter.dy +
            math.sin(angle) * explosionRadius +
            (fallT * fallT * 80);
      }

      final Offset emoticonPos = Offset(xPos, yPos);

      // Skala berdasarkan waktu - muncul lalu mengecil
      double scale;
      if (t < 0.1) {
        // Muncul cepat
        scale = t / 0.1;
      } else if (t > 0.8) {
        // Mengecil di akhir
        scale = (1.0 - t) / 0.2;
      } else {
        // Tetap ukuran penuh dengan sedikit bouncing
        scale = 1.0 + math.sin(t * math.pi * 3) * 0.1;
      }

      // Opasitas
      double opacity;
      if (t < 0.1) {
        opacity = t / 0.1; // Fade in
      } else if (t > 0.8) {
        opacity = (1.0 - t) / 0.2; // Fade out
      } else {
        opacity = 1.0;
      }

      // Ukuran emoticon final
      final double emoticonSize =
          baseEmoticonSize * scale * (0.7 + random.nextDouble() * 0.6);

      // Gambar emoticon
      _drawEmoticon(canvas, emoticon, emoticonPos, emoticonSize, rotation,
          color.withOpacity(opacity));

      // Tambahkan efek kilau untuk beberapa emoticon
      if (i % 3 == 0 && t > 0.1 && t < 0.9) {
        canvas.drawCircle(
            emoticonPos,
            emoticonSize * 0.7,
            Paint()
              ..color = Colors.white.withOpacity(opacity * 0.3)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0));
      }
    }
  }

  // Menggambar emoticon di canvas
  void _drawEmoticon(Canvas canvas, String emoticon, Offset position,
      double size, double rotation, Color color) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: emoticon,
        style: TextStyle(
          fontSize: size,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(rotation);
    canvas.translate(-textPainter.width / 2, -textPainter.height / 2);
    textPainter.paint(canvas, Offset.zero);
    canvas.restore();
  }

  // Fungsi easing untuk efek bounce saat keluar
  double _easeOutBack(double t) {
    const double c1 = 1.70158;
    const double c3 = c1 + 1;
    return 1 + c3 * math.pow(t - 1, 3) + c1 * math.pow(t - 1, 2);
  }

  @override
  bool shouldRepaint(EffectAnimator oldAnimator) => true;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  @override
  double getDefaultRadiusMultiplier() => 1.4;

  @override
  double getOuterPadding() => 80.0; // Extra padding untuk gravitasi
}

class MagicPotionBubblesAnimator implements EffectAnimator {
  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final adjustedCenter = center + positionOffset;
    final random = math.Random(42); // Konsistensi antar frame

    // Jumlah gelembung
    final int bubbleCount = 20;

    // Area bergerak
    final double moveRadius = size.width * 0.7 * radiusMultiplier;

    // Warna-warna untuk efek magic potion
    final List<Color> potionColors = [
      color,
      HSLColor.fromColor(color)
          .withHue((HSLColor.fromColor(color).hue + 30) % 360)
          .toColor(),
      HSLColor.fromColor(color)
          .withHue((HSLColor.fromColor(color).hue + 60) % 360)
          .toColor(),
      HSLColor.fromColor(color)
          .withHue((HSLColor.fromColor(color).hue + 180) % 360)
          .toColor(),
      Colors.purpleAccent,
      Colors.pinkAccent,
    ];

    // Simbol-simbol dalam gelembung
    final List<IconData> potionSymbols = [
      Icons.star,
      Icons.favorite,
      Icons.bolt,
      Icons.local_fire_department,
      Icons.auto_awesome,
      Icons.brightness_7,
      Icons.flare,
      Icons.whatshot,
    ];

    for (int i = 0; i < bubbleCount; i++) {
      // Delay kemunculan per gelembung
      final double bubbleDelay = i * 0.03;
      final double adjustedProgress = math.max(0.0, progress - bubbleDelay);

      if (adjustedProgress <= 0) continue; // Belum waktunya muncul

      // Sudut dasar dan variasi
      final double baseAngle = random.nextDouble() * math.pi * 2;

      // Posisi awal - di sekitar widget
      final double startDistance = moveRadius * 0.2;

      // Posisi akhir - naik ke atas dengan zigzag
      // Kecepatan naik tergantung ukuran gelembung
      final double bubbleSpeed = 0.5 + random.nextDouble() * 0.5;
      final double verticalProgress = adjustedProgress * bubbleSpeed;

      // Pembatasan progress agar tidak terlalu jauh
      final double clampedVerticalProgress = math.min(1.0, verticalProgress);

      // Posisi akhir - bergerak naik dengan zigzag
      final double zigzagAmplitude = moveRadius * 0.2;
      final double zigzagFrequency = 2.0 + random.nextDouble() * 3.0;
      final double zigzagOffset =
          math.sin(verticalProgress * math.pi * zigzagFrequency) *
              zigzagAmplitude;

      // Efek zigzag pada posisi horizontal dan vertikal
      final Offset bubblePos = Offset(
        adjustedCenter.dx + math.cos(baseAngle) * startDistance + zigzagOffset,
        adjustedCenter.dy - (verticalProgress * moveRadius), // Naik ke atas
      );

      // Ukuran gelembung bervariasi
      final double baseBubbleSize =
          (size.width * 0.08) * (0.6 + random.nextDouble() * 0.8);

      // Efek pulsing pada ukuran
      final double pulseEffect =
          1.0 + math.sin(adjustedProgress * math.pi * 3) * 0.1;
      final double bubbleSize = baseBubbleSize * pulseEffect;

      // Opacity berdasarkan fase animasi
      double opacity;
      if (adjustedProgress < 0.2) {
        // Fase awal: fade in
        opacity = adjustedProgress / 0.2;
      } else if (verticalProgress > 0.8) {
        // Fase akhir: fade out ketika terlalu jauh
        opacity = (1.0 - verticalProgress) / 0.2;
      } else {
        // Fase tengah: opasitas penuh
        opacity = 1.0;
      }

      // Warna gelembung dengan variasi
      final Color bubbleColor =
          potionColors[i % potionColors.length].withOpacity(opacity);

      // Gambar gelembung
      canvas.drawCircle(
          bubblePos,
          bubbleSize,
          Paint()
            ..color = bubbleColor
            ..style = PaintingStyle.fill);

      // Gambar outline gelembung
      canvas.drawCircle(
          bubblePos,
          bubbleSize,
          Paint()
            ..color = Colors.white.withOpacity(opacity * 0.7)
            ..style = PaintingStyle.stroke
            ..strokeWidth = bubbleSize * 0.1);

      // Gambar kilauan di gelembung
      final double glintSize = bubbleSize * 0.3;
      canvas.drawCircle(
          Offset(
              bubblePos.dx - bubbleSize * 0.3, bubblePos.dy - bubbleSize * 0.3),
          glintSize,
          Paint()
            ..color = Colors.white.withOpacity(opacity * 0.8)
            ..style = PaintingStyle.fill);

      // Gambar simbol/ikon di dalam beberapa gelembung
      if (i % 3 == 0) {
        final IconData symbol = potionSymbols[i % potionSymbols.length];

        final TextPainter iconPainter = TextPainter(
          text: TextSpan(
            text: String.fromCharCode(symbol.codePoint),
            style: TextStyle(
              inherit: false,
              color: Colors.white.withOpacity(opacity * 0.9),
              fontSize: bubbleSize * 0.8,
              fontFamily: symbol.fontFamily,
              package: symbol.fontPackage,
            ),
          ),
          textDirection: TextDirection.ltr,
        );

        iconPainter.layout();
        iconPainter.paint(
            canvas,
            Offset(
              bubblePos.dx - iconPainter.width / 2,
              bubblePos.dy - iconPainter.height / 2,
            ));
      }
    }
  }

  @override
  bool shouldRepaint(EffectAnimator oldAnimator) => true;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  @override
  double getDefaultRadiusMultiplier() => 1.5;

  @override
  double getOuterPadding() => 70.0;
}

class BubbleLettersAnimator implements EffectAnimator {
  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final adjustedCenter = center + positionOffset;
    final random = math.Random(42); // Konsistensi antar frame

    // Huruf yang akan ditampilkan dalam gelembung
    final List<String> letters = [
      'A',
      'B',
      'C',
      '1',
      '2',
      '3',
      '+',
      '-',
      '×',
      '÷',
      '=',
      '!'
    ];

    // Jumlah gelembung huruf
    final int bubbleCount = 12;

    // Area bergerak
    final double moveRadius = size.width * 0.7 * radiusMultiplier;

    for (int i = 0; i < bubbleCount; i++) {
      // Delay kemunculan per huruf
      final double bubbleDelay = i * 0.05;
      final double adjustedProgress = math.max(0.0, progress - bubbleDelay);

      if (adjustedProgress <= 0) continue; // Belum waktunya muncul

      // Huruf untuk gelembung ini
      final String letter = letters[i % letters.length];

      // Sudut dasar dan variasi
      final double baseAngle = (i * (360 / bubbleCount)) * (math.pi / 180);

      // Posisi awal - di sekitar widget
      final double startDistance = moveRadius * 0.3;

      // Posisi akhir - bergerak naik dengan zigzag
      final double verticalProgress =
          adjustedProgress * (0.7 + random.nextDouble() * 0.5);

      // Efek zigzag pada posisi horizontal dan path melengkung
      final double horizontalOffset =
          math.sin(verticalProgress * math.pi * 2) * (moveRadius * 0.2);

      // Posisi akhir dengan path melengkung ke atas
      final Offset bubblePos = Offset(
        adjustedCenter.dx +
            math.cos(baseAngle) * startDistance +
            horizontalOffset,
        adjustedCenter.dy +
            math.sin(baseAngle) * startDistance -
            (verticalProgress * moveRadius), // Naik ke atas
      );

      // Ukuran gelembung
      final double baseBubbleSize =
          (size.width * 0.08) * (0.8 + random.nextDouble() * 0.4);

      // Efek pulsing pada ukuran
      final double pulseEffect =
          1.0 + math.sin(adjustedProgress * math.pi * 2) * 0.1;
      final double bubbleSize = baseBubbleSize * pulseEffect;

      // Opacity berdasarkan fase animasi
      double opacity;
      if (adjustedProgress < 0.2) {
        // Fase awal: fade in
        opacity = adjustedProgress / 0.2;
      } else if (verticalProgress > 0.8) {
        // Fase akhir: fade out
        opacity = (1.0 - verticalProgress) / 0.2;
      } else {
        // Fase tengah: opasitas penuh
        opacity = 1.0;
      }

      // Palet warna edukatif
      final List<Color> bubbleColors = [
        Color(0xFF42A5F5), // Biru
        Color(0xFF66BB6A), // Hijau
        Color(0xFFFFCA28), // Kuning
        Color(0xFFEF5350), // Merah
        Color(0xFFAB47BC), // Ungu
      ];

      // Warna gelembung dengan variasi
      final Color bubbleColor =
          bubbleColors[i % bubbleColors.length].withOpacity(opacity);

      // Gambar gelembung
      canvas.drawCircle(
          bubblePos,
          bubbleSize,
          Paint()
            ..color = bubbleColor
            ..style = PaintingStyle.fill);

      // Gambar outline gelembung
      canvas.drawCircle(
          bubblePos,
          bubbleSize,
          Paint()
            ..color = Colors.white.withOpacity(opacity * 0.7)
            ..style = PaintingStyle.stroke
            ..strokeWidth = bubbleSize * 0.08);

      // Gambar kilauan di gelembung
      final double glintSize = bubbleSize * 0.25;
      canvas.drawCircle(
          Offset(
              bubblePos.dx - bubbleSize * 0.3, bubblePos.dy - bubbleSize * 0.3),
          glintSize,
          Paint()
            ..color = Colors.white.withOpacity(opacity * 0.8)
            ..style = PaintingStyle.fill);

      // Gambar huruf di dalam gelembung
      final TextStyle textStyle = TextStyle(
        color: Colors.white.withOpacity(opacity),
        fontSize: bubbleSize * 0.8,
        fontWeight: FontWeight.bold,
      );

      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: letter,
          style: textStyle,
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
          canvas,
          Offset(
            bubblePos.dx - textPainter.width / 2,
            bubblePos.dy - textPainter.height / 2,
          ));
    }
  }

  @override
  bool shouldRepaint(EffectAnimator oldAnimator) => true;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  @override
  double getDefaultRadiusMultiplier() => 1.4;

  @override
  double getOuterPadding() => 60.0;
}

class MathicleCloudAnimator implements EffectAnimator {
  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final adjustedCenter = center + positionOffset;
    final random = math.Random(42); // Konsistensi antar frame

    // Jumlah partikel
    final int particleCount = 40;

    // Area bergerak
    final double cloudRadius = size.width * 0.7 * radiusMultiplier;

    // Daftar simbol matematika
    final List<String> mathSymbols = [
      '+',
      '-',
      '×',
      '÷',
      '=',
      '≠',
      '≈',
      '∞',
      'π',
      '√',
      '∑',
      '∫',
      '∂',
      '∝',
      'θ',
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '0',
    ];

    // Ukuran simbol
    final double baseSymbolSize = size.width * 0.07;

    for (int i = 0; i < particleCount; i++) {
      // Simbol untuk partikel ini
      final String symbol = mathSymbols[i % mathSymbols.length];

      // Fase hidup partikel dengan delay
      final double particleDelay = i * 0.02;
      final double adjustedProgress = math.max(0.0, progress - particleDelay);

      if (adjustedProgress <= 0) continue; // Belum waktunya muncul

      // Pergerakan dalam awan
      double t = adjustedProgress;

      // Posisi awal - acak di sekitar widget
      final double initialAngle = random.nextDouble() * math.pi * 2;
      final double initialDistance = random.nextDouble() * cloudRadius * 0.5;

      // Pergerakan melayang dalam awan
      final double currentAngle =
          initialAngle + math.sin(t * math.pi * 2) * 0.3;

      // Efek seperti awan yang mengembang
      double currentDistance = initialDistance;
      if (t < 0.3) {
        // Awan membentuk dari sekitar widget
        currentDistance = initialDistance * (1.0 + (t / 0.3) * 0.5);
      } else if (t > 0.7) {
        // Awan menyebar
        currentDistance = initialDistance * (1.5 + ((t - 0.7) / 0.3) * 1.0);
      } else {
        // Awan tetap stabil dengan sedikit gerakan acak
        currentDistance =
            initialDistance * 1.5 * (1.0 + math.sin(t * math.pi * 4) * 0.1);
      }

      // Posisi partikel
      final Offset symbolPos = Offset(
          adjustedCenter.dx + math.cos(currentAngle) * currentDistance,
          adjustedCenter.dy + math.sin(currentAngle) * currentDistance);

      // Ukuran simbol dengan variasi
      final double symbolSize =
          baseSymbolSize * (0.6 + random.nextDouble() * 0.8);

      // Rotasi simbol untuk efek dinamis
      final double rotation = t * math.pi * (random.nextDouble() * 2 - 1);

      // Opasitas berdasarkan fase
      double opacity;
      if (t < 0.2) {
        // Muncul
        opacity = t / 0.2;
      } else if (t > 0.8) {
        // Menghilang
        opacity = (1.0 - t) / 0.2;
      } else {
        // Tampak penuh dengan fluktuasi
        opacity = 0.7 + math.sin(t * math.pi * 3) * 0.3;
      }

      // Variasi warna untuk simbol
      final Color symbolColor = _getSymbolColor(symbol, color, opacity);

      // Gambar simbol
      _drawMathSymbol(
          canvas, symbol, symbolPos, symbolSize, rotation, symbolColor);
    }
  }

  // Menggambar simbol matematika
  void _drawMathSymbol(Canvas canvas, String symbol, Offset position,
      double size, double rotation, Color color) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: symbol,
        style: TextStyle(
          fontSize: size,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(rotation);
    canvas.translate(-textPainter.width / 2, -textPainter.height / 2);
    textPainter.paint(canvas, Offset.zero);
    canvas.restore();
  }

  // Memilih warna berdasarkan jenis simbol
  Color _getSymbolColor(String symbol, Color baseColor, double opacity) {
    if (RegExp(r'[0-9]').hasMatch(symbol)) {
      // Angka - biru
      return Color(0xFF42A5F5).withOpacity(opacity);
    } else if (['+', '-', '×', '÷'].contains(symbol)) {
      // Operator - hijau
      return Color(0xFF66BB6A).withOpacity(opacity);
    } else if (['=', '≠', '≈', '<', '>'].contains(symbol)) {
      // Perbandingan - oranye
      return Color(0xFFFF9800).withOpacity(opacity);
    } else if (['π', '∞', '∑', '∫'].contains(symbol)) {
      // Simbol khusus - merah
      return Color(0xFFEF5350).withOpacity(opacity);
    } else {
      // Simbol lainnya - ungu
      return Color(0xFFAB47BC).withOpacity(opacity);
    }
  }

  @override
  bool shouldRepaint(EffectAnimator oldAnimator) => true;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  @override
  double getDefaultRadiusMultiplier() => 1.3;

  @override
  double getOuterPadding() => 55.0;
}

class MultiplicationRingsAnimator implements EffectAnimator {
  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final adjustedCenter = center + positionOffset;

    // Jumlah lingkaran konsentris
    final int ringCount = 5;

    // Jumlah angka per lingkaran
    final int numbersPerRing = 12;

    // Radius maksimum
    final double maxRadius = size.width * 0.6 * radiusMultiplier;

    // Ukuran angka
    final double numberSize = size.width * 0.05;

    // Warna-warna untuk lingkaran
    final List<Color> ringColors = [
      Color(0xFF2196F3), // Biru
      Color(0xFF4CAF50), // Hijau
      Color(0xFFFF9800), // Oranye
      Color(0xFFE91E63), // Pink
      Color(0xFF9C27B0), // Ungu
    ];

    for (int ring = 0; ring < ringCount; ring++) {
      // Nilai perkalian untuk lingkaran ini (2×, 3×, 4×, dst)
      final int multiplier = ring + 2;

      // Delay kemunculan per lingkaran - dari dalam ke luar
      final double ringDelay = ring * 0.1;
      final double adjustedProgress = math.max(0.0, progress - ringDelay);

      if (adjustedProgress <= 0) continue; // Lingkaran belum muncul

      // Radius lingkaran ini
      final double baseRadius = maxRadius * ((ring + 1) / ringCount);

      // Animasi radius - membesar
      double currentRadius;
      if (adjustedProgress < 0.2) {
        // Fase membesar
        currentRadius = baseRadius * (adjustedProgress / 0.2);
      } else {
        // Ukuran penuh dengan sedikit pulsing
        currentRadius = baseRadius *
            (1.0 + math.sin(adjustedProgress * math.pi * 3) * 0.05);
      }

      // Ketebalan lingkaran
      final double ringThickness = numberSize * 1.5;

      // Opacity berdasarkan fase
      double opacity;
      if (adjustedProgress < 0.2) {
        // Fase awal: muncul
        opacity = adjustedProgress / 0.2;
      } else if (adjustedProgress > 0.8) {
        // Fase akhir: menghilang
        opacity = (1.0 - adjustedProgress) / 0.2;
      } else {
        // Fase tengah: terlihat penuh
        opacity = 1.0;
      }

      // Warna lingkaran
      final Color ringColor =
          ringColors[ring % ringColors.length].withOpacity(opacity * 0.3);

      // Gambar lingkaran
      canvas.drawCircle(
          adjustedCenter,
          currentRadius,
          Paint()
            ..color = ringColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = ringThickness);

      // Kecepatan rotasi berbeda untuk tiap lingkaran
      final double rotationOffset =
          progress * math.pi * 2 * (1.0 - ring * 0.15);

      // Gambar angka-angka perkalian pada lingkaran
      for (int i = 0; i < numbersPerRing; i++) {
        // Posisi angka pada lingkaran
        final double angle =
            (i * (360 / numbersPerRing) * (math.pi / 180)) + rotationOffset;

        // Angka hasil perkalian
        final int number = (i + 1) * multiplier;

        // Posisi angka
        final Offset numberPos = Offset(
            adjustedCenter.dx + math.cos(angle) * currentRadius,
            adjustedCenter.dy + math.sin(angle) * currentRadius);

        // Warna angka
        final Color numberColor = Colors.white.withOpacity(opacity);

        // Ukuran angka dengan variasi
        final double finalNumberSize =
            numberSize * (1.0 + math.sin(angle * 2) * 0.2);

        // Gambar lingkaran kecil sebagai background angka
        canvas.drawCircle(
            numberPos,
            finalNumberSize * 0.7,
            Paint()
              ..color =
                  ringColors[ring % ringColors.length].withOpacity(opacity));

        // Gambar angka
        final TextPainter textPainter = TextPainter(
          text: TextSpan(
            text: number.toString(),
            style: TextStyle(
              fontSize: finalNumberSize,
              color: numberColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();
        textPainter.paint(
            canvas,
            numberPos.translate(
                -textPainter.width / 2, -textPainter.height / 2));
      }
    }
  }

  @override
  bool shouldRepaint(EffectAnimator oldAnimator) => true;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  @override
  double getDefaultRadiusMultiplier() => 1.3;

  @override
  double getOuterPadding() => 50.0;
}

class AlgebraicTermWalkAnimator implements EffectAnimator {
  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final adjustedCenter = center + positionOffset;

    // Daftar istilah aljabar
    final List<String> algebraicTerms = [
      'x²',
      'y²',
      '2x',
      '3y',
      'xy',
      'a+b',
      'a-b',
      '∛x',
      '√y',
      'z³',
      '2a',
      '3b',
      'x+y',
      'a·b',
      'a/b'
    ];

    // Jumlah istilah yang ditampilkan
    final int termCount = 12;

    // Radius path di sekitar widget
    final double pathRadius = size.width * 0.6 * radiusMultiplier;

    // Ukuran istilah
    final double termSize = size.width * 0.08;

    // Warna-warna matematika
    final List<Color> mathColors = [
      Color(0xFF42A5F5), // Biru
      Color(0xFF66BB6A), // Hijau
      Color(0xFFFFCA28), // Kuning
      Color(0xFFEF5350), // Merah
      Color(0xFFAB47BC), // Ungu
    ];

    // Gambar path oval di sekitar widget (opsional, untuk visualisasi)
    if (false) {
      // Ganti ke true untuk melihat path
      canvas.drawOval(
          Rect.fromCenter(
              center: adjustedCenter,
              width: pathRadius * 2,
              height: pathRadius * 1.7),
          Paint()
            ..color = color.withOpacity(0.1)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0);
    }

    for (int i = 0; i < termCount; i++) {
      // Istilah untuk posisi ini
      final String term = algebraicTerms[i % algebraicTerms.length];

      // Offset posisi di path untuk variasi
      final double posOffset = (i / termCount) * math.pi * 2;

      // Fase gerakan dengan sedikit delay untuk setiap istilah
      final double movePhase = (progress + (i / termCount)) % 1.0;

      // Posisi pada jalur oval
      final double angle = movePhase * math.pi * 2 + posOffset;

      // Membuat jalur oval (bukan lingkaran sempurna)
      final double xRadius = pathRadius;
      final double yRadius =
          pathRadius * 0.85; // Sedikit lebih pendek di sumbu y

      final Offset termPos = Offset(
          adjustedCenter.dx + math.cos(angle) * xRadius,
          adjustedCenter.dy + math.sin(angle) * yRadius);

      // Efek bobbing (naik-turun) saat bergerak
      final double bobbingEffect = math.sin(angle * 3) * (termSize * 0.2);
      final Offset finalPos = Offset(termPos.dx, termPos.dy + bobbingEffect);

      // Opacity - fade in di awal dan fade out di akhir
      double opacity;
      final double normalizedPhase = (movePhase * termCount) % 1.0;

      if (normalizedPhase < 0.1) {
        // Fade in
        opacity = normalizedPhase / 0.1;
      } else if (normalizedPhase > 0.9) {
        // Fade out
        opacity = (1.0 - normalizedPhase) / 0.1;
      } else {
        // Opacity penuh
        opacity = 1.0;
      }

      // Warna istilah
      final Color termColor =
          mathColors[i % mathColors.length].withOpacity(opacity);

      // Rotasi untuk efek lebih dinamis
      final double rotation = math.sin(angle) * 0.2;

      // Gambar background istilah
      final double backgroundSize = termSize * 1.2;
      canvas.drawCircle(
          finalPos,
          backgroundSize / 2,
          Paint()
            ..color = termColor.withOpacity(opacity * 0.3)
            ..style = PaintingStyle.fill);

      // Gambar border
      canvas.drawCircle(
          finalPos,
          backgroundSize / 2,
          Paint()
            ..color = termColor.withOpacity(opacity * 0.8)
            ..style = PaintingStyle.stroke
            ..strokeWidth = backgroundSize * 0.05);

      // Gambar istilah aljabar
      _drawAlgebraicTerm(canvas, term, finalPos, termSize, rotation, termColor);

      // Tambahkan efek pancaran/glow untuk beberapa istilah
      if (i % 3 == 0) {
        canvas.drawCircle(
            finalPos,
            backgroundSize * 0.7,
            Paint()
              ..color = termColor.withOpacity(opacity * 0.2)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0));
      }
    }
  }

  // Menggambar istilah aljabar
  void _drawAlgebraicTerm(Canvas canvas, String term, Offset position,
      double size, double rotation, Color color) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: term,
        style: TextStyle(
          fontSize: size,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(rotation);
    canvas.translate(-textPainter.width / 2, -textPainter.height / 2);
    textPainter.paint(canvas, Offset.zero);
    canvas.restore();
  }

  @override
  bool shouldRepaint(EffectAnimator oldAnimator) => true;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  @override
  double getDefaultRadiusMultiplier() => 1.3;

  @override
  double getOuterPadding() => 55.0;
}
