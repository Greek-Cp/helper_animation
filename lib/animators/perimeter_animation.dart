import 'dart:math' as math;
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:helper_animation/animators/effect_animator.dart';
import 'package:helper_animation/constants/enums.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'dart:math' as math;
import 'dart:ui';

import 'dart:math' as math;
import 'dart:ui';

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
