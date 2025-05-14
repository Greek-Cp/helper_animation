import 'dart:math' as math;
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:helper_animation/animators/effect_animator.dart';
import 'package:helper_animation/constants/enums.dart';

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

// Kelas ray untuk animasi
class _Ray {
  final double angle;
  final double length;
  final double width;
  final double pulseRate;

  _Ray({
    required this.angle,
    required this.length,
    required this.width,
    required this.pulseRate,
  });
}

class PerimeterCircleBurstRayAnimator implements EffectAnimator {
  // ───── konfigurasi ─────
  final int particleCount;
  final int rayCount;
  final double rayLength;
  final double rayWidth;
  final bool enableHueTilt; // aktifkan gradasi
  final double hueTiltRange; // 0‑1 (1 = 360°)
  final double saturationBoost; // 1 = tak berubah
  final bool enableBloom; // lingkaran "halo" di puncak animasi
  final double bloomWidth; // strokeWidth halo

  final List<_Particle> _particles = [];
  final List<_Ray> _rays = [];
  late Random _random;
  bool _isInitialized = false;

  PerimeterCircleBurstRayAnimator({
    this.particleCount = 30,
    this.rayCount = 8,
    this.rayLength = 25.0,
    this.rayWidth = 1.5,
    this.enableHueTilt = false,
    this.hueTiltRange = .30,
    this.saturationBoost = 1.1,
    this.enableBloom = true,
    this.bloomWidth = .5,
  });

  void _initElements() {
    // Only initialize once when animation starts
    if (!_isInitialized) {
      _isInitialized = true;
      _random = Random(DateTime.now().millisecondsSinceEpoch);
      _particles.clear();
      _rays.clear();

      // Init particles with fixed random positions
      for (int i = 0; i < particleCount; i++) {
        final randomRatio = _random.nextDouble();
        final baseAngle = randomRatio * math.pi * 2;
        final angle = baseAngle + (_random.nextDouble() * .4 - .2);

        _particles.add(_Particle(
          angle: angle,
          maxDistance: _random.nextDouble() * 25 + 20,
          baseSize: _random.nextDouble() * 5 + 1.5,
          pulseRate: _random.nextDouble() * 4 + 0.5,
        ));
      }

      // Init rays with fixed random positions
      for (int i = 0; i < rayCount; i++) {
        final randomRatio = _random.nextDouble();
        final randomLength = rayLength * (0.3 + _random.nextDouble() * 1.7);

        _rays.add(_Ray(
          angle: randomRatio * math.pi * 2,
          length: randomLength,
          width: _random.nextDouble() * rayWidth + 0.5,
          pulseRate: _random.nextDouble() * 2 + 0.5,
        ));
      }
    }
  }

