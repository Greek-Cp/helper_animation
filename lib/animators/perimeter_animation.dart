import 'dart:math' as math;
import 'dart:math';

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:helper_animation/animators/effect_animator.dart';
import 'package:helper_animation/constants/enums.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'dart:math' as math;
import 'dart:ui';

import 'dart:math' as math;
import 'dart:ui';
import 'dart:math' as math;
import 'dart:ui';
import 'dart:math' as math;
import 'dart:ui';
import 'dart:math' as math;
import 'dart:ui';
import 'dart:math' as math;
import 'dart:ui';

/// PerimeterPulseCascadeAnimator - Animator efek multi-fase dimana pulse/gelombang
/// bergerak di sepanjang perimeter dan partikel-partikel mengeluarkan burst.
class PerimeterPulseCascadeAnimator implements EffectAnimator {
  // Parameter visual
  final int dotCount; // Jumlah partikel
  final double dotSize; // Ukuran dasar dot
  final double pulseAmplitude; // Amplitudo pulsasi (0-1)
  final double pulseWidth; // Lebar gelombang pulsasi
  final int pulseLaps; // Jumlah putaran gelombang
  final double burstRadius; // Jarak burst
  final double perimetralShift; // Jarak dari perimeter

  // Parameter lanjutan
  final bool enableGlow; // Aktifkan efek glow
  final double glowSize; // Ukuran relatif glow
  final double glowIntensity; // Intensitas glow
  final bool enableTrails; // Aktifkan efek trails
  final int trailCount; // Jumlah trail per dot
  final double trailFade; // Kecepatan memudar trail

  // Parameter warna
  final bool enableHueTilt; // Aktifkan gradasi warna
  final double hueTiltRange; // Rentang gradasi (0-1 = 0-360°)
  final double saturationBoost; // Penguatan saturasi warna

  PerimeterPulseCascadeAnimator({
    this.dotCount = 36, // Banyak dot untuk efek gelombang halus
    this.dotSize = 5, // Ukuran moderat
    this.pulseAmplitude = 0.8, // Amplitudo besar untuk efek dramatis
    this.pulseWidth = 0.2, // Lebar gelombang 20% dari perimeter
    this.pulseLaps = 2, // 2 putaran untuk animasi lengkap
    this.burstRadius = 20.0, // Jarak burst yang terlihat
    this.perimetralShift = 8.0, // Sedikit jarak dari tepi

    this.enableGlow = true, // Aktifkan glow untuk efek visual
    this.glowSize = 2.5, // Glow 2.5x ukuran dot
    this.glowIntensity = 0.5, // Intensitas moderat
    this.enableTrails = true, // Aktifkan trail
    this.trailCount = 3, // 3 trail per dot
    this.trailFade = 0.8, // Memudar cepat

    this.enableHueTilt = false, // Default tidak menggunakan hueTilt
    this.hueTiltRange = 1.0, // Jika diaktifkan, rentang warna penuh (360°)
    this.saturationBoost = 1.2, // Sedikit peningkatan saturasi
  });

  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final c = center + positionOffset;

    // Buat rect untuk perimeter
    final rect = Rect.fromCenter(
      center: c,
      width: size.width,
      height: size.height,
    );

    // Jarak burst aktual
    final actualBurstRadius = burstRadius * radiusMultiplier;

    // Gambar trail terlebih dahulu jika diaktifkan
    if (enableTrails) {
      for (int trail = trailCount - 1; trail >= 0; trail--) {
        final trailProgress = (progress - (trail * 0.02)).clamp(0.0, 1.0);
        final trailOpacity =
            math.pow(1 - (trail / trailCount), trailFade).toDouble();

        _drawPerimeterPulse(canvas, rect, c, trailProgress, color,
            radiusMultiplier, trailOpacity.toDouble());
      }
    } else {
      // Gambar hanya satu pulse tanpa trail
      _drawPerimeterPulse(
          canvas, rect, c, progress, color, radiusMultiplier, 1.0);
    }
  }

  // Helper method untuk menggambar pulse pada perimeter
  void _drawPerimeterPulse(
      Canvas canvas,
      Rect rect,
      Offset center,
      double progress,
      Color color,
      double radiusMultiplier,
      double baseOpacity) {
    // Progress mengontrol posisi gelombang di sepanjang perimeter
    final wavePosition = (progress * pulseLaps) % 1.0;

    // Gambar dots di sepanjang perimeter
    for (int i = 0; i < dotCount; i++) {
      final perimeterRatio = i / dotCount;

      // Posisi dasar pada perimeter
      final basePos = _getPositionOnPerimeter(rect, perimeterRatio);

      // Hitung jarak dari pusat gelombang (0-0.5, dimana 0 = pusat gelombang)
      final distFromPulse = (perimeterRatio - wavePosition).abs();
      final wrappedDist = math.min(distFromPulse, 1 - distFromPulse);

      // Hitung faktor pulsasi berdasarkan jarak dari pusat gelombang
      double pulseFactor = 0;
      if (wrappedDist < pulseWidth / 2) {
        // Use cosine to create smooth pulse shape
        pulseFactor = math.cos((wrappedDist / (pulseWidth / 2)) * math.pi) *
            pulseAmplitude;
      }

      // Arah dari pusat ke perimeter
      final dirVector = basePos - center;
      final distance = dirVector.distance;
      final direction = distance > 0
          ? Offset(dirVector.dx / distance, dirVector.dy / distance)
          : Offset(0, 0);

      // Jarak dari perimeter
      final shiftDistance = perimetralShift * radiusMultiplier;
      final baseShiftedPos = basePos - direction * shiftDistance;

      // Posisi akhir dengan burst
      final burstDistance = pulseFactor * 30;
      final pos = baseShiftedPos - direction * burstDistance;

      // Scale dot berdasarkan pulsasi
      final scale = 1.0 + pulseFactor * 1.5;

      // Opacity menurun untuk trail
      final opacity = baseOpacity * (0.3 + pulseFactor * 0.7).clamp(0.3, 1.0);

      // Warna dot
      Color dotColor = color;
      if (enableHueTilt) {
        final hsl = HSLColor.fromColor(color);
        final hueShift = perimeterRatio * 360 * hueTiltRange;
        dotColor = hsl
            .withHue((hsl.hue + hueShift) % 360)
            .withSaturation((hsl.saturation * saturationBoost).clamp(0.0, 1.0))
            .toColor();
      }
      dotColor = dotColor.withOpacity(opacity);

      // Ukuran akhir dot
      final rad = dotSize * radiusMultiplier * scale;

      // Gambar glow effect
      if (enableGlow && pulseFactor > 0.2) {
        final glowRadius = rad * glowSize;
        final glowOpacity = opacity * pulseFactor * glowIntensity;

        canvas.drawCircle(
            pos,
            glowRadius,
            Paint()
              ..color = dotColor.withOpacity(glowOpacity)
              ..maskFilter =
                  MaskFilter.blur(BlurStyle.normal, glowRadius * 0.5));
      }

      // Gambar dot
      canvas.drawCircle(pos, rad, Paint()..color = dotColor);
    }
  }

  // Helper untuk posisi di perimeter
  Offset _getPositionOnPerimeter(Rect rect, double ratio) {
    final totalPerimeter = 2 * (rect.width + rect.height);
    final distanceAlongPerimeter = totalPerimeter * ratio;

    // Top edge
    if (distanceAlongPerimeter < rect.width) {
      return Offset(rect.left + distanceAlongPerimeter, rect.top);
    }
    // Right edge
    else if (distanceAlongPerimeter < rect.width + rect.height) {
      return Offset(
          rect.right, rect.top + (distanceAlongPerimeter - rect.width));
    }
    // Bottom edge
    else if (distanceAlongPerimeter < 2 * rect.width + rect.height) {
      return Offset(
          rect.right - (distanceAlongPerimeter - rect.width - rect.height),
          rect.bottom);
    }
    // Left edge
    else {
      return Offset(
          rect.left,
          rect.bottom -
              (distanceAlongPerimeter - 2 * rect.width - rect.height));
    }
  }

  @override
  bool shouldRepaint(EffectAnimator old) =>
      old is! PerimeterPulseCascadeAnimator ||
      old.dotCount != dotCount ||
      old.dotSize != dotSize ||
      old.pulseAmplitude != pulseAmplitude ||
      old.pulseWidth != pulseWidth ||
      old.pulseLaps != pulseLaps ||
      old.burstRadius != burstRadius ||
      old.perimetralShift != perimetralShift ||
      old.enableGlow != enableGlow ||
      old.glowSize != glowSize ||
      old.glowIntensity != glowIntensity ||
      old.enableTrails != enableTrails ||
      old.trailCount != trailCount ||
      old.trailFade != trailFade ||
      old.enableHueTilt != enableHueTilt ||
      old.hueTiltRange != hueTiltRange ||
      old.saturationBoost != saturationBoost;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  @override
  double getDefaultRadiusMultiplier() => 1.0;

  @override
  double getOuterPadding() =>
      perimetralShift +
      burstRadius * (1 + pulseAmplitude) +
      dotSize * glowSize +
      10;
}

/// PerimeterConvergeBurstAnimator - Animator efek multi-fase dimana partikel
/// dari perimeter menuju ke pusat, berdenyut, lalu meledak kembali ke perimeter.
class PerimeterConvergeBurstAnimator implements EffectAnimator {
  // Parameter visual
  final int dotCount; // Jumlah partikel
  final double dotSize; // Ukuran dot
  final double dotTailFactor; // Panjang ekor
  final bool enableTail; // Aktifkan ekor
  final double pulseEffect; // Efek pulsasi (0-1)
  final double perimetralShift; // Jarak partikel dari perimeter

  // Fase animasi (proporsi total durasi)
  final double convergePhase; // Fase konvergensi menuju pusat
  final double holdPhase; // Fase diam di pusat dengan pulsasi
  final double burstPhase; // Fase ledakan kembali ke perimeter

  // Parameter lanjutan
  final bool staggered; // Delay antar partikel
  final double staggerAmount; // Jumlah delay
  final bool randomizeOrigin; // Acak posisi awal di perimeter

  // Parameter warna
  final bool enableHueTilt; // Aktifkan gradasi warna
  final double hueTiltRange; // Rentang gradasi (0-1 = 0-360°)
  final double saturationBoost; // Penguatan saturasi warna

  PerimeterConvergeBurstAnimator({
    this.dotCount = 16, // Jumlah dot yang masuk akal untuk perimeter
    this.dotSize = 8, // Ukuran yang terlihat jelas
    this.dotTailFactor = 2.5, // Ekor cukup panjang untuk terlihat
    this.enableTail = true, // Aktifkan ekor untuk efek gerakan
    this.pulseEffect = 0.4, // Pulsasi moderat
    this.perimetralShift = 15.0, // Jarak partikel dari perimeter

    this.convergePhase = 0.35, // 35% waktu untuk konvergensi
    this.holdPhase = 0.2, // 20% waktu untuk diam dan berdenyut
    this.burstPhase = 0.45, // 45% waktu untuk ledakan kembali

    this.staggered = true, // Aktifkan delay antar partikel
    this.staggerAmount = 0.15, // Delay 15% dari total durasi
    this.randomizeOrigin = false, // Posisi awal deterministic

    this.enableHueTilt = false, // Default tidak menggunakan hueTilt
    this.hueTiltRange = 0.8, // Jika diaktifkan, rentang warna 80% (288°)
    this.saturationBoost = 1.2, // Sedikit peningkatan saturasi
  });

  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final c = center + positionOffset;

    // Buat rect untuk perimeter
    final rect = Rect.fromCenter(
      center: c,
      width: size.width,
      height: size.height,
    );

    // Generator acak dengan seed tetap untuk konsistensi
    final rnd = math.Random(42);

    // Hitung batas fase
    final double endConverge = convergePhase;
    final double endHold = convergePhase + holdPhase;
    // endBurst = 1.0

    // Define origin positions for all dots at the perimeter
    final List<Offset> originPositions = [];
    final List<double> perimeterRatios = [];

    // Generate position ratios along perimeter
    for (int i = 0; i < dotCount; i++) {
      double ratio;
      if (randomizeOrigin) {
        ratio = rnd.nextDouble(); // Random position
      } else {
        ratio = i / dotCount; // Evenly spaced
      }
      perimeterRatios.add(ratio);
      originPositions.add(_getPositionOnPerimeter(rect, ratio));
    }

    // Draw each dot
    for (int i = 0; i < dotCount; i++) {
      // Apply staggered delay if enabled
      double adjustedProgress = progress;
      if (staggered) {
        final delay = (i / dotCount) * staggerAmount;
        adjustedProgress = (progress - delay).clamp(0.0, 1.0) / (1.0 - delay);
      }

      // Get dot origin position
      final originPos = originPositions[i];
      final perimeterRatio = perimeterRatios[i];

      // Direction from center to perimeter (for returning phase)
      final dirVector = originPos - c;
      final distance = dirVector.distance;
      final direction = distance > 0
          ? Offset(dirVector.dx / distance, dirVector.dy / distance)
          : Offset(0, 0);

      // Calculate position, scale and opacity based on phase
      Offset pos;
      double dotScale = 1.0;
      double opacity = 1.0;

      // Perimeter shift - make sure dots stay slightly away from edges
      final shiftDistance = perimetralShift * radiusMultiplier;
      final adjustedOrigin = originPos - direction * shiftDistance;

      // PHASE 1: CONVERGE
      if (adjustedProgress < endConverge) {
        final convergeProgress = adjustedProgress / endConverge;
        final easeProgress = _easeInOutCubic(convergeProgress);

        // Interpolate from origin to center
        pos = Offset.lerp(adjustedOrigin, c, easeProgress)!;

        // Scale grows as dots approach center
        dotScale = 0.6 + easeProgress * 0.4;

        // Full opacity during convergence
        opacity = 1.0;
      }
      // PHASE 2: HOLD
      else if (adjustedProgress < endHold) {
        // Stay at center
        pos = c;

        // Apply pulsation during hold
        final holdProgress = (adjustedProgress - endConverge) / holdPhase;
        final pulseVal = math.sin(holdProgress * math.pi * 5) * pulseEffect;
        dotScale = 1.0 + pulseVal;

        // Fully opaque during hold
        opacity = 1.0;
      }
      // PHASE 3: BURST
      else {
        final burstProgress = (adjustedProgress - endHold) / (1.0 - endHold);

        // Use elastic easing for burst
        final easeProgress = _easeOutElastic(burstProgress);

        // Interpolate from center back to origin
        pos = Offset.lerp(c, adjustedOrigin, easeProgress)!;

        // Scale fades out toward the end
        dotScale = burstProgress > 0.8
            ? 1.0 - ((burstProgress - 0.8) / 0.2) * 0.3
            : 1.0;

        // Opacity fades out toward the end
        opacity =
            burstProgress > 0.85 ? 1.0 - ((burstProgress - 0.85) / 0.15) : 1.0;
      }

      // Apply hueTilt if enabled
      Color dotColor = color;
      if (enableHueTilt) {
        final hsl = HSLColor.fromColor(color);
        final hueShift = perimeterRatio * 360 * hueTiltRange;
        dotColor = hsl
            .withHue((hsl.hue + hueShift) % 360)
            .withSaturation((hsl.saturation * saturationBoost).clamp(0.0, 1.0))
            .toColor();
      }
      dotColor = dotColor.withOpacity(opacity);

      // Calculate final dot radius
      final rad = dotSize * radiusMultiplier * dotScale;

      // TAIL EFFECT - only in converge and burst phases
      if (enableTail &&
          (adjustedProgress < endConverge || adjustedProgress > endHold)) {
        final tailLen = rad * dotTailFactor;

        Offset tailDir;
        // Converge: tail points away from center
        if (adjustedProgress < endConverge) {
          tailDir = -direction;
        }
        // Burst: tail points toward center
        else {
          tailDir = direction;
        }

        // Calculate tail start position
        final tailStart = pos - tailDir * tailLen;

        // Draw tail
        canvas.drawLine(
            tailStart,
            pos,
            Paint()
              ..color = dotColor.withOpacity(opacity * 0.7)
              ..strokeWidth = rad * 0.8
              ..strokeCap = StrokeCap.round);
      }

      // Draw dot
      canvas.drawCircle(pos, rad, Paint()..color = dotColor);
    }
  }

  // Helper for positioning on perimeter
  Offset _getPositionOnPerimeter(Rect rect, double ratio) {
    final totalPerimeter = 2 * (rect.width + rect.height);
    final distanceAlongPerimeter = totalPerimeter * ratio;

    // Top edge
    if (distanceAlongPerimeter < rect.width) {
      return Offset(rect.left + distanceAlongPerimeter, rect.top);
    }
    // Right edge
    else if (distanceAlongPerimeter < rect.width + rect.height) {
      return Offset(
          rect.right, rect.top + (distanceAlongPerimeter - rect.width));
    }
    // Bottom edge
    else if (distanceAlongPerimeter < 2 * rect.width + rect.height) {
      return Offset(
          rect.right - (distanceAlongPerimeter - rect.width - rect.height),
          rect.bottom);
    }
    // Left edge
    else {
      return Offset(
          rect.left,
          rect.bottom -
              (distanceAlongPerimeter - 2 * rect.width - rect.height));
    }
  }

  // Easing functions
  double _easeInOutCubic(double t) {
    return t < 0.5 ? 4 * t * t * t : 1 - math.pow(-2 * t + 2, 3) / 2;
  }

  double _easeOutElastic(double t) {
    const c4 = (2 * math.pi) / 3;
    return t == 0
        ? 0
        : t == 1
            ? 1
            : math.pow(2, -10 * t) * math.sin((t * 10 - 0.75) * c4) + 1;
  }

  @override
  bool shouldRepaint(EffectAnimator old) =>
      old is! PerimeterConvergeBurstAnimator ||
      old.dotCount != dotCount ||
      old.dotSize != dotSize ||
      old.dotTailFactor != dotTailFactor ||
      old.enableTail != enableTail ||
      old.pulseEffect != pulseEffect ||
      old.perimetralShift != perimetralShift ||
      old.convergePhase != convergePhase ||
      old.holdPhase != holdPhase ||
      old.burstPhase != burstPhase ||
      old.staggered != staggered ||
      old.staggerAmount != staggerAmount ||
      old.randomizeOrigin != randomizeOrigin ||
      old.enableHueTilt != enableHueTilt ||
      old.hueTiltRange != hueTiltRange ||
      old.saturationBoost != saturationBoost;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  @override
  double getDefaultRadiusMultiplier() => 1.0;

  @override
  double getOuterPadding() =>
      perimetralShift + dotSize * (1 + dotTailFactor) + 10;
}

class PerimeterPulsatingOrbitAnimator implements EffectAnimator {
  // ─── Parameter visual ─────
  final int particleCount; // Jumlah partikel
  final double baseRadius; // Radius dasar partikel
  final double trailLength; // Panjang trail (dalam jumlah partikel)
  final double pulseFrequency; // Frekuensi pulsasi
  final double pulseAmplitude; // Amplitudo pulsasi (faktor penambahan ukuran)
  final double orbitOffset; // Jarak orbit dari perimeter
  final double orbitVariation; // Variasi jarak orbit (untuk efek bergelombang)
  final double trailFade; // Tingkat pelemahan trail (0-1)

  // ─── Parameter warna ─────
  final bool enableHueTilt; // Aktifkan gradasi warna
  final double hueTiltRange; // Rentang gradasi (0-1, dimana 1 = 360°)
  final double saturationBoost; // Peningkatan saturasi (1 = tidak berubah)
  final double brightnessBoost; // Peningkatan kecerahan (1 = tidak berubah)
  final bool glowEffect; // Aktifkan efek glow
  final double glowSize; // Ukuran glow relatif terhadap partikel

  PerimeterPulsatingOrbitAnimator({
    this.particleCount = 48, // Banyak partikel untuk efek mulus
    this.baseRadius = 4.0, // Ukuran dasar partikel
    this.trailLength = 6, // Trail pendek tapi terlihat
    this.pulseFrequency = 2.0, // Frekuensi pulsasi yang menarik
    this.pulseAmplitude = 0.5, // Amplitudo pulsasi moderate
    this.orbitOffset = 6.0, // Jarak orbit dari perimeter
    this.orbitVariation = 4.0, // Variasi jarak untuk gelombang
    this.trailFade = 0.8, // Trail yang memudar cepat

    this.enableHueTilt = false, // Default dinonaktifkan sesuai permintaan
    this.hueTiltRange = 1.0, // Gradasi warna penuh 360°
    this.saturationBoost = 1.2, // Tingkatkan sedikit saturasi
    this.brightnessBoost = 1.1, // Tingkatkan sedikit kecerahan
    this.glowEffect = true, // Aktifkan efek glow
    this.glowSize = 2.0, // Ukuran glow 2x ukuran partikel
  });

  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final c = center + positionOffset;

    // Buat rect untuk perimeter
    final rect = Rect.fromCenter(
      center: c,
      width: size.width,
      height: size.height,
    );

    // Tampilkan trail partikel (dari yang paling transparan ke yang paling solid)
    for (int trail = trailLength.toInt(); trail >= 0; trail--) {
      final trailProgress = (progress - (trail * 0.01)) % 1.0;
      if (trailProgress < 0) continue;

      final trailOpacity =
          math.pow(1 - (trail / (trailLength + 1)), trailFade).toDouble();

      // Gambar semua partikel dalam satu trail
      for (int i = 0; i < particleCount; i++) {
        final particleProgress = (trailProgress + (i / particleCount)) % 1.0;

        // Posisi dasar di perimeter
        final perimeterRatio =
            (particleProgress + 0.5) % 1.0; // Offset 0.5 untuk efek menarik
        final perimeterPos = _getPositionOnPerimeter(rect, perimeterRatio);

        // Pulsasi berbasis waktu dan posisi
        final pulseFactor = 1.0 +
            pulseAmplitude *
                math.sin(particleProgress * math.pi * 2 * pulseFrequency +
                    i * (math.pi * 2 / particleCount));

        // Variasi orbit gelombang (bergerak masuk-keluar dari perimeter)
        final orbitWave = orbitVariation *
            math.sin(particleProgress * math.pi * 4 +
                i * (math.pi * 2 / particleCount));

        // Arah dari pusat ke perimeter
        final dirVector = perimeterPos - c;
        final distance = dirVector.distance;
        final direction = distance > 0
            ? Offset(dirVector.dx / distance, dirVector.dy / distance)
            : Offset(0, 0);

        // Posisi akhir partikel (dengan orbit offset + variasi)
        final orbitDistance = (orbitOffset + orbitWave) * radiusMultiplier;
        final pos = perimeterPos + direction * orbitDistance;

        // Radius partikel akhir (dengan pulsasi dan multiplier)
        final radius = baseRadius * pulseFactor * radiusMultiplier;

        // Warna dengan hue tilt dan opacity untuk trail
        final particleOpacity = trailOpacity.clamp(0.0, 1.0);
        Color particleColor = color;

        if (enableHueTilt) {
          final hsl = HSLColor.fromColor(color);

          // Gradasi warna berputar sepanjang perimeter
          final hueShift = perimeterRatio * 360 * hueTiltRange;

          // Brightness bervariasi dengan pulsasi
          final brightnessFactor = (pulseFactor - 1.0) * 0.2 + 1.0;

          particleColor = hsl
              .withHue((hsl.hue + hueShift) % 360)
              .withSaturation(
                  (hsl.saturation * saturationBoost).clamp(0.0, 1.0))
              .withLightness(
                  (hsl.lightness * brightnessBoost * brightnessFactor)
                      .clamp(0.0, 1.0))
              .toColor();
        }

        particleColor = particleColor.withOpacity(particleOpacity);

        // Gambar glow effect (jika diaktifkan)
        if (glowEffect) {
          canvas.drawCircle(
              pos,
              radius * glowSize,
              Paint()
                ..color = particleColor.withOpacity(particleOpacity * 0.3)
                ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.8));
        }

        // Gambar partikel utama
        canvas.drawCircle(pos, radius, Paint()..color = particleColor);
      }
    }
  }

  // Helper untuk mendapatkan posisi pada perimeter
  Offset _getPositionOnPerimeter(Rect rect, double ratio) {
    final totalPerimeter = 2 * (rect.width + rect.height);
    final distanceAlongPerimeter = totalPerimeter * ratio;

    // Sisi atas
    if (distanceAlongPerimeter < rect.width) {
      return Offset(rect.left + distanceAlongPerimeter, rect.top);
    }
    // Sisi kanan
    else if (distanceAlongPerimeter < rect.width + rect.height) {
      return Offset(
          rect.right, rect.top + (distanceAlongPerimeter - rect.width));
    }
    // Sisi bawah
    else if (distanceAlongPerimeter < 2 * rect.width + rect.height) {
      return Offset(
          rect.right - (distanceAlongPerimeter - rect.width - rect.height),
          rect.bottom);
    }
    // Sisi kiri
    else {
      return Offset(
          rect.left,
          rect.bottom -
              (distanceAlongPerimeter - 2 * rect.width - rect.height));
    }
  }

  @override
  bool shouldRepaint(EffectAnimator old) =>
      old is! PerimeterPulsatingOrbitAnimator ||
      old.particleCount != particleCount ||
      old.baseRadius != baseRadius ||
      old.trailLength != trailLength ||
      old.pulseFrequency != pulseFrequency ||
      old.pulseAmplitude != pulseAmplitude ||
      old.orbitOffset != orbitOffset ||
      old.orbitVariation != orbitVariation ||
      old.trailFade != trailFade ||
      old.enableHueTilt != enableHueTilt ||
      old.hueTiltRange != hueTiltRange ||
      old.saturationBoost != saturationBoost ||
      old.brightnessBoost != brightnessBoost ||
      old.glowEffect != glowEffect ||
      old.glowSize != glowSize;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  @override
  double getDefaultRadiusMultiplier() => 1.0;

  @override
  double getOuterPadding() =>
      orbitOffset +
      orbitVariation +
      baseRadius * (1 + pulseAmplitude) * glowSize +
      10;
}

