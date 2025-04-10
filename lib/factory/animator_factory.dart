import 'dart:math';

import 'package:helper_animation/animators/new_animator.dart';

import '../constants/enums.dart';
import '../animators/confetti_animator.dart';
import '../animators/effect_animator.dart';
import '../animators/firework_animator.dart';
import '../animators/orbital_animator.dart';
import 'package:flutter/material.dart';
import '../animators/ripple_animator.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

/// Animator untuk efek whirlpool yang memberikan feedback visual ketika item ditempatkan
/// Animator untuk efek ray-bubble-pop: titik kecil → pancaran ray → gelembung pecah
/// dengan warna yang otomatis beradaptasi dari warna widget asli
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Kumpulan fungsi & helper yang dipakai bersama oleh semua animator.
class AnimationUtils {
  static const int _defaultSeed = 42;

  // ---------- Random ----------
  static math.Random random([int seed = _defaultSeed]) => math.Random(seed);

  // ---------- Easing ----------
  static double easeOut(double t) => 1 - math.pow(1 - t, 3).toDouble();
  static double easeIn(double t) => math.pow(t, 3).toDouble();
  static double easeInOut(double t) => t < .5
      ? 4 * math.pow(t, 3).toDouble()
      : 1 - math.pow(-2 * t + 2, 3).toDouble() / 2;

  static double elasticOut(double t) {
    const c4 = (2 * math.pi) / 3;
    if (t == 0 || t == 1) return t;
    return math.pow(2, -10 * t) * math.sin((t * 10 - .75) * c4) + 1;
  }

  static double elasticInOut(double t) {
    const c5 = (2 * math.pi) / 4.5;
    if (t == 0 || t == 1) return t;
    if (t < .5) {
      return -(math.pow(2, 20 * t - 10) * math.sin((20 * t - 11.125) * c5)) / 2;
    }
    return (math.pow(2, -20 * t + 10) * math.sin((20 * t - 11.125) * c5)) / 2 +
        1;
  }

  static double bouncyEaseOut(double t) {
    if (t < 4 / 11) return (121 * t * t) / 16;
    if (t < 8 / 11) return (363 / 40 * t * t) - (99 / 10 * t) + 17 / 5;
    if (t < 9 / 10)
      return (4356 / 361 * t * t) - (35442 / 1805 * t) + 16061 / 1805;
    return (54 / 5 * t * t) - (513 / 25 * t) + 268 / 25;
  }

  // ---------- Color ----------
  static Color shiftHue(
    Color color,
    double hueShift, {
    double saturationFactor = 1.0,
    double lightnessFactor = 1.0,
  }) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withHue((hsl.hue + hueShift * 360) % 360)
        .withSaturation(
            (hsl.saturation * saturationFactor).clamp(0.0, 1.0).toDouble())
        .withLightness(
            (hsl.lightness * lightnessFactor).clamp(0.0, 1.0).toDouble())
        .toColor();
  }

  // ---------- Drawing helpers ----------
  static void drawStar(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, size, paint);
    for (int i = 0; i < 4; i++) {
      final a = i * (math.pi / 2);
      canvas.drawCircle(
          Offset(center.dx + math.cos(a) * size * 1.5,
              center.dy + math.sin(a) * size * 1.5),
          size * .3,
          paint);
    }
  }

  /// Sparkle util (set `foreground=true` untuk bintang terang di depan).
  static void drawSparkles({
    required Canvas canvas,
    required Offset center,
    required double progress,
    required Color baseColor,
    required math.Random random,
    required double maxDistance,
    required int sparkleCount,
    required bool foreground,
  }) {
    for (int i = 0; i < sparkleCount; i++) {
      final d = random.nextDouble() * maxDistance * (foreground ? 1.5 : 1.2);
      final a = random.nextDouble() * math.pi * 2;
      final pos =
          Offset(center.dx + math.cos(a) * d, center.dy + math.sin(a) * d);

      final size =
          random.nextDouble() * (foreground ? 4 : 3) + (foreground ? 2 : 1);

      final col = HSLColor.fromColor(baseColor)
          .withLightness(0.7 + random.nextDouble() * .3)
          .withSaturation(0.7 + random.nextDouble() * .3)
          .toColor()
          .withOpacity(foreground
              ? (.5 + random.nextDouble() * .5)
              : (.3 + random.nextDouble() * .4));

      foreground
          ? drawStar(canvas, pos, size, col)
          : canvas.drawCircle(pos, size, Paint()..color = col);
    }
  }
}

/// Radial burst ala firework, tetapi memakai shape (circle + tail) ──
/// cocok sebagai penanda netral “item berhasil di‑drop”.
/// Spiral burst partikel dengan rotasi dan pengurangan ukuran.
class SpiralExplosionAnimator implements EffectAnimator {
  // ---------- tampilan ----------
  final int particleCount;
  final double circleRadius; // radius lingkaran awal
  final double tailFactor; // panjang ekor = circleRadius * tailFactor
  final double explosionScale; // jarak lempar relatif sisi terpendek
  final double spiralTightness; // seberapa ketat spiral (0-1)
  final double rotationSpeed; // kecepatan rotasi

  // ---------- opsi warna ----------
  final bool enableHueTilt; // aktifkan gradasi
  final double hueTiltRange; // 0‑1  (1 = 360° penuh)
  final double saturationBoost; // 1 = tak berubah

  SpiralExplosionAnimator({
    this.particleCount = 24,
    this.circleRadius = 5,
    this.tailFactor = 2.5,
    this.explosionScale = .65,
    this.spiralTightness = 0.3,
    this.rotationSpeed = 2.0,
    //
    this.enableHueTilt = true,
    this.hueTiltRange = .5,
    this.saturationBoost = 1.2,
  });

  // fase
  static const double _burstPhase = .7;

  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final c = center + positionOffset;
    final shortestSide = math.min(size.width, size.height);

    final explosionRadius = shortestSide * explosionScale * radiusMultiplier;

    // sudut partikel awal
    final List<double> angles = List.generate(
      particleCount,
      (i) => (i / particleCount) * 2 * math.pi,
    );

    for (int i = 0; i < particleCount; i++) {
      final delay = i * 0.015;
      final rawT = progress - delay;
      if (rawT <= 0) continue;

      // normalisasi progress partikel
      final t = (rawT / (1 - delay)).clamp(0.0, 1.0);

      // Sudut dasar + rotasi tambahan berdasarkan waktu
      final baseAngle = angles[i];
      final rotationAngle = baseAngle + (t * rotationSpeed * math.pi);

      // ---- posisi spiral ----
      double distance;
      if (t < _burstPhase) {
        final burstT = t / _burstPhase;
        distance = explosionRadius * _easeOutCubic(burstT);
      } else {
        final fallT = (t - _burstPhase) / (1 - _burstPhase);
        distance = explosionRadius + (fallT * fallT * 40);
      }

      // Tambahkan efek spiral - semakin jauh, semakin berputar
      final spiralAngle =
          baseAngle + (distance * spiralTightness / explosionRadius) * math.pi;

      final pos =
          c + Offset(math.cos(spiralAngle), math.sin(spiralAngle)) * distance;

      // ---- skala & opasitas ----
      final scale = t < .1
          ? t / .1
          : t > .85
              ? (1 - t) / .15
              : 1.0 - (t * 0.4); // Semakin kecil seiring waktu

      final opacity = t < .1
          ? t / .1
          : t > .85
              ? (1 - t) / .15
              : 1.0;

      // ---- warna ----
      Color particleColor = color;
      if (enableHueTilt) {
        final hsl = HSLColor.fromColor(color);
        final hueShiftDeg = (spiralAngle / (2 * math.pi)) * 360 * hueTiltRange;
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

      // ekor
      final tailLen = rad * tailFactor;
      final tailStart =
          pos - Offset(math.cos(spiralAngle), math.sin(spiralAngle)) * tailLen;
      canvas.drawLine(
          tailStart,
          pos,
          Paint()
            ..color = particleColor
            ..strokeWidth = rad * .8
            ..strokeCap = StrokeCap.round);
    }
  }

  // easing
  double _easeOutCubic(double t) {
    return 1 - math.pow(1 - t, 3).toDouble();
  }

  // overrides
  @override
  bool shouldRepaint(EffectAnimator old) =>
      old is! SpiralExplosionAnimator ||
      old.particleCount != particleCount ||
      old.circleRadius != circleRadius ||
      old.tailFactor != tailFactor ||
      old.explosionScale != explosionScale ||
      old.spiralTightness != spiralTightness ||
      old.rotationSpeed != rotationSpeed ||
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

/// Radial burst partikel (lingkaran + ekor) dengan opsi gradasi HSV.
class ShapeExplosionAnimator implements EffectAnimator {
  // ---------- tampilan ----------
  final int particleCount;
  final double circleRadius; // radius lingkaran awal
  final double tailFactor; // panjang ekor = circleRadius * tailFactor
  final double explosionScale; // jarak lempar relatif sisi terpendek
  final bool useUniformAngle;

  // ---------- opsi warna ----------
  final bool enableHueTilt; // aktifkan gradasi
  final double hueTiltRange; // 0‑1  (1 = 360° penuh)
  final double saturationBoost; // 1 = tak berubah