  // ───── paint ─────
  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color baseColor,
      {double radiusMultiplier = 1, Offset positionOffset = Offset.zero}) {
    _initElements();

    final c = center + positionOffset;

    // Buat rect untuk perimeter
    final rect = Rect.fromCenter(
      center: c,
      width: size.width,
      height: size.height,
    );

    // Modified progress to only go outward (0 to 1)
    final distP = _easeOutQuad(progress);

    // Reset initialization when animation completes
    if (progress >= 1.0) {
      _isInitialized = false;
    }

    // ----- BLOOM halo (opsional) -----
    if (enableBloom && (progress > .45 && progress < .55)) {
      final bloomT = (progress - .45) / .1;
      final opacity = 1 - (bloomT - .5).abs() * 2;

      final bloomPath = Path();
      bloomPath.addRect(rect.inflate(bloomWidth * radiusMultiplier));

      canvas.drawPath(
          bloomPath,
          Paint()
            ..color = baseColor.withOpacity(opacity * .4)
            ..style = PaintingStyle.stroke
            ..strokeWidth = bloomWidth * radiusMultiplier
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    }

    // ----- RAY (BARU) -----
    for (final ray in _rays) {
      // Calculate position on perimeter based on ray's angle
      final angle = ray.angle;
      final perimeterPos = Offset(c.dx + (size.width / 2) * math.cos(angle),
          c.dy + (size.height / 2) * math.sin(angle));

      // Calculate direction from center
      final dirVector = perimeterPos - c;
      final distance = dirVector.distance;
      final direction = distance > 0
          ? Offset(dirVector.dx / distance, dirVector.dy / distance)
          : Offset(0, 0);

      // Calculate ray end position
      final curLength = ray.length * distP * radiusMultiplier;
      final endPos = perimeterPos + direction * curLength;

      // Pulse effect
      final pulse =
          .7 + .3 * math.sin((progress + ray.pulseRate) * math.pi * 2);
      final widthPx = ray.width * pulse * radiusMultiplier;

      // Opacity
      double opacity = 1;
      if (progress < .2) {
        opacity = progress / .2;
      } else if (progress > .8) {
        opacity = (1 - progress) / .2;
      }

      // Color with random shift
      Color rayColor = baseColor;
      if (enableHueTilt) {
        final hsl = HSLColor.fromColor(baseColor);
        final shift = (ray.angle / (2 * math.pi)) * 360 * hueTiltRange;
        rayColor = hsl
            .withHue((hsl.hue + shift) % 360)
            .withSaturation((hsl.saturation * saturationBoost).clamp(0, 1))
            .toColor();
      }

      final rayPaint = Paint()
        ..color = rayColor.withOpacity(opacity * 0.8)
        ..strokeWidth = widthPx
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

      canvas.drawLine(perimeterPos, endPos, rayPaint);
    }

    // ----- PARTICLES -----
    for (final p in _particles) {
      // Calculate position on perimeter based on particle's angle
      final angle = p.angle;
      final perimeterPos = Offset(c.dx + (size.width / 2) * math.cos(angle),
          c.dy + (size.height / 2) * math.sin(angle));

      // Calculate direction and distance
      final dirVector = perimeterPos - c;
      final distance = dirVector.distance;
      final direction = distance > 0
          ? Offset(dirVector.dx / distance, dirVector.dy / distance)
          : Offset(0, 0);

      // Calculate particle position
      final curDist = p.maxDistance * distP * radiusMultiplier;
      final pos = perimeterPos + direction * curDist;

      // Pulse effect
      final pulse = .5 + .5 * math.sin((progress + p.pulseRate) * math.pi * 2);
      final sizePx = p.baseSize * pulse * radiusMultiplier;

      // Opacity
      double opacity = 1;
      if (progress < .2) {
        opacity = progress / .2;
      } else if (progress > .8) {
        opacity = (1 - progress) / .2;
      }

      // Color with random shift
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

      // Draw glow
      canvas.drawCircle(
          pos,
          sizePx * 1.6,
          Paint()
            ..color = col.withOpacity(.25)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2));

      // Draw core
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
      old is! PerimeterCircleBurstRayAnimator ||
      old.particleCount != particleCount ||
      old.rayCount != rayCount ||
      old.rayLength != rayLength ||
      old.rayWidth != rayWidth ||
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
  double getOuterPadding() =>
      45; // Sedikit lebih besar dari aslinya tapi masih aman
}

class PerimeterCircleBurstRayInAnimator implements EffectAnimator {
  // ───── konfigurasi ─────
  final int particleCount;
  final int rayCount;
  final double rayLength;
  final double rayWidth;
  final bool enableHueTilt;
  final double hueTiltRange;
  final double saturationBoost;
  final bool enableBloom;
  final double bloomWidth;

  final List<_Particle> _particles = [];
  final List<_Ray> _rays = [];
  late Random _random;
  bool _isInitialized = false;

  PerimeterCircleBurstRayInAnimator({
    this.particleCount = 30,
    this.rayCount = 8,
    this.rayLength = 25.0,
    this.rayWidth = 1.5,
    this.enableHueTilt = false,
    this.hueTiltRange = .30,
    this.saturationBoost = 1.1,
    this.enableBloom = true,
    this.bloomWidth = .5,
  });

  void _initElements() {
    // Only initialize once when animation starts
    if (!_isInitialized) {
      _isInitialized = true;
      _random = Random(DateTime.now().millisecondsSinceEpoch);
      _particles.clear();
      _rays.clear();

      // Init particles with fixed random positions
      for (int i = 0; i < particleCount; i++) {
        final randomRatio = _random.nextDouble();
        final baseAngle = randomRatio * math.pi * 2;
        final angle = baseAngle + (_random.nextDouble() * .4 - .2);

        _particles.add(_Particle(
          angle: angle,
          maxDistance: _random.nextDouble() * 25 + 20,
          baseSize: _random.nextDouble() * 5 + 1.5,
          pulseRate: _random.nextDouble() * 4 + 0.5,
        ));
      }

      // Init rays with fixed random positions
      for (int i = 0; i < rayCount; i++) {
        final randomRatio = _random.nextDouble();
        final randomLength = rayLength * (0.3 + _random.nextDouble() * 1.7);

        _rays.add(_Ray(
          angle: randomRatio * math.pi * 2,
          length: randomLength,
          width: _random.nextDouble() * rayWidth + 0.5,
          pulseRate: _random.nextDouble() * 2 + 0.5,
        ));
      }
    }
  }

  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color baseColor,
      {double radiusMultiplier = 1, Offset positionOffset = Offset.zero}) {
    _initElements();

    final c = center + positionOffset;

    // Buat rect untuk perimeter
    final rect = Rect.fromCenter(
      center: c,
      width: size.width,
      height: size.height,
    );

    // Modified progress for inward animation
    final distP = _easeOutQuad(progress);

    // Reset initialization when animation completes
    if (progress >= 1.0) {
      _isInitialized = false;
    }

    // ----- BLOOM halo (opsional) -----
    if (enableBloom && (progress > .45 && progress < .55)) {
      final bloomT = (progress - .45) / .1;
      final opacity = 1 - (bloomT - .5).abs() * 2;

      final bloomPath = Path();
      bloomPath.addRect(rect.inflate(bloomWidth * radiusMultiplier));

      canvas.drawPath(
          bloomPath,
          Paint()
            ..color = baseColor.withOpacity(opacity * .4)
            ..style = PaintingStyle.stroke
            ..strokeWidth = bloomWidth * radiusMultiplier
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    }

    // ----- RAY (BARU) -----
    for (final ray in _rays) {
      // Calculate position on perimeter based on ray's angle
      final angle = ray.angle;
      final outerPos = Offset(
          c.dx +
              (size.width / 2 + ray.length * radiusMultiplier) *
                  math.cos(angle),
          c.dy +
              (size.height / 2 + ray.length * radiusMultiplier) *
                  math.sin(angle));

      // Calculate direction from outer to center (inward)
      final dirVector = c - outerPos;
      final distance = dirVector.distance;
      final direction = distance > 0
          ? Offset(dirVector.dx / distance, dirVector.dy / distance)
          : Offset(0, 0);

      // Calculate ray positions
      final startPos =
          outerPos + direction * (ray.length * (1 - distP) * radiusMultiplier);
      final endPos = outerPos + direction * (ray.length * radiusMultiplier);

      // Pulse effect
      final pulse =
          .7 + .3 * math.sin((progress + ray.pulseRate) * math.pi * 2);
      final widthPx = ray.width * pulse * radiusMultiplier;

      // Opacity with smooth fade
      double opacity = 1;
      if (progress < .2) {
        opacity = progress / .2;
      } else if (progress > .8) {
        opacity = (1 - progress) / .2;
      }

      // Color with random shift
      Color rayColor = baseColor;
      if (enableHueTilt) {
        final hsl = HSLColor.fromColor(baseColor);
        final shift = (ray.angle / (2 * math.pi)) * 360 * hueTiltRange;
        rayColor = hsl
            .withHue((hsl.hue + shift) % 360)
            .withSaturation((hsl.saturation * saturationBoost).clamp(0, 1))
            .toColor();
      }

      final rayPaint = Paint()
        ..color = rayColor.withOpacity(opacity * 0.8)
        ..strokeWidth = widthPx
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

      canvas.drawLine(startPos, endPos, rayPaint);
    }

    // ----- PARTICLES -----
    for (final p in _particles) {
      // Calculate outer position based on particle's angle
      final angle = p.angle;
      final outerPos = Offset(
          c.dx +
              (size.width / 2 + p.maxDistance * radiusMultiplier) *
                  math.cos(angle),
          c.dy +
              (size.height / 2 + p.maxDistance * radiusMultiplier) *
                  math.sin(angle));

      // Calculate direction and distance (inward)
      final dirVector = c - outerPos;
      final distance = dirVector.distance;
      final direction = distance > 0
          ? Offset(dirVector.dx / distance, dirVector.dy / distance)
          : Offset(0, 0);

      // Calculate particle position (from outer to center)
      final curDist = p.maxDistance * distP * radiusMultiplier;
      final pos = outerPos + direction * curDist;

      // Pulse effect
      final pulse = .5 + .5 * math.sin((progress + p.pulseRate) * math.pi * 2);
      final sizePx = p.baseSize * pulse * radiusMultiplier;

      // Opacity with smooth fade
      double opacity = 1;
      if (progress < .2) {
        opacity = progress / .2;
      } else if (progress > .8) {
        opacity = (1 - progress) / .2;
      }

      // Color with random shift
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

      // Draw glow
      canvas.drawCircle(
          pos,
          sizePx * 1.6,
          Paint()
            ..color = col.withOpacity(.25)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2));

      // Draw core
      canvas.drawCircle(pos, sizePx, Paint()..color = col);
    }
  }

  // ───── easing ─────
  double _easeOutQuad(double t) => t * (2 - t);
  double _easeInQuad(double t) => t * t;

  // ───── overrides ─────
  @override
  bool shouldRepaint(EffectAnimator old) =>
      old is! PerimeterCircleBurstRayInAnimator ||
      old.particleCount != particleCount ||
      old.rayCount != rayCount ||
      old.rayLength != rayLength ||
      old.rayWidth != rayWidth ||
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
  double getOuterPadding() => 45;
}