class PerimeterBlossomOrbitAnimator implements EffectAnimator {
  // Parameter utama
  final int particleCount;
  final double baseRadius;
  final double orbitRadius;
  final double blossomSpeed;
  final double orbitSpeed;

  // Parameter detail
  final double particleVariation;
  final double staggerDelay;
  final double endScale;

  // Parameter visual
  final bool enableGlow;
  final double glowIntensity;
  final bool enableHueTilt;
  final double hueTiltRange;
  final double saturationBoost;

  // Fase animasi
  static const double _blossomEnd = 0.4;
  static const double _orbitTransitionEnd = 0.6;

  PerimeterBlossomOrbitAnimator({
    this.particleCount = 20,
    this.baseRadius = 5.0,
    this.orbitRadius = 10.0,
    this.blossomSpeed = 1.0,
    this.orbitSpeed = 0.7,
    this.particleVariation = 0.3,
    this.staggerDelay = 0.02,
    this.endScale = 1.2,
    this.enableGlow = true,
    this.glowIntensity = 0.6,
    this.enableHueTilt = false, // Default diatur ke false
    this.hueTiltRange = 0.8,
    this.saturationBoost = 1.2,
  });

  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final c = center + positionOffset;
    final rect = Rect.fromCenter(
      center: c,
      width: size.width,
      height: size.height,
    );

    final rnd = math.Random(42); // Seed tetap untuk animasi konsisten
    final actualOrbitRadius = orbitRadius * radiusMultiplier;

    // Gambar setiap partikel
    for (int i = 0; i < particleCount; i++) {
      // Delay berbasis indeks untuk efek stagger
      final delay = i * staggerDelay;
      final adjustedProgress =
          (progress * blossomSpeed - delay).clamp(0.0, 1.0);

      // Jika belum waktunya muncul, lewati
      if (adjustedProgress <= 0) continue;

      // Posisi awal di perimeter (untuk fase orbit)
      final perimeterRatio = i / particleCount;
      final initialPeriPos = _getPositionOnPerimeter(rect, perimeterRatio);

      // Arah dari pusat ke perimeter
      final dirVector = initialPeriPos - c;
      final distance = dirVector.distance;
      final direction = distance > 0
          ? Offset(dirVector.dx / distance, dirVector.dy / distance)
          : Offset(0, 0);

      // Variasi acak untuk jalur dan ukuran
      final angleFactor = 0.5 + rnd.nextDouble() * particleVariation;
      final sizeFactor = 0.8 + rnd.nextDouble() * particleVariation * 0.4;

      // Variasi arah berdasarkan indeks dan randomness
      final angle = (i / particleCount) * math.pi * 2 + rnd.nextDouble() * 0.3;
      final varDirection =
          Offset(math.cos(angle) * angleFactor, math.sin(angle) * angleFactor);

      // Posisi akhir partikel berbasis fase animasi
      Offset pos;
      double particleScale;

      if (adjustedProgress < _blossomEnd) {
        // Fase 1: Blossom dari tengah
        final blossomRatio = adjustedProgress / _blossomEnd;
        final easeRatio = _easeOutQuad(blossomRatio);

        // Arah bergerak dari pusat ke perimeter dengan variasi
        final blendedDir = _blendVectors(varDirection, direction, blossomRatio);

        // Jarak dari pusat berbasis pada progress
        final moveDistance = distance * easeRatio * 0.85;

        // Posisi akhir
        pos = c + blendedDir * moveDistance;

        // Skala: tumbuh dari kecil
        particleScale = 0.3 + blossomRatio * 0.7;
      } else if (adjustedProgress < _orbitTransitionEnd) {
        // Fase 2: Transisi ke orbit
        final transitionRatio = (adjustedProgress - _blossomEnd) /
            (_orbitTransitionEnd - _blossomEnd);
        final easeRatio = _easeInOutCubic(transitionRatio);

        // Posisi awal (akhir dari fase blossom)
        final startPos = c + varDirection * (distance * 0.85);

        // Posisi akhir di orbit
        final targetPos = initialPeriPos + direction * actualOrbitRadius;

        // Interpolasi dari posisi blossom ke posisi orbit
        pos = Offset.lerp(startPos, targetPos, easeRatio)!;

        // Skala: konsisten selama transisi
        particleScale = 1.0;
      } else {
        // Fase 3: Orbit di perimeter
        // Progress untuk orbit (kecepatan berbeda dari blossom)
        final orbitProgress = (progress * orbitSpeed) % 1.0;

        // Posisi di sepanjang perimeter dengan orbit
        final orbitRatio = (perimeterRatio + orbitProgress) % 1.0;
        final periPos = _getPositionOnPerimeter(rect, orbitRatio);

        // Arah vektor untuk orbit
        final orbitDir = periPos - c;
        final orbitDist = orbitDir.distance;
        final orbitDirection = orbitDist > 0
            ? Offset(orbitDir.dx / orbitDist, orbitDir.dy / orbitDist)
            : Offset(0, 0);

        // Posisi akhir: perimeter + offset orbit
        pos = periPos + orbitDirection * actualOrbitRadius;

        // Skala: sedikit membesar di orbit
        particleScale = endScale;
      }

      // Ukuran partikel akhir
      final radius = baseRadius * radiusMultiplier * sizeFactor * particleScale;

      // Warna partikel
      Color particleColor = color;

      // Terapkan hueTilt jika diaktifkan
      if (enableHueTilt) {
        final hsl = HSLColor.fromColor(color);
        final hueShift = perimeterRatio * 360 * hueTiltRange;
        particleColor = hsl
            .withHue((hsl.hue + hueShift) % 360)
            .withSaturation((hsl.saturation * saturationBoost).clamp(0.0, 1.0))
            .toColor();
      }

      // Gambar glow jika diaktifkan
      if (enableGlow) {
        final glowRadius = radius * 2.0;
        canvas.drawCircle(
            pos,
            glowRadius,
            Paint()
              ..color = particleColor.withOpacity(glowIntensity)
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.8));
      }

      // Gambar partikel
      canvas.drawCircle(pos, radius, Paint()..color = particleColor);
    }
  }

  // Blend dua vektor dengan rasio
  Offset _blendVectors(Offset v1, Offset v2, double ratio) {
    return Offset(v1.dx * (1 - ratio) + v2.dx * ratio,
        v1.dy * (1 - ratio) + v2.dy * ratio);
  }

  // Fungsi easing
  double _easeOutQuad(double t) {
    return t * (2 - t);
  }

  double _easeInOutCubic(double t) {
    return t < 0.5 ? 4 * t * t * t : 1 - math.pow(-2 * t + 2, 3) / 2;
  }

  // Helper untuk mendapatkan posisi pada perimeter
  Offset _getPositionOnPerimeter(Rect rect, double ratio) {
    final totalPerimeter = 2 * (rect.width + rect.height);
    final distanceAlongPerimeter = totalPerimeter * ratio;

    if (distanceAlongPerimeter < rect.width) {
      return Offset(rect.left + distanceAlongPerimeter, rect.top);
    } else if (distanceAlongPerimeter < rect.width + rect.height) {
      return Offset(
          rect.right, rect.top + (distanceAlongPerimeter - rect.width));
    } else if (distanceAlongPerimeter < 2 * rect.width + rect.height) {
      return Offset(
          rect.right - (distanceAlongPerimeter - rect.width - rect.height),
          rect.bottom);
    } else {
      return Offset(
          rect.left,
          rect.bottom -
              (distanceAlongPerimeter - 2 * rect.width - rect.height));
    }
  }

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  @override
  double getDefaultRadiusMultiplier() => 1.0;

  @override
  double getOuterPadding() => orbitRadius + baseRadius * endScale * 3;

  @override
  bool shouldRepaint(EffectAnimator old) =>
      old is! PerimeterBlossomOrbitAnimator ||
      old.particleCount != particleCount ||
      old.baseRadius != baseRadius ||
      old.orbitRadius != orbitRadius ||
      old.blossomSpeed != blossomSpeed ||
      old.orbitSpeed != orbitSpeed ||
      old.particleVariation != particleVariation ||
      old.staggerDelay != staggerDelay ||
      old.endScale != endScale ||
      old.enableGlow != enableGlow ||
      old.glowIntensity != glowIntensity ||
      old.enableHueTilt != enableHueTilt ||
      old.hueTiltRange != hueTiltRange ||
      old.saturationBoost != saturationBoost;
}

class PerimeterEnergyFieldAnimator implements EffectAnimator {
  final int lineCount;
  final double lineWidth;
  final double fieldDepth;
  final double waveFrequency;
  final double waveAmplitude;
  final double flowSpeed;
  final bool connectCorners;

  // Warna
  final bool enableHueTilt;
  final double hueTiltRange;
  final double saturationBoost;
  final double opacityBase;

  PerimeterEnergyFieldAnimator({
    this.lineCount = 15,
    this.lineWidth = 1.5,
    this.fieldDepth = 30.0,
    this.waveFrequency = 2.5,
    this.waveAmplitude = 8.0,
    this.flowSpeed = 1.0,
    this.connectCorners = true,
    this.enableHueTilt = true,
    this.hueTiltRange = 0.6,
    this.saturationBoost = 1.3,
    this.opacityBase = 0.6,
  });

  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final c = center + positionOffset;
    final rect = Rect.fromCenter(
      center: c,
      width: size.width,
      height: size.height,
    );

    // Gambar field garis energi dari perimeter ke dalam
    for (int i = 0; i < lineCount; i++) {
      final lineRatio = i / (lineCount - 1);

      // Field ini memiliki 2 komponen: garis perimeter dan garis dalam
      // Gambar garis perimeter - mengikuti bentuk perimeter
      final path = Path();
      final segments = 100; // Resolusi untuk menggambar

      for (int j = 0; j <= segments; j++) {
        final segmentRatio = j / segments;

        // Posisi pada perimeter
        final basePos = _getPositionOnPerimeter(rect, segmentRatio);

        // Arah ke dalam (normal)
        final dirVector = c - basePos;
        final distance = dirVector.distance;
        final direction = distance > 0
            ? Offset(dirVector.dx / distance, dirVector.dy / distance)
            : Offset(0, 0);

        // Menambahkan gelombang mengalir
        final wave = math.sin(
                (segmentRatio * waveFrequency + progress * flowSpeed) *
                    math.pi *
                    2) *
            waveAmplitude *
            radiusMultiplier;

        // Depth adjustment based on line ratio
        final depth = fieldDepth * radiusMultiplier * lineRatio;

        // Final position - dari perimeter, ke dalam dengan wave
        final pos = basePos + direction * (depth + wave);

        if (j == 0) {
          path.moveTo(pos.dx, pos.dy);
        } else {
          path.lineTo(pos.dx, pos.dy);
        }
      }

      // Tutup path jika perlu
      if (connectCorners) {
        path.close();
      }

      // Color dengan hueTilt dan opacity
      Color lineColor = color;
      if (enableHueTilt) {
        final hsl = HSLColor.fromColor(color);
        final hueShift = lineRatio * 360 * hueTiltRange;
        lineColor = hsl
            .withHue((hsl.hue + hueShift) % 360)
            .withSaturation((hsl.saturation * saturationBoost).clamp(0.0, 1.0))
            .toColor();
      }

      // Opacity lebih tinggi untuk garis terluar
      final opacity = opacityBase * (1 - lineRatio * 0.5);

      // Gambar garis energi
      canvas.drawPath(
          path,
          Paint()
            ..color = lineColor.withOpacity(opacity)
            ..style = PaintingStyle.stroke
            ..strokeWidth = lineWidth * radiusMultiplier
            ..strokeCap = StrokeCap.round);
    }
  }

  Offset _getPositionOnPerimeter(Rect rect, double ratio) {
    final totalPerimeter = 2 * (rect.width + rect.height);
    final distanceAlongPerimeter = totalPerimeter * ratio;

    if (distanceAlongPerimeter < rect.width) {
      return Offset(rect.left + distanceAlongPerimeter, rect.top);
    } else if (distanceAlongPerimeter < rect.width + rect.height) {
      return Offset(
          rect.right, rect.top + (distanceAlongPerimeter - rect.width));
    } else if (distanceAlongPerimeter < 2 * rect.width + rect.height) {
      return Offset(
          rect.right - (distanceAlongPerimeter - rect.width - rect.height),
          rect.bottom);
    } else {
      return Offset(
          rect.left,
          rect.bottom -
              (distanceAlongPerimeter - 2 * rect.width - rect.height));
    }
  }

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;
  @override
  double getDefaultRadiusMultiplier() => 1.0;
  @override
  double getOuterPadding() => fieldDepth + waveAmplitude + 5;
  @override
  bool shouldRepaint(EffectAnimator old) =>
      old is! PerimeterEnergyFieldAnimator;
}

class PerimeterParticleSwarmAnimator implements EffectAnimator {
  final int particleCount;
  final double particleSize;
  final double swarmWidth;
  final double swarmSpeed;
  final double orbitalSpeed;
  final bool useGlow;

  // Swarm behavior
  final double chaosLevel;
  final double coherenceLevel;
  final int seed;

  // Colors
  final bool enableHueTilt;
  final double hueTiltRange;
  final double saturationBoost;

  PerimeterParticleSwarmAnimator({
    this.particleCount = 80,
    this.particleSize = 3.0,
    this.swarmWidth = 20.0,
    this.swarmSpeed = 1.0,
    this.orbitalSpeed = 0.3,
    this.useGlow = true,
    this.chaosLevel = 0.5,
    this.coherenceLevel = 0.7,
    this.seed = 42,
    this.enableHueTilt = true,
    this.hueTiltRange = 0.7,
    this.saturationBoost = 1.2,
  });

  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final c = center + positionOffset;
    final rect = Rect.fromCenter(
      center: c,
      width: size.width,
      height: size.height,
    );

    final rnd = math.Random(seed);
    final particlePositions = <Offset>[];
    final particleAngles = <double>[];
    final particleSizes = <double>[];
    final particleOffsets = <double>[];

    // Pergerakan orbital sepanjang perimeter
    final orbitProgress = progress * orbitalSpeed;

    // Initialize particles - tetap untuk konsistensi animasi
    if (particlePositions.isEmpty) {
      for (int i = 0; i < particleCount; i++) {
        particleAngles.add(rnd.nextDouble() * math.pi * 2);
        particleSizes.add(0.5 + rnd.nextDouble() * 1.0);
        particleOffsets.add(rnd.nextDouble());
      }
    }

    // Update dan gambar semua partikel
    for (int i = 0; i < particleCount; i++) {
      // Basis pergerakan swarm
      final baseProgress = (progress * swarmSpeed + particleOffsets[i]) % 1.0;

      // Posisi utama pada perimeter dengan orbital motion
      final perimeterRatio = (baseProgress + orbitProgress) % 1.0;
      final perimeterPos = _getPositionOnPerimeter(rect, perimeterRatio);

      // Arah normal
      final dirVector = perimeterPos - c;
      final distance = dirVector.distance;
      final direction = distance > 0
          ? Offset(dirVector.dx / distance, dirVector.dy / distance)
          : Offset(0, 0);

      // Tambahkan chaos/randomness ke posisi partikel
      final angle = particleAngles[i] + baseProgress * math.pi * 2 * chaosLevel;
      final chaosX =
          math.cos(angle) * swarmWidth * radiusMultiplier * chaosLevel;
      final chaosY =
          math.sin(angle) * swarmWidth * radiusMultiplier * chaosLevel;

      // Tambahkan coherence (tetap dekat perimeter)
      final swarmDepth = swarmWidth * radiusMultiplier * coherenceLevel;
      final coherenceOffset = direction * swarmDepth;

      // Posisi akhir
      final pos = perimeterPos + coherenceOffset + Offset(chaosX, chaosY);

      // Warna dengan hueTilt
      Color particleColor = color;
      if (enableHueTilt) {
        final hsl = HSLColor.fromColor(color);
        final hueShift = perimeterRatio * 360 * hueTiltRange;
        particleColor = hsl
            .withHue((hsl.hue + hueShift) % 360)
            .withSaturation((hsl.saturation * saturationBoost).clamp(0.0, 1.0))
            .toColor();
      }

      // Ukuran berbasis pada particleSizes
      final size = particleSize * particleSizes[i] * radiusMultiplier;

      // Gambar glow jika diaktifkan
      if (useGlow) {
        canvas.drawCircle(
            pos,
            size * 2.0,
            Paint()
              ..color = particleColor.withOpacity(0.3)
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, size * 0.8));
      }

      // Gambar partikel
      canvas.drawCircle(pos, size, Paint()..color = particleColor);
    }
  }

  Offset _getPositionOnPerimeter(Rect rect, double ratio) {
    final totalPerimeter = 2 * (rect.width + rect.height);
    final distanceAlongPerimeter = totalPerimeter * ratio;

    if (distanceAlongPerimeter < rect.width) {
      return Offset(rect.left + distanceAlongPerimeter, rect.top);
    } else if (distanceAlongPerimeter < rect.width + rect.height) {
      return Offset(
          rect.right, rect.top + (distanceAlongPerimeter - rect.width));
    } else if (distanceAlongPerimeter < 2 * rect.width + rect.height) {
      return Offset(
          rect.right - (distanceAlongPerimeter - rect.width - rect.height),
          rect.bottom);
    } else {
      return Offset(
          rect.left,
          rect.bottom -
              (distanceAlongPerimeter - 2 * rect.width - rect.height));
    }
  }

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;
  @override
  double getDefaultRadiusMultiplier() => 1.0;
  @override
  double getOuterPadding() => swarmWidth * (1 + chaosLevel) + particleSize * 2;
  @override
  bool shouldRepaint(EffectAnimator old) =>
      old is! PerimeterParticleSwarmAnimator;
}

class PerimeterGradientShimmerAnimator implements EffectAnimator {
  final double shimmerWidth;
  final double shimmerSpeed;
  final double shimmerCount;
  final double shimmerOffset;
  final bool gradientPerimeter;

  // Effects
  final bool useBlur;
  final double blurRadius;

  // Colors
  final bool enableHueTilt;
  final double hueTiltRange;
  final double saturationBoost;
  final double brightnessBoost;

  PerimeterGradientShimmerAnimator({
    this.shimmerWidth = 30.0,
    this.shimmerSpeed = 1.0,
    this.shimmerCount = 2.0,
    this.shimmerOffset = 5.0,
    this.gradientPerimeter = true,
    this.useBlur = true,
    this.blurRadius = 8.0,
    this.enableHueTilt = true,
    this.hueTiltRange = 1.0, // Full rainbow
    this.saturationBoost = 1.4,
    this.brightnessBoost = 1.2,
  });

  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final c = center + positionOffset;
    final rect = Rect.fromCenter(
      center: c,
      width: size.width,
      height: size.height,
    );

    final width = shimmerWidth * radiusMultiplier;
    final offset = shimmerOffset * radiusMultiplier;

    // Buat gradient colors jika hueTilt diaktifkan
    final List<Color> shimmerColors = [];
    final List<double> shimmerStops = [];

    if (enableHueTilt) {
      final steps = 12; // Lebih banyak steps = gradient lebih halus
      for (int i = 0; i <= steps; i++) {
        final ratio = i / steps;
        final hsl = HSLColor.fromColor(color);
        final hueShift = ratio * 360 * hueTiltRange;

        final adjustedColor = hsl
            .withHue((hsl.hue + hueShift) % 360)
            .withSaturation((hsl.saturation * saturationBoost).clamp(0.0, 1.0))
            .withLightness((hsl.lightness * brightnessBoost).clamp(0.0, 1.0))
            .toColor();

        shimmerColors.add(adjustedColor);
        shimmerStops.add(ratio);
      }
    } else {
      // Gradient sederhana jika hueTilt dinonaktifkan
      shimmerColors.add(color);
      shimmerColors.add(color.withOpacity(0.3));
      shimmerColors.add(color);

      shimmerStops.add(0.0);
      shimmerStops.add(0.5);
      shimmerStops.add(1.0);
    }

    // Gambar shimmer untuk setiap shimmerCount
    for (int i = 0; i < shimmerCount; i++) {
      final shimmerProgress =
          ((progress * shimmerSpeed) + (i / shimmerCount)) % 1.0;

      // Create path untuk shimmer
      final path = Path();
      final segments = 100; // Resolution untuk menggambar

      for (int j = 0; j <= segments; j++) {
        final segmentRatio = j / segments;

        // Posisi basis pada perimeter
        final basePos = _getPositionOnPerimeter(rect, segmentRatio);

        // Arah normal ke dalam
        final dirVector = c - basePos;
        final distance = dirVector.distance;
        final direction = distance > 0
            ? Offset(dirVector.dx / distance, dirVector.dy / distance)
            : Offset(0, 0);

        // Posisi dengan offset ke dalam
        final pos = basePos + direction * offset;

        if (j == 0) {
          path.moveTo(pos.dx, pos.dy);
        } else {
          path.lineTo(pos.dx, pos.dy);
        }
      }

      // Close path
      path.close();

      // Buat shader untuk shimmer
      Paint shimmerPaint;

      if (gradientPerimeter) {
        // Sweep gradient mengikuti perimeter
        final Gradient gradient = SweepGradient(
          center: Alignment.center,
          colors: shimmerColors,
          stops: shimmerStops,
          startAngle: 0,
          endAngle: math.pi * 2,
          transform: GradientRotation(shimmerProgress * math.pi * 2),
        );

        shimmerPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..shader = gradient.createShader(rect);
      } else {
        // Simple color
        shimmerPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..color = color;
      }

      // Tambahkan blur jika diaktifkan
      if (useBlur) {
        shimmerPaint.maskFilter =
            MaskFilter.blur(BlurStyle.normal, blurRadius * radiusMultiplier);
      }

      // Gambar shimmer
      canvas.drawPath(path, shimmerPaint);
    }
  }

  Offset _getPositionOnPerimeter(Rect rect, double ratio) {
    final totalPerimeter = 2 * (rect.width + rect.height);
    final distanceAlongPerimeter = totalPerimeter * ratio;

    if (distanceAlongPerimeter < rect.width) {
      return Offset(rect.left + distanceAlongPerimeter, rect.top);
    } else if (distanceAlongPerimeter < rect.width + rect.height) {
      return Offset(
          rect.right, rect.top + (distanceAlongPerimeter - rect.width));
    } else if (distanceAlongPerimeter < 2 * rect.width + rect.height) {
      return Offset(
          rect.right - (distanceAlongPerimeter - rect.width - rect.height),
          rect.bottom);
    } else {
      return Offset(
          rect.left,
          rect.bottom -
              (distanceAlongPerimeter - 2 * rect.width - rect.height));
    }
  }

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;
  @override
  double getDefaultRadiusMultiplier() => 1.0;
  @override
  double getOuterPadding() => shimmerOffset + shimmerWidth + blurRadius;
  @override
  bool shouldRepaint(EffectAnimator old) =>
      old is! PerimeterGradientShimmerAnimator;
}

class PerimeterSparkleTrailAnimator implements EffectAnimator {
  final int particleCount;
  final double baseRadius;
  final double sparkleFrequency;
  final double sparkleSize;
  final double trailLength;
  final double orbitDistance;
  final bool randomSparkle;

  // Warna
  final bool enableHueTilt;
  final double hueTiltRange;
  final double saturationBoost;

  PerimeterSparkleTrailAnimator({
    this.particleCount = 12,
    this.baseRadius = 3.0,
    this.sparkleFrequency = 3.0,
    this.sparkleSize = 1.8,
    this.trailLength = 8.0,
    this.orbitDistance = 8.0,
    this.randomSparkle = true,
    this.enableHueTilt = true,
    this.hueTiltRange = 0.8,
    this.saturationBoost = 1.3,
  });

  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final c = center + positionOffset;
    final rect = Rect.fromCenter(
      center: c,
      width: size.width,
      height: size.height,
    );
    final rnd = math.Random(42);