  ShapeExplosionAnimator({
    this.particleCount = 18,
    this.circleRadius = 6,
    this.tailFactor = 3,
    this.explosionScale = .7,
    this.useUniformAngle = true,
    //
    this.enableHueTilt = true,
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

    final explosionRadius = shortestSide * explosionScale * radiusMultiplier;

    // sudut partikel
    final List<double> angles = List.generate(
      particleCount,
      (i) => useUniformAngle
          ? (i / particleCount) * 2 * math.pi
          : rnd.nextDouble() * 2 * math.pi,
    );

    for (int i = 0; i < particleCount; i++) {
      final delay = i * 0.02;
      final rawT = progress - delay;
      if (rawT <= 0) continue;

      // normalisasi progress partikel
      final t = (rawT / (1 - delay)).clamp(0.0, 1.0);

      final angle = angles[i];

      // ---- posisi radial ----
      double distance;
      if (t < _burstPhase) {
        final burstT = t / _burstPhase;
        distance = explosionRadius * _easeOutBack(burstT);
      } else {
        final fallT = (t - _burstPhase) / (1 - _burstPhase);
        distance = explosionRadius + (fallT * fallT * 60);
      }

      final pos = c + Offset(math.cos(angle), math.sin(angle)) * distance;

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
        final hueShiftDeg = (angle / (2 * math.pi)) * 360 * hueTiltRange;
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

      // ekor
      final tailLen = rad * tailFactor;
      final tailStart =
          pos - Offset(math.cos(angle), math.sin(angle)) * tailLen;
      canvas.drawLine(
          tailStart,
          pos,
          Paint()
            ..color = particleColor
            ..strokeWidth = rad * .8
            ..strokeCap = StrokeCap.round);
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
      old is! ShapeExplosionAnimator ||
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

class ShapeImplodeAnimator implements EffectAnimator {
  // ───── visual ─────
  final int particleCount;
  final double circleRadius;
  final double tailFactor;
  final double spawnScale; // radius awal = spawnScale * sisi terpendek
  final bool useUniformAngle;
  // ───── warna ─────
  final bool enableHueTilt;
  final double hueTiltRange;
  final double saturationBoost;

  ShapeImplodeAnimator({
    this.particleCount = 18,
    this.circleRadius = 6,
    this.tailFactor = 3,
    this.spawnScale = .75,
    this.useUniformAngle = true,
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

    final spawnRadius = minSide * spawnScale * radiusMultiplier;

    // sudut tetap
    final angles = List<double>.generate(
      particleCount,
      (i) => useUniformAngle
          ? (i / particleCount) * 2 * math.pi
          : rnd.nextDouble() * 2 * math.pi,
    );

    for (var i = 0; i < particleCount; i++) {
      final delay = i * 0.02;
      final rawT = p - delay;
      if (rawT <= 0) continue;

      final t = (rawT / (1 - delay)).clamp(0.0, 1.0);
      final angle = angles[i];

      // ── posisi radial ──
      double dist;
      if (t < _spawnEnd) {
        final tt = t / _spawnEnd; // 0‑1
        dist = spawnRadius * (1 - _easeOutQuad(tt));
      } else if (t < _convergeEnd) {
        final tt = (t - _spawnEnd) / (_convergeEnd - _spawnEnd);
        dist = spawnRadius * (1 - _easeInBack(tt));
      } else {
        final tt = (t - _convergeEnd) / (1 - _convergeEnd);
        dist = spawnRadius * (0.15 * (1 - tt)); // makin dekat ke 0
      }

      final pos = c + Offset(math.cos(angle), math.sin(angle)) * dist;

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
        final shift = (angle / (2 * math.pi)) * 360 * hueTiltRange;
        col = hsl
            .withHue((hsl.hue + shift) % 360)
            .withSaturation((hsl.saturation * saturationBoost).clamp(0, 1))
            .toColor();
      }
      col = col.withOpacity(opacity.toDouble());

      // ── gambar ──
      final rad = circleRadius * radiusMultiplier * scale;
      cv.drawCircle(pos, rad, Paint()..color = col);

      final tailLen = rad * tailFactor;
      final tailEnd = pos + Offset(math.cos(angle), math.sin(angle)) * tailLen;
      cv.drawLine(
          pos,
          tailEnd,
          Paint()
            ..color = col
            ..strokeWidth = rad * .8
            ..strokeCap = StrokeCap.round);
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
      old is! ShapeImplodeAnimator ||
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

class ShapeRetractImplodeAnimator implements EffectAnimator {
  // ───── parameter visual ─────
  final int particleCount;
  final double circleRadius; // radius dot
  final double tailFactor; // tailLen = circleRadius * tailFactor
  final double spawnScale; // spawnRadius = spawnScale * sisi terpendek
  final bool useUniformAngle;

  // ───── opsi warna ─────
  final bool enableHueTilt;
  final double hueTiltRange; // 0‑1   (1 => 360°)
  final double saturationBoost; // 1 => no change

  ShapeRetractImplodeAnimator({
    this.particleCount = 18,
    this.circleRadius = 6,
    this.tailFactor = 3,
    this.spawnScale = .75,
    this.useUniformAngle = true,
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

    final spawnRadius = minSide * spawnScale * radiusMultiplier;

    // sudut partikel (deterministik)
    final angles = List<double>.generate(
      particleCount,
      (i) => useUniformAngle
          ? (i / particleCount) * 2 * math.pi
          : rnd.nextDouble() * 2 * math.pi,
    );

    for (int i = 0; i < particleCount; i++) {
      // delay ringan antar partikel
      final delay = i * 0.02;
      final rawT = progress - delay;
      if (rawT <= 0) continue;

      // normalisasi agar setiap partikel selesai di progress==1
      final t = (rawT / (1 - delay)).clamp(0.0, 1.0);

      final angle = angles[i];

      // ─── posisi radial ───
      double dist;
      if (t < _tailRetractEnd) {
        dist = spawnRadius; // tetap di tepi
      } else {
        final tt = (t - _tailRetractEnd) / (1 - _tailRetractEnd); // 0‑1
        dist = spawnRadius * (1 - _easeInQuad(tt)); // implosion
      }
      final pos = c + Offset(math.cos(angle), math.sin(angle)) * dist;

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
        final hueShift = (angle / (2 * math.pi)) * 360 * hueTiltRange;
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
        final tailEnd =
            pos + Offset(math.cos(angle), math.sin(angle)) * tailLen;
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

  // ───── easing helpers ─────
  double _easeInQuad(double t) => t * t;

  // ───── overrides ─────
  @override
  bool shouldRepaint(EffectAnimator old) =>
      old is! ShapeRetractImplodeAnimator ||
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

class ShapeExplodeOutAnimator implements EffectAnimator {
  // ─── parameter visual ───
  final int particleCount;
  final double circleRadius;
  final double tailFactor;
  final double explosionScale; // radius akhir relatif sisi terpendek
  final bool useUniformAngle;

  // ─── opsi warna ───
  final bool enableHueTilt;
  final double hueTiltRange;
  final double saturationBoost;

  ShapeExplodeOutAnimator({
    this.particleCount = 18,
    this.circleRadius = 6,
    this.tailFactor = 3,
    this.explosionScale = .7,
    this.useUniformAngle = true,
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

    final explosionRadius = minSide * explosionScale * radiusMultiplier;

    // sudut tetap
    final angles = List<double>.generate(
      particleCount,
      (i) => useUniformAngle
          ? (i / particleCount) * 2 * math.pi
          : rnd.nextDouble() * 2 * math.pi,
    );

    for (int i = 0; i < particleCount; i++) {
      final delay = i * 0.02; // partikel muncul bergiliran
      final rawT = progress - delay;
      if (rawT <= 0) continue;

      // normalisasi supaya selesai saat progress==1
      final t = (rawT / (1 - delay)).clamp(0.0, 1.0);
      final angle = angles[i];

      // ─── posisi radial ───
      double dist;
      if (t < _tailGrowEnd) {
        // belum jauh dari pusat
        dist = explosionRadius * .1; // 10 % jarak akhir
      } else {
        final tt = (t - _tailGrowEnd) / (1 - _tailGrowEnd); // 0‑1
        dist = explosionRadius * _easeOutBack(tt);
      }
      final pos = c + Offset(math.cos(angle), math.sin(angle)) * dist;

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
        final shift = (angle / (2 * math.pi)) * 360 * hueTiltRange;
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
        final tailStart =
            pos - Offset(math.cos(angle), math.sin(angle)) * tailLen;
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

  // easing
  double _easeOutBack(double t) {
    const c1 = 1.70158;
    const c3 = c1 + 1;
    return 1 + c3 * math.pow(t - 1, 3) + c1 * math.pow(t - 1, 2);
  }

  // overrides
  @override
  bool shouldRepaint(EffectAnimator old) =>
      old is! ShapeExplodeOutAnimator ||
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

class OrbitBloomAnimatorV2 implements EffectAnimator {
  // ───── tampilan ─────
  final int particleCount; // jumlah partikel (12 default)
  final double circleRadius; // radius titik
  final double tailFactor; // tailLen = circleRadius * tailFactor
  final double orbitMargin; // px di luar sisi terbesar widget
  final double bloomExtra; // penambahan radius di fase bloom
  final bool useUniformAngle;

  // ───── warna ─────
  final bool enableHueTilt;
  final double hueTiltRange;
  final double saturationBoost;

  OrbitBloomAnimatorV2({
    this.particleCount = 12,
    this.circleRadius = 6,
    this.tailFactor = 3,
    this.orbitMargin = 10,
    this.bloomExtra = 30,
    this.useUniformAngle = true,
    //
    this.enableHueTilt = true,
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

    // radius orbit = (sisi TERBESAR / 2) + margin
    final double baseOrbit =
        (math.max(size.width, size.height) / 2 + orbitMargin) *
            radiusMultiplier;

    // sudut dasar (deterministik)
    final angles = List<double>.generate(
      particleCount,
      (i) => useUniformAngle
          ? (i / particleCount) * 2 * math.pi
          : rnd.nextDouble() * 2 * math.pi,
    );

    for (int i = 0; i < particleCount; i++) {
      // sedikit stagger supaya terlihat dinamis
      final delay = i * 0.015;
      final rawT = progress - delay;
      if (rawT <= 0) continue;

      // normalisasi agar selesai di progress==1
      final t = (rawT / (1 - delay)).clamp(0.0, 1.0);
      final angle = angles[i];

      // ── radius & sudut ──
      double r, theta;
      if (t < _launchEnd) {
        final tt = t / _launchEnd; // 0‑1
        r = _easeOutBack(tt) * baseOrbit; // meluncur ke orbit
        theta = angle;
      } else if (t < _orbitEnd) {
        final tt = (t - _launchEnd) / (_orbitEnd - _launchEnd);
        r = baseOrbit;
        theta = angle + 2 * math.pi * 1.0 * tt; // 1 putaran penuh
      } else {
        final tt = (t - _orbitEnd) / (1 - _orbitEnd);
        r = baseOrbit + bloomExtra * tt; // bloom melebar
        theta = angle + 2 * math.pi; // stop berputar
      }

      final pos = c + Offset(math.cos(theta), math.sin(theta)) * r;

      // ── tail ── (selalu mengarah ke pusat)
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

      final tailStart =
          pos - Offset(math.cos(theta), math.sin(theta)) * tailLen;

      // ── skala & opasitas ──
      final opacity = t < .9 ? 1.0 : 1 - (t - .9) / .1;
      final scale = opacity; // titik mengecil seiring pudar

      // ── warna ──
      Color col = color;
      if (enableHueTilt) {
        final hsl = HSLColor.fromColor(color);
        final shift = (angle / (2 * math.pi)) * 360 * hueTiltRange;
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

  // ───── easing helpers ─────
  double _easeOutBack(double t) {
    const c1 = 1.70158, c3 = c1 + 1;
    return 1 + c3 * math.pow(t - 1, 3) + c1 * math.pow(t - 1, 2);
  }

  // ───── overrides ─────
  @override
  bool shouldRepaint(EffectAnimator old) => true;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  @override
  double getDefaultRadiusMultiplier() => 1.0;

  @override
  double getOuterPadding() =>
      orbitMargin + bloomExtra + circleRadius * tailFactor;
}

class CircleBurstAnimator implements EffectAnimator {
  // ───── konfigurasi ─────
  final int particleCount;
  final bool enableHueTilt; // aktifkan gradasi
  final double hueTiltRange; // 0‑1 (1 = 360°)
  final double saturationBoost; // 1 = tak berubah
  final bool enableBloom; // lingkaran “halo” di puncak animasi
  final double bloomWidth; // strokeWidth halo

  final List<_Particle> _particles = [];
  final Random _random = Random();

  CircleBurstAnimator({
    this.particleCount = 20,
    this.enableHueTilt = true,
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
    final orbitScale = size.width * .7 * radiusMultiplier;

    // progress radial: 0 → 1 → 0
    final distP = progress < .5
        ? _easeOutQuad(progress * 2)
        : _easeInQuad(2 - progress * 2);

    // ----- BLOOM halo (opsional) -----
    if (enableBloom && (progress > .45 && progress < .55)) {
      final bloomT = (progress - .45) / .1; // 0‑1
      final opacity = 1 - (bloomT - .5).abs() * 2; // naik lalu turun
      final radius = orbitScale * 1.05;

      canvas.drawCircle(
          c,
          radius,
          Paint()
            ..color = baseColor.withOpacity(opacity * .4)
            ..style = PaintingStyle.stroke
            ..strokeWidth = bloomWidth * radiusMultiplier
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3)); // glow
    }

    // ----- partikel -----
    for (final p in _particles) {
      final curDist =
          p.maxDistance * distP * orbitScale / 30; // 30 = skala asal

      final pos = c + Offset(math.cos(p.angle), math.sin(p.angle)) * curDist;

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
        final shift = (p.angle / (2 * math.pi)) * 360 * hueTiltRange;
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

  // ───── easing ─────
  double _easeOutQuad(double t) => t * (2 - t);
  double _easeInQuad(double t) => t * t;

  // ───── overrides ─────
  @override
  bool shouldRepaint(EffectAnimator old) => true;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;
  @override
  double getDefaultRadiusMultiplier() => 1;
  @override
  double getOuterPadding() => 25;
}

// ───── model partikel ─────
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

class CircleBurstCleanAnimator implements EffectAnimator {
  // ─── konfigurasi utama ───
  final int particleCount;
  final bool enableHueTilt;
  final double hueTiltRange; // 0–1  (1 = 360° penuh)
  final double saturationBoost;
  final bool enableBloom; // true = gambar halo
  final double bloomWidth; // strokeWidth halo

  final List<_Particle> _particles = [];

  CircleBurstCleanAnimator({
    this.particleCount = 18,
    this.enableHueTilt = true,
    this.hueTiltRange = .30,
    this.saturationBoost = 1.1,
    this.enableBloom = true,
    this.bloomWidth = 2.5,
  });

  // inisialisasi satu kali
  void _initParticles() {
    if (_particles.isNotEmpty) return;

    for (int i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * 2 * math.pi; // RATA, tanpa jitter
      _particles.add(_Particle(
        angle: angle,
        maxDistance: 30, // semua sama → lingkaran rapi
        baseSize: 4,
        pulseRate: 2, // pulsa lembut
      ));
    }
  }

  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color baseColor,
      {double radiusMultiplier = 1, Offset positionOffset = Offset.zero}) {
    _initParticles();

    final c = center + positionOffset;
    final orbitScale = size.width * .7 * radiusMultiplier;

    // 0→1→0 jarak radial
    final distP = progress < .5
        ? _easeOutQuad(progress * 2)
        : _easeInQuad(2 - progress * 2);

    // ─── bloom halo (tanpa blur) ───
    if (enableBloom && progress > .45 && progress < .55) {
      final t = (progress - .45) / .1; // 0‑1
      final opacity = 1 - (t - .5).abs() * 2; // naik lalu turun
      final radius = orbitScale * 1.05;

      canvas.drawCircle(
        c,
        radius,
        Paint()
          ..color = baseColor.withOpacity(opacity * .5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = bloomWidth * radiusMultiplier,
      );
    }

    // ─── partikel ───
    for (final p in _particles) {
      final curDist = p.maxDistance * distP * orbitScale / 30;

      final pos = c +
          Offset(
            math.cos(p.angle) * curDist,
            math.sin(p.angle) * curDist,
          );

      // pulsasi ukuran
      final pulse = .5 + .5 * math.sin(progress * math.pi * 2 * p.pulseRate);
      final sizePx = p.baseSize * pulse * radiusMultiplier;

      // opacity fade in/out
      double opacity = 1;
      if (distP < .2)
        opacity = distP / .2;
      else if (distP > .8) opacity = (1 - distP) / .2;

      // warna (HSV shift opsional)
      Color col = baseColor;
      if (enableHueTilt) {
        final hsl = HSLColor.fromColor(baseColor);
        final shift = (p.angle / (2 * math.pi)) * 360 * hueTiltRange;
        col = hsl
            .withHue((hsl.hue + shift) % 360)
            .withSaturation((hsl.saturation * saturationBoost).clamp(0, 1))
            .toColor();
      }
      col = col.withOpacity(opacity);

      // gambar lingkaran inti (TIDAK ada blur/glow)
      canvas.drawCircle(pos, sizePx, Paint()..color = col);
    }
  }

  // ─── easing ───
  double _easeOutQuad(double t) => t * (2 - t);
  double _easeInQuad(double t) => t * t;

  // ─── overrides ───
  @override
  bool shouldRepaint(EffectAnimator old) => true;
  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;
  @override
  double getDefaultRadiusMultiplier() => 1;
  @override
  double getOuterPadding() => 25;
}

class MagicDustAnimator implements EffectAnimator {
  // ─── kecepatan ───
  final double speed;

  // ─── tampilan ───
  final int particleCount;
  final double baseSize;
  final double areaScale;
  final double gravity;

  // ─── warna ───
  final bool enableHueTilt;
  final double hueTiltRange;
  final double saturationBoost;

  MagicDustAnimator({
    this.speed = 1.0,
    this.particleCount = 40,
    this.baseSize = 3,
    this.areaScale = .7,
    this.gravity = 20,
    this.enableHueTilt = true,
    this.hueTiltRange = .30,
    this.saturationBoost = 1.1,
  });

  @override
  void paint(Canvas cv, Size size, double p, Offset center, Color base,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final progress = (p * speed).clamp(0.0, 1.0); // ❶ skala progress

    final c = center + positionOffset;
    final areaR = size.width * areaScale * radiusMultiplier;
    final rnd = math.Random(42);

    for (int i = 0; i < particleCount; i++) {
      final prnd = math.Random(i * 97);
      final delay = prnd.nextDouble() * .3 / speed; // ❷ delay diperkecil
      final t = (progress - delay).clamp(0.0, 1.0);
      if (t == 0) continue;

      final angle = prnd.nextDouble() * 2 * math.pi;
      final startDist = areaR * (.5 + prnd.nextDouble() * .5);
      final dist = startDist * (1 - t * .6);

      var pos = c + Offset(math.cos(angle) * dist, math.sin(angle) * dist);
      pos = pos.translate(0, gravity * t * t);

      final sizePx = baseSize * radiusMultiplier * (1 - t * .3);

      double opacity;
      if (t < .3)
        opacity = t / .3;
      else if (t > .7)
        opacity = (1 - t) / .3;
      else
        opacity = 1;

      Color col = base;
      if (enableHueTilt) {
        final hsl = HSLColor.fromColor(base);
        final shift = (angle / (2 * math.pi)) * 360 * hueTiltRange;
        col = hsl
            .withHue((hsl.hue + shift) % 360)
            .withSaturation((hsl.saturation * saturationBoost).clamp(0, 1))
            .toColor();
      }
      col = col.withOpacity(opacity);

      cv.drawCircle(pos, sizePx, Paint()..color = col);
    }
  }

  // ------------------------------ overrides
  @override
  bool shouldRepaint(EffectAnimator old) =>
      old is! MagicDustAnimator ||
      old.speed != speed ||
      old.enableHueTilt != enableHueTilt ||
      old.hueTiltRange != hueTiltRange ||
      old.saturationBoost != saturationBoost;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;
  @override
  double getDefaultRadiusMultiplier() => 1.2;
  @override
  double getOuterPadding() => areaScale * 0.7 * 100;
}

class PixelExplosionAnimator implements EffectAnimator {
  // ─── kecepatan (1 = normal) ───
  final double speed;

  // ─── warna ───
  final bool enableHueTilt;
  final double hueTiltRange; // 0‑1
  final double saturationBoost;

  PixelExplosionAnimator({
    this.speed = 1.0,
    this.enableHueTilt = true,
    this.hueTiltRange = .30,
    this.saturationBoost = 1.1,
  });

  // ------------------------------ paint
  @override
  void paint(Canvas canvas, Size size, double p, Offset center, Color base,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final progress = (p * speed).clamp(0.0, 1.0); // ❶ skala progress

    final c = center + positionOffset;
    final explosionR = size.width * .6 * radiusMultiplier;
    const pixelCount = 60;
    const baseSize = 3.0;

    for (int i = 0; i < pixelCount; i++) {
      final rnd = math.Random(i * 97);
      final angle = rnd.nextDouble() * 2 * math.pi;
      final speedFactor = .5 + rnd.nextDouble(); // 0.5–1.5

      double dist, sizePx, opacity;

      if (progress < .2) {
        final t = progress / .2;
        final startDist = explosionR * (.3 + rnd.nextDouble() * .7);
        dist = startDist * (1 - t);
        sizePx = baseSize * (.5 + t * .5);
        opacity = .3 + t * .7;
      } else if (progress < .6) {
        final t = (progress - .2) / .4;
        dist = explosionR * math.pow(t, 1.5) * speedFactor;
        sizePx = baseSize * (1 + rnd.nextDouble() * .5);
        opacity = 1;
      } else {
        final t = (progress - .6) / .4;
        dist = explosionR * (speedFactor + .2 * t * speedFactor);
        sizePx = baseSize * (1 - t * .5);
        opacity = 1 - t;
      }

      final pos = c + Offset(math.cos(angle) * dist, math.sin(angle) * dist);

      // warna (HSV shift opsional)
      Color col = base;
      if (enableHueTilt) {
        final hsl = HSLColor.fromColor(base);
        final shift = (angle / (2 * math.pi)) * 360 * hueTiltRange;
        col = hsl
            .withHue((hsl.hue + shift) % 360)
            .withSaturation((hsl.saturation * saturationBoost).clamp(0, 1))
            .toColor();
      }
      col = col.withOpacity(opacity);

      canvas.drawCircle(pos, sizePx * radiusMultiplier, Paint()..color = col);

      // highlight 20 %
      if (rnd.nextDouble() < .2) {
        canvas.drawCircle(
            pos.translate(-sizePx * .25, -sizePx * .25),
            sizePx * .2,
            Paint()..color = Colors.white.withOpacity(opacity * .8));
      }
    }
  }

  // ------------------------------ overrides
  @override
  bool shouldRepaint(EffectAnimator old) =>
      old is! PixelExplosionAnimator ||
      old.speed != speed ||
      old.enableHueTilt != enableHueTilt ||
      old.hueTiltRange != hueTiltRange ||
      old.saturationBoost != saturationBoost;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;
  @override
  double getDefaultRadiusMultiplier() => 1.2;
  @override
  double getOuterPadding() => 22.0;
}

/// Gelombang pulsa melingkar dengan partikel yang muncul dan menghilang.
class PulseWaveAnimator implements EffectAnimator {
  // ---------- tampilan ----------
  final int ringCount; // jumlah gelombang
  final int particlesPerRing; // jumlah partikel per gelombang
  final double particleRadius; // ukuran partikel
  final double waveScale; // jarak maksimum gelombang
  final double waveThickness; // ketebalan gelombang
  final double waveSpeed; // kecepatan gelombang

  // ---------- opsi warna ----------
  final bool enableHueTilt; // aktifkan gradasi
  final double hueTiltRange; // 0‑1  (1 = 360° penuh)
  final double saturationBoost; // 1 = tak berubah

  PulseWaveAnimator({
    this.ringCount = 3,
    this.particlesPerRing = 16,
    this.particleRadius = 4,
    this.waveScale = 0.8,
    this.waveThickness = 0.15,
    this.waveSpeed = 0.8,
    //
    this.enableHueTilt = true,
    this.hueTiltRange = 0.3,
    this.saturationBoost = 1.1,
  });

  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final c = center + positionOffset;
    final shortestSide = math.min(size.width, size.height);
    final maxRadius = shortestSide * waveScale * radiusMultiplier;

    for (int ring = 0; ring < ringCount; ring++) {
      // Fase untuk setiap gelombang (offset sesuai nomor ring)
      final ringPhase = (progress + (ring / ringCount)) % 1.0;

      // Radius gelombang
      final waveRadius = maxRadius * ringPhase * waveSpeed;

      // Opacity berdasarkan fase (muncul dan menghilang)
      final opacity = _pulseOpacity(ringPhase);
      if (opacity <= 0) continue;

      // Gambar partikel pada gelombang
      for (int i = 0; i < particlesPerRing; i++) {
        final angle = (i / particlesPerRing) * 2 * math.pi;

        // Efek jitter - partikel bergerak sedikit ke dalam/luar
        final jitter = math.sin(angle * 3 + progress * 10) *
            waveThickness *
            maxRadius *
            0.3;
        final particleRadius = waveRadius + jitter;

        final pos =
            c + Offset(math.cos(angle), math.sin(angle)) * particleRadius;

        // Warna partikel
        Color particleColor = color;
        if (enableHueTilt) {
          final hsl = HSLColor.fromColor(color);
          final hueShiftDeg = (angle / (2 * math.pi)) * 360 * hueTiltRange;
          particleColor = hsl
              .withHue((hsl.hue + hueShiftDeg) % 360)
              .withSaturation(
                  (hsl.saturation * saturationBoost).clamp(0.0, 1.0))
              .toColor();
        }
        particleColor = particleColor.withOpacity(opacity);

        // Ukuran partikel berdasarkan fase
        final particleSize = this.particleRadius *
            radiusMultiplier *
            (1.0 + math.sin(ringPhase * math.pi) * 0.5);

        // Gambar partikel
        canvas.drawCircle(pos, particleSize, Paint()..color = particleColor);

        // Gambar ekor pendek (opsional)
        final tailLen = particleSize * 1.5;
        final inwardAngle = angle + math.pi; // mengarah ke dalam
        final tailEnd = pos +
            Offset(math.cos(inwardAngle), math.sin(inwardAngle)) * tailLen;

        canvas.drawLine(
            pos,
            tailEnd,
            Paint()
              ..color = particleColor.withOpacity(opacity * 0.7)
              ..strokeWidth = particleSize * 0.5
              ..strokeCap = StrokeCap.round);
      }
    }
  }

  // Fungsi untuk menentukan opacity berdasarkan fase
  double _pulseOpacity(double phase) {
    if (phase < 0.1) {
      // Fase awal - muncul
      return phase / 0.1;
    } else if (phase > 0.8) {
      // Fase akhir - menghilang
      return (1.0 - phase) / 0.2;
    } else {
      // Fase tengah - penuh
      return 1.0;
    }
  }

  // overrides
  @override
  bool shouldRepaint(EffectAnimator old) =>
      old is! PulseWaveAnimator ||
      old.ringCount != ringCount ||
      old.particlesPerRing != particlesPerRing ||
      old.particleRadius != particleRadius ||
      old.waveScale != waveScale ||
      old.waveThickness != waveThickness ||
      old.waveSpeed != waveSpeed ||
      old.enableHueTilt != enableHueTilt ||
      old.hueTiltRange != hueTiltRange ||
      old.saturationBoost != saturationBoost;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;
  @override
  double getDefaultRadiusMultiplier() => 1;
  @override
  double getOuterPadding() => waveScale * 100;
}

/// DotBurst animator dengan titik-titik yang meledak keluar dengan pola elastis dan ekor opsional.
class DotBurstAnimator implements EffectAnimator {
  // ---------- tampilan ----------
  final int dotCount;
  final double dotSize; // ukuran dot
  final double dotTailFactor; // panjang ekor (opsional)
  final bool enableTail; // aktifkan ekor
  final double explosionScale; // jarak lempar relatif sisi terpendek
  final double pulseEffect; // efek pulsasi pada dot (0-1)

  // ---------- opsi warna ----------
  final bool enableHueTilt; // aktifkan gradasi
  final double hueTiltRange; // 0‑1  (1 = 360° penuh)
  final double saturationBoost; // 1 = tak berubah

  DotBurstAnimator({
    this.dotCount = 24,
    this.dotSize = 6,
    this.dotTailFactor = 2.5,
    this.enableTail = true,
    this.explosionScale = .75,
    this.pulseEffect = 0.3,
    //
    this.enableHueTilt = true,
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
    final explosionRadius = shortestSide * explosionScale * radiusMultiplier;

    // sudut awal
    final List<double> angles = List.generate(
      dotCount,
      (i) => (i / dotCount) * 2 * math.pi,
    );

    for (int i = 0; i < dotCount; i++) {
      final delay = i * 0.02;
      final rawT = progress - delay;
      if (rawT <= 0) continue;

      // normalisasi progress
      final t = (rawT / (1 - delay)).clamp(0.0, 1.0);

      final baseAngle = angles[i];

      // ---- posisi ----
      double distance;
      if (t < _burstPhase) {
        final burstT = t / _burstPhase;
        distance = explosionRadius * _easeOutElastic(burstT);
      } else {
        final fallT = (t - _burstPhase) / (1 - _burstPhase);
        distance = explosionRadius + (fallT * fallT * 50);
      }

      final pos =
          c + Offset(math.cos(baseAngle), math.sin(baseAngle)) * distance;

      // ---- skala & opasitas ----
      // Tambahkan efek pulsasi pada ukuran dot
      final pulseScale = 1.0 + math.sin(t * math.pi * 6) * pulseEffect;
      final scale = (t < .15
              ? t / .15
              : t > .80
                  ? (1 - t) / .20
                  : 1.0) *
          pulseScale;

      final opacity = t < .15
          ? t / .15
          : t > .80
              ? (1 - t) / .20
              : 1.0;

      // ---- warna ----
      Color dotColor = color;
      if (enableHueTilt) {
        final hsl = HSLColor.fromColor(color);
        final hueShiftDeg = (baseAngle / (2 * math.pi)) * 360 * hueTiltRange;
        dotColor = hsl
            .withHue((hsl.hue + hueShiftDeg) % 360)
            .withSaturation((hsl.saturation * saturationBoost).clamp(0.0, 1.0))
            .toColor();
      }
      dotColor = dotColor.withOpacity(opacity);

      // ---- gambar dot ----
      final rad = dotSize * radiusMultiplier * scale;
      canvas.drawCircle(pos, rad, Paint()..color = dotColor);

      // Tambahkan ekor jika diaktifkan
      if (enableTail) {
        final tailLen = rad * dotTailFactor;
        final tailStart =
            pos - Offset(math.cos(baseAngle), math.sin(baseAngle)) * tailLen;

        canvas.drawLine(
            tailStart,
            pos,
            Paint()
              ..color = dotColor.withOpacity(opacity * 0.7)
              ..strokeWidth = rad * 0.8
              ..strokeCap = StrokeCap.round);
      }
    }
  }

  // easing
  double _easeOutElastic(double t) {
    const c4 = (2 * math.pi) / 3;
    return t == 0
        ? 0
        : t == 1
            ? 1
            : math.pow(2, -10 * t) * math.sin((t * 10 - 0.75) * c4) + 1;
  }

  // overrides
  @override
  bool shouldRepaint(EffectAnimator old) =>
      old is! DotBurstAnimator ||
      old.dotCount != dotCount ||
      old.dotSize != dotSize ||
      old.dotTailFactor != dotTailFactor ||
      old.enableTail != enableTail ||
      old.explosionScale != explosionScale ||
      old.pulseEffect != pulseEffect ||
      old.enableHueTilt != enableHueTilt ||
      old.hueTiltRange != hueTiltRange ||
      old.saturationBoost != saturationBoost;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;
  @override
  double getDefaultRadiusMultiplier() => 1;
  @override
  double getOuterPadding() => explosionScale * 100 + dotSize * 2;
}

/// DotAbsorbBurstAnimator dengan efek partikel yang menyerap dari luar lalu meledak keluar.
/// DotAbsorbBurstAnimator dengan efek partikel yang menyerap dari luar lalu meledak keluar.
/// DotAbsorbBurstAnimator dengan efek partikel yang menyerap dari luar lalu meledak keluar.
/// Partikel terdistribusi merata di sepanjang 360 derajat.
class DotAbsorbBurstAnimator implements EffectAnimator {
  // ---------- tampilan ----------
  final int dotCount;
  final double dotSize; // ukuran dot
  final double dotTailFactor; // panjang ekor (opsional)
  final bool enableTail; // aktifkan ekor
  final double explosionScale; // jarak lempar relatif sisi terpendek
  final double absorptionScale; // jarak awal partikel sebelum absorpsi
  final double pulseEffect; // efek pulsasi pada dot (0-1)

  // ---------- fase animasi ----------
  final double absorbPhase; // proporsi animasi untuk fase penyerapan (0-1)
  final double
      holdPhase; // proporsi animasi untuk fase diam setelah menyerap (0-1)

  // ---------- opsi warna ----------
  final bool enableHueTilt; // aktifkan gradasi
  final double hueTiltRange; // 0‑1  (1 = 360° penuh)
  final double saturationBoost; // 1 = tak berubah

  DotAbsorbBurstAnimator({
    this.dotCount = 5,
    this.dotSize = 15,
    this.dotTailFactor = 1.0,
    this.enableTail = true,
    this.explosionScale = .8,
    this.absorptionScale =
        1.2, // jarak awal sebelum menyerap (lebih besar dari explosionScale)
    this.pulseEffect = 0.25,
    //
    this.absorbPhase = 0.4, // 40% waktu animasi untuk menyerap
    this.holdPhase = 0.15, // 15% waktu animasi untuk diam
    //
    this.enableHueTilt = true,
    this.hueTiltRange = .45,
    this.saturationBoost = 1.2,
  });

  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final c = center + positionOffset;
    final shortestSide = math.min(size.width, size.height);
    final explosionRadius = shortestSide * explosionScale * radiusMultiplier;
    final absorptionRadius = shortestSide * absorptionScale * radiusMultiplier;

    // Sudut awal semua partikel - terdistribusi secara merata 360 derajat
    final List<double> angles = List.generate(
      dotCount,
      (i) => (i / dotCount) * 2 * math.pi,
    );

    // Random untuk variasi
    final rnd = math.Random(42);

    // Fase animasi
    final bool isInAbsorbPhase = progress <= absorbPhase;
    final bool isInHoldPhase =
        progress > absorbPhase && progress <= (absorbPhase + holdPhase);
    final bool isInBurstPhase = progress > (absorbPhase + holdPhase);

    for (int i = 0; i < dotCount; i++) {
      final baseAngle = angles[i];

      // Variasi latar belakang per partikel
      final particleVariation = 0.1 + rnd.nextDouble() * 0.2; // 10-30% variasi

      double particleProgress = progress;
      double distance = 0;
      double opacity = 1.0;
      double scale = 1.0;

      // ---- Hitung posisi berdasarkan fase ----
      if (isInAbsorbPhase) {
        // Fase absorpsi: partikel bergerak dari luar ke dalam
        final absorbProgress = progress / absorbPhase;
        // Fungsi easing untuk gerakan menyerap
        final easedProgress = _easeInOutQuint(absorbProgress);

        // Posisi awal selalu pada sudut yang sama, mulai dari jarak absorptionRadius
        distance = absorptionRadius * (1.0 - easedProgress);

        // Skala partikel membesar saat mendekati pusat
        scale = 0.3 + absorbProgress * 0.7;

        // Opacity bertambah saat mendekati pusat
        opacity = 0.4 + absorbProgress * 0.6;
      } else if (isInHoldPhase) {
        // Fase diam: partikel berkumpul di pusat dan berdenyut
        distance = 0;

        // Pulsasi saat hold
        final holdProgress = (progress - absorbPhase) / holdPhase;
        final pulse = 0.8 + math.sin(holdProgress * math.pi * 8) * 0.4;
        scale = pulse;

        opacity = 1.0;
      } else {
        // Fase burst: partikel meledak keluar dari dalam ke luar
        final burstProgress = (progress - (absorbPhase + holdPhase)) /
            (1.0 - (absorbPhase + holdPhase));

        // Tidak ada delay untuk partikel, semua bergerak serentak
        // Efek elastic saat meledak keluar
        distance = explosionRadius * _easeOutElastic(burstProgress);

        // Skala dan opacity
        scale = burstProgress < 0.15
            ? burstProgress / 0.15
            : burstProgress > 0.8
                ? (1.0 - burstProgress) / 0.2
                : 1.0;

        opacity = burstProgress < 0.15
            ? burstProgress / 0.15
            : burstProgress > 0.8
                ? (1.0 - burstProgress) / 0.2
                : 1.0;
      }

      // Tidak ada variasi jarak untuk memastikan posisi sejajar

      // Posisi final partikel
      final pos =
          c + Offset(math.cos(baseAngle), math.sin(baseAngle)) * distance;

      // ---- warna ----
      Color dotColor = color;
      if (enableHueTilt) {
        final hsl = HSLColor.fromColor(color);
        final hueShiftDeg = (baseAngle / (2 * math.pi)) * 360 * hueTiltRange;
        dotColor = hsl
            .withHue((hsl.hue + hueShiftDeg) % 360)
            .withSaturation((hsl.saturation * saturationBoost).clamp(0.0, 1.0))
            .toColor();
      }
      dotColor = dotColor.withOpacity(opacity);

      // ---- efek pulsasi ----
      if (!isInHoldPhase) {
        final pulseScale = 1.0 + math.sin(progress * math.pi * 6) * pulseEffect;
        scale *= pulseScale;
      }

      // ---- gambar dot ----
      final rad = dotSize * radiusMultiplier * scale;
      canvas.drawCircle(pos, rad, Paint()..color = dotColor);

      // Tambahkan ekor jika diaktifkan dan dalam fase burst
      if (enableTail && isInBurstPhase) {
        final tailLen = rad * dotTailFactor;
        // Ekor mengarah ke belakang arah gerakan
        final tailStart =
            pos - Offset(math.cos(baseAngle), math.sin(baseAngle)) * tailLen;

        canvas.drawLine(
            tailStart,
            pos,
            Paint()
              ..color = dotColor.withOpacity(opacity * 0.7)
              ..strokeWidth = rad * 0.8
              ..strokeCap = StrokeCap.round);
      }
    }
  }

  // easing functions
  double _easeOutElastic(double t) {
    const c4 = (2 * math.pi) / 3;
    return t == 0
        ? 0
        : t == 1
            ? 1
            : math.pow(2, -10 * t) * math.sin((t * 10 - 0.75) * c4) + 1;
  }

  double _easeInOutQuint(double t) {
    return t < 0.5 ? 16 * t * t * t * t * t : 1 - math.pow(-2 * t + 2, 5) / 2;
  }

  // overrides
  @override
  bool shouldRepaint(EffectAnimator old) =>
      old is! DotAbsorbBurstAnimator ||
      old.dotCount != dotCount ||
      old.dotSize != dotSize ||
      old.dotTailFactor != dotTailFactor ||
      old.enableTail != enableTail ||
      old.explosionScale != explosionScale ||
      old.absorptionScale != absorptionScale ||
      old.pulseEffect != pulseEffect ||
      old.absorbPhase != absorbPhase ||
      old.holdPhase != holdPhase ||
      old.enableHueTilt != enableHueTilt ||
      old.hueTiltRange != hueTiltRange ||
      old.saturationBoost != saturationBoost;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;
  @override
  double getDefaultRadiusMultiplier() => 1;
  @override
  double getOuterPadding() => math.max(absorptionScale, explosionScale) * 120;
}

/// Ray Burst animator dengan garis-garis yang memancar dari pusat.
/// Ray Burst animator dengan garis-garis yang memancar dan bergerak keluar dari pusat.
class RayBurstMovingAnimator implements EffectAnimator {
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

  RayBurstMovingAnimator({
    this.rayCount = 16,
    this.lineWidth = 2.0,
    this.lineLength = 30.0, // panjang tetap garis dalam piksel
    this.rayLength = 0.7,
    this.expansionRate = 1.2,
    //
    this.enableHueTilt = true,
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

    // sudut untuk setiap sinar
    final List<double> angles = List.generate(
      rayCount,
      (i) => (i / rayCount) * 2 * math.pi,
    );

    for (int rayIndex = 0; rayIndex < rayCount; rayIndex++) {
      final angle = angles[rayIndex];

      // Sedikit delay antar sinar
      final rayDelay = rayIndex * 0.01;
      final rawT = progress - rayDelay;
      if (rawT <= 0) continue;

      // Normalisasi progress
      final t = (rawT / (1 - rayDelay)).clamp(0.0, 1.0);

      // ---- Jarak pusat garis dari pusat animasi ----
      double distance;
      if (t < _burstPhase) {
        final burstT = t / _burstPhase;
        distance = maxRayDistance * _easeOutCubic(burstT);
      } else {
        final fadeT = (t - _burstPhase) / (1 - _burstPhase);
        distance = maxRayDistance + (fadeT * fadeT * 30);
      }

      // Sesuaikan jarak dengan faktor ekspansi
      final actualDistance = distance * expansionRate;

      // ---- Penghitungan posisi garis yang bergerak keluar ----
      // Titik tengah garis
      final midPoint =
          c + Offset(math.cos(angle), math.sin(angle)) * actualDistance;

      // Titik awal dan akhir garis berdasarkan titik tengah dan panjang garis
      final halfLength = actualLineLength / 2;
      final startPoint =
          midPoint - Offset(math.cos(angle), math.sin(angle)) * halfLength;
      final endPoint =
          midPoint + Offset(math.cos(angle), math.sin(angle)) * halfLength;

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
        final hueShiftDeg = (angle / (2 * math.pi)) * 360 * hueTiltRange;
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

  // easing
  double _easeOutCubic(double t) {
    return 1 - math.pow(1 - t, 3).toDouble();
  }

  // overrides
  @override
  bool shouldRepaint(EffectAnimator old) =>
      old is! RayBurstMovingAnimator ||
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

class CircleOrbitSequentialAnimator implements EffectAnimator {
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

  CircleOrbitSequentialAnimator({
    this.particleCount = 12,
    this.circleRadius = 6,
    this.orbitMargin = 14,
    this.rotations = 1.2,
    this.fadeExtra = 16,
    this.glowSigma = 4,
    this.stagger = .05, // 5 % durasi per dot
    //
    this.enableHueTilt = true,
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
    final orbitR = (math.max(size.width, size.height) / 2 + orbitMargin) *
        radiusMultiplier;

    for (int i = 0; i < particleCount; i++) {
      // setiap dot punya delay = i * stagger
      final delay = i * stagger;
      final rawT = p - delay;
      if (rawT <= 0) continue; // belum lahir

      // progress lokal 0‑1, distorsi supaya selesai tepat di p==1
      final t = (rawT / (1 - delay)).clamp(0.0, 1.0);

      final angle0 = i * 2 * math.pi / particleCount;

      // ── radius & sudut ──
      double r, theta;
      if (t < _launchEnd) {
        r = _easeOutBack(t / _launchEnd) * orbitR;
        theta = angle0;
      } else if (t < _orbitEnd) {
        final tt = (t - _launchEnd) / (_orbitEnd - _launchEnd);
        r = orbitR;
        theta = angle0 + 2 * math.pi * rotations * tt;
      } else {
        final tt = (t - _orbitEnd) / (1 - _orbitEnd);
        r = orbitR + fadeExtra * tt;
        theta = angle0 + 2 * math.pi * rotations;
      }

      final pos = c + Offset(math.cos(theta), math.sin(theta)) * r;

      // ── opacity & skala ──
      final opacity = t < .9 ? 1.0 : 1 - (t - .9) / .1;
      final scale = opacity;

      // ── warna (HSV shift opsional) ──
      Color col = baseColor;
      if (enableHueTilt) {
        final hsl = HSLColor.fromColor(baseColor);
        final shift = (angle0 / (2 * math.pi)) * 360 * hueTiltRange;
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

  // ───── easing helper ─────
  double _easeOutBack(double t) {
    const c1 = 1.70158, c3 = c1 + 1;
    return 1 + c3 * math.pow(t - 1, 3) + c1 * math.pow(t - 1, 2);
  }

  // ───── overrides ─────
  @override
  bool shouldRepaint(EffectAnimator old) => true;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  @override
  double getDefaultRadiusMultiplier() => 1.0;

  @override
  double getOuterPadding() => orbitMargin + fadeExtra + circleRadius;
}

class MultiRingOrbitAnimator implements EffectAnimator {
  // ─── konfigurasi partikel ───
  final int particlesPerRing; // banyak dot tiap ring
  final int ringCount; // berapa ring (1–3 disarankan)
  final double circleRadius; // radius dot
  final double ringGap; // jarak antar ring
  final double orbitMargin; // jarak ring terluar dari widget
  final double rotations; // putaran selama fase orbit
  final double fadeExtra; // sedikit maju saat fade
  final double glowSigma;

  // ─── HSV shift ───
  final bool enableHueTilt;
  final double hueTiltRange;
  final double saturationBoost;

  MultiRingOrbitAnimator({
    this.particlesPerRing = 10,
    this.ringCount = 1,
    this.circleRadius = 12,
    this.ringGap = 10,
    this.orbitMargin = 12,
    this.rotations = 1.2,
    this.fadeExtra = 14,
    this.glowSigma = 4,
    //
    this.enableHueTilt = true,
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

    // radius ring terluar
    final outerR = (math.max(size.width, size.height) / 2 + orbitMargin) *
        radiusMultiplier;

    // radius setiap ring, paling dalam → terluar
    final List<double> ringRadii = List.generate(
      ringCount,
      (i) => outerR - (ringCount - 1 - i) * ringGap * radiusMultiplier,
    );

    for (int ringIdx = 0; ringIdx < ringCount; ringIdx++) {
      final rBase = ringRadii[ringIdx];

      for (int j = 0; j < particlesPerRing; j++) {
        // sudut dasar: ring 0 dan ring 1 di‑offset ½ segmen agar tak sejajar
        final angle0 =
            (j + (ringIdx.isOdd ? .5 : 0)) * 2 * math.pi / particlesPerRing;

        // progress global (semua dot bersama)
        final t = p.clamp(0.0, 1.0);

        // ── radius & sudut ──
        double r, theta;
        if (t < _launchEnd) {
          r = _easeOutBack(t / _launchEnd) * rBase;
          theta = angle0;
        } else if (t < _orbitEnd) {
          final tt = (t - _launchEnd) / (_orbitEnd - _launchEnd);
          r = rBase;
          theta = angle0 + 2 * math.pi * rotations * tt;
        } else {
          final tt = (t - _orbitEnd) / (1 - _orbitEnd);
          r = rBase - _easeIn(tt) * (rBase - fadeExtra);
          theta = angle0 + 2 * math.pi * rotations;
        }

        final pos = c + Offset(math.cos(theta), math.sin(theta)) * r;

        // ── opacity & skala ──
        final opacity = t < .9 ? 1.0 : 1 - (t - .9) / .1;
        final scale = opacity;

        // ── warna (HSV shift) ──
        Color col = baseColor;
        if (enableHueTilt) {
          final hsl = HSLColor.fromColor(baseColor);
          final shift = (angle0 / (2 * math.pi)) * 360 * hueTiltRange;
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

  // ─── easing helpers ───
  double _easeOutBack(double t) {
    const c1 = 1.70158, c3 = c1 + 1;
    return 1 + c3 * math.pow(t - 1, 3) + c1 * math.pow(t - 1, 2);
  }

  double _easeIn(double t) => t * t * t;

  // ─── overrides ───
  @override
  bool shouldRepaint(EffectAnimator old) => true;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;
  @override
  double getDefaultRadiusMultiplier() => 1.0;
  @override
  double getOuterPadding() =>
      orbitMargin + ringGap * (ringCount - 1) + circleRadius;
}

class SequentialRingOrbitAnimator implements EffectAnimator {
  // ─── konfigurasi utama ───
  final int particlesPerRing;
  final int ringCount; // 1–3
  final double circleRadius;
  final double ringGap; // jarak antar ring
  final double orbitMargin; // ring terluar – widget
  final double rotations; // putaran fase orbit
  final double glowSigma;

  // ─── HSV shift ───
  final bool enableHueTilt;
  final double hueTiltRange;
  final double saturationBoost;

  SequentialRingOrbitAnimator({
    this.particlesPerRing = 10,
    this.ringCount = 1,
    this.circleRadius = 6,
    this.ringGap = 10,
    this.orbitMargin = 14,
    this.rotations = 1.2,
    this.glowSigma = 4,
    //
    this.enableHueTilt = true,
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
    final outerR = (math.max(size.width, size.height) / 2 + orbitMargin) *
        radiusMultiplier;

    // radius setiap ring (dalam → luar)
    final List<double> ringR = List.generate(
      ringCount,
      (i) => outerR - (ringCount - 1 - i) * ringGap * radiusMultiplier,
    );

    // durasi spawn per dot (agar dot‑N selesai tepat di _spawnEnd)
    final spawnSlice = _spawnEnd / particlesPerRing;

    for (int ringIdx = 0; ringIdx < ringCount; ringIdx++) {
      final rBase = ringR[ringIdx];

      for (int j = 0; j < particlesPerRing; j++) {
        final angle0 =
            (j + (ringIdx.isOdd ? .5 : 0)) * 2 * math.pi / particlesPerRing;

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

        // ─── radius & sudut ───
        double r, theta;
        if (t <= 1) {
          // fase Spawn (per‑dot)
          r = _easeOutBack(t) * rBase;
          theta = angle0; // belum berputar
        } else if (p < _orbitEnd) {
          // fase Orbit
          final tt = (p - _spawnEnd) / (_orbitEnd - _spawnEnd);
          r = rBase;
          theta = angle0 + 2 * math.pi * rotations * tt;
        } else {
          // fase Return
          final tt = (p - _orbitEnd) / (1 - _orbitEnd);
          r = rBase * (1 - _easeIn(tt));
          theta = angle0 + 2 * math.pi * rotations;
        }

        final pos = c + Offset(math.cos(theta), math.sin(theta)) * r;

        // ─── opacity & skala ───
        final globalFade = p < .92 ? 1.0 : 1 - (p - .92) / .08;
        final scale = globalFade;

        // ─── warna (HSV) ───
        Color col = baseColor;
        if (enableHueTilt) {
          final hsl = HSLColor.fromColor(baseColor);
          final shift = (angle0 / (2 * math.pi)) * 360 * hueTiltRange;
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

  // ─── easing helpers ───
  double _easeOutBack(double t) {
    const c1 = 1.70158, c3 = c1 + 1;
    return 1 + c3 * math.pow(t - 1, 3) + c1 * math.pow(t - 1, 2);
  }

  double _easeIn(double t) => t * t * t;

  // ─── overrides ───
  @override
  bool shouldRepaint(covariant EffectAnimator old) => true;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;
  @override
  double getDefaultRadiusMultiplier() => 1;
  @override
  double getOuterPadding() =>
      orbitMargin + ringGap * (ringCount - 1) + circleRadius;
}

class FlowerCircleAnimator implements EffectAnimator {
  // ───── konfigurasi visual ─────
  final int petalCount; // 6–12
  final double petalRadius; // radius lingkaran kelopak
  final double ringMargin; // jarak dari tepi widget ke pusat kelopak
  final double centerRadius; // radius putik
  final double glowSigma;

  // ───── warna ─────
  final Color petalColor;
  final Color centerColor;
  final bool enableHueTilt;
  final double hueTiltRange;
  final double saturationBoost;

  FlowerCircleAnimator({
    this.petalCount = 8,
    this.petalRadius = 6,
    this.ringMargin = 8,
    this.centerRadius = 10,
    this.glowSigma = 4,
    //
    this.petalColor = const Color(0xFFFF6BAA),
    this.centerColor = const Color(0xFFFFD54F),
    this.enableHueTilt = true,
    this.hueTiltRange = .25,
    this.saturationBoost = 1.1,
  });

  // fase global: grow 0‑.25 → hold .25‑.75 → fade .75‑1
  static const double _growEnd = .25;
  static const double _fadeBeg = .75;

  @override
  void paint(Canvas cv, Size size, double p, Offset center, Color _,
      {double radiusMultiplier = 1, Offset positionOffset = Offset.zero}) {
    final c = center + positionOffset;
    final maxSide = math.max(size.width, size.height);
    final ringR = (maxSide / 2 + ringMargin) * radiusMultiplier;

    final t = p.clamp(0.0, 1.0);

    // ─── kelopak ───
    for (int i = 0; i < petalCount; i++) {
      final baseAngle = i * 2 * math.pi / petalCount;

      // stagger kecil supaya kelopak mekar bergiliran
      final localDelay = i * .03;
      double localT = (t - localDelay).clamp(0.0, 1.0);

      // skala radial (0‑1)
      double grow;
      if (localT < _growEnd) {
        grow = localT / _growEnd; // bergerak keluar
      } else if (localT < _fadeBeg) {
        grow = 1; // diam
      } else {
        final tt = (localT - _fadeBeg) / (1 - _fadeBeg);
        grow = 1 - tt; // kembali ke pusat
      }

      final pos =
          c + Offset(math.cos(baseAngle), math.sin(baseAngle)) * (ringR * grow);

      // opacity
      final opacity =
          localT < _fadeBeg ? 1.0 : 1 - (localT - _fadeBeg) / (1 - _fadeBeg);

      // warna kelopak
      Color col = petalColor;
      if (enableHueTilt) {
        final hsl = HSLColor.fromColor(petalColor);
        final shift = (i / petalCount) * 360 * hueTiltRange;
        col = hsl
            .withHue((hsl.hue + shift) % 360)
            .withSaturation((hsl.saturation * saturationBoost).clamp(0, 1))
            .toColor();
      }
      col = col.withOpacity(opacity);

      // glow lembut
      cv.drawCircle(
          pos,
          petalRadius * 1.6,
          Paint()
            ..color = col.withOpacity(.25)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowSigma));

      // kelopak (lingkaran)
      cv.drawCircle(pos, petalRadius, Paint()..color = col);
    }

    // ─── putik (pusat) ───
    double centerScale;
    if (t < _growEnd) {
      centerScale = t / _growEnd; // tumbuh
    } else if (t < _fadeBeg) {
      centerScale = 1;
    } else {
      centerScale = 1 - (t - _fadeBeg) / (1 - _fadeBeg);
    }

    final centerRad = centerRadius * centerScale * radiusMultiplier;

    // glow putik
    cv.drawCircle(
        c,
        centerRad * 1.8,
        Paint()
          ..color = centerColor.withOpacity(.25 * centerScale)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowSigma));

    cv.drawCircle(
        c, centerRad, Paint()..color = centerColor.withOpacity(centerScale));
  }

  // ─── overrides ───
  @override
  bool shouldRepaint(covariant EffectAnimator old) => true;

  @override
  AnimationPosition getDefaultPosition() =>
      AnimationPosition.outside; // di bawah widget

  @override
  double getDefaultRadiusMultiplier() => 1;

  @override
  double getOuterPadding() => ringMargin + petalLengthEstimate + petalRadius;

  double get petalLengthEstimate => petalRadius * 2; // untuk padding kasar
}

/// Natural flower animator yang membuat bunga alami seperti Hibiscus/Petunia di sekitar widget.
/// Magical aesthetic flower animator dengan detail tinggi dan efek berkilau.
class MagicalFlowerAnimator implements EffectAnimator {
  // ---------- tampilan bunga ----------
  final int petalCount; // jumlah kelopak
  final double petalWidth; // lebar kelopak
  final double petalLength; // panjang kelopak
  final double flowerScale; // skala bunga relatif terhadap radius widget
  final double centerScale; // ukuran pusat bunga relatif terhadap kelopak
  final double petalCurve; // tingkat kelengkungan kelopak (0-1)
  final double petalOverlap; // seberapa banyak kelopak bertumpuk
  final double rotationSpeed; // kecepatan rotasi bunga

  // ---------- efek dekoratif ----------
  final bool enableGlowEffect; // efek berpendar di sekitar bunga
  final bool enableSparkles; // partikel berkilau di sekitar bunga
  final bool enablePatternDetail; // detail pola pada kelopak
  final bool enablePetalGradient; // gradien warna pada kelopak
  final int sparkleCount; // jumlah partikel berkilau

  // ---------- opsi warna ----------
  final bool enableHueTilt; // aktifkan gradasi warna
  final double hueTiltRange; // 0‑1  (1 = 360° penuh)
  final double saturationBoost; // 1 = tak berubah
  final Color centerColor; // warna pusat bunga
  final Color accentColor; // warna aksen untuk detail bunga

  MagicalFlowerAnimator({
    this.petalCount = 5,
    this.petalWidth = 50.0,
    this.petalLength = 70.0,
    this.flowerScale = 1.5,
    this.centerScale = 0.3,
    this.petalCurve = 0.4,
    this.petalOverlap = 0.2,
    this.rotationSpeed = 0.1,
    //
    this.enableGlowEffect = true,
    this.enableSparkles = true,
    this.enablePatternDetail = true,
    this.enablePetalGradient = true,
    this.sparkleCount = 12,
    //
    this.enableHueTilt = true,
    this.hueTiltRange = 0.15,
    this.saturationBoost = 1.2,
    this.centerColor = const Color(0xFF55BBAA),
    this.accentColor = const Color(0xFFFFFFFF),
  });

  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final c = center + positionOffset;
    final radius = math.min(size.width, size.height) / 2;
    final flowerRadius = radius * flowerScale * radiusMultiplier;

    // Rotasi berdasarkan waktu
    final baseRotation = progress * rotationSpeed * 2 * math.pi;

    // Efek mekar dengan animation curve
    double bloomProgress;
    if (progress < 0.4) {
      // Fase mekar (0-40%)
      bloomProgress = _easeOutBack(progress / 0.4);
    } else {
      // Fase stabil dengan efek mengembang/mengecil perlahan
      final waveT = (progress - 0.4) / 0.6;
      bloomProgress = 1.0 + (math.sin(waveT * 3 * math.pi) * 0.05);
    }

    // Opasitas - muncul perlahan
    final opacity = progress < 0.15
        ? progress / 0.15
        : progress > 0.85
            ? (1 - (progress - 0.85) / 0.15)
            : 1.0;

    // ----- Gambar efek glow jika diaktifkan -----
    if (enableGlowEffect) {
      final glowRadius = flowerRadius * 1.1 * bloomProgress;
      final glowPaint = Paint()
        ..shader = ui.Gradient.radial(
          c,
          glowRadius,
          [
            color.withOpacity(0.3 * opacity),
            color.withOpacity(0.1 * opacity),
            color.withOpacity(0.0),
          ],
          [0.5, 0.8, 1.0],
        );

      canvas.drawCircle(c, glowRadius, glowPaint);
    }

    // ----- Gambar kelopak-kelopak bunga -----
    final actualPetalLength = petalLength * radiusMultiplier * bloomProgress;
    final actualPetalWidth = petalWidth * radiusMultiplier * bloomProgress;

    // Sudut untuk setiap kelopak dengan overlap
    final overlapAngle = (petalOverlap * 2 * math.pi) / petalCount;
    final List<double> angles = List.generate(
      petalCount,
      (i) => (i / petalCount) * 2 * math.pi + baseRotation - overlapAngle,
    );

    // Gambar kelopak dari belakang ke depan
    for (int i = 0; i < petalCount; i++) {
      final angle = angles[i];

      // Warna kelopak dengan variasi halus antar kelopak
      Color petalBaseColor = color;
      if (enableHueTilt) {
        final hsl = HSLColor.fromColor(color);
        final hueShiftDeg = (i / petalCount) * 360 * hueTiltRange;
        petalBaseColor = hsl
            .withHue((hsl.hue + hueShiftDeg) % 360)
            .withSaturation((hsl.saturation * saturationBoost).clamp(0.0, 1.0))
            .toColor();
      }
      petalBaseColor = petalBaseColor.withOpacity(opacity);

      // Gambar kelopak dengan detail estetik
      _drawMagicalPetal(
        canvas: canvas,
        center: c,
        angle: angle,
        petalLength: actualPetalLength,
        petalWidth: actualPetalWidth,
        curve: petalCurve,
        baseColor: petalBaseColor,
        accentColor: accentColor.withOpacity(opacity * 0.8),
        enablePattern: enablePatternDetail,
        enableGradient: enablePetalGradient,
        progress: progress,
        index: i,
      );
    }

    // ----- Gambar pusat bunga dengan detail -----
    final centerSize = actualPetalLength * centerScale;

    // Warna pusat
    Color actualCenterColor = centerColor.withOpacity(opacity);

    // Buat berkilau sedikit perlahan
    final glowIntensity = (math.sin(progress * 5) * 0.3) + 0.7;

    // Lingkaran luar (putih)
    canvas.drawCircle(
        c,
        centerSize * 1.05,
        Paint()
          ..color = Colors.white.withOpacity(opacity * 0.9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = centerSize * 0.15);

    // Lingkaran dalam (pusat)
    final centerPaint = Paint()
      ..shader = ui.Gradient.radial(
        c,
        centerSize,
        [
          HSLColor.fromColor(actualCenterColor)
              .withLightness(
                  (HSLColor.fromColor(actualCenterColor).lightness * 1.3)
                      .clamp(0.0, 1.0))
              .toColor()
              .withOpacity(opacity * glowIntensity),
          actualCenterColor,
          HSLColor.fromColor(actualCenterColor)
              .withLightness(
                  (HSLColor.fromColor(actualCenterColor).lightness * 0.7)
                      .clamp(0.0, 1.0))
              .toColor()
              .withOpacity(opacity),
        ],
        [0.3, 0.6, 1.0],
      );

    canvas.drawCircle(c, centerSize, centerPaint);

    // Detail pada pusat bunga
    _drawCenterDetail(
      canvas: canvas,
      center: c,
      radius: centerSize,
      baseColor: actualCenterColor,
      accentColor: accentColor.withOpacity(opacity * 0.9),
      progress: progress,
    );

    // ----- Gambar sparkles jika diaktifkan -----
    if (enableSparkles) {
      _drawSparkles(
        canvas: canvas,
        center: c,
        radius: flowerRadius * 1.2,
        count: sparkleCount,
        baseColor: accentColor.withOpacity(opacity * 0.9),
        progress: progress,
      );
    }
  }

  // Metode untuk menggambar kelopak dengan efek magis
  void _drawMagicalPetal({
    required Canvas canvas,
    required Offset center,
    required double angle,
    required double petalLength,
    required double petalWidth,
    required double curve,
    required Color baseColor,
    required Color accentColor,
    required bool enablePattern,
    required bool enableGradient,
    required double progress,
    required int index,
  }) {
    // Posisi ujung kelopak
    final tipPosition =
        center + Offset(math.cos(angle), math.sin(angle)) * petalLength;

    // Posisi untuk titik kontrol Bezier
    final controlDist = petalLength * 0.6;
    final controlWidth = petalWidth * 0.6;

    // Sudut untuk titik tepi kelopak
    final rightAngle = angle + math.pi / 2;
    final leftAngle = angle - math.pi / 2;

    // Titik dasar kelopak, sedikit lebih dekat ke pusat
    final baseOffset = petalLength * 0.15;
    final basePosition =
        center + Offset(math.cos(angle), math.sin(angle)) * baseOffset;

    // Titik tepi kanan dan kiri kelopak
    final rightEdge = basePosition +
        Offset(math.cos(rightAngle), math.sin(rightAngle)) * controlWidth * 0.5;
    final leftEdge = basePosition +
        Offset(math.cos(leftAngle), math.sin(leftAngle)) * controlWidth * 0.5;

    // Titik kontrol Bezier dengan efek gelombang diujung
    final waveFactor = math.sin(progress * 4 + index) * 0.1 + 1.0;

    final rightControl1 = center +
        Offset(math.cos(angle), math.sin(angle)) * controlDist * 0.3 +
        Offset(math.cos(rightAngle), math.sin(rightAngle)) * controlWidth;

    final rightControl2 = center +
        Offset(math.cos(angle), math.sin(angle)) * controlDist * 0.7 +
        Offset(math.cos(rightAngle), math.sin(rightAngle)) *
            controlWidth *
            (curve * waveFactor);

    final leftControl1 = center +
        Offset(math.cos(angle), math.sin(angle)) * controlDist * 0.3 +
        Offset(math.cos(leftAngle), math.sin(leftAngle)) * controlWidth;

    final leftControl2 = center +
        Offset(math.cos(angle), math.sin(angle)) * controlDist * 0.7 +
        Offset(math.cos(leftAngle), math.sin(leftAngle)) *
            controlWidth *
            (curve * waveFactor);

    // Buat path untuk kelopak
    final path = Path();
    path.moveTo(rightEdge.dx, rightEdge.dy);
    path.cubicTo(rightControl1.dx, rightControl1.dy, rightControl2.dx,
        rightControl2.dy, tipPosition.dx, tipPosition.dy);
    path.cubicTo(leftControl2.dx, leftControl2.dy, leftControl1.dx,
        leftControl1.dy, leftEdge.dx, leftEdge.dy);
    path.close();

    // Setup paint untuk kelopak
    final petalPaint = Paint();

    // Efek gradien pada kelopak
    if (enableGradient) {
      // Posisi highlight spot untuk efek cahaya
      final highlightAngle = angle + (math.sin(progress * 3) * 0.3);
      final highlightDistance = petalLength * 0.6;
      final highlightPos = center +
          Offset(math.cos(highlightAngle), math.sin(highlightAngle)) *
              highlightDistance;

      // Warna-warna gradien yang natural
      final lightColor = HSLColor.fromColor(baseColor)
          .withLightness(
              (HSLColor.fromColor(baseColor).lightness * 1.3).clamp(0.0, 1.0))
          .toColor()
          .withOpacity(baseColor.opacity * 0.9);

      final midColor = baseColor;

      final darkColor = HSLColor.fromColor(baseColor)
          .withLightness(
              (HSLColor.fromColor(baseColor).lightness * 0.7).clamp(0.0, 1.0))
          .toColor()
          .withOpacity(baseColor.opacity);

      // Gradien multi-titik
      petalPaint.shader = ui.Gradient.radial(
        highlightPos,
        petalLength,
        [
          lightColor,
          midColor,
          darkColor,
        ],
        [0.2, 0.6, 1.0],
      );
    } else {
      petalPaint.color = baseColor;
    }

    // Gambar kelopak dasar
    canvas.drawPath(path, petalPaint);

    // Tambahkan detail pola pada kelopak jika diaktifkan
    if (enablePattern) {
      _drawPetalPatterns(
        canvas: canvas,
        path: path,
        center: center,
        basePosition: basePosition,
        tipPosition: tipPosition,
        angle: angle,
        petalLength: petalLength,
        petalWidth: petalWidth,
        accentColor: accentColor,
        progress: progress,
      );
    }

    // Tambah highlight di tepi kelopak
    final edgePaint = Paint()
      ..color = accentColor.withOpacity(accentColor.opacity * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = petalWidth * 0.02;

    canvas.drawPath(path, edgePaint);
  }

  // Metode untuk menggambar detail pola pada kelopak
  void _drawPetalPatterns({
    required Canvas canvas,
    required Path path,
    required Offset center,
    required Offset basePosition,
    required Offset tipPosition,
    required double angle,
    required double petalLength,
    required double petalWidth,
    required Color accentColor,
    required double progress,
  }) {
    // Urat utama kelopak
    final veinPaint = Paint()
      ..color = accentColor.withOpacity(accentColor.opacity * 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = petalWidth * 0.02;

    final veinPath = Path();
    veinPath.moveTo(basePosition.dx, basePosition.dy);
    veinPath.lineTo(tipPosition.dx, tipPosition.dy);

    canvas.drawPath(veinPath, veinPaint);

    // Sudut untuk urat cabang
    final rightAngle = angle + math.pi / 2;
    final leftAngle = angle - math.pi / 2;

    // Urat cabang dengan variasi
    final veinCount = 5; // 5 pasang urat cabang
    for (int i = 1; i <= veinCount; i++) {
      final t = i / (veinCount + 1);
      final mainVeinPoint = Offset.lerp(basePosition, tipPosition, t)!;

      // Panjang urat cabang bervariasi
      final branchLengthFactor =
          math.sin(t * math.pi); // lebih panjang di tengah
      final branchLength = petalWidth * 0.4 * branchLengthFactor;

      // Sudut bervariasi untuk efek lengkung
      final curveAngle = 0.3 * math.sin(t * math.pi);

      // Cabang kanan dan kiri dengan efek lengkung
      final rightBranch = mainVeinPoint +
          Offset(math.cos(rightAngle + curveAngle),
                  math.sin(rightAngle + curveAngle)) *
              branchLength;
      final leftBranch = mainVeinPoint +
          Offset(math.cos(leftAngle - curveAngle),
                  math.sin(leftAngle - curveAngle)) *
              branchLength;

      // Untuk efek lebih natural, buat kurva untuk urat cabang
      final branchPath = Path();

      // Urat kanan
      branchPath.moveTo(mainVeinPoint.dx, mainVeinPoint.dy);
      final rightControlPoint = Offset.lerp(mainVeinPoint, rightBranch, 0.5)! +
          Offset(math.cos(rightAngle + curveAngle + 0.3),
                  math.sin(rightAngle + curveAngle + 0.3)) *
              (branchLength * 0.2);
      branchPath.quadraticBezierTo(rightControlPoint.dx, rightControlPoint.dy,
          rightBranch.dx, rightBranch.dy);

      // Urat kiri
      branchPath.moveTo(mainVeinPoint.dx, mainVeinPoint.dy);
      final leftControlPoint = Offset.lerp(mainVeinPoint, leftBranch, 0.5)! +
          Offset(math.cos(leftAngle - curveAngle - 0.3),
                  math.sin(leftAngle - curveAngle - 0.3)) *
              (branchLength * 0.2);
      branchPath.quadraticBezierTo(leftControlPoint.dx, leftControlPoint.dy,
          leftBranch.dx, leftBranch.dy);

      // Atur ketebalan urat cabang (lebih tipis dari urat utama)
      final branchPaint = Paint()
        ..color = accentColor.withOpacity(accentColor.opacity * 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = petalWidth * 0.015;

      canvas.drawPath(branchPath, branchPaint);

      // Tambahkan urat-urat halus tersier
      final tertiaryCount = 2; // 2 urat tersier per cabang
      final tertiaryPaint = Paint()
        ..color = accentColor.withOpacity(accentColor.opacity * 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = petalWidth * 0.01;

      for (int j = 1; j <= tertiaryCount; j++) {
        final s = j / (tertiaryCount + 1);

        // Untuk cabang kanan
        final rightTertiaryBase = Offset.lerp(mainVeinPoint, rightBranch, s)!;
        final rightTertiaryLength = branchLength * 0.4 * (1 - s);
        final rightTertiaryAngle = rightAngle + curveAngle * 1.5;
        final rightTertiaryEnd = rightTertiaryBase +
            Offset(math.cos(rightTertiaryAngle), math.sin(rightTertiaryAngle)) *
                rightTertiaryLength;

        // Untuk cabang kiri
        final leftTertiaryBase = Offset.lerp(mainVeinPoint, leftBranch, s)!;
        final leftTertiaryLength = branchLength * 0.4 * (1 - s);
        final leftTertiaryAngle = leftAngle - curveAngle * 1.5;
        final leftTertiaryEnd = leftTertiaryBase +
            Offset(math.cos(leftTertiaryAngle), math.sin(leftTertiaryAngle)) *
                leftTertiaryLength;

        final tertiaryPath = Path();
        tertiaryPath.moveTo(rightTertiaryBase.dx, rightTertiaryBase.dy);
        tertiaryPath.lineTo(rightTertiaryEnd.dx, rightTertiaryEnd.dy);

        tertiaryPath.moveTo(leftTertiaryBase.dx, leftTertiaryBase.dy);
        tertiaryPath.lineTo(leftTertiaryEnd.dx, leftTertiaryEnd.dy);

        canvas.drawPath(tertiaryPath, tertiaryPaint);
      }
    }

    // Tambahkan pola titik hias di sepanjang urat utama
    final dotCount = 3; // 3 titik dekoratif
    for (int i = 1; i <= dotCount; i++) {
      final t = 0.3 + (i * 0.2); // posisi di 0.5, 0.7, 0.9 dari urat
      final dotPos = Offset.lerp(basePosition, tipPosition, t)!;

      // Pola titik yang sedikit berkilau
      final dotPaint = Paint()
        ..color = accentColor.withOpacity(accentColor.opacity * 0.7);

      final dotSize =
          petalWidth * 0.04 * (1 - (t * 0.3)); // makin kecil ke ujung
      canvas.drawCircle(dotPos, dotSize, dotPaint);
    }
  }

  // Metode untuk menggambar detail pada pusat bunga
  void _drawCenterDetail({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required Color baseColor,
    required Color accentColor,
    required double progress,
  }) {
    // Detail pola pada pusat bunga
    final dotCount = 8;
    final dotAngleStep = (2 * math.pi) / dotCount;
    final dotRadius = radius * 0.15;
    final dotDistance = radius * 0.5;

    // Rotate pattern a bit
    final patternRotation = progress * math.pi * 0.5;

    for (int i = 0; i < dotCount; i++) {
      final dotAngle = i * dotAngleStep + patternRotation;
      final dotPos =
          center + Offset(math.cos(dotAngle), math.sin(dotAngle)) * dotDistance;

      // Efek berkilau dengan timing yang berbeda untuk setiap titik
      final glowPhase = (progress * 3 + i * 0.3) % 1.0;
      final glowSize = 1.0 + math.sin(glowPhase * 2 * math.pi) * 0.3;

      final dotPaint = Paint()
        ..color = accentColor.withOpacity(accentColor.opacity * 0.8);

      canvas.drawCircle(dotPos, dotRadius * glowSize, dotPaint);
    }

    // Tambahkan garis radial halus di pusat
    final radialLineCount = 16;
    final radialLineStep = (2 * math.pi) / radialLineCount;
    final linePaint = Paint()
      ..color = accentColor.withOpacity(accentColor.opacity * 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.02;

    for (int i = 0; i < radialLineCount; i++) {
      final lineAngle = i * radialLineStep + patternRotation;
      final innerPoint = center +
          Offset(math.cos(lineAngle), math.sin(lineAngle)) * (radius * 0.3);
      final outerPoint = center +
          Offset(math.cos(lineAngle), math.sin(lineAngle)) * (radius * 0.8);

      canvas.drawLine(innerPoint, outerPoint, linePaint);
    }
  }

  // Metode untuk menggambar efek partikel berkilau
  void _drawSparkles({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required int count,
    required Color baseColor,
    required double progress,
  }) {
    final random = math.Random(42); // Seed tetap agar posisi konsisten

    for (int i = 0; i < count; i++) {
      // Posisi sparkle - melayang di sekitar bunga
      final angle = (i / count) * 2 * math.pi + (progress * math.pi * 0.3);
      final distance = radius * (0.8 + random.nextDouble() * 0.4);

      // Tambahkan efek melayang
      final floatOffset = math.sin(progress * 5 + i) * (radius * 0.05);
      final floatAngle = angle + math.pi / 2; // arah melayang tegak lurus

      final sparklePos = center +
          Offset(math.cos(angle), math.sin(angle)) * distance +
          Offset(math.cos(floatAngle), math.sin(floatAngle)) * floatOffset;

      // Ukuran berkilau (berkedip)
      final sparklePhase = (progress * 5 + i * 0.7) % 1.0;
      final size =
          radius * 0.03 * (0.5 + math.sin(sparklePhase * 2 * math.pi) * 0.5);

      if (size <= 0) continue;

      // Warna sparkle dengan variasi
      final hue =
          (HSLColor.fromColor(baseColor).hue + random.nextDouble() * 30) % 360;
      final sparkleColor = HSLColor.fromAHSL(
        baseColor.opacity,
        hue,
        0.3,
        0.8,
      ).toColor();

      // Gambar sparkle (bintang kecil)
      _drawSparkle(canvas, sparklePos, size, sparkleColor);
    }
  }

  // Metode untuk menggambar partikel berkilau berbentuk bintang
  void _drawSparkle(Canvas canvas, Offset position, double size, Color color) {
    final outerRadius = size;
    final innerRadius = size * 0.4;
    final points = 4; // bintang 4 sudut

    final path = Path();

    for (int i = 0; i < points * 2; i++) {
      final angle = (i / (points * 2)) * 2 * math.pi;
      final radius = i % 2 == 0 ? outerRadius : innerRadius;

      final x = position.dx + math.cos(angle) * radius;
      final y = position.dy + math.sin(angle) * radius;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();

    // Berikan efek glowing
    final glowPaint = Paint()
      ..color = color.withOpacity(0.7)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

    canvas.drawPath(path, glowPaint);

    // Gambar center
    final corePaint = Paint()..color = Colors.white.withOpacity(0.9);
    canvas.drawCircle(position, size * 0.2, corePaint);
  }

  // Easing function untuk efek bloom
  double _easeOutBack(double t) {
    const c1 = 1.70158;
    const c3 = c1 + 1;
    return 1 + c3 * math.pow(t - 1, 3) + c1 * math.pow(t - 1, 2);
  }

  // overrides
  @override
  bool shouldRepaint(EffectAnimator old) =>
      old is! MagicalFlowerAnimator ||
      old.petalCount != petalCount ||
      old.petalWidth != petalWidth ||
      old.petalLength != petalLength ||
      old.flowerScale != flowerScale ||
      old.centerScale != centerScale ||
      old.petalCurve != petalCurve ||
      old.petalOverlap != petalOverlap ||
      old.rotationSpeed != rotationSpeed ||
      old.enableGlowEffect != enableGlowEffect ||
      old.enableSparkles != enableSparkles ||
      old.enablePatternDetail != enablePatternDetail ||
      old.enablePetalGradient != enablePetalGradient ||
      old.sparkleCount != sparkleCount ||
      old.enableHueTilt != enableHueTilt ||
      old.hueTiltRange != hueTiltRange ||
      old.saturationBoost != saturationBoost ||
      old.centerColor != centerColor ||
      old.accentColor != accentColor;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  @override
  double getDefaultRadiusMultiplier() => 1;

  @override
  double getOuterPadding() => math.max(petalWidth, petalLength) * 2.2;
}

/// Magical orbit dots animator dengan efek berkilau dan estetik.
class MagicalOrbitDotsAnimator implements EffectAnimator {
  // ---------- orbit settings ----------
  final int orbitCount; // jumlah orbit
  final int dotsPerOrbit; // jumlah titik per orbit
  final double orbitBaseRadius; // radius orbit relatif terhadap radius widget
  final double orbitSpacing; // jarak antar orbit
  final double dotSize; // ukuran dasar titik
  final bool reverseAlternate; // orbit berselang-seling arah rotasi

  // ---------- efek dekoratif ----------
  final bool enableGlowEffect; // efek berpendar di tengah
  final bool enableDotTrails; // efek jejak di belakang titik
  final bool enableSparkles; // partikel berkilau acak
  final int sparkleCount; // jumlah partikel berkilau

  // ---------- animation settings ----------
  final List<double> orbitSpeeds; // kecepatan rotasi untuk setiap orbit
  final double pulseFactor; // faktor pulsasi titik (0 = tidak berdenyut)

  // ---------- opsi warna ----------
  final bool enableHueTilt; // aktifkan gradasi warna
  final double hueTiltRange; // 0‑1  (1 = 360° penuh)
  final double saturationBoost; // 1 = tak berubah
  final Color centerGlowColor; // warna glow di tengah

  MagicalOrbitDotsAnimator({
    this.orbitCount = 3,
    this.dotsPerOrbit = 8,
    this.orbitBaseRadius = 0.8,
    this.orbitSpacing = 0.3,
    this.dotSize = 6.0,
    this.reverseAlternate = true,
    //
    this.enableGlowEffect = true,
    this.enableDotTrails = true,
    this.enableSparkles = true,
    this.sparkleCount = 12,
    //
    this.orbitSpeeds = const [0.8, 0.5, 0.3], // default speeds for 3 orbits
    this.pulseFactor = 0.2,
    //
    this.enableHueTilt = true,
    this.hueTiltRange = 0.6,
    this.saturationBoost = 1.2,
    this.centerGlowColor = const Color(0xFF55BBAA),
  });

  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final c = center + positionOffset;
    final baseRadius = math.min(size.width, size.height) / 2;

    // Normalize orbit speeds if not enough provided
    List<double> speeds = List.from(orbitSpeeds);
    while (speeds.length < orbitCount) {
      speeds.add(0.3); // Default speed for additional orbits
    }

    // Opacity animation
    final opacity = progress < 0.15
        ? progress / 0.15
        : progress > 0.85
            ? (1 - (progress - 0.85) / 0.15)
            : 1.0;

    // ----- Draw center glow if enabled -----
    if (enableGlowEffect) {
      final centerRadius = baseRadius * orbitSpacing * 0.6 * radiusMultiplier;

      // Pulsing effect for the glow
      final pulsePhase = math.sin(progress * 5) * 0.2 + 0.8;
      final glowRadius = centerRadius * pulsePhase;

      final glowPaint = Paint()
        ..shader = ui.Gradient.radial(
          c,
          glowRadius * 1.5,
          [
            centerGlowColor.withOpacity(0.7 * opacity),
            centerGlowColor.withOpacity(0.4 * opacity),
            centerGlowColor.withOpacity(0.0),
          ],
          [0.0, 0.5, 1.0],
        );

      canvas.drawCircle(c, glowRadius * 1.5, glowPaint);

      // Inner brighter core
      final corePaint = Paint()
        ..shader = ui.Gradient.radial(
          c,
          glowRadius * 0.8,
          [
            Colors.white.withOpacity(0.8 * opacity),
            centerGlowColor.withOpacity(0.6 * opacity),
            centerGlowColor.withOpacity(0.4 * opacity),
          ],
          [0.0, 0.4, 1.0],
        );

      canvas.drawCircle(c, glowRadius * 0.8, corePaint);
    }

    // ----- Draw orbiting dots -----
    for (int orbitIndex = 0; orbitIndex < orbitCount; orbitIndex++) {
      // Calculate orbit radius
      final orbitRadius = baseRadius *
          (orbitBaseRadius + (orbitIndex * orbitSpacing)) *
          radiusMultiplier;

      // Calculate direction (alternate orbits can go in reverse)
      final direction = (reverseAlternate && orbitIndex % 2 == 1) ? -1.0 : 1.0;

      // Orbit speed
      final orbitSpeed = speeds[orbitIndex];

      // Calculate dot positions for this orbit
      for (int dotIndex = 0; dotIndex < dotsPerOrbit; dotIndex++) {
        // Base angle for this dot
        final baseAngle = (dotIndex / dotsPerOrbit) * 2 * math.pi;

        // Rotation based on progress and speed
        final rotationAngle = direction * progress * orbitSpeed * 2 * math.pi;

        // Final angle
        final angle = baseAngle + rotationAngle;

        // Dot position
        final dotPos =
            c + Offset(math.cos(angle), math.sin(angle)) * orbitRadius;

        // ----- Draw dot trail if enabled -----
        if (enableDotTrails) {
          final trailLength = 5; // Number of trail segments

          for (int i = 1; i <= trailLength; i++) {
            final trailFactor = i / trailLength;
            final trailAngle = angle - (direction * trailFactor * 0.3);
            final trailPos = c +
                Offset(math.cos(trailAngle), math.sin(trailAngle)) *
                    orbitRadius;

            // Trail opacity and size decrease along the trail
            final trailOpacity = (1 - trailFactor) * 0.5 * opacity;
            final trailSize =
                dotSize * radiusMultiplier * (1 - trailFactor * 0.8);

            if (trailOpacity <= 0 || trailSize <= 0) continue;

            // Trail dot color with slight hue shift
            Color trailColor = color;
            if (enableHueTilt) {
              final hsl = HSLColor.fromColor(color);
              final hueShift = ((orbitIndex * dotsPerOrbit + dotIndex) /
                      (orbitCount * dotsPerOrbit)) *
                  360 *
                  hueTiltRange;
              trailColor = hsl
                  .withHue((hsl.hue + hueShift - (trailFactor * 15)) %
                      360) // Slight shift for trail
                  .withSaturation(
                      (hsl.saturation * saturationBoost).clamp(0.0, 1.0))
                  .toColor();
            }

            final trailPaint = Paint()
              ..color = trailColor.withOpacity(trailOpacity)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

            canvas.drawCircle(trailPos, trailSize, trailPaint);
          }
        }

        // ----- Draw main dot -----
        // Pulse effect - dots grow and shrink slightly
        final pulsePhase =
            math.sin((progress * 7) + (dotIndex * 0.7) + (orbitIndex * 1.5)) *
                    pulseFactor +
                1.0;
        final dotRadius = dotSize * radiusMultiplier * pulsePhase;

        // Dot color with hue variation based on position
        Color dotColor = color;
        if (enableHueTilt) {
          final hsl = HSLColor.fromColor(color);
          final hueShift = ((orbitIndex * dotsPerOrbit + dotIndex) /
                  (orbitCount * dotsPerOrbit)) *
              360 *
              hueTiltRange;
          dotColor = hsl
              .withHue((hsl.hue + hueShift) % 360)
              .withSaturation(
                  (hsl.saturation * saturationBoost).clamp(0.0, 1.0))
              .toColor();
        }
        dotColor = dotColor.withOpacity(opacity);

        // The main dot with glow effect
        final dotGlowPaint = Paint()
          ..color = dotColor.withOpacity(0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);

        canvas.drawCircle(dotPos, dotRadius * 1.4, dotGlowPaint);

        // Brighter core
        final dotPaint = Paint()..color = dotColor;
        canvas.drawCircle(dotPos, dotRadius, dotPaint);

        // Highlight spot
        final highlightPaint = Paint()
          ..color = Colors.white.withOpacity(0.8 * opacity);
        final highlightOffset =
            Offset(-dotRadius * 0.2, -dotRadius * 0.2); // Top-left highlight
        canvas.drawCircle(
            dotPos + highlightOffset, dotRadius * 0.3, highlightPaint);
      }
    }

    // ----- Draw random sparkles if enabled -----
    if (enableSparkles) {
      _drawSparkles(
        canvas: canvas,
        center: c,
        radius: baseRadius *
            orbitBaseRadius *
            (1 + orbitSpacing * (orbitCount - 1)) *
            radiusMultiplier,
        count: sparkleCount,
        baseColor: color.withOpacity(opacity * 0.8),
        progress: progress,
      );
    }
  }

  // Method to draw sparkles
  void _drawSparkles({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required int count,
    required Color baseColor,
    required double progress,
  }) {
    final random = math.Random(42); // Fixed seed for consistent positions

    for (int i = 0; i < count; i++) {
      // Sparkle position - random placement around orbits
      final angle = random.nextDouble() * 2 * math.pi;
      final distance = radius * (0.3 + random.nextDouble() * 0.9);

      // Add floating effect
      final floatOffset = math.sin(progress * 4 + i * 1.2) * (radius * 0.03);
      final floatAngle =
          angle + random.nextDouble() * math.pi; // Random float direction

      final sparklePos = center +
          Offset(math.cos(angle), math.sin(angle)) * distance +
          Offset(math.cos(floatAngle), math.sin(floatAngle)) * floatOffset;

      // Twinkling size effect
      final sparklePhase = (progress * 3 + i * 0.4) % 1.0;
      final sizeFactor =
          0.2 + math.pow(math.sin(sparklePhase * math.pi), 2) * 0.8;
      final size = (2 + random.nextDouble() * 2) * sizeFactor;

      if (sizeFactor <= 0.2) continue; // Skip almost invisible sparkles

      // Sparkle color with variation
      final hue =
          (HSLColor.fromColor(baseColor).hue + random.nextDouble() * 60) % 360;
      final sparkleColor = HSLColor.fromAHSL(
        baseColor.opacity * sizeFactor,
        hue,
        0.5,
        0.7,
      ).toColor();

      // Draw sparkle as a simple 4-point star or a circle
      if (random.nextBool()) {
        _drawStarSparkle(canvas, sparklePos, size, sparkleColor);
      } else {
        _drawCircleSparkle(canvas, sparklePos, size * 0.7, sparkleColor);
      }
    }
  }

  // Draw a star-shaped sparkle
  void _drawStarSparkle(
      Canvas canvas, Offset position, double size, Color color) {
    final outerRadius = size;
    final innerRadius = size * 0.4;
    final points = 4; // 4-point star

    final path = Path();

    for (int i = 0; i < points * 2; i++) {
      final angle = (i / (points * 2)) * 2 * math.pi;
      final radius = i % 2 == 0 ? outerRadius : innerRadius;

      final x = position.dx + math.cos(angle) * radius;
      final y = position.dy + math.sin(angle) * radius;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();

    // Glow effect
    final glowPaint = Paint()
      ..color = color.withOpacity(0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

    canvas.drawPath(path, glowPaint);

    // Core
    final corePaint = Paint()..color = Colors.white.withOpacity(0.8);
    canvas.drawCircle(position, size * 0.2, corePaint);
  }

  // Draw a circular sparkle
  void _drawCircleSparkle(
      Canvas canvas, Offset position, double size, Color color) {
    // Glow
    final glowPaint = Paint()
      ..color = color.withOpacity(0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

    canvas.drawCircle(position, size * 1.3, glowPaint);

    // Main circle
    final circlePaint = Paint()..color = color;
    canvas.drawCircle(position, size, circlePaint);

    // Highlight
    final highlightPaint = Paint()..color = Colors.white.withOpacity(0.8);
    canvas.drawCircle(position + Offset(-size * 0.2, -size * 0.2), size * 0.3,
        highlightPaint);
  }

  // overrides
  @override
  bool shouldRepaint(EffectAnimator old) =>
      old is! MagicalOrbitDotsAnimator ||
      old.orbitCount != orbitCount ||
      old.dotsPerOrbit != dotsPerOrbit ||
      old.orbitBaseRadius != orbitBaseRadius ||
      old.orbitSpacing != orbitSpacing ||
      old.dotSize != dotSize ||
      old.reverseAlternate != reverseAlternate ||
      old.enableGlowEffect != enableGlowEffect ||
      old.enableDotTrails != enableDotTrails ||
      old.enableSparkles != enableSparkles ||
      old.sparkleCount != sparkleCount ||
      !_listEquals(old.orbitSpeeds, orbitSpeeds) ||
      old.pulseFactor != pulseFactor ||
      old.enableHueTilt != enableHueTilt ||
      old.hueTiltRange != hueTiltRange ||
      old.saturationBoost != saturationBoost ||
      old.centerGlowColor != centerGlowColor;

  // Helper for list comparison
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  @override
  double getDefaultRadiusMultiplier() => 1;

  @override
  double getOuterPadding() =>
      orbitBaseRadius * 100 + (orbitSpacing * orbitCount * 100) + dotSize * 2;
}

class AnimatorFactory {
  static EffectAnimator createAnimator(AnimationType type) {
    switch (type) {
      case AnimationType.radialFirework:
        return RadialFireworkAnimator();
      case AnimationType.firework:
        return ShapeExplosionAnimator();
      case AnimationType.ripple:
        return PulseWaveAnimator();
      case AnimationType.spiral:
        return SpiralExplosionAnimator();
      case AnimationType.shapeExplosion:
        return ShapeExplosionAnimator();
      case AnimationType.shapeImplode:
        return ShapeImplodeAnimator();
      case AnimationType.shapeRetractImplode:
        return ShapeRetractImplodeAnimator();
      case AnimationType.shapeExplodeOut:
        return ShapeExplodeOutAnimator();
      case AnimationType.orbitBloom:
        return OrbitBloomAnimatorV2();
      case AnimationType.circleBurst:
        return CircleBurstAnimator();
      case AnimationType.circleBurstClean:
        return CircleBurstCleanAnimator();
      case AnimationType.magicDust:
        return MagicDustAnimator();
      case AnimationType.pixelExplosion:
        return PixelExplosionAnimator();
      case AnimationType.pulseWave:
        return PulseWaveAnimator();
      case AnimationType.dotBurst:
        return DotBurstAnimator();
      case AnimationType.dotAbsorbBurst:
        return DotAbsorbBurstAnimator();
      case AnimationType.rayLine:
        return RayBurstMovingAnimator();
      case AnimationType.circleOrbitSequential:
        return CircleOrbitSequentialAnimator();
      case AnimationType.multiRingOrbit:
        return MultiRingOrbitAnimator();
      case AnimationType.sequentialRingOrbit:
        return SequentialRingOrbitAnimator();
      case AnimationType.flowerCircle:
        return FlowerCircleAnimator();
      case AnimationType.magicalFlower:
        return MagicalFlowerAnimator();
      case AnimationType.magicalOrbitDots:
        return MagicalOrbitDotsAnimator();
    }
  }
}