    for (int i = 0; i < particleCount; i++) {
      final particleRatio = i / particleCount;
      final particleProgress = (progress + particleRatio) % 1.0;

      // Posisi pada perimeter
      final perimeterPos = _getPositionOnPerimeter(rect, particleRatio);

      // Arah normal
      final dirVector = perimeterPos - c;
      final distance = dirVector.distance;
      final direction = distance > 0
          ? Offset(dirVector.dx / distance, dirVector.dy / distance)
          : Offset(0, 0);

      // Posisi akhir
      final pos = perimeterPos + direction * (orbitDistance * radiusMultiplier);

      // Warna untuk partikel utama
      Color particleColor = color;
      if (enableHueTilt) {
        final hsl = HSLColor.fromColor(color);
        final hueShift = particleRatio * 360 * hueTiltRange;
        particleColor = hsl
            .withHue((hsl.hue + hueShift) % 360)
            .withSaturation((hsl.saturation * saturationBoost).clamp(0.0, 1.0))
            .toColor();
      }

      // Gambar partikel utama
      final baseRad = baseRadius * radiusMultiplier;
      canvas.drawCircle(pos, baseRad, Paint()..color = particleColor);

      // Gambar trail dengan sparkles
      for (int t = 1; t <= trailLength; t++) {
        final trailRatio = t / trailLength;
        final trailPos = _getPositionOnPerimeter(
            rect, (particleRatio - (trailRatio * 0.2)) % 1.0);

        final trailDir = trailPos - c;
        final trailDist = trailDir.distance;
        final trailDirection = trailDist > 0
            ? Offset(trailDir.dx / trailDist, trailDir.dy / trailDist)
            : Offset(0, 0);

        final finalTrailPos =
            trailPos + trailDirection * (orbitDistance * radiusMultiplier);

        // Opacity menurun untuk trail
        final opacity = (1 - trailRatio) * 0.7;

        // Ukuran sparkle dengan variasi
        final shouldSparkle = randomSparkle
            ? rnd.nextDouble() < (1 - trailRatio) * 0.7
            : math.sin(trailRatio * sparkleFrequency * math.pi) > 0.7;

        if (shouldSparkle) {
          final sparkleRad = baseRad * sparkleSize * (1 - trailRatio * 0.6);
          final sparkleColor = particleColor.withOpacity(opacity * 1.5);

          // Gambar sparkle dengan glow
          canvas.drawCircle(
              finalTrailPos,
              sparkleRad * 1.6,
              Paint()
                ..color = sparkleColor.withOpacity(opacity * 0.3)
                ..maskFilter =
                    MaskFilter.blur(BlurStyle.normal, sparkleRad * 0.6));

          canvas.drawCircle(
              finalTrailPos, sparkleRad, Paint()..color = sparkleColor);
        } else {
          // Gambar titik trail normal
          canvas.drawCircle(finalTrailPos, baseRad * (1 - trailRatio * 0.8),
              Paint()..color = particleColor.withOpacity(opacity));
        }
      }
    }
  }

  Offset _getPositionOnPerimeter(Rect rect, double ratio) {
    final totalPerimeter = 2 * (rect.width + rect.height);
    final distanceAlongPerimeter = totalPerimeter * ratio;

    if (distanceAlongPerimeter < rect.width) {
      return Offset(rect.left + distanceAlongPerimeter, rect.top);
    } else if (distanceAlongPerimeter < rect.width + rect.height) {
      return Offset(
          rect.right, rect.top + (distanceAlongPerimeter - rect.width));
    } else if (distanceAlongPerimeter < 2 * rect.width + rect.height) {
      return Offset(
          rect.right - (distanceAlongPerimeter - rect.width - rect.height),
          rect.bottom);
    } else {
      return Offset(
          rect.left,
          rect.bottom -
              (distanceAlongPerimeter - 2 * rect.width - rect.height));
    }
  }

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;
  @override
  double getDefaultRadiusMultiplier() => 1.0;
  @override
  double getOuterPadding() => orbitDistance + baseRadius * sparkleSize * 3;
  @override
  bool shouldRepaint(EffectAnimator old) =>
      old is! PerimeterSparkleTrailAnimator;
}

class PerimeterRainbowRibbonAnimator implements EffectAnimator {
  final double ribbonWidth;
  final double ribbonAmplitude;
  final double ribbonFrequency;
  final double ribbonOffset;
  final int segments;
  final double glowIntensity;

  // Colors
  final bool enableHueTilt;
  final double hueTiltRange;
  final double hueCycles;
  final double saturationBoost;

  PerimeterRainbowRibbonAnimator({
    this.ribbonWidth = 6.0,
    this.ribbonAmplitude = 4.0,
    this.ribbonFrequency = 3.0,
    this.ribbonOffset = 8.0,
    this.segments = 100,
    this.glowIntensity = 0.4,
    this.enableHueTilt = true,
    this.hueTiltRange = 1.0,
    this.hueCycles = 2.0,
    this.saturationBoost = 1.2,
  });

  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final c = center + positionOffset;
    final rect = Rect.fromCenter(
      center: c,
      width: size.width,
      height: size.height,
    );

    final path = Path();
    final width = ribbonWidth * radiusMultiplier;

    // Gambar ribbon sepanjang perimeter
    for (int i = 0; i <= segments; i++) {
      final ratio = i / segments;
      final perimeterPos = _getPositionOnPerimeter(rect, ratio);

      // Arah normal dari pusat ke perimeter
      final dirVector = perimeterPos - c;
      final distance = dirVector.distance;
      final direction = distance > 0
          ? Offset(dirVector.dx / distance, dirVector.dy / distance)
          : Offset(0, 0);

      // Buat efek bergelombang
      final wave =
          math.sin((ratio * ribbonFrequency + progress) * math.pi * 2) *
              ribbonAmplitude *
              radiusMultiplier;

      final offset = (ribbonOffset + wave) * radiusMultiplier;
      final pos = perimeterPos + direction * offset;

      if (i == 0) {
        path.moveTo(pos.dx, pos.dy);
      } else {
        path.lineTo(pos.dx, pos.dy);
      }
    }

    // Gambar ribbon dengan glow
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, width * 0.5);

    // Jika enableHueTilt, gunakan gradient untuk ribbon
    if (enableHueTilt) {
      final gradientColors = <Color>[];
      final gradientStops = <double>[];

      // Buat gradient colors
      for (int i = 0; i <= segments; i++) {
        final ratio = i / segments;
        final hsl = HSLColor.fromColor(color);
        final hueShift = (ratio * hueCycles) * 360 * hueTiltRange;

        final adjustedColor = hsl
            .withHue((hsl.hue + hueShift) % 360)
            .withSaturation((hsl.saturation * saturationBoost).clamp(0.0, 1.0))
            .toColor();

        gradientColors.add(adjustedColor);
        gradientStops.add(ratio);
      }

      // Buat shader untuk gradient sepanjang path
      final shader = SweepGradient(
        center: Alignment.center,
        colors: gradientColors,
        stops: gradientStops,
        startAngle: 0,
        endAngle: math.pi * 2,
        transform: GradientRotation(progress * math.pi * 2),
      ).createShader(rect);

      paint.shader = shader;

      // Gambar glow effect
      if (glowIntensity > 0) {
        final glowPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = width * 2
          ..strokeCap = StrokeCap.round
          ..shader = shader
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, width * 1.5);

        canvas.drawPath(
            path, glowPaint..color = color.withOpacity(glowIntensity));
      }

      // Gambar ribbon utama
      canvas.drawPath(path, paint);
    } else {
      // Non-gradient version
      canvas.drawPath(path, paint..color = color);
    }
  }

  Offset _getPositionOnPerimeter(Rect rect, double ratio) {
    final totalPerimeter = 2 * (rect.width + rect.height);
    final distanceAlongPerimeter = totalPerimeter * ratio;

    if (distanceAlongPerimeter < rect.width) {
      return Offset(rect.left + distanceAlongPerimeter, rect.top);
    } else if (distanceAlongPerimeter < rect.width + rect.height) {
      return Offset(
          rect.right, rect.top + (distanceAlongPerimeter - rect.width));
    } else if (distanceAlongPerimeter < 2 * rect.width + rect.height) {
      return Offset(
          rect.right - (distanceAlongPerimeter - rect.width - rect.height),
          rect.bottom);
    } else {
      return Offset(
          rect.left,
          rect.bottom -
              (distanceAlongPerimeter - 2 * rect.width - rect.height));
    }
  }

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;
  @override
  double getDefaultRadiusMultiplier() => 1.0;
  @override
  double getOuterPadding() => ribbonOffset + ribbonAmplitude + ribbonWidth * 3;
  @override
  bool shouldRepaint(EffectAnimator old) =>
      old is! PerimeterRainbowRibbonAnimator;
}

class PerimeterNeonPulseAnimator implements EffectAnimator {
  final double pulseWidth;
  final double pulseCount;
  final double pulseSpeed;
  final double pulseGap;
  final double orbitDistance;
  final double glowIntensity;

  // Colors
  final bool enableHueTilt;
  final double hueTiltRange;
  final double saturationBoost;
  final double brightnessBoost;

  PerimeterNeonPulseAnimator({
    this.pulseWidth = 20.0,
    this.pulseCount = 3.0,
    this.pulseSpeed = 1.0,
    this.pulseGap = 0.2,
    this.orbitDistance = 8.0,
    this.glowIntensity = 0.6,
    this.enableHueTilt = true,
    this.hueTiltRange = 0.5,
    this.saturationBoost = 1.4,
    this.brightnessBoost = 1.2,
  });

  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final c = center + positionOffset;
    final rect = Rect.fromCenter(
      center: c,
      width: size.width,
      height: size.height,
    );

    final totalPerimeter = 2 * (rect.width + rect.height);
    final segments = 100; // Resolution for drawing

    // Gambar pulse neon lights di sepanjang perimeter
    for (int pulse = 0; pulse < pulseCount; pulse++) {
      final pulseOffset = pulse / pulseCount;
      final pulseProgress = (progress * pulseSpeed + pulseOffset) % 1.0;

      final path = Path();
      bool firstPoint = true;

      for (int i = 0; i <= segments; i++) {
        final segmentRatio = i / segments;

        // Hitung jarak dari pusat pulse (0 to 1, dimana 0 = pusat pulse)
        final distFromPulse = (segmentRatio - pulseProgress).abs();
        final wrappedDist = math.min(distFromPulse, 1 - distFromPulse);

        // Skip if outside pulse width
        if (wrappedDist > pulseGap) continue;

        // Get point on perimeter
        final perimeterPos = _getPositionOnPerimeter(rect, segmentRatio);

        // Intensity based on distance from pulse center
        final intensity = 1.0 - (wrappedDist / pulseGap);

        // Direction from center to perimeter
        final dirVector = perimeterPos - c;
        final distance = dirVector.distance;
        final direction = distance > 0
            ? Offset(dirVector.dx / distance, dirVector.dy / distance)
            : Offset(0, 0);

        // Final position with orbit distance
        final orbitDist = orbitDistance * radiusMultiplier;
        final pos = perimeterPos + direction * orbitDist;

        // Build path
        if (firstPoint) {
          path.moveTo(pos.dx, pos.dy);
          firstPoint = false;
        } else {
          path.lineTo(pos.dx, pos.dy);
        }

        // Compute color with hueTilt
        Color pulseColor = color;
        if (enableHueTilt) {
          final hsl = HSLColor.fromColor(color);
          final hueShift = segmentRatio * 360 * hueTiltRange;
          pulseColor = hsl
              .withHue((hsl.hue + hueShift) % 360)
              .withSaturation(
                  (hsl.saturation * saturationBoost).clamp(0.0, 1.0))
              .withLightness((hsl.lightness * brightnessBoost).clamp(0.0, 1.0))
              .toColor();
        }

        // Draw glow point
        final glowRadius = pulseWidth * radiusMultiplier * intensity;
        final glowOpacity = intensity * glowIntensity;

        canvas.drawCircle(
            pos,
            glowRadius,
            Paint()
              ..color = pulseColor.withOpacity(glowOpacity)
              ..maskFilter =
                  MaskFilter.blur(BlurStyle.normal, glowRadius * 0.5));

        // Draw core point
        canvas.drawCircle(pos, glowRadius * 0.3,
            Paint()..color = pulseColor.withOpacity(intensity));
      }
    }
  }

  Offset _getPositionOnPerimeter(Rect rect, double ratio) {
    final totalPerimeter = 2 * (rect.width + rect.height);
    final distanceAlongPerimeter = totalPerimeter * ratio;

    if (distanceAlongPerimeter < rect.width) {
      return Offset(rect.left + distanceAlongPerimeter, rect.top);
    } else if (distanceAlongPerimeter < rect.width + rect.height) {
      return Offset(
          rect.right, rect.top + (distanceAlongPerimeter - rect.width));
    } else if (distanceAlongPerimeter < 2 * rect.width + rect.height) {
      return Offset(
          rect.right - (distanceAlongPerimeter - rect.width - rect.height),
          rect.bottom);
    } else {
      return Offset(
          rect.left,
          rect.bottom -
              (distanceAlongPerimeter - 2 * rect.width - rect.height));
    }
  }

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;
  @override
  double getDefaultRadiusMultiplier() => 1.0;
  @override
  double getOuterPadding() => orbitDistance + pulseWidth * 2;
  @override
  bool shouldRepaint(EffectAnimator old) => old is! PerimeterNeonPulseAnimator;
}

class PerimeterMultiRingOrbitAnimator implements EffectAnimator {
  // ─── konfigurasi partikel ───
  final int particlesPerRing; // banyak dot tiap ring
  final int ringCount; // berapa ring (1–3 disarankan)
  final double circleRadius; // radius dot
  final double ringGap; // jarak antar ring
  final double orbitMargin; // jarak ring terluar dari perimeter
  final double rotations; // putaran selama fase orbit
  final double fadeExtra; // sedikit maju saat fade
  final double glowSigma;

  // ─── HSV shift ───
  final bool enableHueTilt;
  final double hueTiltRange;
  final double saturationBoost;

  PerimeterMultiRingOrbitAnimator({
    this.particlesPerRing = 12,
    this.ringCount = 1,
    this.circleRadius = 12,
    this.ringGap = 10,
    this.orbitMargin = 12,
    this.rotations = 1.2,
    this.fadeExtra = 14,
    this.glowSigma = 4,
    //
    this.enableHueTilt = false,
    this.hueTiltRange = .35,
    this.saturationBoost = 1.1,
  }) : assert(ringCount >= 1 && ringCount <= 3);

  // fase global: launch 0‑.2 → orbit .2‑.8 → return .8‑1
  static const double _launchEnd = .20;
  static const double _orbitEnd = .80;

  @override
  void paint(Canvas cv, Size size, double p, Offset center, Color baseColor,
      {double radiusMultiplier = 1, Offset positionOffset = Offset.zero}) {
    final c = center + positionOffset;

    // Buat rect untuk perimeter
    final rect = Rect.fromCenter(
      center: c,
      width: size.width,
      height: size.height,
    );

    // Jarak orbit dari perimeter untuk setiap ring
    final List<double> ringDistances = List.generate(
      ringCount,
      (i) => orbitMargin * radiusMultiplier + (i * ringGap * radiusMultiplier),
    );

    for (int ringIdx = 0; ringIdx < ringCount; ringIdx++) {
      final orbDist = ringDistances[ringIdx];

      for (int j = 0; j < particlesPerRing; j++) {
        // Posisi di perimeter dengan offset antar ring
        final perimeterRatio =
            (j + (ringIdx.isOdd ? 0.5 : 0)) / particlesPerRing;

        // progress global
        final t = p.clamp(0.0, 1.0);

        Offset pos;
        if (t < _launchEnd) {
          // Fase awal - partikel meluncur dari perimeter ke orbit
          final launchRatio = _easeOutBack(t / _launchEnd);
          final startPos = _getPositionOnPerimeter(rect, perimeterRatio);

          final dirVector = startPos - c;
          final distance = dirVector.distance;
          final direction = distance > 0
              ? Offset(dirVector.dx / distance, dirVector.dy / distance)
              : Offset(0, 0);

          pos = startPos + direction * orbDist * launchRatio;
        } else if (t < _orbitEnd) {
          // Fase orbit - bergerak sepanjang perimeter
          final orbitT = (t - _launchEnd) / (_orbitEnd - _launchEnd);
          final orbitPos = perimeterRatio + rotations * orbitT;
          final orbitPerimeterPos =
              _getPositionOnPerimeter(rect, orbitPos % 1.0);

          final dirVector = orbitPerimeterPos - c;
          final distance = dirVector.distance;
          final direction = distance > 0
              ? Offset(dirVector.dx / distance, dirVector.dy / distance)
              : Offset(0, 0);

          pos = orbitPerimeterPos + direction * orbDist;
        } else {
          // Fase akhir - kembali ke perimeter
          final returnT = (t - _orbitEnd) / (1 - _orbitEnd);
          final returnRatio = _easeIn(returnT);
          final endPer = (perimeterRatio + rotations) % 1.0;
          final endPerimeterPos = _getPositionOnPerimeter(rect, endPer);

          final dirVector = endPerimeterPos - c;
          final distance = dirVector.distance;
          final direction = distance > 0
              ? Offset(dirVector.dx / distance, dirVector.dy / distance)
              : Offset(0, 0);

          // Kembali ke perimeter dengan jarak fadeExtra
          final returnDistance = orbDist - returnRatio * (orbDist - fadeExtra);
          pos = endPerimeterPos + direction * returnDistance;
        }

        // ── opacity & skala ──
        final opacity = t < .9 ? 1.0 : 1 - (t - .9) / .1;
        final scale = opacity;

        // ── warna (HSV shift) ──
        Color col = baseColor;
        if (enableHueTilt) {
          final hsl = HSLColor.fromColor(baseColor);
          final shift = perimeterRatio * 360 * hueTiltRange;
          col = hsl
              .withHue((hsl.hue + shift) % 360)
              .withSaturation((hsl.saturation * saturationBoost).clamp(0, 1))
              .toColor();
        }
        col = col.withOpacity(opacity);

        final drawR = circleRadius * radiusMultiplier * scale;

        // glow
        cv.drawCircle(
            pos,
            drawR * 1.6,
            Paint()
              ..color = col.withOpacity(.25)
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowSigma));

        // lingkaran utama
        cv.drawCircle(pos, drawR, Paint()..color = col);
      }
    }
  }

  // Helper untuk mendapatkan posisi pada perimeter
  Offset _getPositionOnPerimeter(Rect rect, double ratio) {
    final totalPerimeter = 2 * (rect.width + rect.height);
    final distanceAlongPerimeter = totalPerimeter * ratio;

    // Sisi atas
    if (distanceAlongPerimeter < rect.width) {
      return Offset(rect.left + distanceAlongPerimeter, rect.top);
    }
    // Sisi kanan
    else if (distanceAlongPerimeter < rect.width + rect.height) {
      return Offset(
          rect.right, rect.top + (distanceAlongPerimeter - rect.width));
    }
    // Sisi bawah
    else if (distanceAlongPerimeter < 2 * rect.width + rect.height) {
      return Offset(
          rect.right - (distanceAlongPerimeter - rect.width - rect.height),
          rect.bottom);
    }
    // Sisi kiri
    else {
      return Offset(
          rect.left,
          rect.bottom -
              (distanceAlongPerimeter - 2 * rect.width - rect.height));
    }
  }

  // ─── easing helpers ───
  double _easeOutBack(double t) {
    const c1 = 1.70158, c3 = c1 + 1;
    return 1 + c3 * math.pow(t - 1, 3) + c1 * math.pow(t - 1, 2);
  }

  double _easeIn(double t) => t * t * t;

  // ─── overrides ───
  @override
  bool shouldRepaint(EffectAnimator old) =>
      old is! PerimeterMultiRingOrbitAnimator ||
      old.particlesPerRing != particlesPerRing ||
      old.ringCount != ringCount ||
      old.circleRadius != circleRadius ||
      old.ringGap != ringGap ||
      old.orbitMargin != orbitMargin ||
      old.rotations != rotations ||
      old.fadeExtra != fadeExtra ||
      old.glowSigma != glowSigma ||
      old.enableHueTilt != enableHueTilt ||
      old.hueTiltRange != hueTiltRange ||
      old.saturationBoost != saturationBoost;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;
  @override
  double getDefaultRadiusMultiplier() => 1.0;
  @override
  double getOuterPadding() =>
      orbitMargin + ringGap * (ringCount - 1) + circleRadius;
}

class PerimeterSequentialRingOrbitAnimator implements EffectAnimator {
  // ─── konfigurasi utama ───
  final int particlesPerRing;
  final int ringCount; // 1–3
  final double circleRadius;
  final double ringGap; // jarak antar ring
  final double orbitMargin; // ring terluar – perimeter
  final double rotations; // putaran fase orbit
  final double glowSigma;

  // ─── HSV shift ───
  final bool enableHueTilt;
  final double hueTiltRange;
  final double saturationBoost;

  PerimeterSequentialRingOrbitAnimator({
    this.particlesPerRing = 12,
    this.ringCount = 1,
    this.circleRadius = 6,
    this.ringGap = 10,
    this.orbitMargin = 14,
    this.rotations = 1.2,
    this.glowSigma = 4,
    //
    this.enableHueTilt = false,
    this.hueTiltRange = .35,
    this.saturationBoost = 1.1,
  }) : assert(ringCount >= 1 && ringCount <= 3);

  // proporsi progress
  static const double _spawnEnd = .35;
  static const double _orbitEnd = .75;

  @override
  void paint(Canvas cv, Size size, double p, Offset center, Color baseColor,
      {double radiusMultiplier = 1, Offset positionOffset = Offset.zero}) {
    final c = center + positionOffset;

    // Buat rect untuk perimeter
    final rect = Rect.fromCenter(
      center: c,
      width: size.width,
      height: size.height,
    );

    // Jarak orbit dari perimeter untuk setiap ring
    final List<double> ringDistances = List.generate(
      ringCount,
      (i) => orbitMargin * radiusMultiplier + (i * ringGap * radiusMultiplier),
    );

    // durasi spawn per dot (agar dot‑N selesai tepat di _spawnEnd)
    final spawnSlice = _spawnEnd / particlesPerRing;

    for (int ringIdx = 0; ringIdx < ringCount; ringIdx++) {
      final orbDist = ringDistances[ringIdx];

      for (int j = 0; j < particlesPerRing; j++) {
        final perimeterRatio =
            (j + (ringIdx.isOdd ? 0.5 : 0)) / particlesPerRing;
        final startPos = _getPositionOnPerimeter(rect, perimeterRatio);

        final dirVector = startPos - c;
        final distance = dirVector.distance;
        final dirToOut = distance > 0
            ? Offset(dirVector.dx / distance, dirVector.dy / distance)
            : Offset(0, 0);

        // ─── progress lokal (0‑1) per dot ───
        final double delay = j * spawnSlice;
        double t;
        if (p < delay) continue; // belum lahir
        if (p < _spawnEnd) {
          t = (p - delay) / spawnSlice; // 0‑1 dalam fase spawn
          if (t > 1) t = 1;
        } else {
          // semua dot sudah muncul
          t = 1 + (p - _spawnEnd) / (1 - _spawnEnd); // 1‑2 rentang orbit‑return
        }

        // ─── posisi ───
        Offset pos;
        if (t <= 1) {
          // fase Spawn (per‑dot) - dari perimeter ke orbit
          final moveDistance = _easeOutBack(t) * orbDist;
          pos = startPos + dirToOut * moveDistance;
        } else if (p < _orbitEnd) {
          // fase Orbit - bergerak sepanjang perimeter
          final orbitT = (p - _spawnEnd) / (_orbitEnd - _spawnEnd);
          final orbitPos = perimeterRatio + rotations * orbitT;
          final orbitPerimeterPos =
              _getPositionOnPerimeter(rect, orbitPos % 1.0);

          final orbDirVector = orbitPerimeterPos - c;
          final orbDistance = orbDirVector.distance;
          final orbDirection = orbDistance > 0
              ? Offset(
                  orbDirVector.dx / orbDistance, orbDirVector.dy / orbDistance)
              : Offset(0, 0);

          pos = orbitPerimeterPos + orbDirection * orbDist;
        } else {
          // fase Return - kembali ke perimeter
          final returnT = (p - _orbitEnd) / (1 - _orbitEnd);
          final returnRatio = _easeIn(returnT);
          final endPerimeterPos = _getPositionOnPerimeter(rect, perimeterRatio);

          final endDirVector = endPerimeterPos - c;
          final endDistance = endDirVector.distance;
          final endDirection = endDistance > 0
              ? Offset(
                  endDirVector.dx / endDistance, endDirVector.dy / endDistance)
              : Offset(0, 0);

          // Kembali ke perimeter
          final returnDistance = orbDist * (1 - returnRatio);
          pos = endPerimeterPos + endDirection * returnDistance;
        }

        // ─── opacity & skala ───
        final globalFade = p < .92 ? 1.0 : 1 - (p - .92) / .08;
        final scale = globalFade;

        // ─── warna (HSV) ───
        Color col = baseColor;
        if (enableHueTilt) {
          final hsl = HSLColor.fromColor(baseColor);
          final shift = perimeterRatio * 360 * hueTiltRange;
          col = hsl
              .withHue((hsl.hue + shift) % 360)
              .withSaturation((hsl.saturation * saturationBoost).clamp(0, 1))
              .toColor();
        }
        col = col.withOpacity(globalFade);

        final drawR = circleRadius * radiusMultiplier * scale;

        // glow
        cv.drawCircle(
            pos,
            drawR * 1.6,
            Paint()
              ..color = col.withOpacity(.25)
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowSigma));

        // dot utama
        cv.drawCircle(pos, drawR, Paint()..color = col);
      }
    }
  }

  // Helper untuk mendapatkan posisi pada perimeter
  Offset _getPositionOnPerimeter(Rect rect, double ratio) {
    final totalPerimeter = 2 * (rect.width + rect.height);
    final distanceAlongPerimeter = totalPerimeter * ratio;

    // Sisi atas
    if (distanceAlongPerimeter < rect.width) {
      return Offset(rect.left + distanceAlongPerimeter, rect.top);
    }
    // Sisi kanan
    else if (distanceAlongPerimeter < rect.width + rect.height) {
      return Offset(
          rect.right, rect.top + (distanceAlongPerimeter - rect.width));
    }
    // Sisi bawah
    else if (distanceAlongPerimeter < 2 * rect.width + rect.height) {
      return Offset(
          rect.right - (distanceAlongPerimeter - rect.width - rect.height),
          rect.bottom);
    }
    // Sisi kiri
    else {
      return Offset(
          rect.left,
          rect.bottom -
              (distanceAlongPerimeter - 2 * rect.width - rect.height));
    }
  }

  // ─── easing helpers ───
  double _easeOutBack(double t) {
    const c1 = 1.70158, c3 = c1 + 1;
    return 1 + c3 * math.pow(t - 1, 3) + c1 * math.pow(t - 1, 2);
  }

  double _easeIn(double t) => t * t * t;

  // ─── overrides ───
  @override
  bool shouldRepaint(covariant EffectAnimator old) =>
      old is! PerimeterSequentialRingOrbitAnimator ||
      old.particlesPerRing != particlesPerRing ||
      old.ringCount != ringCount ||
      old.circleRadius != circleRadius ||
      old.ringGap != ringGap ||
      old.orbitMargin != orbitMargin ||
      old.rotations != rotations ||
      old.glowSigma != glowSigma ||
      old.enableHueTilt != enableHueTilt ||
      old.hueTiltRange != hueTiltRange ||
      old.saturationBoost != saturationBoost;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;
  @override
  double getDefaultRadiusMultiplier() => 1;
  @override
  double getOuterPadding() =>
      orbitMargin + ringGap * (ringCount - 1) + circleRadius;
}

class PerimeterOrbitBloomAnimatorV2 implements EffectAnimator {
  // ───── tampilan ─────
  final int particleCount; // jumlah partikel (12 default)
  final double circleRadius; // radius titik
  final double tailFactor; // tailLen = circleRadius * tailFactor
  final double orbitMargin; // px di luar perimeter
  final double bloomExtra; // penambahan radius di fase bloom
  final bool distributeEvenly;

  // ───── warna ─────
  final bool enableHueTilt;
  final double hueTiltRange;
  final double saturationBoost;

  PerimeterOrbitBloomAnimatorV2({
    this.particleCount = 16,
    this.circleRadius = 6,
    this.tailFactor = 3,
    this.orbitMargin = 10,
    this.bloomExtra = 30,
    this.distributeEvenly = true,
    //
    this.enableHueTilt = false,
    this.hueTiltRange = .28,
    this.saturationBoost = 1.1,
  });

  // batas fase
  static const double _launchEnd = .18;
  static const double _orbitEnd = .70;

  // ───── paint ─────
  @override
  void paint(Canvas cv, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final c = center + positionOffset;
    final rnd = math.Random(42);

    // Buat rect untuk perimeter
    final rect = Rect.fromCenter(
      center: c,
      width: size.width,
      height: size.height,
    );

    // Jarak orbit = margin di luar perimeter
    final double baseOrbit = orbitMargin * radiusMultiplier;

    for (int i = 0; i < particleCount; i++) {
      // sedikit stagger supaya terlihat dinamis
      final delay = i * 0.015;
      final rawT = progress - delay;
      if (rawT <= 0) continue;

      // normalisasi agar selesai di progress==1
      final t = (rawT / (1 - delay)).clamp(0.0, 1.0);

      // Posisi awal di perimeter
      final perimeterRatio =
          distributeEvenly ? i / particleCount : rnd.nextDouble();
      final originalPos = _getPositionOnPerimeter(rect, perimeterRatio);

      // Vektor dari pusat ke posisi perimeter
      final dirVector = originalPos - c;
      final distance = dirVector.distance;
      final direction = distance > 0
          ? Offset(dirVector.dx / distance, dirVector.dy / distance)
          : Offset(0, 0);

      // ── radius & sudut dari perimeter ──
      double moveDistance;
      if (t < _launchEnd) {
        final tt = t / _launchEnd; // 0‑1
        moveDistance = _easeOutBack(tt) * baseOrbit; // meluncur ke orbit
      } else if (t < _orbitEnd) {
        // Fase orbit - bergerak sekeliling perimeter
        final tt = (t - _launchEnd) / (_orbitEnd - _launchEnd);
        moveDistance = baseOrbit;

        // Bergerak sekeliling perimeter
        final orbitAngle = perimeterRatio * 2 * math.pi + 2 * math.pi * tt;
        final orbitPos =
            _getPositionOnPerimeter(rect, orbitAngle / (2 * math.pi));

        // Override pos untuk fase orbit
        final pos = orbitPos + direction * moveDistance;

        // ── tail ── (mengarah ke perimeter)
        final tailLen = circleRadius * tailFactor * radiusMultiplier;
        final tailStart = pos - direction * tailLen;

        // ── skala & opasitas ──
        final opacity = t < .9 ? 1.0 : 1 - (t - .9) / .1;
        final scale = opacity; // titik mengecil seiring pudar

        // ── warna ──
        Color col = color;
        if (enableHueTilt) {
          final hsl = HSLColor.fromColor(color);
          final shift = (perimeterRatio) * 360 * hueTiltRange;
          col = hsl
              .withHue((hsl.hue + shift) % 360)
              .withSaturation((hsl.saturation * saturationBoost).clamp(0, 1))
              .toColor();
        }
        col = col.withOpacity(opacity);

        // ── gambar ──
        final rad = circleRadius * radiusMultiplier * scale;
        cv.drawCircle(pos, rad, Paint()..color = col);

        cv.drawLine(
            tailStart,
            pos,
            Paint()
              ..color = col
              ..strokeWidth = rad * .8
              ..strokeCap = StrokeCap.round);

        continue; // Lanjut ke partikel berikutnya setelah fase orbit
      } else {
        final tt = (t - _orbitEnd) / (1 - _orbitEnd);
        moveDistance = baseOrbit + bloomExtra * tt; // bloom melebar
      }

      // Posisi akhir - dari perimeter + jarak gerakan
      final pos = originalPos + direction * moveDistance;

      // ── tail ── (mengarah ke perimeter)
      final tailLen = circleRadius *
          tailFactor *
          (t < _launchEnd
              ? (t / _launchEnd) // grow
              : 1 +
                  (t > _orbitEnd
                      ? (t - _orbitEnd) / (1 - _orbitEnd) * .4
                      : 0)) // memanjang sedikit saat bloom
          *
          radiusMultiplier;

      final tailStart = pos - direction * tailLen;

      // ── skala & opasitas ──
      final opacity = t < .9 ? 1.0 : 1 - (t - .9) / .1;
      final scale = opacity; // titik mengecil seiring pudar

      // ── warna ──
      Color col = color;
      if (enableHueTilt) {
        final hsl = HSLColor.fromColor(color);
        final shift = (perimeterRatio) * 360 * hueTiltRange;
        col = hsl
            .withHue((hsl.hue + shift) % 360)
            .withSaturation((hsl.saturation * saturationBoost).clamp(0, 1))
            .toColor();
      }
      col = col.withOpacity(opacity);

      // ── gambar ──
      final rad = circleRadius * radiusMultiplier * scale;
      cv.drawCircle(pos, rad, Paint()..color = col);

      cv.drawLine(
          tailStart,
          pos,
          Paint()
            ..color = col
            ..strokeWidth = rad * .8
            ..strokeCap = StrokeCap.round);
    }
  }

  // Helper untuk mendapatkan posisi pada perimeter
  Offset _getPositionOnPerimeter(Rect rect, double ratio) {
    final totalPerimeter = 2 * (rect.width + rect.height);
    final distanceAlongPerimeter = totalPerimeter * ratio;

    // Sisi atas
    if (distanceAlongPerimeter < rect.width) {
      return Offset(rect.left + distanceAlongPerimeter, rect.top);
    }
    // Sisi kanan
    else if (distanceAlongPerimeter < rect.width + rect.height) {
      return Offset(
          rect.right, rect.top + (distanceAlongPerimeter - rect.width));
    }
    // Sisi bawah
    else if (distanceAlongPerimeter < 2 * rect.width + rect.height) {
      return Offset(
          rect.right - (distanceAlongPerimeter - rect.width - rect.height),
          rect.bottom);
    }
    // Sisi kiri
    else {
      return Offset(
          rect.left,
          rect.bottom -
              (distanceAlongPerimeter - 2 * rect.width - rect.height));
    }
  }

  // ───── easing helpers ─────
  double _easeOutBack(double t) {
    const c1 = 1.70158, c3 = c1 + 1;
    return 1 + c3 * math.pow(t - 1, 3) + c1 * math.pow(t - 1, 2);
  }

  // ───── overrides ─────
  @override
  bool shouldRepaint(EffectAnimator old) =>
      old is! PerimeterOrbitBloomAnimatorV2 ||
      old.particleCount != particleCount ||
      old.circleRadius != circleRadius ||
      old.tailFactor != tailFactor ||
      old.orbitMargin != orbitMargin ||
      old.bloomExtra != bloomExtra ||
      old.distributeEvenly != distributeEvenly ||
      old.enableHueTilt != enableHueTilt ||
      old.hueTiltRange != hueTiltRange ||
      old.saturationBoost != saturationBoost;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  @override
  double getDefaultRadiusMultiplier() => 1.0;

  @override
  double getOuterPadding() =>
      orbitMargin + bloomExtra + circleRadius * tailFactor;
}

class PerimeterRayBurstMovingAnimator implements EffectAnimator {
  // ---------- tampilan ----------
  final int rayCount; // jumlah sinar
  final double lineWidth; // tebal garis
  final double lineLength; // panjang tetap garis
  final double
      rayLength; // jarak tempuh maksimum relatif terhadap sisi terpendek
  final double expansionRate; // kecepatan ekspansi

  // ---------- opsi warna ----------
  final bool enableHueTilt; // aktifkan gradasi
  final double hueTiltRange; // 0‑1  (1 = 360° penuh)
  final double saturationBoost; // 1 = tak berubah

  PerimeterRayBurstMovingAnimator({
    this.rayCount = 24,
    this.lineWidth = 2.0,
    this.lineLength = 30.0, // panjang tetap garis dalam piksel
    this.rayLength = 0.7,
    this.expansionRate = 1.2,
    //
    this.enableHueTilt = false,
    this.hueTiltRange = .45,
    this.saturationBoost = 1.2,
  });

  // fase
  static const double _burstPhase = .65;

  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final c = center + positionOffset;
    final shortestSide = math.min(size.width, size.height);
    final maxRayDistance = shortestSide * rayLength * radiusMultiplier;
    final actualLineLength = lineLength * radiusMultiplier;

    // Buat rect untuk perimeter
    final rect = Rect.fromCenter(
      center: c,
      width: size.width,
      height: size.height,
    );

    for (int rayIndex = 0; rayIndex < rayCount; rayIndex++) {
      // Posisi awal di perimeter
      final perimeterRatio = rayIndex / rayCount;
      final startPos = _getPositionOnPerimeter(rect, perimeterRatio);

      // Vektor arah dari perimeter ke luar (menjauh dari pusat)
      final dirToOut = startPos - c;
      final distance = dirToOut.distance;
      final direction = distance > 0
          ? Offset(dirToOut.dx / distance, dirToOut.dy / distance)
          : Offset(0, 0);

      // Sedikit delay antar sinar
      final rayDelay = rayIndex * 0.01;
      final rawT = progress - rayDelay;
      if (rawT <= 0) continue;

      // Normalisasi progress
      final t = (rawT / (1 - rayDelay)).clamp(0.0, 1.0);

      // ---- Jarak gerakan dari perimeter ----
      double moveDistance;
      if (t < _burstPhase) {
        final burstT = t / _burstPhase;
        moveDistance = maxRayDistance * _easeOutCubic(burstT);
      } else {
        final fadeT = (t - _burstPhase) / (1 - _burstPhase);
        moveDistance = maxRayDistance + (fadeT * fadeT * 30);
      }

      // Sesuaikan jarak dengan faktor ekspansi
      final actualDistance = moveDistance * expansionRate;

      // ---- Posisi tengah garis yang bergerak keluar dari perimeter ----
      final midPoint = startPos + direction * actualDistance;

      // Titik awal dan akhir garis berdasarkan titik tengah dan panjang garis
      final halfLength = actualLineLength / 2;
      final startPoint = midPoint - direction * halfLength;
      final endPoint = midPoint + direction * halfLength;

      // ---- Opasitas ----
      final opacity = t < 0.15
          ? t / 0.15
          : t > 0.85
              ? (1 - t) / 0.15
              : 1.0;

      // ---- Warna ----
      Color rayColor = color;
      if (enableHueTilt) {
        final hsl = HSLColor.fromColor(color);
        final hueShiftDeg = perimeterRatio * 360 * hueTiltRange;
        rayColor = hsl
            .withHue((hsl.hue + hueShiftDeg) % 360)
            .withSaturation((hsl.saturation * saturationBoost).clamp(0.0, 1.0))
            .toColor();
      }
      rayColor = rayColor.withOpacity(opacity);

      // ---- Gambar garis ----
      final lineThickness = lineWidth * radiusMultiplier;

      canvas.drawLine(
          startPoint,
          endPoint,
          Paint()
            ..color = rayColor
            ..strokeWidth = lineThickness
            ..strokeCap = StrokeCap.round);
    }
  }

  // Helper untuk mendapatkan posisi pada perimeter
  Offset _getPositionOnPerimeter(Rect rect, double ratio) {
    final totalPerimeter = 2 * (rect.width + rect.height);
    final distanceAlongPerimeter = totalPerimeter * ratio;

    // Sisi atas
    if (distanceAlongPerimeter < rect.width) {
      return Offset(rect.left + distanceAlongPerimeter, rect.top);
    }
    // Sisi kanan
    else if (distanceAlongPerimeter < rect.width + rect.height) {
      return Offset(
          rect.right, rect.top + (distanceAlongPerimeter - rect.width));
    }
    // Sisi bawah
    else if (distanceAlongPerimeter < 2 * rect.width + rect.height) {
      return Offset(
          rect.right - (distanceAlongPerimeter - rect.width - rect.height),
          rect.bottom);
    }
    // Sisi kiri
    else {
      return Offset(
          rect.left,
          rect.bottom -
              (distanceAlongPerimeter - 2 * rect.width - rect.height));
    }
  }

  // easing
  double _easeOutCubic(double t) {
    return 1 - math.pow(1 - t, 3).toDouble();
  }

  // overrides
  @override
  bool shouldRepaint(EffectAnimator old) =>
      old is! PerimeterRayBurstMovingAnimator ||
      old.rayCount != rayCount ||
      old.lineWidth != lineWidth ||
      old.lineLength != lineLength ||
      old.rayLength != rayLength ||
      old.expansionRate != expansionRate ||
      old.enableHueTilt != enableHueTilt ||
      old.hueTiltRange != hueTiltRange ||
      old.saturationBoost != saturationBoost;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;
  @override
  double getDefaultRadiusMultiplier() => 1;
  @override
  double getOuterPadding() => rayLength * 100 + lineLength;
}

class _Particle {
  final double angle;
  final double maxDistance;
  final double baseSize;
  final double pulseRate;

  _Particle({
    required this.angle,
    required this.maxDistance,
    required this.baseSize,
    required this.pulseRate,
  });
}

// Kelas untuk animasi langsung keluar
class PerimeterCircleDirectOutAnimator implements EffectAnimator {
  // ───── konfigurasi ─────
  final int particleCount;
  final bool enableHueTilt; // aktifkan gradasi
  final double hueTiltRange; // 0‑1 (1 = 360°)
  final double saturationBoost; // 1 = tak berubah
  final bool enableBloom; // lingkaran "halo" di puncak animasi
  final double bloomWidth; // strokeWidth halo

  final List<_Particle> _particles = [];
  final Random _random = Random();

  PerimeterCircleDirectOutAnimator({
    this.particleCount = 24,
    this.enableHueTilt = false,
    this.hueTiltRange = .30,
    this.saturationBoost = 1.1,
    this.enableBloom = true,
    this.bloomWidth = 2.5,
  });

  // ───── inisialisasi partikel (sekali saja) ─────
  void _initParticles() {
    if (_particles.isNotEmpty) return;

    for (int i = 0; i < particleCount; i++) {
      final baseAngle = (i / particleCount) * math.pi * 2;
      final angle = baseAngle + (_random.nextDouble() * .2 - .1);

      _particles.add(_Particle(
        angle: angle,
        maxDistance: _random.nextDouble() * 15 + 25,
        baseSize: _random.nextDouble() * 4 + 2,
        pulseRate: _random.nextDouble() * 3 + 1,
      ));
    }
  }

  // ───── paint ─────
  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color baseColor,
      {double radiusMultiplier = 1, Offset positionOffset = Offset.zero}) {
    _initParticles();

    final c = center + positionOffset;

    // Buat rect untuk perimeter
    final rect = Rect.fromCenter(
      center: c,
      width: size.width,
      height: size.height,
    );

    // Jarak maksimal gerakan dari perimeter
    final maxOutwardDistance = 25 * radiusMultiplier;

    // progress langsung keluar: 0 → 1
    final distP = _easeOutQuad(progress);

    // ----- BLOOM halo (opsional) -----
    if (enableBloom && progress > .85) {
      final bloomOpacity = _easeInQuad(1 - (progress - .85) / .15);

      // Buat halo di sekitar perimeter
      final bloomPath = Path();
      bloomPath.addRect(rect.inflate(bloomWidth * radiusMultiplier));

      canvas.drawPath(
          bloomPath,
          Paint()
            ..color = baseColor.withOpacity(bloomOpacity * .4)
            ..style = PaintingStyle.stroke
            ..strokeWidth = bloomWidth * radiusMultiplier
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3)); // glow
    }

    // ----- partikel -----
    for (int i = 0; i < _particles.length; i++) {
      final p = _particles[i];

      // Posisi di perimeter
      final perimeterRatio = i / particleCount;
      final perimeterPos = _getPositionOnPerimeter(rect, perimeterRatio);

      // Vektor dari pusat ke perimeter (arah gerakan)
      final dirVector = perimeterPos - c;
      final distance = dirVector.distance;
      final direction = distance > 0
          ? Offset(dirVector.dx / distance, dirVector.dy / distance)
          : Offset(0, 0);

      // Jarak gerakan dari perimeter
      final curDist = p.maxDistance * distP * radiusMultiplier;

      // Posisi akhir
      final pos = perimeterPos + direction * curDist;

      // pulsasi
      final pulse = .5 + .5 * math.sin(progress * math.pi * 2 * p.pulseRate);
      final sizePx = p.baseSize * pulse * radiusMultiplier;

      // opacity fade out di akhir
      double opacity = progress < .9 ? 1 : (1 - (progress - .9) / .1);
      opacity = opacity.clamp(0, 1);

      // warna
      Color col = baseColor;
      if (enableHueTilt) {
        final hsl = HSLColor.fromColor(baseColor);
        final shift = perimeterRatio * 360 * hueTiltRange;
        col = hsl
            .withHue((hsl.hue + shift) % 360)
            .withSaturation((hsl.saturation * saturationBoost).clamp(0, 1))
            .toColor();
      }
      col = col.withOpacity(opacity);

      // Decay blur tingkat 3 (terluar) - blur jangkauan luas
      canvas.drawCircle(
          pos,
          sizePx * 3.5,
          Paint()
            ..color = col.withOpacity(.15)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));

      // Decay blur tingkat 2 (menengah)
      canvas.drawCircle(
          pos,
          sizePx * 2.5,
          Paint()
            ..color = col.withOpacity(.35)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));

      // Decay blur tingkat 1 (dekat)
      canvas.drawCircle(
          pos,
          sizePx * 1.8,
          Paint()
            ..color = col.withOpacity(.5)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));

      // lingkaran inti
      canvas.drawCircle(pos, sizePx, Paint()..color = col);
    }
  }

  // Helper untuk mendapatkan posisi pada perimeter
  Offset _getPositionOnPerimeter(Rect rect, double ratio) {
    final totalPerimeter = 2 * (rect.width + rect.height);
    final distanceAlongPerimeter = totalPerimeter * ratio;

    // Sisi atas
    if (distanceAlongPerimeter < rect.width) {
      return Offset(rect.left + distanceAlongPerimeter, rect.top);
    }
    // Sisi kanan
    else if (distanceAlongPerimeter < rect.width + rect.height) {
      return Offset(
          rect.right, rect.top + (distanceAlongPerimeter - rect.width));
    }
    // Sisi bawah
    else if (distanceAlongPerimeter < 2 * rect.width + rect.height) {
      return Offset(
          rect.right - (distanceAlongPerimeter - rect.width - rect.height),
          rect.bottom);
    }
    // Sisi kiri
    else {
      return Offset(
          rect.left,
          rect.bottom -
              (distanceAlongPerimeter - 2 * rect.width - rect.height));
    }
  }

  // ───── easing ─────
  double _easeOutQuad(double t) => t * (2 - t);
  double _easeInQuad(double t) => t * t;

  // ───── overrides ─────
  @override
  bool shouldRepaint(EffectAnimator old) =>
      old is! PerimeterCircleDirectOutAnimator ||
      old.particleCount != particleCount ||
      old.enableHueTilt != enableHueTilt ||
      old.hueTiltRange != hueTiltRange ||
      old.saturationBoost != saturationBoost ||
      old.enableBloom != enableBloom ||
      old.bloomWidth != bloomWidth;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;
  @override
  double getDefaultRadiusMultiplier() => 1;
  @override
  double getOuterPadding() => 40; // Perkiraan jarak terjauh partikel
}

// Kelas untuk animasi dari luar ke dalam
class PerimeterCircleOutsideInAnimator implements EffectAnimator {
  // ───── konfigurasi ─────
  final int particleCount;
  final bool enableHueTilt; // aktifkan gradasi
  final double hueTiltRange; // 0‑1 (1 = 360°)
  final double saturationBoost; // 1 = tak berubah
  final bool enableBloom; // lingkaran "halo" di puncak animasi
  final double bloomWidth; // strokeWidth halo

  final List<_Particle> _particles = [];
  final Random _random = Random();

  PerimeterCircleOutsideInAnimator({
    this.particleCount = 24,
    this.enableHueTilt = false,
    this.hueTiltRange = .30,
    this.saturationBoost = 1.1,
    this.enableBloom = true,
    this.bloomWidth = 1.5,
  });

  // ───── inisialisasi partikel (sekali saja) ─────
  void _initParticles() {
    if (_particles.isNotEmpty) return;

    for (int i = 0; i < particleCount; i++) {
      final baseAngle = (i / particleCount) * math.pi * 2;
      final angle = baseAngle + (_random.nextDouble() * .2 - .1);

      _particles.add(_Particle(
        angle: angle,
        maxDistance: _random.nextDouble() * 15 + 25,
        baseSize: _random.nextDouble() * 4 + 2,
        pulseRate: _random.nextDouble() * 3 + 1,
      ));
    }
  }

  // ───── paint ─────
  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color baseColor,
      {double radiusMultiplier = 1, Offset positionOffset = Offset.zero}) {
    _initParticles();

    final c = center + positionOffset;

    // Buat rect untuk perimeter
    final rect = Rect.fromCenter(
      center: c,
      width: size.width,
      height: size.height,
    );

    // Jarak maksimal gerakan dari perimeter
    final maxOutwardDistance = 25 * radiusMultiplier;

    // progress dari luar ke dalam: 1 → 0
    final distP = _easeInQuad(1 - progress);

    // ----- BLOOM halo (opsional) -----
    if (enableBloom && progress < .15) {
      final bloomOpacity = _easeInQuad(progress / .15);

      // Buat halo di sekitar perimeter
      final bloomPath = Path();
      bloomPath.addRect(rect.inflate(bloomWidth * radiusMultiplier));

      canvas.drawPath(
          bloomPath,
          Paint()
            ..color = baseColor.withOpacity(bloomOpacity * .4)
            ..style = PaintingStyle.stroke
            ..strokeWidth = bloomWidth * radiusMultiplier
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3)); // glow
    }

    // ----- partikel -----
    for (int i = 0; i < _particles.length; i++) {
      final p = _particles[i];

      // Posisi di perimeter
      final perimeterRatio = i / particleCount;
      final perimeterPos = _getPositionOnPerimeter(rect, perimeterRatio);

      // Vektor dari pusat ke perimeter (arah gerakan)
      final dirVector = perimeterPos - c;
      final distance = dirVector.distance;
      final direction = distance > 0
          ? Offset(dirVector.dx / distance, dirVector.dy / distance)
          : Offset(0, 0);

      // Jarak gerakan dari perimeter
      final curDist = p.maxDistance * distP * radiusMultiplier;

      // Posisi akhir (mulai dari luar)
      final pos = perimeterPos + direction * curDist;

      // pulsasi
      final pulse = .5 + .5 * math.sin(progress * math.pi * 2 * p.pulseRate);
      final sizePx = p.baseSize * pulse * radiusMultiplier;

      // opacity fade in di awal
      double opacity = progress > .1 ? 1 : progress / .1;
      opacity = opacity.clamp(0, 1);

      // warna
      Color col = baseColor;
      if (enableHueTilt) {
        final hsl = HSLColor.fromColor(baseColor);
        final shift = perimeterRatio * 360 * hueTiltRange;
        col = hsl
            .withHue((hsl.hue + shift) % 360)
            .withSaturation((hsl.saturation * saturationBoost).clamp(0, 1))
            .toColor();
      }
      col = col.withOpacity(opacity);

      // Decay blur tingkat 3 (terluar) - blur jangkauan luas
      canvas.drawCircle(
          pos,
          sizePx * 3.5,
          Paint()
            ..color = col.withOpacity(.15)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));

      // Decay blur tingkat 2 (menengah)
      canvas.drawCircle(
          pos,
          sizePx * 2.5,
          Paint()
            ..color = col.withOpacity(.35)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));

      // Decay blur tingkat 1 (dekat)
      canvas.drawCircle(
          pos,
          sizePx * 1.8,
          Paint()
            ..color = col.withOpacity(.5)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));

      // lingkaran inti
      canvas.drawCircle(pos, sizePx, Paint()..color = col);
    }
  }

  // Helper untuk mendapatkan posisi pada perimeter
  Offset _getPositionOnPerimeter(Rect rect, double ratio) {
    final totalPerimeter = 2 * (rect.width + rect.height);
    final distanceAlongPerimeter = totalPerimeter * ratio;

    // Sisi atas
    if (distanceAlongPerimeter < rect.width) {
      return Offset(rect.left + distanceAlongPerimeter, rect.top);
    }
    // Sisi kanan
    else if (distanceAlongPerimeter < rect.width + rect.height) {
      return Offset(
          rect.right, rect.top + (distanceAlongPerimeter - rect.width));
    }
    // Sisi bawah
    else if (distanceAlongPerimeter < 2 * rect.width + rect.height) {
      return Offset(
          rect.right - (distanceAlongPerimeter - rect.width - rect.height),
          rect.bottom);
    }
    // Sisi kiri
    else {
      return Offset(
          rect.left,
          rect.bottom -
              (distanceAlongPerimeter - 2 * rect.width - rect.height));
    }
  }

  // ───── easing ─────
  double _easeOutQuad(double t) => t * (2 - t);
  double _easeInQuad(double t) => t * t;

  // ───── overrides ─────
  @override
  bool shouldRepaint(EffectAnimator old) =>
      old is! PerimeterCircleOutsideInAnimator ||
      old.particleCount != particleCount ||
      old.enableHueTilt != enableHueTilt ||
      old.hueTiltRange != hueTiltRange ||
      old.saturationBoost != saturationBoost ||
      old.enableBloom != enableBloom ||
      old.bloomWidth != bloomWidth;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;
  @override
  double getDefaultRadiusMultiplier() => 1;
  @override
  double getOuterPadding() => 40; // Perkiraan jarak terjauh partikel
}

class PerimeterCircleBurstAnimator implements EffectAnimator {
  // ───── konfigurasi ─────
  final int particleCount;
  final bool enableHueTilt; // aktifkan gradasi
  final double hueTiltRange; // 0‑1 (1 = 360°)
  final double saturationBoost; // 1 = tak berubah
  final bool enableBloom; // lingkaran "halo" di puncak animasi
  final double bloomWidth; // strokeWidth halo

  final List<_Particle> _particles = [];
  final Random _random = Random();

  PerimeterCircleBurstAnimator({
    this.particleCount = 24,
    this.enableHueTilt = false,
    this.hueTiltRange = .30,
    this.saturationBoost = 1.1,
    this.enableBloom = true,
    this.bloomWidth = .5,
  });

  // ───── inisialisasi partikel (sekali saja) ─────
  void _initParticles() {
    if (_particles.isNotEmpty) return;

    for (int i = 0; i < particleCount; i++) {
      final baseAngle = (i / particleCount) * math.pi * 2;
      final angle = baseAngle + (_random.nextDouble() * .2 - .1);

      _particles.add(_Particle(
        angle: angle,
        maxDistance: _random.nextDouble() * 15 + 25,
        baseSize: _random.nextDouble() * 4 + 2,
        pulseRate: _random.nextDouble() * 3 + 1,
      ));
    }
  }

  // ───── paint ─────
  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color baseColor,
      {double radiusMultiplier = 1, Offset positionOffset = Offset.zero}) {
    _initParticles();

    final c = center + positionOffset;

    // Buat rect untuk perimeter
    final rect = Rect.fromCenter(
      center: c,
      width: size.width,
      height: size.height,
    );

    // Jarak maksimal gerakan dari perimeter
    final maxOutwardDistance = 25 * radiusMultiplier;

    // progress radial: 0 → 1 → 0
    final distP = progress < .5
        ? _easeOutQuad(progress * 2)
        : _easeInQuad(2 - progress * 2);

    // ----- BLOOM halo (opsional) -----
    if (enableBloom && (progress > .45 && progress < .55)) {
      final bloomT = (progress - .45) / .1; // 0‑1
      final opacity = 1 - (bloomT - .5).abs() * 2; // naik lalu turun

      // Buat halo di sekitar perimeter
      final bloomPath = Path();
      bloomPath.addRect(rect.inflate(bloomWidth * radiusMultiplier));

      canvas.drawPath(
          bloomPath,
          Paint()
            ..color = baseColor.withOpacity(opacity * .4)
            ..style = PaintingStyle.stroke
            ..strokeWidth = bloomWidth * radiusMultiplier
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3)); // glow
    }

    // ----- partikel -----
    for (int i = 0; i < _particles.length; i++) {
      final p = _particles[i];

      // Posisi di perimeter
      final perimeterRatio = i / particleCount;
      final perimeterPos = _getPositionOnPerimeter(rect, perimeterRatio);

      // Vektor dari pusat ke perimeter (arah gerakan)
      final dirVector = perimeterPos - c;
      final distance = dirVector.distance;
      final direction = distance > 0
          ? Offset(dirVector.dx / distance, dirVector.dy / distance)
          : Offset(0, 0);

      // Jarak gerakan dari perimeter
      final curDist = p.maxDistance * distP * radiusMultiplier;

      // Posisi akhir
      final pos = perimeterPos + direction * curDist;

      // pulsasi
      final pulse = .5 + .5 * math.sin(progress * math.pi * 2 * p.pulseRate);
      final sizePx = p.baseSize * pulse * radiusMultiplier;

      // opacity fade in/out
      double opacity = 1;
      if (distP < .2)
        opacity = distP / .2;
      else if (distP > .8) opacity = (1 - distP) / .2;

      // warna
      Color col = baseColor;
      if (enableHueTilt) {
        final hsl = HSLColor.fromColor(baseColor);
        final shift = perimeterRatio * 360 * hueTiltRange;
        col = hsl
            .withHue((hsl.hue + shift) % 360)
            .withSaturation((hsl.saturation * saturationBoost).clamp(0, 1))
            .toColor();
      }
      col = col.withOpacity(opacity);

      // glow ringan
      canvas.drawCircle(
          pos,
          sizePx * 1.6,
          Paint()
            ..color = col.withOpacity(.25)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2));

      // lingkaran inti
      canvas.drawCircle(pos, sizePx, Paint()..color = col);
    }
  }

  // Helper untuk mendapatkan posisi pada perimeter
  Offset _getPositionOnPerimeter(Rect rect, double ratio) {
    final totalPerimeter = 2 * (rect.width + rect.height);
    final distanceAlongPerimeter = totalPerimeter * ratio;

    // Sisi atas
    if (distanceAlongPerimeter < rect.width) {
      return Offset(rect.left + distanceAlongPerimeter, rect.top);
    }
    // Sisi kanan
    else if (distanceAlongPerimeter < rect.width + rect.height) {
      return Offset(
          rect.right, rect.top + (distanceAlongPerimeter - rect.width));
    }
    // Sisi bawah
    else if (distanceAlongPerimeter < 2 * rect.width + rect.height) {
      return Offset(
          rect.right - (distanceAlongPerimeter - rect.width - rect.height),
          rect.bottom);
    }
    // Sisi kiri
    else {
      return Offset(
          rect.left,
          rect.bottom -
              (distanceAlongPerimeter - 2 * rect.width - rect.height));
    }
  }

  // ───── easing ─────
  double _easeOutQuad(double t) => t * (2 - t);
  double _easeInQuad(double t) => t * t;

  // ───── overrides ─────
  @override
  bool shouldRepaint(EffectAnimator old) =>
      old is! PerimeterCircleBurstAnimator ||
      old.particleCount != particleCount ||
      old.enableHueTilt != enableHueTilt ||
      old.hueTiltRange != hueTiltRange ||
      old.saturationBoost != saturationBoost ||
      old.enableBloom != enableBloom ||
      old.bloomWidth != bloomWidth;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;
  @override
  double getDefaultRadiusMultiplier() => 1;
  @override
  double getOuterPadding() => 40; // Perkiraan jarak terjauh partikel
}

class PerimeterShapeExplosionAnimator implements EffectAnimator {
  // ---------- tampilan ----------
  final int particleCount;
  final double circleRadius; // radius lingkaran awal
  final double tailFactor; // panjang ekor = circleRadius * tailFactor
  final double explosionScale; // jarak lempar relatif sisi terpendek
  final bool distributeEvenly;

  // ---------- opsi warna ----------
  final bool enableHueTilt; // aktifkan gradasi
  final double hueTiltRange; // 0‑1  (1 = 360° penuh)
  final double saturationBoost; // 1 = tak berubah

  PerimeterShapeExplosionAnimator({
    this.particleCount = 24,
    this.circleRadius = 6,
    this.tailFactor = 3,
    this.explosionScale = .7,
    this.distributeEvenly = true,
    //
    this.enableHueTilt = false,
    this.hueTiltRange = .35,
    this.saturationBoost = 1.1,
  });

  // fase
  static const double _burstPhase = .6;

  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final c = center + positionOffset;
    final rnd = math.Random(42);
    final shortestSide = math.min(size.width, size.height);

    // Buat rect untuk perimeter
    final rect = Rect.fromCenter(
      center: c,
      width: size.width,
      height: size.height,
    );

    final explosionRadius = shortestSide * explosionScale * radiusMultiplier;

    for (int i = 0; i < particleCount; i++) {
      final delay = i * 0.02;
      final rawT = progress - delay;
      if (rawT <= 0) continue;

      // normalisasi progress partikel
      final t = (rawT / (1 - delay)).clamp(0.0, 1.0);

      // Posisi awal di perimeter
      final perimeterRatio =
          distributeEvenly ? i / particleCount : rnd.nextDouble();
      final startPos = _getPositionOnPerimeter(rect, perimeterRatio);

      // Hitung arah gerakan - keluar dari perimeter
      final dirVector = startPos - c;
      final distance = dirVector.distance;

      // Normalisasi vektor arah
      final normalizedDx = distance > 0 ? dirVector.dx / distance : 0;
      final normalizedDy = distance > 0 ? dirVector.dy / distance : 0;
      final direction =
          Offset(normalizedDx.toDouble(), normalizedDy.toDouble());

      // ---- posisi radial ----
      double moveDist;
      if (t < _burstPhase) {
        final burstT = t / _burstPhase;
        moveDist = explosionRadius * _easeOutBack(burstT);
      } else {
        final fallT = (t - _burstPhase) / (1 - _burstPhase);
        moveDist = explosionRadius + (fallT * fallT * 60);
      }

      // Posisi akhir partikel - dari perimeter menuju keluar
      final pos = startPos + (direction * moveDist);

      // ---- skala & opasitas ----
      final scale = t < .1
          ? t / .1
          : t > .85
              ? (1 - t) / .15
              : 1.0;

      final opacity = t < .1
          ? t / .1
          : t > .85
              ? (1 - t) / .15
              : 1.0;

      // ---- warna ----
      Color particleColor = color;
      if (enableHueTilt) {
        final hsl = HSLColor.fromColor(color);
        final hueShiftDeg = perimeterRatio * 360 * hueTiltRange;
        particleColor = hsl
            .withHue((hsl.hue + hueShiftDeg) % 360)
            .withSaturation((hsl.saturation * saturationBoost).clamp(0.0, 1.0))
            .toColor();
      }
      particleColor = particleColor.withOpacity(opacity);

      // ---- gambar ----
      final rad = circleRadius * radiusMultiplier * scale;

      // lingkaran
      canvas.drawCircle(pos, rad, Paint()..color = particleColor);

      // ekor - mengarah kembali ke perimeter
      final tailLen = rad * tailFactor;
      final tailStart = pos - direction * tailLen;
      canvas.drawLine(
          tailStart,
          pos,
          Paint()
            ..color = particleColor
            ..strokeWidth = rad * .8
            ..strokeCap = StrokeCap.round);
    }
  }

  // Helper untuk mendapatkan posisi pada perimeter
  Offset _getPositionOnPerimeter(Rect rect, double ratio) {
    final totalPerimeter = 2 * (rect.width + rect.height);
    final distanceAlongPerimeter = totalPerimeter * ratio;

    // Sisi atas
    if (distanceAlongPerimeter < rect.width) {
      return Offset(rect.left + distanceAlongPerimeter, rect.top);
    }
    // Sisi kanan
    else if (distanceAlongPerimeter < rect.width + rect.height) {
      return Offset(
          rect.right, rect.top + (distanceAlongPerimeter - rect.width));
    }
    // Sisi bawah
    else if (distanceAlongPerimeter < 2 * rect.width + rect.height) {
      return Offset(
          rect.right - (distanceAlongPerimeter - rect.width - rect.height),
          rect.bottom);
    }
    // Sisi kiri
    else {
      return Offset(
          rect.left,
          rect.bottom -
              (distanceAlongPerimeter - 2 * rect.width - rect.height));
    }
  }

  // easing
  double _easeOutBack(double t) {
    const c1 = 1.70158;
    const c3 = c1 + 1;
    return 1 + c3 * math.pow(t - 1, 3) + c1 * math.pow(t - 1, 2);
  }

  // overrides
  @override
  bool shouldRepaint(EffectAnimator old) =>
      old is! PerimeterShapeExplosionAnimator ||
      old.particleCount != particleCount ||
      old.circleRadius != circleRadius ||
      old.tailFactor != tailFactor ||
      old.explosionScale != explosionScale ||
      old.enableHueTilt != enableHueTilt ||
      old.hueTiltRange != hueTiltRange ||
      old.saturationBoost != saturationBoost;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;
  @override
  double getDefaultRadiusMultiplier() => 1;
  @override
  double getOuterPadding() => circleRadius * tailFactor + explosionScale * 100;
}

class PerimeterShapeImplodeAnimator implements EffectAnimator {
  // ───── visual ─────
  final int particleCount;
  final double circleRadius;
  final double tailFactor;
  final double spawnScale; // radius awal = spawnScale * sisi terpendek
  final bool distributeEvenly;
  // ───── warna ─────
  final bool enableHueTilt;
  final double hueTiltRange;
  final double saturationBoost;

  PerimeterShapeImplodeAnimator({
    this.particleCount = 24,
    this.circleRadius = 6,
    this.tailFactor = 3,
    this.spawnScale = .75,
    this.distributeEvenly = true,
    this.enableHueTilt = false,
    this.hueTiltRange = .35,
    this.saturationBoost = 1.1,
  });

  // batas fase
  static const double _spawnEnd = .15;
  static const double _convergeEnd = .75;

  @override
  void paint(Canvas cv, Size size, double p, Offset center, Color color,
      {double radiusMultiplier = 1, Offset positionOffset = Offset.zero}) {
    final c = center + positionOffset;
    final rnd = math.Random(42);
    final minSide = math.min(size.width, size.height);

    // Buat rect untuk perimeter
    final rect = Rect.fromCenter(
      center: c,
      width: size.width,
      height: size.height,
    );

    final spawnRadius = minSide * spawnScale * radiusMultiplier;

    for (var i = 0; i < particleCount; i++) {
      final delay = i * 0.02;
      final rawT = p - delay;
      if (rawT <= 0) continue;

      final t = (rawT / (1 - delay)).clamp(0.0, 1.0);

      // Posisi pada perimeter
      final perimeterRatio =
          distributeEvenly ? i / particleCount : rnd.nextDouble();
      final perimeterPos = _getPositionOnPerimeter(rect, perimeterRatio);

      // Tentukan arah - dari luar menuju ke perimeter dan kemudian ke pusat
      final dirToCenter = c - perimeterPos;
      final distance = dirToCenter.distance;
      final direction = distance > 0
          ? Offset(dirToCenter.dx / distance, dirToCenter.dy / distance)
          : Offset(0, 0);

      // ── posisi radial ──
      double dist;
      Offset pos;

      if (t < _spawnEnd) {
        // Mulai dari jauh di luar perimeter
        final tt = t / _spawnEnd; // 0‑1
        dist = spawnRadius * (1 - _easeOutQuad(tt));
        pos = perimeterPos - direction * dist; // Di luar perimeter
      } else if (t < _convergeEnd) {
        // Bergerak dari perimeter menuju pusat
        final tt = (t - _spawnEnd) / (_convergeEnd - _spawnEnd);
        final ratio = _easeInBack(tt); // 0-1
        pos = Offset.lerp(perimeterPos, c, ratio)!;
      } else {
        // Dekat pusat di akhir animasi
        final tt = (t - _convergeEnd) / (1 - _convergeEnd);
        final ratio = 1.0 - (0.15 * (1 - tt)); // mendekati 1
        pos = Offset.lerp(perimeterPos, c, ratio)!;
      }

      // ── skala & opasitas ──
      final scale = t < _spawnEnd
          ? t / _spawnEnd
          : t > _convergeEnd
              ? (1 - t) / (1 - _convergeEnd)
              : 1.0;

      final opacity = scale; // sama‑sama turun/naik

      // ── warna ──
      Color col = color;
      if (enableHueTilt) {
        final hsl = HSLColor.fromColor(color);
        final shift = perimeterRatio * 360 * hueTiltRange;
        col = hsl
            .withHue((hsl.hue + shift) % 360)
            .withSaturation((hsl.saturation * saturationBoost).clamp(0, 1))
            .toColor();
      }
      col = col.withOpacity(opacity.toDouble());

      // ── gambar ──
      final rad = circleRadius * radiusMultiplier * scale;
      cv.drawCircle(pos, rad, Paint()..color = col);

      // Arah tail - menunjuk ke arah gerakan
      final tailLen = rad * tailFactor;
      final tailDir =
          t < _spawnEnd ? direction : -direction; // Balik arah setelah spawn
      final tailEnd = pos + tailDir * tailLen;

      cv.drawLine(
          pos,
          tailEnd,
          Paint()
            ..color = col
            ..strokeWidth = rad * .8
            ..strokeCap = StrokeCap.round);
    }
  }

  // Helper untuk mendapatkan posisi pada perimeter
  Offset _getPositionOnPerimeter(Rect rect, double ratio) {
    final totalPerimeter = 2 * (rect.width + rect.height);
    final distanceAlongPerimeter = totalPerimeter * ratio;

    // Sisi atas
    if (distanceAlongPerimeter < rect.width) {
      return Offset(rect.left + distanceAlongPerimeter, rect.top);
    }
    // Sisi kanan
    else if (distanceAlongPerimeter < rect.width + rect.height) {
      return Offset(
          rect.right, rect.top + (distanceAlongPerimeter - rect.width));
    }
    // Sisi bawah
    else if (distanceAlongPerimeter < 2 * rect.width + rect.height) {
      return Offset(
          rect.right - (distanceAlongPerimeter - rect.width - rect.height),
          rect.bottom);
    }
    // Sisi kiri
    else {
      return Offset(
          rect.left,
          rect.bottom -
              (distanceAlongPerimeter - 2 * rect.width - rect.height));
    }
  }

  // ───── easing lokal ─────
  double _easeOutQuad(double t) => 1 - (1 - t) * (1 - t);
  double _easeInBack(double t) {
    const c1 = 1.70158;
    const c3 = c1 + 1;
    return c3 * t * t * t - c1 * t * t;
  }

  // ───── override ─────
  @override
  bool shouldRepaint(EffectAnimator old) =>
      old is! PerimeterShapeImplodeAnimator ||
      old.particleCount != particleCount ||
      old.circleRadius != circleRadius ||
      old.tailFactor != tailFactor ||
      old.spawnScale != spawnScale ||
      old.enableHueTilt != enableHueTilt ||
      old.hueTiltRange != hueTiltRange ||
      old.saturationBoost != saturationBoost;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;
  @override
  double getDefaultRadiusMultiplier() => 1;
  @override
  double getOuterPadding() => spawnScale * 100 + circleRadius * tailFactor;
}

class PerimeterShapeRetractImplodeAnimator implements EffectAnimator {
  // ───── parameter visual ─────
  final int particleCount;
  final double circleRadius; // radius dot
  final double tailFactor; // tailLen = circleRadius * tailFactor
  final double spawnScale; // spawnRadius = spawnScale * sisi terpendek
  final bool distributeEvenly;

  // ───── opsi warna ─────
  final bool enableHueTilt;
  final double hueTiltRange; // 0‑1   (1 => 360°)
  final double saturationBoost; // 1 => no change

  PerimeterShapeRetractImplodeAnimator({
    this.particleCount = 24,
    this.circleRadius = 6,
    this.tailFactor = 3,
    this.spawnScale = .75,
    this.distributeEvenly = true,
    //
    this.enableHueTilt = false,
    this.hueTiltRange = .35,
    this.saturationBoost = 1.1,
  });

  // batas fase
  static const double _tailRetractEnd = .30;

  // ───── paint ─────
  @override
  void paint(Canvas cv, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final c = center + positionOffset;
    final rnd = math.Random(42);
    final minSide = math.min(size.width, size.height);

    // Buat rect untuk perimeter
    final rect = Rect.fromCenter(
      center: c,
      width: size.width,
      height: size.height,
    );

    for (int i = 0; i < particleCount; i++) {
      // delay ringan antar partikel
      final delay = i * 0.02;
      final rawT = progress - delay;
      if (rawT <= 0) continue;

      // normalisasi agar setiap partikel selesai di progress==1
      final t = (rawT / (1 - delay)).clamp(0.0, 1.0);

      // Posisi pada perimeter
      final perimeterRatio =
          distributeEvenly ? i / particleCount : rnd.nextDouble();
      final perimeterPos = _getPositionOnPerimeter(rect, perimeterRatio);

      // Arah menuju pusat
      final dirToCenter = c - perimeterPos;
      final distance = dirToCenter.distance;
      final direction = distance > 0
          ? Offset(dirToCenter.dx / distance, dirToCenter.dy / distance)
          : Offset(0, 0);

      // ─── posisi radial ───
      Offset pos;
      if (t < _tailRetractEnd) {
        // tetap di perimeter selama fase retract
        pos = perimeterPos;
      } else {
        // implode ke pusat
        final implodeT = (t - _tailRetractEnd) / (1 - _tailRetractEnd); // 0‑1
        final moveRatio = _easeInQuad(implodeT);
        pos = Offset.lerp(perimeterPos, c, moveRatio)!;
      }

      // ─── tail length ───
      double tailLen;
      if (t < _tailRetractEnd) {
        final tailT = 1 - (t / _tailRetractEnd); // 1→0
        tailLen = circleRadius * tailFactor * tailT * radiusMultiplier;
      } else {
        tailLen = 0;
      }

      // ─── skala & opasitas dot ───
      final scale = t < _tailRetractEnd
          ? 1.0
          : 1 -
              ((t - _tailRetractEnd) / (1 - _tailRetractEnd)) *
                  .4; // sedikit mengecil
      final opacity = t < _tailRetractEnd
          ? 1.0
          : 1 - ((t - _tailRetractEnd) / (1 - _tailRetractEnd)); // fade out

      // ─── warna ───
      Color col = color;
      if (enableHueTilt) {
        final hsl = HSLColor.fromColor(color);
        final hueShift = perimeterRatio * 360 * hueTiltRange;
        col = hsl
            .withHue((hsl.hue + hueShift) % 360)
            .withSaturation((hsl.saturation * saturationBoost).clamp(0.0, 1.0))
            .toColor();
      }
      col = col.withOpacity(opacity.toDouble());

      // ─── gambar dot ───
      final rad = circleRadius * radiusMultiplier * scale;
      cv.drawCircle(pos, rad, Paint()..color = col);

      // ─── gambar tail (jika masih ada) ───
      if (tailLen > 0) {
        // Tails keluar dari perimeter
        final tailDir = -direction; // Berlawanan dengan arah ke pusat
        final tailEnd = pos + tailDir * tailLen;

        cv.drawLine(
            pos,
            tailEnd,
            Paint()
              ..color = col
              ..strokeWidth = rad * .8
              ..strokeCap = StrokeCap.round);
      }
    }
  }

  // Helper untuk mendapatkan posisi pada perimeter
  Offset _getPositionOnPerimeter(Rect rect, double ratio) {
    final totalPerimeter = 2 * (rect.width + rect.height);
    final distanceAlongPerimeter = totalPerimeter * ratio;

    // Sisi atas
    if (distanceAlongPerimeter < rect.width) {
      return Offset(rect.left + distanceAlongPerimeter, rect.top);
    }
    // Sisi kanan
    else if (distanceAlongPerimeter < rect.width + rect.height) {
      return Offset(
          rect.right, rect.top + (distanceAlongPerimeter - rect.width));
    }
    // Sisi bawah
    else if (distanceAlongPerimeter < 2 * rect.width + rect.height) {
      return Offset(
          rect.right - (distanceAlongPerimeter - rect.width - rect.height),
          rect.bottom);
    }
    // Sisi kiri
    else {
      return Offset(
          rect.left,
          rect.bottom -
              (distanceAlongPerimeter - 2 * rect.width - rect.height));
    }
  }

  // ───── easing helpers ─────
  double _easeInQuad(double t) => t * t;

  // ───── overrides ─────
  @override
  bool shouldRepaint(EffectAnimator old) =>
      old is! PerimeterShapeRetractImplodeAnimator ||
      old.particleCount != particleCount ||
      old.circleRadius != circleRadius ||
      old.tailFactor != tailFactor ||
      old.spawnScale != spawnScale ||
      old.enableHueTilt != enableHueTilt ||
      old.hueTiltRange != hueTiltRange ||
      old.saturationBoost != saturationBoost;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;
  @override
  double getDefaultRadiusMultiplier() => 1.0;
  @override
  double getOuterPadding() => spawnScale * 100 + circleRadius * tailFactor;
}

class PerimeterShapeExplodeOutAnimator implements EffectAnimator {
  // ─── parameter visual ───
  final int particleCount;
  final double circleRadius;
  final double tailFactor;
  final double explosionScale; // radius akhir relatif sisi terpendek
  final bool distributeEvenly;

  // ─── opsi warna ───
  final bool enableHueTilt;
  final double hueTiltRange;
  final double saturationBoost;

  PerimeterShapeExplodeOutAnimator({
    this.particleCount = 24,
    this.circleRadius = 6,
    this.tailFactor = 3,
    this.explosionScale = .7,
    this.distributeEvenly = true,
    //
    this.enableHueTilt = false,
    this.hueTiltRange = .35,
    this.saturationBoost = 1.1,
  });

  // batas fase
  static const double _dotSpawnEnd = .18; // 0‑.18  dot fade‑in
  static const double _tailGrowEnd = .40; // .18‑.40 tail tumbuh
  // sisanya (.40‑1) explode ke luar

  // ─── paint ───
  @override
  void paint(Canvas cv, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final c = center + positionOffset;
    final rnd = math.Random(42);
    final minSide = math.min(size.width, size.height);

    // Buat rect untuk perimeter
    final rect = Rect.fromCenter(
      center: c,
      width: size.width,
      height: size.height,
    );

    final explosionRadius = minSide * explosionScale * radiusMultiplier;

    for (int i = 0; i < particleCount; i++) {
      final delay = i * 0.02; // partikel muncul bergiliran
      final rawT = progress - delay;
      if (rawT <= 0) continue;

      // normalisasi supaya selesai saat progress==1
      final t = (rawT / (1 - delay)).clamp(0.0, 1.0);

      // Posisi di perimeter
      final perimeterRatio =
          distributeEvenly ? i / particleCount : rnd.nextDouble();
      final perimeterPos = _getPositionOnPerimeter(rect, perimeterRatio);

      // Arah - dari perimeter ke luar
      final dirToOut = perimeterPos - c;
      final distance = dirToOut.distance;
      final direction = distance > 0
          ? Offset(dirToOut.dx / distance, dirToOut.dy / distance)
          : Offset(0, 0);

      // ─── posisi radial ───
      double moveDist;
      if (t < _tailGrowEnd) {
        // tetap di perimeter
        moveDist = 0;
      } else {
        final explodeT = (t - _tailGrowEnd) / (1 - _tailGrowEnd); // 0‑1
        moveDist = explosionRadius * _easeOutBack(explodeT);
      }
      final pos = perimeterPos + direction * moveDist;

      // ─── tail length ───
      double tailLen;
      if (t < _dotSpawnEnd) {
        tailLen = 0;
      } else if (t < _tailGrowEnd) {
        final tailT = (t - _dotSpawnEnd) / (_tailGrowEnd - _dotSpawnEnd);
        tailLen = circleRadius *
            tailFactor *
            tailT *
            radiusMultiplier; // tumbuh 0→penuh
      } else {
        tailLen = circleRadius * tailFactor * radiusMultiplier;
      }

      // ─── skala & opasitas dot ───
      double scale;
      double opacity;
      if (t < _dotSpawnEnd) {
        scale = t / _dotSpawnEnd; // grow‑in
        opacity = scale;
      } else if (t > .85) {
        scale = 1 - (t - .85) / .15 * .3; // sedikit mengecil
        opacity = 1 - (t - .85) / .15; // fade‑out
      } else {
        scale = 1.0;
        opacity = 1.0;
      }

      // ─── warna ───
      Color col = color;
      if (enableHueTilt) {
        final hsl = HSLColor.fromColor(color);
        final shift = perimeterRatio * 360 * hueTiltRange;
        col = hsl
            .withHue((hsl.hue + shift) % 360)
            .withSaturation((hsl.saturation * saturationBoost).clamp(0, 1))
            .toColor();
      }
      col = col.withOpacity(opacity.toDouble());

      // ─── gambar dot ───
      final rad = circleRadius * radiusMultiplier * scale;
      cv.drawCircle(pos, rad, Paint()..color = col);

      // ─── gambar tail ───
      if (tailLen > 0) {
        // Tail mengarah kembali ke perimeter
        final tailDir = -direction;
        final tailStart = pos + tailDir * tailLen;

        cv.drawLine(
            tailStart,
            pos,
            Paint()
              ..color = col
              ..strokeWidth = rad * .8
              ..strokeCap = StrokeCap.round);
      }
    }
  }

  // Helper untuk mendapatkan posisi pada perimeter
  Offset _getPositionOnPerimeter(Rect rect, double ratio) {
    final totalPerimeter = 2 * (rect.width + rect.height);
    final distanceAlongPerimeter = totalPerimeter * ratio;

    // Sisi atas
    if (distanceAlongPerimeter < rect.width) {
      return Offset(rect.left + distanceAlongPerimeter, rect.top);
    }
    // Sisi kanan
    else if (distanceAlongPerimeter < rect.width + rect.height) {
      return Offset(
          rect.right, rect.top + (distanceAlongPerimeter - rect.width));
    }
    // Sisi bawah
    else if (distanceAlongPerimeter < 2 * rect.width + rect.height) {
      return Offset(
          rect.right - (distanceAlongPerimeter - rect.width - rect.height),
          rect.bottom);
    }
    // Sisi kiri
    else {
      return Offset(
          rect.left,
          rect.bottom -
              (distanceAlongPerimeter - 2 * rect.width - rect.height));
    }
  }

  // easing
  double _easeOutBack(double t) {
    const c1 = 1.70158;
    const c3 = c1 + 1;
    return 1 + c3 * math.pow(t - 1, 3) + c1 * math.pow(t - 1, 2);
  }

  // overrides
  @override
  bool shouldRepaint(EffectAnimator old) =>
      old is! PerimeterShapeExplodeOutAnimator ||
      old.particleCount != particleCount ||
      old.circleRadius != circleRadius ||
      old.tailFactor != tailFactor ||
      old.explosionScale != explosionScale ||
      old.enableHueTilt != enableHueTilt ||
      old.hueTiltRange != hueTiltRange ||
      old.saturationBoost != saturationBoost;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;
  @override
  double getDefaultRadiusMultiplier() => 1.0;
  @override
  double getOuterPadding() => circleRadius * tailFactor + explosionScale * 100;
}

class PerimeterCircleOrbitSequentialAnimator implements EffectAnimator {
  // ─── parameter visual ───
  final int particleCount; // jumlah titik
  final double circleRadius; // radius dasar titik
  final double orbitMargin; // jarak di luar widget
  final double rotations; // putaran tiap titik
  final double fadeExtra; // sedikit maju di fase fade
  final double glowSigma; // blur glow
  final double stagger; // jeda antar dot (0‑1, proporsi durasi)

  // ─── HSV shift ───
  final bool enableHueTilt;
  final double hueTiltRange;
  final double saturationBoost;

  PerimeterCircleOrbitSequentialAnimator({
    this.particleCount = 16,
    this.circleRadius = 6,
    this.orbitMargin = 14,
    this.rotations = 1.2,
    this.fadeExtra = 16,
    this.glowSigma = 4,
    this.stagger = .05, // 5 % durasi per dot
    //
    this.enableHueTilt = false,
    this.hueTiltRange = .35,
    this.saturationBoost = 1.1,
  });

  // fase (per‑dot, local progress 0‑1)
  static const double _launchEnd = .25;
  static const double _orbitEnd = .75;

  @override
  void paint(Canvas cv, Size size, double p, Offset center, Color baseColor,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final c = center + positionOffset;

    // Buat rect untuk perimeter
    final rect = Rect.fromCenter(
      center: c,
      width: size.width,
      height: size.height,
    );

    // Jarak orbit di luar perimeter
    final orbitR = orbitMargin * radiusMultiplier;

    for (int i = 0; i < particleCount; i++) {
      // setiap dot punya delay = i * stagger
      final delay = i * stagger;
      final rawT = p - delay;
      if (rawT <= 0) continue; // belum lahir

      // progress lokal 0‑1, distorsi supaya selesai tepat di p==1
      final t = (rawT / (1 - delay)).clamp(0.0, 1.0);

      // Posisi awal di perimeter
      final perimeterRatio = i / particleCount;
      final startPos = _getPositionOnPerimeter(rect, perimeterRatio);

      // Vektor dari pusat ke perimeter
      final dirToOut = startPos - c;
      final distance = dirToOut.distance;
      final direction = distance > 0
          ? Offset(dirToOut.dx / distance, dirToOut.dy / distance)
          : Offset(0, 0);

      // ── posisi ──
      Offset pos;
      if (t < _launchEnd) {
        // Fase peluncuran - dari perimeter ke orbit
        final launchT = t / _launchEnd;
        final moveDistance = _easeOutBack(launchT) * orbitR;
        pos = startPos + direction * moveDistance;
      } else if (t < _orbitEnd) {
        // Fase orbit - bergerak sekeliling perimeter
        final orbitT = (t - _launchEnd) / (_orbitEnd - _launchEnd);

        // Bergerak di sepanjang perimeter
        final orbitAngle =
            perimeterRatio * 2 * math.pi + 2 * math.pi * rotations * orbitT;
        final orbitPos =
            _getPositionOnPerimeter(rect, (orbitAngle / (2 * math.pi)) % 1.0);

        // Tambahkan jarak orbit
        final orbDirVector = orbitPos - c;
        final orbDistance = orbDirVector.distance;
        final orbDirection = orbDistance > 0
            ? Offset(
                orbDirVector.dx / orbDistance, orbDirVector.dy / orbDistance)
            : Offset(0, 0);

        pos = orbitPos + orbDirection * orbitR;
      } else {
        // Fase fade out - menjauh dari perimeter
        final fadeT = (t - _orbitEnd) / (1 - _orbitEnd);
        final endPerimeterRatio = (perimeterRatio + rotations) % 1.0;
        final endPos = _getPositionOnPerimeter(rect, endPerimeterRatio);

        final endDirVector = endPos - c;
        final endDistance = endDirVector.distance;
        final endDirection = endDistance > 0
            ? Offset(
                endDirVector.dx / endDistance, endDirVector.dy / endDistance)
            : Offset(0, 0);

        final moveDistance = orbitR + fadeExtra * fadeT;
        pos = endPos + endDirection * moveDistance;
      }

      // ── opacity & skala ──
      final opacity = t < .9 ? 1.0 : 1 - (t - .9) / .1;
      final scale = opacity;

      // ── warna (HSV shift opsional) ──
      Color col = baseColor;
      if (enableHueTilt) {
        final hsl = HSLColor.fromColor(baseColor);
        final shift = perimeterRatio * 360 * hueTiltRange;
        col = hsl
            .withHue((hsl.hue + shift) % 360)
            .withSaturation((hsl.saturation * saturationBoost).clamp(0, 1))
            .toColor();
      }
      col = col.withOpacity(opacity);

      final drawR = circleRadius * radiusMultiplier * scale;

      // glow lembut
      cv.drawCircle(
          pos,
          drawR * 1.6,
          Paint()
            ..color = col.withOpacity(.25)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowSigma));

      // lingkaran utama
      cv.drawCircle(pos, drawR, Paint()..color = col);
    }
  }

  // Helper untuk mendapatkan posisi pada perimeter
  Offset _getPositionOnPerimeter(Rect rect, double ratio) {
    final totalPerimeter = 2 * (rect.width + rect.height);
    final distanceAlongPerimeter = totalPerimeter * ratio;

    // Sisi atas
    if (distanceAlongPerimeter < rect.width) {
      return Offset(rect.left + distanceAlongPerimeter, rect.top);
    }
    // Sisi kanan
    else if (distanceAlongPerimeter < rect.width + rect.height) {
      return Offset(
          rect.right, rect.top + (distanceAlongPerimeter - rect.width));
    }
    // Sisi bawah
    else if (distanceAlongPerimeter < 2 * rect.width + rect.height) {
      return Offset(
          rect.right - (distanceAlongPerimeter - rect.width - rect.height),
          rect.bottom);
    }
    // Sisi kiri
    else {
      return Offset(
          rect.left,
          rect.bottom -
              (distanceAlongPerimeter - 2 * rect.width - rect.height));
    }
  }

  // ───── easing helper ─────
  double _easeOutBack(double t) {
    const c1 = 1.70158, c3 = c1 + 1;
    return 1 + c3 * math.pow(t - 1, 3) + c1 * math.pow(t - 1, 2);
  }

  // ───── overrides ─────
  @override
  bool shouldRepaint(EffectAnimator old) =>
      old is! PerimeterCircleOrbitSequentialAnimator ||
      old.particleCount != particleCount ||
      old.circleRadius != circleRadius ||
      old.orbitMargin != orbitMargin ||
      old.rotations != rotations ||
      old.fadeExtra != fadeExtra ||
      old.glowSigma != glowSigma ||
      old.stagger != stagger ||
      old.enableHueTilt != enableHueTilt ||
      old.hueTiltRange != hueTiltRange ||
      old.saturationBoost != saturationBoost;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  @override
  double getDefaultRadiusMultiplier() => 1.0;

  @override
  double getOuterPadding() => orbitMargin + fadeExtra + circleRadius;
}

class PerimeterRadialBurstAnimator implements EffectAnimator {
  final int particleCount;
  final double particleRadius;
  final double tailFactor;
  final double maxRadiusScale;
  final bool distributeEvenly;

  // Opsi warna
  final bool enableColorShift;
  final double colorShiftRange;
  final double saturationBoost;

  // Fase animasi
  static const double _growPhaseEnd = 0.2; // Fase partikel membesar
  static const double _expandPhaseEnd = 0.8; // Fase partikel bergerak keluar

  PerimeterRadialBurstAnimator({
    this.particleCount = 30,
    this.particleRadius = 5,
    this.tailFactor = 2.5,
    this.maxRadiusScale = 0.6,
    this.distributeEvenly = true,
    this.enableColorShift = false,
    this.colorShiftRange = 0.4,
    this.saturationBoost = 1.2,
  });

  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1, Offset positionOffset = Offset.zero}) {
    final c = center + positionOffset;
    final rnd = math.Random(42); // Seed tetap untuk konsistensi

    // Buat rect untuk perimeter
    final rect = Rect.fromCenter(
      center: c,
      width: size.width,
      height: size.height,
    );

    // Perkirakan jarak maksimum partikel bergerak
    final minSide = math.min(size.width, size.height);
    final maxDistance = minSide * maxRadiusScale * radiusMultiplier;

    // Gambar setiap partikel
    for (var i = 0; i < particleCount; i++) {
      final delay = i * 0.03; // Delay bertahap
      final rawT = progress - delay;
      if (rawT <= 0) continue;

      final t = (rawT / (1 - delay)).clamp(0.0, 1.0);

      // Posisi awal di perimeter
      final perimeterRatio =
          distributeEvenly ? i / particleCount : rnd.nextDouble();
      final startPos = _getPositionOnPerimeter(rect, perimeterRatio);

      // Hitung arah gerakan - keluar dari pusat widget
      final directionVector = startPos - c;
      final distance = directionVector.distance;

      // Normalisasi vektor arah
      final normalizedDx = distance > 0 ? directionVector.dx / distance : 0;
      final normalizedDy = distance > 0 ? directionVector.dy / distance : 0;
      final direction =
          Offset(normalizedDx.toDouble(), normalizedDy.toDouble());

      // Hitung jarak gerakan berdasarkan fase animasi
      double moveDist;
      if (t < _growPhaseEnd) {
        // Fase awal - mulai dari perimeter dengan sedikit gerakan
        final tt = t / _growPhaseEnd;
        moveDist = maxDistance * _easeOutExpo(tt) * 0.1; // Sedikit gerakan awal
      } else if (t < _expandPhaseEnd) {
        // Fase ekspansi - bergerak keluar dari 10% hingga 100%
        final tt = (t - _growPhaseEnd) / (_expandPhaseEnd - _growPhaseEnd);
        moveDist = maxDistance * (0.1 + (0.9 * _easeOutQuad(tt)));
      } else {
        // Fase akhir - tetap pada posisi maksimum
        moveDist = maxDistance;
      }

      // Posisi akhir partikel
      final pos = startPos + (direction * moveDist);

      // Skala dan opasitas
      double scale, opacity;
      if (t < _growPhaseEnd) {
        // Membesar cepat di awal
        scale = _easeOutExpo(t / _growPhaseEnd);
        opacity = scale;
      } else if (t > _expandPhaseEnd) {
        // Mengecil dan memudar di akhir
        final tt = (t - _expandPhaseEnd) / (1 - _expandPhaseEnd);
        scale = 1.0 - _easeInQuad(tt);
        opacity = scale;
      } else {
        // Ukuran penuh pada fase ekspansi
        scale = 1.0;
        opacity = 1.0;
      }

      // Warna dengan color shift optional
      Color particleColor = color;
      if (enableColorShift) {
        final hsl = HSLColor.fromColor(color);
        final shift = perimeterRatio * 360 * colorShiftRange;
        particleColor = hsl
            .withHue((hsl.hue + shift) % 360)
            .withSaturation((hsl.saturation * saturationBoost).clamp(0.0, 1.0))
            .toColor();
      }
      particleColor = particleColor.withOpacity(opacity);

      // Gambar partikel dan ekornya
      final rad = particleRadius * radiusMultiplier * scale;
      canvas.drawCircle(pos, rad, Paint()..color = particleColor);

      // Gambar ekor partikel (mengarah ke perimeter/asal)
      if (tailFactor > 0) {
        // Ekor mengarah ke arah yang berlawanan (balik ke perimeter)
        final tailEnd = pos - (direction * (rad * tailFactor));

        canvas.drawLine(
            pos,
            tailEnd,
            Paint()
              ..color = particleColor
              ..strokeWidth = rad * 0.7
              ..strokeCap = StrokeCap.round);
      }
    }
  }

  // Helper untuk mendapatkan posisi pada perimeter
  Offset _getPositionOnPerimeter(Rect rect, double ratio) {
    final totalPerimeter = 2 * (rect.width + rect.height);
    final distanceAlongPerimeter = totalPerimeter * ratio;

    // Sisi atas
    if (distanceAlongPerimeter < rect.width) {
      return Offset(rect.left + distanceAlongPerimeter, rect.top);
    }
    // Sisi kanan
    else if (distanceAlongPerimeter < rect.width + rect.height) {
      return Offset(
          rect.right, rect.top + (distanceAlongPerimeter - rect.width));
    }
    // Sisi bawah
    else if (distanceAlongPerimeter < 2 * rect.width + rect.height) {
      return Offset(
          rect.right - (distanceAlongPerimeter - rect.width - rect.height),
          rect.bottom);
    }
    // Sisi kiri
    else {
      return Offset(
          rect.left,
          rect.bottom -
              (distanceAlongPerimeter - 2 * rect.width - rect.height));
    }
  }

  // Fungsi easing
  double _easeOutExpo(double t) {
    return t == 1.0 ? 1.0 : 1 - math.pow(2, -10 * t).toDouble();
  }

  double _easeOutQuad(double t) => 1 - (1 - t) * (1 - t);

  double _easeInQuad(double t) => t * t;

  @override
  bool shouldRepaint(EffectAnimator old) =>
      old is! PerimeterRadialBurstAnimator ||
      old.particleCount != particleCount ||
      old.particleRadius != particleRadius ||
      old.tailFactor != tailFactor ||
      old.maxRadiusScale != maxRadiusScale ||
      old.distributeEvenly != distributeEvenly ||
      old.enableColorShift != enableColorShift ||
      old.colorShiftRange != colorShiftRange ||
      old.saturationBoost != saturationBoost;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  @override
  double getDefaultRadiusMultiplier() => 1;

  @override
  double getOuterPadding() =>
      maxRadiusScale * 100 + particleRadius * tailFactor;
}

// 1. PULSAR: Partikel tetap di perimeter dan berdenyut keluar-masuk
class PerimeterCirclePulsarAnimator implements EffectAnimator {
  // ───── konfigurasi ─────
  final int particleCount;
  final bool enableHueTilt;
  final double hueTiltRange;
  final double saturationBoost;
  final bool enableBloom;
  final double bloomWidth;

  // Konfigurasi khusus Pulsar
  final double pulseMinRadius;
  final double pulseMaxRadius;
  final double pulseSpeed;

  final List<_Particle> _particles = [];
  final Random _random = Random();

  PerimeterCirclePulsarAnimator({
    this.particleCount = 32,
    this.enableHueTilt = true,
    this.hueTiltRange = .45,
    this.saturationBoost = 1.2,
    this.enableBloom = true,
    this.bloomWidth = 3.0,
    this.pulseMinRadius = 2.0,
    this.pulseMaxRadius = 6.0,
    this.pulseSpeed = 2.0,
  });

  void _initParticles() {
    if (_particles.isNotEmpty) return;

    for (int i = 0; i < particleCount; i++) {
      _particles.add(_Particle(
        angle: 0, // Tidak digunakan untuk animasi ini
        maxDistance: 0, // Tidak digunakan untuk animasi ini
        baseSize: _random.nextDouble() * (pulseMaxRadius - pulseMinRadius) +
            pulseMinRadius,
        pulseRate: _random.nextDouble() * 1.5 * pulseSpeed + pulseSpeed,
      ));
    }
  }

  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color baseColor,
      {double radiusMultiplier = 1, Offset positionOffset = Offset.zero}) {
    _initParticles();

    final c = center + positionOffset;

    final rect = Rect.fromCenter(
      center: c,
      width: size.width,
      height: size.height,
    );

    // Bloom glow pada perimeter
    if (enableBloom) {
      final bloomOpacity = 0.3 + 0.2 * math.sin(progress * math.pi * 2);

      final bloomPath = Path();
      bloomPath.addRect(rect.inflate(bloomWidth * radiusMultiplier));

      canvas.drawPath(
          bloomPath,
          Paint()
            ..color = baseColor.withOpacity(bloomOpacity)
            ..style = PaintingStyle.stroke
            ..strokeWidth = bloomWidth * radiusMultiplier
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
    }

    // Paint partikel pada perimeter
    for (int i = 0; i < _particles.length; i++) {
      final p = _particles[i];
      final perimeterRatio = i / particleCount;

      // Posisi partikel di perimeter
      final pos = _getPositionOnPerimeter(rect, perimeterRatio);

      // Efek pulsasi dengan fase yang bervariasi antar partikel
      final phaseShift = perimeterRatio * 2 * math.pi;
      final pulseValue = 0.5 +
          0.5 * math.sin((progress * math.pi * 2 * p.pulseRate) + phaseShift);

      // Ukuran partikel
      final sizePx =
          (pulseMinRadius + (pulseMaxRadius - pulseMinRadius) * pulseValue) *
              radiusMultiplier;

      // Warna dengan efek hue shift sesuai posisi di perimeter
      Color col = baseColor;
      if (enableHueTilt) {
        final hsl = HSLColor.fromColor(baseColor);
        final shift = perimeterRatio * 360 * hueTiltRange;
        col = hsl
            .withHue((hsl.hue + shift) % 360)
            .withSaturation((hsl.saturation * saturationBoost).clamp(0, 1))
            .toColor();
      }

      // Opacity yang juga berpulsa dengan fase berbeda
      final opacityPhase =
          phaseShift + math.pi / 3; // offset agar berbeda dari pulsasi ukuran
      final opacityValue = 0.6 +
          0.4 *
              math.sin(
                  (progress * math.pi * 2 * p.pulseRate * 0.7) + opacityPhase);
      col = col.withOpacity(opacityValue);

      // Efek decay blur bertingkat
      // Blur terluar
      canvas.drawCircle(
          pos,
          sizePx * 4.0,
          Paint()
            ..color = col.withOpacity(0.1)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12));

      // Blur menengah
      canvas.drawCircle(
          pos,
          sizePx * 3.0,
          Paint()
            ..color = col.withOpacity(0.25)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));

      // Blur dekat
      canvas.drawCircle(
          pos,
          sizePx * 2.0,
          Paint()
            ..color = col.withOpacity(0.4)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));

      // Inti partikel
      canvas.drawCircle(pos, sizePx, Paint()..color = col);
    }
  }

  Offset _getPositionOnPerimeter(Rect rect, double ratio) {
    final totalPerimeter = 2 * (rect.width + rect.height);
    final distanceAlongPerimeter = totalPerimeter * ratio;

    // Sisi atas
    if (distanceAlongPerimeter < rect.width) {
      return Offset(rect.left + distanceAlongPerimeter, rect.top);
    }
    // Sisi kanan
    else if (distanceAlongPerimeter < rect.width + rect.height) {
      return Offset(
          rect.right, rect.top + (distanceAlongPerimeter - rect.width));
    }
    // Sisi bawah
    else if (distanceAlongPerimeter < 2 * rect.width + rect.height) {
      return Offset(
          rect.right - (distanceAlongPerimeter - rect.width - rect.height),
          rect.bottom);
    }
    // Sisi kiri
    else {
      return Offset(
          rect.left,
          rect.bottom -
              (distanceAlongPerimeter - 2 * rect.width - rect.height));
    }
  }

  double _easeOutQuad(double t) => t * (2 - t);
  double _easeInQuad(double t) => t * t;

  @override
  bool shouldRepaint(EffectAnimator old) =>
      old is! PerimeterCirclePulsarAnimator ||
      old.particleCount != particleCount ||
      old.enableHueTilt != enableHueTilt ||
      old.hueTiltRange != hueTiltRange ||
      old.saturationBoost != saturationBoost ||
      old.enableBloom != enableBloom ||
      old.bloomWidth != bloomWidth ||
      old.pulseMinRadius != pulseMinRadius ||
      old.pulseMaxRadius != pulseMaxRadius ||
      old.pulseSpeed != pulseSpeed;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;
  @override
  double getDefaultRadiusMultiplier() => 1;
  @override
  double getOuterPadding() => 40;
}

// 2. ORBIT: Partikel bergerak mengorbit di sekitar perimeter
class PerimeterCircleOrbitAnimator implements EffectAnimator {
  // ───── konfigurasi ─────
  final int particleCount;
  final bool enableHueTilt;
  final double hueTiltRange;
  final double saturationBoost;
  final bool enableTrails;
  final double orbitDistance;
  final double orbitSpeed;
  final bool reverseDirection;

  final List<_Particle> _particles = [];
  final Random _random = Random();

  PerimeterCircleOrbitAnimator({
    this.particleCount = 28,
    this.enableHueTilt = true,
    this.hueTiltRange = .3,
    this.saturationBoost = 1.15,
    this.enableTrails = true,
    this.orbitDistance = 15.0,
    this.orbitSpeed = 0.8,
    this.reverseDirection = false,
  });

  void _initParticles() {
    if (_particles.isNotEmpty) return;

    for (int i = 0; i < particleCount; i++) {
      _particles.add(_Particle(
        angle: _random.nextDouble() * math.pi * 2,
        maxDistance: _random.nextDouble() * 4 + orbitDistance,
        baseSize: _random.nextDouble() * 3 + 2,
        pulseRate: _random.nextDouble() * 0.5 + 0.8,
      ));
    }
  }

  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color baseColor,
      {double radiusMultiplier = 1, Offset positionOffset = Offset.zero}) {
    _initParticles();

    final c = center + positionOffset;

    final rect = Rect.fromCenter(
      center: c,
      width: size.width,
      height: size.height,
    );

    // Menghitung jarak orbit berdasarkan progress
    final orbitProgress = progress * math.pi * 2 * orbitSpeed;

    // Paint partikel yang bergerak mengorbit
    for (int i = 0; i < _particles.length; i++) {
      final p = _particles[i];
      final basePerimeterRatio = i / particleCount;

      // Posisi dasar di perimeter
      final basePos = _getPositionOnPerimeter(rect, basePerimeterRatio);

      // Menghitung arah orbit
      final direction = reverseDirection ? -1.0 : 1.0;

      // Menghitung offset orbit berdasarkan progress
      final orbitAngle = p.angle + orbitProgress * direction;
      final orbitOffset = Offset(
          math.cos(orbitAngle) * p.maxDistance * radiusMultiplier,
          math.sin(orbitAngle) * p.maxDistance * radiusMultiplier);

      // Posisi akhir
      final pos = basePos + orbitOffset;

      // Pulsasi ukuran
      final pulse = 0.8 + 0.2 * math.sin(progress * math.pi * 2 * p.pulseRate);
      final sizePx = p.baseSize * pulse * radiusMultiplier;

      // Warna dengan efek hue shift
      Color col = baseColor;
      if (enableHueTilt) {
        final hsl = HSLColor.fromColor(baseColor);
        final shift = basePerimeterRatio * 360 * hueTiltRange;
        col = hsl
            .withHue((hsl.hue + shift) % 360)
            .withSaturation((hsl.saturation * saturationBoost).clamp(0, 1))
            .toColor();
      }

      // Gambar trails jika diaktifkan
      if (enableTrails) {
        // Menggambar beberapa titik "bayangan" kecil di belakang
        for (int t = 1; t <= 5; t++) {
          final trailRatio = t / 5;
          final trailOpacity = 0.3 * (1 - trailRatio);
          final trailSize = sizePx * (1 - 0.4 * trailRatio);

          // Menghitung posisi trail
          final trailAngle =
              p.angle + (orbitProgress - trailRatio * 0.5) * direction;
          final trailOffset = Offset(
              math.cos(trailAngle) * p.maxDistance * radiusMultiplier,
              math.sin(trailAngle) * p.maxDistance * radiusMultiplier);
          final trailPos = basePos + trailOffset;

          // Menggambar trail
          canvas.drawCircle(trailPos, trailSize,
              Paint()..color = col.withOpacity(trailOpacity));
        }
      }

      // Efek decay blur bertingkat
      canvas.drawCircle(
          pos,
          sizePx * 3.0,
          Paint()
            ..color = col.withOpacity(0.15)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));

      canvas.drawCircle(
          pos,
          sizePx * 2.0,
          Paint()
            ..color = col.withOpacity(0.3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));

      canvas.drawCircle(
          pos,
          sizePx * 1.5,
          Paint()
            ..color = col.withOpacity(0.5)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2));

      // Inti partikel
      canvas.drawCircle(pos, sizePx, Paint()..color = col);
    }
  }

  Offset _getPositionOnPerimeter(Rect rect, double ratio) {
    final totalPerimeter = 2 * (rect.width + rect.height);
    final distanceAlongPerimeter = totalPerimeter * ratio;

    // Sisi atas
    if (distanceAlongPerimeter < rect.width) {
      return Offset(rect.left + distanceAlongPerimeter, rect.top);
    }
    // Sisi kanan
    else if (distanceAlongPerimeter < rect.width + rect.height) {
      return Offset(
          rect.right, rect.top + (distanceAlongPerimeter - rect.width));
    }
    // Sisi bawah
    else if (distanceAlongPerimeter < 2 * rect.width + rect.height) {
      return Offset(
          rect.right - (distanceAlongPerimeter - rect.width - rect.height),
          rect.bottom);
    }
    // Sisi kiri
    else {
      return Offset(
          rect.left,
          rect.bottom -
              (distanceAlongPerimeter - 2 * rect.width - rect.height));
    }
  }

  @override
  bool shouldRepaint(EffectAnimator old) =>
      old is! PerimeterCircleOrbitAnimator ||
      old.particleCount != particleCount ||
      old.enableHueTilt != enableHueTilt ||
      old.hueTiltRange != hueTiltRange ||
      old.saturationBoost != saturationBoost ||
      old.enableTrails != enableTrails ||
      old.orbitDistance != orbitDistance ||
      old.orbitSpeed != orbitSpeed ||
      old.reverseDirection != reverseDirection;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;
  @override
  double getDefaultRadiusMultiplier() => 1;
  @override
  double getOuterPadding() => 40;
}

// 3. WAVE: Partikel bergerak dalam pola gelombang dari perimeter
class PerimeterCircleWaveAnimator implements EffectAnimator {
  // ───── konfigurasi ─────
  final int particleCount;
  final bool enableHueTilt;
  final double hueTiltRange;
  final double saturationBoost;
  final double waveAmplitude;
  final double waveFrequency;
  final bool enableGradientSize;

  final List<_Particle> _particles = [];
  final Random _random = Random();

  PerimeterCircleWaveAnimator({
    this.particleCount = 36,
    this.enableHueTilt = true,
    this.hueTiltRange = .5,
    this.saturationBoost = 1.2,
    this.waveAmplitude = 20.0,
    this.waveFrequency = 2.0,
    this.enableGradientSize = true,
  });

  void _initParticles() {
    if (_particles.isNotEmpty) return;

    for (int i = 0; i < particleCount; i++) {
      _particles.add(_Particle(
        angle: 0,
        maxDistance: _random.nextDouble() * 0.3 * waveAmplitude + waveAmplitude,
        baseSize: _random.nextDouble() * 3 + 2,
        pulseRate: _random.nextDouble() * 0.2 + 0.9,
      ));
    }
  }

  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color baseColor,
      {double radiusMultiplier = 1, Offset positionOffset = Offset.zero}) {
    _initParticles();

    final c = center + positionOffset;

    final rect = Rect.fromCenter(
      center: c,
      width: size.width,
      height: size.height,
    );

    // Efek gelombang progresif
    final waveProgress = progress * math.pi * 2 * waveFrequency;

    // Paint partikel bergelombang
    for (int i = 0; i < _particles.length; i++) {
      final p = _particles[i];
      final perimeterRatio = i / particleCount;

      // Posisi dasar di perimeter
      final basePos = _getPositionOnPerimeter(rect, perimeterRatio);

      // Menghitung arah dari pusat ke perimeter
      final dirVector = basePos - c;
      final distance = dirVector.distance;
      final direction = distance > 0
          ? Offset(dirVector.dx / distance, dirVector.dy / distance)
          : Offset(0, 0);

      // Menghitung amplitudo gelombang dengan fase berdasarkan posisi
      final phaseShift = perimeterRatio * math.pi * 2;
      final waveMultiplier = math.sin(waveProgress + phaseShift);

      // Jarak dari perimeter
      final waveDistance =
          p.maxDistance * waveMultiplier.abs() * radiusMultiplier;

      // Posisi akhir
      final pos = basePos + direction * waveDistance;

      // Ukuran yang bervariasi berdasarkan posisi jika diaktifkan
      double sizeMultiplier = 1.0;
      if (enableGradientSize) {
        // Ukuran berbeda tergantung posisi di perimeter
        sizeMultiplier =
            0.7 + 0.6 * (math.sin(perimeterRatio * math.pi * 4) * 0.5 + 0.5);
      }

      // Pulsasi ukuran
      final pulse = 0.7 +
          0.3 * math.sin(progress * math.pi * 2 * p.pulseRate + phaseShift);
      final sizePx = p.baseSize * pulse * sizeMultiplier * radiusMultiplier;

      // Warna dengan efek hue shift dan brightness berdasarkan gelombang
      Color col = baseColor;
      if (enableHueTilt) {
        final hsl = HSLColor.fromColor(baseColor);
        final shift = perimeterRatio * 360 * hueTiltRange;

        // Brightness berdasarkan posisi gelombang
        final brightnessShift = 0.1 * waveMultiplier.abs();

        col = hsl
            .withHue((hsl.hue + shift) % 360)
            .withSaturation((hsl.saturation * saturationBoost).clamp(0, 1))
            .withLightness((hsl.lightness + brightnessShift).clamp(0, 1))
            .toColor();
      }

      // Opacity berdasarkan posisi gelombang
      final opacity = 0.7 + 0.3 * waveMultiplier.abs();
      col = col.withOpacity(opacity);

      // Efek decay blur bertingkat
      canvas.drawCircle(
          pos,
          sizePx * 3.5,
          Paint()
            ..color = col.withOpacity(0.15)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));

      canvas.drawCircle(
          pos,
          sizePx * 2.5,
          Paint()
            ..color = col.withOpacity(0.25)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));

      canvas.drawCircle(
          pos,
          sizePx * 1.7,
          Paint()
            ..color = col.withOpacity(0.4)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2));

      // Inti partikel
      canvas.drawCircle(pos, sizePx, Paint()..color = col);
    }
  }

  Offset _getPositionOnPerimeter(Rect rect, double ratio) {
    final totalPerimeter = 2 * (rect.width + rect.height);
    final distanceAlongPerimeter = totalPerimeter * ratio;

    // Sisi atas
    if (distanceAlongPerimeter < rect.width) {
      return Offset(rect.left + distanceAlongPerimeter, rect.top);
    }
    // Sisi kanan
    else if (distanceAlongPerimeter < rect.width + rect.height) {
      return Offset(
          rect.right, rect.top + (distanceAlongPerimeter - rect.width));
    }
    // Sisi bawah
    else if (distanceAlongPerimeter < 2 * rect.width + rect.height) {
      return Offset(
          rect.right - (distanceAlongPerimeter - rect.width - rect.height),
          rect.bottom);
    }
    // Sisi kiri
    else {
      return Offset(
          rect.left,
          rect.bottom -
              (distanceAlongPerimeter - 2 * rect.width - rect.height));
    }
  }

  @override
  bool shouldRepaint(EffectAnimator old) =>
      old is! PerimeterCircleWaveAnimator ||
      old.particleCount != particleCount ||
      old.enableHueTilt != enableHueTilt ||
      old.hueTiltRange != hueTiltRange ||
      old.saturationBoost != saturationBoost ||
      old.waveAmplitude != waveAmplitude ||
      old.waveFrequency != waveFrequency ||
      old.enableGradientSize != enableGradientSize;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;
  @override
  double getDefaultRadiusMultiplier() => 1;
  @override
  double getOuterPadding() => 40;
}

// 4. TELEPORT: Partikel teleport antar posisi di perimeter
class PerimeterCircleTeleportAnimator implements EffectAnimator {
  // ───── konfigurasi ─────
  final int particleCount;
  final bool enableHueTilt;
  final double hueTiltRange;
  final double saturationBoost;
  final double teleportFrequency;
  final double fadeTime;
  final bool enableSizeJitter;

  final List<_TeleportParticle> _particles = [];
  final Random _random = Random();

  PerimeterCircleTeleportAnimator({
    this.particleCount = 24,
    this.enableHueTilt = true,
    this.hueTiltRange = .4,
    this.saturationBoost = 1.1,
    this.teleportFrequency = 0.8,
    this.fadeTime = 0.2,
    this.enableSizeJitter = true,
  });

  void _initParticles() {
    if (_particles.isNotEmpty) return;

    for (int i = 0; i < particleCount; i++) {
      final currentPos = _random.nextDouble();
      final targetPos = _random.nextDouble();

      _particles.add(_TeleportParticle(
        currentPosition: currentPos,
        targetPosition: targetPos,
        teleportTime: _random.nextDouble(),
        baseSize: _random.nextDouble() * 3 + 2,
        sizePulseRate: _random.nextDouble() * 0.5 + 0.8,
      ));
    }
  }

  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color baseColor,
      {double radiusMultiplier = 1, Offset positionOffset = Offset.zero}) {
    _initParticles();

    final c = center + positionOffset;

    final rect = Rect.fromCenter(
      center: c,
      width: size.width,
      height: size.height,
    );

    // Progress untuk teleport (berbasis waktu)
    final teleportCycleProgress = progress * teleportFrequency;

    // Update dan paint partikel yang teleport
    for (int i = 0; i < _particles.length; i++) {
      final p = _particles[i];

      // Cek apakah waktunya teleport
      if ((teleportCycleProgress - p.teleportTime) % 1 < fadeTime) {
        // Dalam mode teleport/perpindahan
        final teleportProgress =
            ((teleportCycleProgress - p.teleportTime) % 1) / fadeTime;

        // Interpolasi posisi
        final currentPerimeterRatio = p.currentPosition;
        final targetPerimeterRatio = p.targetPosition;

        // Opacity selama teleport (naik di target, turun di asal)
        final fadeOutOpacity = 1 - teleportProgress;
        final fadeInOpacity = teleportProgress;

        // Posisi asal dan target
        final currentPos = _getPositionOnPerimeter(rect, currentPerimeterRatio);
        final targetPos = _getPositionOnPerimeter(rect, targetPerimeterRatio);

        // Pulsasi ukuran
        final sizePulse =
            0.8 + 0.2 * math.sin(progress * math.pi * 2 * p.sizePulseRate);
        final currentSizePx = p.baseSize * sizePulse * radiusMultiplier;

        // Target ukuran mungkin berbeda jika size jitter diaktifkan
        final targetSizePx = enableSizeJitter
            ? p.baseSize * (0.8 + _random.nextDouble() * 0.4) * radiusMultiplier
            : currentSizePx;

        // Warna dengan efek hue
        Color currentCol = baseColor;
        Color targetCol = baseColor;

        if (enableHueTilt) {
          final hsl = HSLColor.fromColor(baseColor);

          // Hue shift untuk posisi asal
          final currentShift = currentPerimeterRatio * 360 * hueTiltRange;
          currentCol = hsl
              .withHue((hsl.hue + currentShift) % 360)
              .withSaturation((hsl.saturation * saturationBoost).clamp(0, 1))
              .toColor()
              .withOpacity(fadeOutOpacity);

          // Hue shift untuk posisi target
          final targetShift = targetPerimeterRatio * 360 * hueTiltRange;
          targetCol = hsl
              .withHue((hsl.hue + targetShift) % 360)
              .withSaturation((hsl.saturation * saturationBoost).clamp(0, 1))
              .toColor()
              .withOpacity(fadeInOpacity);
        } else {
          currentCol = currentCol.withOpacity(fadeOutOpacity);
          targetCol = targetCol.withOpacity(fadeInOpacity);
        }

        // Gambar partikel yang menghilang di posisi asal
        if (fadeOutOpacity > 0) {
          // Efek decay blur
          canvas.drawCircle(
              currentPos,
              currentSizePx * 3.0,
              Paint()
                ..color = currentCol.withOpacity(currentCol.opacity * 0.2)
                ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));

          canvas.drawCircle(
              currentPos,
              currentSizePx * 2.0,
              Paint()
                ..color = currentCol.withOpacity(currentCol.opacity * 0.4)
                ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));

          // Inti partikel
          canvas.drawCircle(
              currentPos, currentSizePx, Paint()..color = currentCol);
        }

        // Gambar partikel yang muncul di posisi target
        if (fadeInOpacity > 0) {
          // Efek decay blur
          canvas.drawCircle(
              targetPos,
              targetSizePx * 3.0,
              Paint()
                ..color = targetCol.withOpacity(targetCol.opacity * 0.2)
                ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));

          canvas.drawCircle(
              targetPos,
              targetSizePx * 2.0,
              Paint()
                ..color = targetCol.withOpacity(targetCol.opacity * 0.4)
                ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));

          // Inti partikel
          canvas.drawCircle(
              targetPos, targetSizePx, Paint()..color = targetCol);
        }

        // Update particle dengan posisi baru setelah selesai teleport
        if (teleportProgress >= 1.0) {
          p.currentPosition = p.targetPosition;
          p.targetPosition = _random.nextDouble();
          p.teleportTime =
              (teleportCycleProgress + _random.nextDouble() * 0.5 + 0.2) % 1;
        }
      } else {
        // Mode normal (tidak teleport)
        final perimeterRatio = p.currentPosition;
        final pos = _getPositionOnPerimeter(rect, perimeterRatio);

        // Pulsasi ukuran
        final sizePulse =
            0.8 + 0.2 * math.sin(progress * math.pi * 2 * p.sizePulseRate);
        final sizePx = p.baseSize * sizePulse * radiusMultiplier;

        // Warna
        Color col = baseColor;
        if (enableHueTilt) {
          final hsl = HSLColor.fromColor(baseColor);
          final shift = perimeterRatio * 360 * hueTiltRange;
          col = hsl
              .withHue((hsl.hue + shift) % 360)
              .withSaturation((hsl.saturation * saturationBoost).clamp(0, 1))
              .toColor();
        }

        // Efek decay blur
        canvas.drawCircle(
            pos,
            sizePx * 3.0,
            Paint()
              ..color = col.withOpacity(0.15)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));

        canvas.drawCircle(
            pos,
            sizePx * 2.0,
            Paint()
              ..color = col.withOpacity(0.3)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));

        // Inti partikel
        canvas.drawCircle(pos, sizePx, Paint()..color = col);
      }
    }
  }

  Offset _getPositionOnPerimeter(Rect rect, double ratio) {
    final totalPerimeter = 2 * (rect.width + rect.height);
    final distanceAlongPerimeter = totalPerimeter * ratio;

    // Sisi atas
    if (distanceAlongPerimeter < rect.width) {
      return Offset(rect.left + distanceAlongPerimeter, rect.top);
    }
    // Sisi kanan
    else if (distanceAlongPerimeter < rect.width + rect.height) {
      return Offset(
          rect.right, rect.top + (distanceAlongPerimeter - rect.width));
    }
    // Sisi bawah
    else if (distanceAlongPerimeter < 2 * rect.width + rect.height) {
      return Offset(
          rect.right - (distanceAlongPerimeter - rect.width - rect.height),
          rect.bottom);
    }
    // Sisi kiri
    else {
      return Offset(
          rect.left,
          rect.bottom -
              (distanceAlongPerimeter - 2 * rect.width - rect.height));
    }
  }

  @override
  bool shouldRepaint(EffectAnimator old) =>
      old is! PerimeterCircleTeleportAnimator ||
      old.particleCount != particleCount ||
      old.enableHueTilt != enableHueTilt ||
      old.hueTiltRange != hueTiltRange ||
      old.saturationBoost != saturationBoost ||
      old.teleportFrequency != teleportFrequency ||
      old.fadeTime != fadeTime ||
      old.enableSizeJitter != enableSizeJitter;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;
  @override
  double getDefaultRadiusMultiplier() => 1;
  @override
  double getOuterPadding() => 40;
}

// 6. RIPPLE: Efek gelombang riak dari perimeter
class PerimeterCircleRippleAnimator implements EffectAnimator {
  // ───── konfigurasi ─────
  final int rippleCount;
  final bool enableHueTilt;
  final double hueTiltRange;
  final double saturationBoost;
  final int particlesPerRipple;
  final double rippleSpeed;
  final double rippleWidth;

  final List<_Ripple> _ripples = [];
  final Random _random = Random();

  PerimeterCircleRippleAnimator({
    this.rippleCount = 3,
    this.enableHueTilt = true,
    this.hueTiltRange = .3,
    this.saturationBoost = 1.1,
    this.particlesPerRipple = 36,
    this.rippleSpeed = 1.2,
    this.rippleWidth = 10.0,
  });

  void _initRipples() {
    if (_ripples.isNotEmpty) return;

    // Jarak antar ripple
    final interval = 1.0 / rippleCount;

    for (int i = 0; i < rippleCount; i++) {
      final startTime = i * interval;

      // Partikel-partikel dalam ripple
      final particles = <_Particle>[];
      for (int j = 0; j < particlesPerRipple; j++) {
        final perimeterRatio = j / particlesPerRipple;
        final sizeVariation = _random.nextDouble() * 0.4 + 0.8;

        particles.add(_Particle(
          angle: 0, // Tidak digunakan untuk ripple
          maxDistance: 25 + _random.nextDouble() * 10,
          baseSize: 2.0 * sizeVariation,
          pulseRate: 0, // Tidak digunakan untuk ripple
        ));
      }

      _ripples.add(_Ripple(
        startTime: startTime,
        particles: particles,
      ));
    }
  }

  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color baseColor,
      {double radiusMultiplier = 1, Offset positionOffset = Offset.zero}) {
    _initRipples();

    final c = center + positionOffset;

    final rect = Rect.fromCenter(
      center: c,
      width: size.width,
      height: size.height,
    );

    // Paint ripples
    for (final ripple in _ripples) {
      // Adjusted progress for each ripple based on start time
      final rippleTime = (progress - ripple.startTime) * rippleSpeed % 1.0;

      // Only draw during the active period
      if (rippleTime >= 0 && rippleTime <= 1.0) {
        // Distanse from perimeter (0 to max and back to 0)
        final distanceProgress = rippleTime < 0.5
            ? _easeOutQuad(rippleTime * 2)
            : _easeInQuad(2 - rippleTime * 2);

        // Opacity based on ripple time
        final opacity = rippleTime < 0.1
            ? rippleTime / 0.1 // Fade in
            : rippleTime > 0.9
                ? (1 - (rippleTime - 0.9) / 0.1) // Fade out
                : 1.0; // Full opacity

        // Draw all particles in the ripple
        for (int i = 0; i < ripple.particles.length; i++) {
          final p = ripple.particles[i];
          final perimeterRatio = i / ripple.particles.length;

          // Position on perimeter
          final perimeterPos = _getPositionOnPerimeter(rect, perimeterRatio);

          // Direction from center to perimeter
          final dirVector = perimeterPos - c;
          final distance = dirVector.distance;
          final direction = distance > 0
              ? Offset(dirVector.dx / distance, dirVector.dy / distance)
              : Offset(0, 0);

          // Distance from perimeter
          final rippleDist =
              p.maxDistance * distanceProgress * radiusMultiplier;

          // Final position
          final pos = perimeterPos + direction * rippleDist;

          // Size with slight variation per particle
          final sizePx = p.baseSize * radiusMultiplier;

          // Color with hue shift based on perimeter position
          Color col = baseColor;
          if (enableHueTilt) {
            final hsl = HSLColor.fromColor(baseColor);
            final shift = perimeterRatio * 360 * hueTiltRange;
            col = hsl
                .withHue((hsl.hue + shift) % 360)
                .withSaturation((hsl.saturation * saturationBoost).clamp(0, 1))
                .toColor();
          }
          col = col.withOpacity(opacity);

          // Width of the ripple (thinner as it moves)
          final rippleWidthMultiplier = 1.0 - 0.3 * distanceProgress;

          // Decay blur for ripple particle
          canvas.drawCircle(
              pos,
              sizePx * 3.0 * rippleWidthMultiplier,
              Paint()
                ..color = col.withOpacity(col.opacity * 0.15)
                ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));

          canvas.drawCircle(
              pos,
              sizePx * 2.0 * rippleWidthMultiplier,
              Paint()
                ..color = col.withOpacity(col.opacity * 0.3)
                ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));

          // Core of the ripple particle
          canvas.drawCircle(
              pos, sizePx * rippleWidthMultiplier, Paint()..color = col);
        }
      }
    }
  }

  Offset _getPositionOnPerimeter(Rect rect, double ratio) {
    final totalPerimeter = 2 * (rect.width + rect.height);
    final distanceAlongPerimeter = totalPerimeter * ratio;

    // Sisi atas
    if (distanceAlongPerimeter < rect.width) {
      return Offset(rect.left + distanceAlongPerimeter, rect.top);
    }
    // Sisi kanan
    else if (distanceAlongPerimeter < rect.width + rect.height) {
      return Offset(
          rect.right, rect.top + (distanceAlongPerimeter - rect.width));
    }
    // Sisi bawah
    else if (distanceAlongPerimeter < 2 * rect.width + rect.height) {
      return Offset(
          rect.right - (distanceAlongPerimeter - rect.width - rect.height),
          rect.bottom);
    }
    // Sisi kiri
    else {
      return Offset(
          rect.left,
          rect.bottom -
              (distanceAlongPerimeter - 2 * rect.width - rect.height));
    }
  }

  double _easeOutQuad(double t) => t * (2 - t);
  double _easeInQuad(double t) => t * t;

  @override
  bool shouldRepaint(EffectAnimator old) =>
      old is! PerimeterCircleRippleAnimator ||
      old.rippleCount != rippleCount ||
      old.enableHueTilt != enableHueTilt ||
      old.hueTiltRange != hueTiltRange ||
      old.saturationBoost != saturationBoost ||
      old.particlesPerRipple != particlesPerRipple ||
      old.rippleSpeed != rippleSpeed ||
      old.rippleWidth != rippleWidth;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;
  @override
  double getDefaultRadiusMultiplier() => 1;
  @override
  double getOuterPadding() => 40;
}

// Kelas partikel untuk animasi teleport
class _TeleportParticle {
  double currentPosition;
  double targetPosition;
  double teleportTime;
  final double baseSize;
  final double sizePulseRate;

  _TeleportParticle({
    required this.currentPosition,
    required this.targetPosition,
    required this.teleportTime,
    required this.baseSize,
    required this.sizePulseRate,
  });
}

// Kelas untuk ripple
class _Ripple {
  final double startTime;
  final List<_Particle> particles;

  _Ripple({
    required this.startTime,
    required this.particles,
  });
}

// Kelas untuk firework
class _Firework {
  final double perimeterPosition;
  final double startTime;
  final List<_FireworkSpark> sparks;

  _Firework({
    required this.perimeterPosition,
    required this.startTime,
    required this.sparks,
  });
}

// Kelas untuk percikan firework
class _FireworkSpark {
  final double angle;
  final double maxDistance;
  final double duration;
  final double baseSize;

  _FireworkSpark({
    required this.angle,
    required this.maxDistance,
    required this.duration,
    required this.baseSize,
  });
}

// Animator untuk partikel dot dan ray yang bergerak keluar
class PerimeterCircleBurstDotRayOutAnimator implements EffectAnimator {
  // ───── konfigurasi ─────
  final int dotParticleCount;
  final int rayParticleCount;
  final bool enableHueTilt;
  final double hueTiltRange;
  final double saturationBoost;
  final bool enableBloom;
  final double bloomWidth;
  final double rayLength;
  final double rayWidth;

  final List<_Particle> _dotParticles = [];
  final List<_RayParticle> _rayParticles = [];
  final Random _random = Random();

  PerimeterCircleBurstDotRayOutAnimator({
    this.dotParticleCount = 16,
    this.rayParticleCount = 8,
    this.enableHueTilt = false,
    this.hueTiltRange = .30,
    this.saturationBoost = 1.1,
    this.enableBloom = true,
    this.bloomWidth = 2.5,
    this.rayLength = 30.0,
    this.rayWidth = 3.0,
  });

  // ───── inisialisasi partikel ─────
  void _initParticles() {
    if (_dotParticles.isNotEmpty && _rayParticles.isNotEmpty) return;

    // Inisialisasi dot particles
    for (int i = 0; i < dotParticleCount; i++) {
      final baseAngle = (i / dotParticleCount) * math.pi * 2;
      final angle = baseAngle + (_random.nextDouble() * .2 - .1);

      _dotParticles.add(_Particle(
        angle: angle,
        maxDistance: _random.nextDouble() * 15 + 25,
        baseSize: _random.nextDouble() * 4 + 2,
        pulseRate: _random.nextDouble() * 3 + 1,
      ));
    }

    // Inisialisasi ray particles
    for (int i = 0; i < rayParticleCount; i++) {
      final baseAngle = (i / rayParticleCount) * math.pi * 2;
      final angle = baseAngle + (_random.nextDouble() * .1 - .05);

      _rayParticles.add(_RayParticle(
        angle: angle,
        maxDistance: _random.nextDouble() * 20 + rayLength,
        baseWidth: _random.nextDouble() * 2 + rayWidth,
        pulseRate: _random.nextDouble() * 2 + 0.8,
      ));
    }
  }

  // ───── paint ─────
  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color baseColor,
      {double radiusMultiplier = 1, Offset positionOffset = Offset.zero}) {
    _initParticles();

    final c = center + positionOffset;

    // Buat rect untuk perimeter
    final rect = Rect.fromCenter(
      center: c,
      width: size.width,
      height: size.height,
    );

    // Progress langsung keluar: 0 → 1
    final distP = _easeOutQuad(progress);

    // ----- BLOOM halo (opsional) -----
    if (enableBloom && progress > .85) {
      final bloomOpacity = _easeInQuad(1 - (progress - .85) / .15);

      // Buat halo di sekitar perimeter
      final bloomPath = Path();
      bloomPath.addRect(rect.inflate(bloomWidth * radiusMultiplier));

      canvas.drawPath(
          bloomPath,
          Paint()
            ..color = baseColor.withOpacity(bloomOpacity * .4)
            ..style = PaintingStyle.stroke
            ..strokeWidth = bloomWidth * radiusMultiplier
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    }

    // ----- dot particles -----
    for (int i = 0; i < _dotParticles.length; i++) {
      final p = _dotParticles[i];

      // Posisi di perimeter
      final perimeterRatio = i / dotParticleCount;
      final perimeterPos = _getPositionOnPerimeter(rect, perimeterRatio);

      // Vektor dari pusat ke perimeter (arah gerakan)
      final dirVector = perimeterPos - c;
      final distance = dirVector.distance;
      final direction = distance > 0
          ? Offset(dirVector.dx / distance, dirVector.dy / distance)
          : Offset(0, 0);

      // Jarak gerakan dari perimeter
      final curDist = p.maxDistance * distP * radiusMultiplier;

      // Posisi akhir
      final pos = perimeterPos + direction * curDist;

      // Pulsasi
      final pulse = .5 + .5 * math.sin(progress * math.pi * 2 * p.pulseRate);
      final sizePx = p.baseSize * pulse * radiusMultiplier;

      // Opacity fade out di akhir
      double opacity = progress < .9 ? 1 : (1 - (progress - .9) / .1);
      opacity = opacity.clamp(0, 1);

      // Warna
      Color col = baseColor;
      if (enableHueTilt) {
        final hsl = HSLColor.fromColor(baseColor);
        final shift = perimeterRatio * 360 * hueTiltRange;
        col = hsl
            .withHue((hsl.hue + shift) % 360)
            .withSaturation((hsl.saturation * saturationBoost).clamp(0, 1))
            .toColor();
      }
      col = col.withOpacity(opacity);

      // Decay blur tingkat 3 (terluar) - blur jangkauan luas
      canvas.drawCircle(
          pos,
          sizePx * 3.5,
          Paint()
            ..color = col.withOpacity(.15)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));

      // Decay blur tingkat 2 (menengah)
      canvas.drawCircle(
          pos,
          sizePx * 2.5,
          Paint()
            ..color = col.withOpacity(.35)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));

      // Decay blur tingkat 1 (dekat)
      canvas.drawCircle(
          pos,
          sizePx * 1.8,
          Paint()
            ..color = col.withOpacity(.5)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));

      // Lingkaran inti
      canvas.drawCircle(pos, sizePx, Paint()..color = col);
    }

    // ----- ray particles -----
    for (int i = 0; i < _rayParticles.length; i++) {
      final p = _rayParticles[i];

      // Posisi di perimeter
      final perimeterRatio = i / rayParticleCount;
      final perimeterPos = _getPositionOnPerimeter(rect, perimeterRatio);

      // Vektor dari pusat ke perimeter (arah gerakan)
      final dirVector = perimeterPos - c;
      final distance = dirVector.distance;
      final direction = distance > 0
          ? Offset(dirVector.dx / distance, dirVector.dy / distance)
          : Offset(0, 0);

      // Jarak gerakan dari perimeter
      final curDist = p.maxDistance * distP * radiusMultiplier;

      // Titik awal ray (pada perimeter)
      final startPos = perimeterPos;

      // Titik akhir ray (maksimum)
      final endPos = perimeterPos + direction * curDist;

      // Pulsasi lebar ray
      final pulse = .5 + .5 * math.sin(progress * math.pi * 2 * p.pulseRate);
      final rayWidthPx = p.baseWidth * pulse * radiusMultiplier;

      // Opacity fade out di akhir
      double opacity = progress < .9 ? 1 : (1 - (progress - .9) / .1);
      opacity = opacity.clamp(0, 1);

      // Warna
      Color col = baseColor;
      if (enableHueTilt) {
        final hsl = HSLColor.fromColor(baseColor);
        final shift = perimeterRatio * 360 * hueTiltRange;
        col = hsl
            .withHue((hsl.hue + shift) % 360)
            .withSaturation((hsl.saturation * saturationBoost).clamp(0, 1))
            .toColor();
      }
      col = col.withOpacity(opacity);

      // Gambar ray dengan gradient
      final paint = Paint()
        ..strokeWidth = rayWidthPx
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..shader = ui.Gradient.linear(
          startPos,
          endPos,
          [
            col.withOpacity(col.opacity * 0.8),
            col.withOpacity(col.opacity * 0.1),
          ],
          [0.0, 1.0],
        );

      // Ray dengan blur (glow)
      final blurPaint = Paint()
        ..strokeWidth = rayWidthPx * 2.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..shader = ui.Gradient.linear(
          startPos,
          endPos,
          [
            col.withOpacity(col.opacity * 0.6),
            col.withOpacity(col.opacity * 0.0),
          ],
          [0.0, 1.0],
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      // Gambar ray yang lebih blur dulu
      canvas.drawLine(startPos, endPos, blurPaint);

      // Gambar ray yang lebih solid di atasnya
      canvas.drawLine(startPos, endPos, paint);
    }
  }

  // Helper untuk mendapatkan posisi pada perimeter
  Offset _getPositionOnPerimeter(Rect rect, double ratio) {
    final totalPerimeter = 2 * (rect.width + rect.height);
    final distanceAlongPerimeter = totalPerimeter * ratio;

    // Sisi atas
    if (distanceAlongPerimeter < rect.width) {
      return Offset(rect.left + distanceAlongPerimeter, rect.top);
    }
    // Sisi kanan
    else if (distanceAlongPerimeter < rect.width + rect.height) {
      return Offset(
          rect.right, rect.top + (distanceAlongPerimeter - rect.width));
    }
    // Sisi bawah
    else if (distanceAlongPerimeter < 2 * rect.width + rect.height) {
      return Offset(
          rect.right - (distanceAlongPerimeter - rect.width - rect.height),
          rect.bottom);
    }
    // Sisi kiri
    else {
      return Offset(
          rect.left,
          rect.bottom -
              (distanceAlongPerimeter - 2 * rect.width - rect.height));
    }
  }

  // ───── easing ─────
  double _easeOutQuad(double t) => t * (2 - t);
  double _easeInQuad(double t) => t * t;

  // ───── overrides ─────
  @override
  bool shouldRepaint(EffectAnimator old) =>
      old is! PerimeterCircleBurstDotRayOutAnimator ||
      old.dotParticleCount != dotParticleCount ||
      old.rayParticleCount != rayParticleCount ||
      old.enableHueTilt != enableHueTilt ||
      old.hueTiltRange != hueTiltRange ||
      old.saturationBoost != saturationBoost ||
      old.enableBloom != enableBloom ||
      old.bloomWidth != bloomWidth ||
      old.rayLength != rayLength ||
      old.rayWidth != rayWidth;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;
  @override
  double getDefaultRadiusMultiplier() => 1;
  @override
  double getOuterPadding() => 40;
}

// Animator untuk partikel dot dan ray yang bergerak dari luar ke dalam
class PerimeterCircleBurstDotRayInAnimator implements EffectAnimator {
  // ───── konfigurasi ─────
  final int dotParticleCount;
  final int rayParticleCount;
  final bool enableHueTilt;
  final double hueTiltRange;
  final double saturationBoost;
  final bool enableBloom;
  final double bloomWidth;
  final double rayLength;
  final double rayWidth;

  final List<_Particle> _dotParticles = [];
  final List<_RayParticle> _rayParticles = [];
  final Random _random = Random();

  PerimeterCircleBurstDotRayInAnimator({
    this.dotParticleCount = 16,
    this.rayParticleCount = 8,
    this.enableHueTilt = false,
    this.hueTiltRange = .30,
    this.saturationBoost = 1.1,
    this.enableBloom = true,
    this.bloomWidth = 2.5,
    this.rayLength = 30.0,
    this.rayWidth = 3.0,
  });

  // ───── inisialisasi partikel ─────
  void _initParticles() {
    if (_dotParticles.isNotEmpty && _rayParticles.isNotEmpty) return;

    // Inisialisasi dot particles
    for (int i = 0; i < dotParticleCount; i++) {
      final baseAngle = (i / dotParticleCount) * math.pi * 2;
      final angle = baseAngle + (_random.nextDouble() * .2 - .1);

      _dotParticles.add(_Particle(
        angle: angle,
        maxDistance: _random.nextDouble() * 15 + 25,
        baseSize: _random.nextDouble() * 4 + 2,
        pulseRate: _random.nextDouble() * 3 + 1,
      ));
    }

    // Inisialisasi ray particles
    for (int i = 0; i < rayParticleCount; i++) {
      final baseAngle = (i / rayParticleCount) * math.pi * 2;
      final angle = baseAngle + (_random.nextDouble() * .1 - .05);

      _rayParticles.add(_RayParticle(
        angle: angle,
        maxDistance: _random.nextDouble() * 20 + rayLength,
        baseWidth: _random.nextDouble() * 2 + rayWidth,
        pulseRate: _random.nextDouble() * 2 + 0.8,
      ));
    }
  }

  // ───── paint ─────
  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color baseColor,
      {double radiusMultiplier = 1, Offset positionOffset = Offset.zero}) {
    _initParticles();

    final c = center + positionOffset;

    // Buat rect untuk perimeter
    final rect = Rect.fromCenter(
      center: c,
      width: size.width,
      height: size.height,
    );

    // Progress dari luar ke dalam: 1 → 0
    final distP = _easeInQuad(1 - progress);

    // ----- BLOOM halo (opsional) -----
    if (enableBloom && progress < .15) {
      final bloomOpacity = _easeInQuad(progress / .15);

      // Buat halo di sekitar perimeter
      final bloomPath = Path();
      bloomPath.addRect(rect.inflate(bloomWidth * radiusMultiplier));

      canvas.drawPath(
          bloomPath,
          Paint()
            ..color = baseColor.withOpacity(bloomOpacity * .4)
            ..style = PaintingStyle.stroke
            ..strokeWidth = bloomWidth * radiusMultiplier
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    }

    // ----- dot particles -----
    for (int i = 0; i < _dotParticles.length; i++) {
      final p = _dotParticles[i];

      // Posisi di perimeter
      final perimeterRatio = i / dotParticleCount;
      final perimeterPos = _getPositionOnPerimeter(rect, perimeterRatio);

      // Vektor dari pusat ke perimeter (arah gerakan)
      final dirVector = perimeterPos - c;
      final distance = dirVector.distance;
      final direction = distance > 0
          ? Offset(dirVector.dx / distance, dirVector.dy / distance)
          : Offset(0, 0);

      // Jarak gerakan dari perimeter
      final curDist = p.maxDistance * distP * radiusMultiplier;

      // Posisi akhir (mulai dari luar)
      final pos = perimeterPos + direction * curDist;

      // Pulsasi
      final pulse = .5 + .5 * math.sin(progress * math.pi * 2 * p.pulseRate);
      final sizePx = p.baseSize * pulse * radiusMultiplier;

      // Opacity fade in di awal
      double opacity = progress > .1 ? 1 : progress / .1;
      opacity = opacity.clamp(0, 1);

      // Warna
      Color col = baseColor;
      if (enableHueTilt) {
        final hsl = HSLColor.fromColor(baseColor);
        final shift = perimeterRatio * 360 * hueTiltRange;
        col = hsl
            .withHue((hsl.hue + shift) % 360)
            .withSaturation((hsl.saturation * saturationBoost).clamp(0, 1))
            .toColor();
      }
      col = col.withOpacity(opacity);

      // Decay blur tingkat 3 (terluar) - blur jangkauan luas
      canvas.drawCircle(
          pos,
          sizePx * 3.5,
          Paint()
            ..color = col.withOpacity(.15)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));

      // Decay blur tingkat 2 (menengah)
      canvas.drawCircle(
          pos,
          sizePx * 2.5,
          Paint()
            ..color = col.withOpacity(.35)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));

      // Decay blur tingkat 1 (dekat)
      canvas.drawCircle(
          pos,
          sizePx * 1.8,
          Paint()
            ..color = col.withOpacity(.5)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));

      // Lingkaran inti
      canvas.drawCircle(pos, sizePx, Paint()..color = col);
    }

    // ----- ray particles -----
    for (int i = 0; i < _rayParticles.length; i++) {
      final p = _rayParticles[i];

      // Posisi di perimeter
      final perimeterRatio = i / rayParticleCount;
      final perimeterPos = _getPositionOnPerimeter(rect, perimeterRatio);

      // Vektor dari pusat ke perimeter (arah gerakan)
      final dirVector = perimeterPos - c;
      final distance = dirVector.distance;
      final direction = distance > 0
          ? Offset(dirVector.dx / distance, dirVector.dy / distance)
          : Offset(0, 0);

      // Jarak gerakan dari perimeter
      final curDist = p.maxDistance * distP * radiusMultiplier;

      // Titik akhir ray (pada perimeter)
      final endPos = perimeterPos;

      // Titik awal ray (dari luar)
      final startPos = perimeterPos + direction * curDist;

      // Pulsasi lebar ray
      final pulse = .5 + .5 * math.sin(progress * math.pi * 2 * p.pulseRate);
      final rayWidthPx = p.baseWidth * pulse * radiusMultiplier;

      // Opacity fade in di awal
      double opacity = progress > .1 ? 1 : progress / .1;
      opacity = opacity.clamp(0, 1);

      // Warna
      Color col = baseColor;
      if (enableHueTilt) {
        final hsl = HSLColor.fromColor(baseColor);
        final shift = perimeterRatio * 360 * hueTiltRange;
        col = hsl
            .withHue((hsl.hue + shift) % 360)
            .withSaturation((hsl.saturation * saturationBoost).clamp(0, 1))
            .toColor();
      }
      col = col.withOpacity(opacity);

      // Gambar ray dengan gradient
      final paint = Paint()
        ..strokeWidth = rayWidthPx
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..shader = ui.Gradient.linear(
          startPos,
          endPos,
          [
            col.withOpacity(col.opacity * 0.1),
            col.withOpacity(col.opacity * 0.8),
          ],
          [0.0, 1.0],
        );

      // Ray dengan blur (glow)
      final blurPaint = Paint()
        ..strokeWidth = rayWidthPx * 2.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..shader = ui.Gradient.linear(
          startPos,
          endPos,
          [
            col.withOpacity(col.opacity * 0.0),
            col.withOpacity(col.opacity * 0.6),
          ],
          [0.0, 1.0],
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      // Gambar ray yang lebih blur dulu
      canvas.drawLine(startPos, endPos, blurPaint);

      // Gambar ray yang lebih solid di atasnya
      canvas.drawLine(startPos, endPos, paint);
    }
  }

  // Helper untuk mendapatkan posisi pada perimeter
  Offset _getPositionOnPerimeter(Rect rect, double ratio) {
    final totalPerimeter = 2 * (rect.width + rect.height);
    final distanceAlongPerimeter = totalPerimeter * ratio;

    // Sisi atas
    if (distanceAlongPerimeter < rect.width) {
      return Offset(rect.left + distanceAlongPerimeter, rect.top);
    }
    // Sisi kanan
    else if (distanceAlongPerimeter < rect.width + rect.height) {
      return Offset(
          rect.right, rect.top + (distanceAlongPerimeter - rect.width));
    }
    // Sisi bawah
    else if (distanceAlongPerimeter < 2 * rect.width + rect.height) {
      return Offset(
          rect.right - (distanceAlongPerimeter - rect.width - rect.height),
          rect.bottom);
    }
    // Sisi kiri
    else {
      return Offset(
          rect.left,
          rect.bottom -
              (distanceAlongPerimeter - 2 * rect.width - rect.height));
    }
  }

  // ───── easing ─────
  double _easeOutQuad(double t) => t * (2 - t);
  double _easeInQuad(double t) => t * t;

  // ───── overrides ─────
  @override
  bool shouldRepaint(EffectAnimator old) =>
      old is! PerimeterCircleBurstDotRayInAnimator ||
      old.dotParticleCount != dotParticleCount ||
      old.rayParticleCount != rayParticleCount ||
      old.enableHueTilt != enableHueTilt ||
      old.hueTiltRange != hueTiltRange ||
      old.saturationBoost != saturationBoost ||
      old.enableBloom != enableBloom ||
      old.bloomWidth != bloomWidth ||
      old.rayLength != rayLength ||
      old.rayWidth != rayWidth;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;
  @override
  double getDefaultRadiusMultiplier() => 1;
  @override
  double getOuterPadding() => 40;
}

// Kelas untuk partikel ray
class _RayParticle {
  final double angle;
  final double maxDistance;
  final double baseWidth;
  final double pulseRate;

  _RayParticle({
    required this.angle,
    required this.maxDistance,
    required this.baseWidth,
    required this.pulseRate,
  });
}
