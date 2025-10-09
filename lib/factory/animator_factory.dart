import 'package:helper_animation/animators/new_animator.dart';
import 'package:helper_animation/animators/new_perimeter_animation.dart';
import 'package:helper_animation/animators/old_animator.dart';
import 'package:helper_animation/animators/perimeter_animation.dart';

import '../constants/enums.dart';
import '../animators/effect_animator.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

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

class AnimatorFactory {
  static EffectAnimator createAnimator(
    AnimationUndergroundType type, {
    bool enableMixedColor = false,
    List<Color>? particleColors,
  }) {
    switch (type) {
      case AnimationUndergroundType.perimeterCircleBurstDotRayOut:
        return PerimeterCircleBurstDotRayOutAnimator(
          enableHueTilt: enableMixedColor,
          dotParticleCount: 16,
          rayParticleCount: 8,
          rayLength: 30.0,
          rayWidth: 3.0,
          saturationBoost: enableMixedColor ? 1.1 : 1.0,
        );
      case AnimationUndergroundType.perimeterCircleBurstDotRayIn:
        return PerimeterCircleBurstDotRayInAnimator(
          enableHueTilt: enableMixedColor,
          dotParticleCount: 16,
          rayParticleCount: 8,
          rayLength: 30.0,
          rayWidth: 3.0,
          saturationBoost: enableMixedColor ? 1.1 : 1.0,
        );
      case AnimationUndergroundType.perimeterPulseCascadeAnimator:
        return PerimeterPulseCascadeAnimator(
          enableHueTilt: enableMixedColor,
        );
      case AnimationUndergroundType.perimeterConvergeBurstAnimator:
        return PerimeterConvergeBurstAnimator(
          enableHueTilt: enableMixedColor,
        );
      // Animator perimeter tambahan
      case AnimationUndergroundType.perimeterPulsatingOrbit:
        return PerimeterPulsatingOrbitAnimator(enableHueTilt: enableMixedColor);
      case AnimationUndergroundType.perimeterSparkleTrail:
        return PerimeterSparkleTrailAnimator(enableHueTilt: enableMixedColor);
      case AnimationUndergroundType.perimeterRainbowRibbon:
        return PerimeterRainbowRibbonAnimator(enableHueTilt: enableMixedColor);
      case AnimationUndergroundType.perimeterNeonPulse:
        return PerimeterNeonPulseAnimator(enableHueTilt: enableMixedColor);
      case AnimationUndergroundType.perimeterEnergyField:
        return PerimeterEnergyFieldAnimator(enableHueTilt: enableMixedColor);
      case AnimationUndergroundType.perimeterParticleSwarm:
        return PerimeterParticleSwarmAnimator(enableHueTilt: enableMixedColor);
      case AnimationUndergroundType.perimeterGradientShimmer:
        return PerimeterGradientShimmerAnimator(
            enableHueTilt: enableMixedColor);

      // Animator perimeter blossoming khusus untuk drop target
      case AnimationUndergroundType.perimeterBlossomOrbit:
        return PerimeterBlossomOrbitAnimator(
          particleCount: 20,
          baseRadius: 5.0,
          orbitRadius: 10.0,
          blossomSpeed: 1.0,
          enableHueTilt: enableMixedColor,
        );
      // Animator perimeter baru
      case AnimationUndergroundType.perimeterRadialBurst:
        return PerimeterGradientShimmerAnimator(
            enableHueTilt: enableMixedColor);
      case AnimationUndergroundType.perimeterShapeExplosion:
        return PerimeterShapeExplosionAnimator(enableHueTilt: enableMixedColor);
      case AnimationUndergroundType.perimeterShapeImplode:
        return PerimeterShapeImplodeAnimator(enableHueTilt: enableMixedColor);
      case AnimationUndergroundType.perimeterShapeRetractImplode:
        return PerimeterShapeRetractImplodeAnimator(
            enableHueTilt: enableMixedColor);
      case AnimationUndergroundType.perimeterShapeExplodeOut:
        return PerimeterShapeExplodeOutAnimator(
            enableHueTilt: enableMixedColor);
      case AnimationUndergroundType.perimeterOrbitBloom:
        return PerimeterOrbitBloomAnimatorV2(enableHueTilt: enableMixedColor);
      case AnimationUndergroundType.perimeterRayBurst:
        return PerimeterRayBurstMovingAnimator(enableHueTilt: enableMixedColor);
      case AnimationUndergroundType.perimeterCircleBurst:
        return PerimeterCircleBurstAnimator(enableHueTilt: enableMixedColor);
      case AnimationUndergroundType.perimeterCircleOrbitSequential:
        return PerimeterCircleOrbitSequentialAnimator(
            enableHueTilt: enableMixedColor);
      case AnimationUndergroundType.perimeterMultiRingOrbit:
        return PerimeterMultiRingOrbitAnimator(enableHueTilt: enableMixedColor);
      case AnimationUndergroundType.perimeterSequentialRingOrbit:
        return PerimeterSequentialRingOrbitAnimator(
            enableHueTilt: enableMixedColor);
      case AnimationUndergroundType.shapeExplode:
        return PerimeterRadialBurstAnimator(enableColorShift: enableMixedColor);
      case AnimationUndergroundType.shapeVortex:
        return ShapeVortexAnimator(enableHueTilt: enableMixedColor);
      case AnimationUndergroundType.shapePulse:
        return ShapePulseAnimator(enableHueTilt: enableMixedColor);
      case AnimationUndergroundType.shapeWave:
        return ShapeWaveAnimator(enableHueTilt: enableMixedColor);
      case AnimationUndergroundType.shapeMorph:
        return ShapeMorphAnimator(
          enableHueTilt: false,
          startShape: ShapeType.circle,
          endShape: ShapeType.star,
        );
      case AnimationUndergroundType.radialBurst:
        return RadialBurstAnimator(enableColorShift: enableMixedColor);
      case AnimationUndergroundType.bounceOutward:
        return BounceOutwardAnimator(enableColorShift: enableMixedColor);
      case AnimationUndergroundType.spiralOutward:
        return SpiralOutwardAnimator(enableColorShift: enableMixedColor);
      case AnimationUndergroundType.radialFirework:
        return RadialFireworkAnimator(enableColorShift: enableMixedColor);
      case AnimationUndergroundType.firework:
        return ShapeExplosionAnimator(enableHueTilt: enableMixedColor);
      case AnimationUndergroundType.spiral:
        return SpiralExplosionAnimator(enableHueTilt: enableMixedColor);
      case AnimationUndergroundType.shapeExplosion:
        return ShapeExplosionAnimator(enableHueTilt: enableMixedColor);
      case AnimationUndergroundType.shapeImplode:
        return ShapeImplodeAnimator(enableHueTilt: enableMixedColor);
      case AnimationUndergroundType.shapeRetractImplode:
        return ShapeRetractImplodeAnimator(enableHueTilt: enableMixedColor);
      case AnimationUndergroundType.shapeExplodeOut:
        return ShapeExplodeOutAnimator(enableHueTilt: enableMixedColor);
      case AnimationUndergroundType.orbitBloom:
        return OrbitBloomAnimatorV2(enableHueTilt: enableMixedColor);
      case AnimationUndergroundType.circleBurst:
        return CircleBurstAnimator(enableHueTilt: enableMixedColor);
      case AnimationUndergroundType.circleBurstClean:
        return CircleBurstCleanAnimator(enableHueTilt: enableMixedColor);
      case AnimationUndergroundType.magicDust:
        return MagicDustAnimator(enableHueTilt: enableMixedColor);
      case AnimationUndergroundType.pixelExplosion:
        return PixelExplosionAnimator(
          enableHueTilt: enableMixedColor,
          particleColors: particleColors,
        );
      case AnimationUndergroundType.dotBurst:
        return DotBurstAnimator(enableHueTilt: enableMixedColor);
      case AnimationUndergroundType.dotAbsorbBurst:
        return DotAbsorbBurstAnimator(enableHueTilt: enableMixedColor);
      case AnimationUndergroundType.rayLine:
        return RayBurstMovingAnimator(enableHueTilt: enableMixedColor);
      case AnimationUndergroundType.circleOrbitSequential:
        return CircleOrbitSequentialAnimator(enableHueTilt: enableMixedColor);
      case AnimationUndergroundType.multiRingOrbit:
        return MultiRingOrbitAnimator(enableHueTilt: enableMixedColor);
      case AnimationUndergroundType.sequentialRingOrbit:
        return SequentialRingOrbitAnimator(enableHueTilt: enableMixedColor);
      case AnimationUndergroundType.flowerCircle:
        return FlowerCircleAnimator(enableHueTilt: enableMixedColor);
      case AnimationUndergroundType.magicalOrbitDots:
        return MagicalOrbitDotsAnimator(enableHueTilt: enableMixedColor);
      case AnimationUndergroundType.perimeterCircleBurstDirectOut:
        return PerimeterCircleDirectOutAnimator(
            enableHueTilt: enableMixedColor);
      case AnimationUndergroundType.perimeterCircleBurstDirectIn:
        return PerimeterCircleOutsideInAnimator(
            enableHueTilt: enableMixedColor);
      case AnimationUndergroundType.perimeterCirclePulsar:
        return PerimeterCirclePulsarAnimator(
          enableHueTilt: enableMixedColor,
          saturationBoost: enableMixedColor ? 1.2 : 1.0,
          hueTiltRange: enableMixedColor ? 0.45 : 0.0,
        );

      case AnimationUndergroundType.perimeterCircleOrbit:
        return PerimeterCircleOrbitAnimator(
          enableHueTilt: enableMixedColor,
          saturationBoost: enableMixedColor ? 1.15 : 1.0,
          hueTiltRange: enableMixedColor ? 0.3 : 0.0,
          enableTrails: true,
        );

      case AnimationUndergroundType.perimeterCircleWave:
        return PerimeterCircleWaveAnimator(
          enableHueTilt: enableMixedColor,
          saturationBoost: enableMixedColor ? 1.2 : 1.0,
          hueTiltRange: enableMixedColor ? 0.5 : 0.0,
        );

      case AnimationUndergroundType.perimeterCircleTeleport:
        return PerimeterCircleTeleportAnimator(
          enableHueTilt: enableMixedColor,
          saturationBoost: enableMixedColor ? 1.1 : 1.0,
          hueTiltRange: enableMixedColor ? 0.4 : 0.0,
        );

      case AnimationUndergroundType.perimeterCircleRipple:
        return PerimeterCircleRippleAnimator(
          enableHueTilt: enableMixedColor,
          saturationBoost: enableMixedColor ? 1.1 : 1.0,
          hueTiltRange: enableMixedColor ? 0.3 : 0.0,
        );
      case AnimationUndergroundType.perimeterNewRadialBurstIn:
        // TODO: Handle this case.
        return PerimeterNewRadialBurstAnimatorIn(
            enableColorShift: enableMixedColor);

      case AnimationUndergroundType.perimeterNewRadialBurstOut:
        return PerimeterNewRadialBurstAnimatorOut(
            enableColorShift: enableMixedColor);
      case AnimationUndergroundType.perimeterNewCircleBurstOutAnimator:
        // TODO: Handle this case.
        return PerimeterNewCircleBurstOutAnimator(
            enableHueTilt: enableMixedColor);

      case AnimationUndergroundType.perimeterNewCircleBurstInAnimator:
        return PerimeterCircleBurstAnimator(enableHueTilt: enableMixedColor);
      case AnimationUndergroundType.perimeterNewCircleBurstMixRayInAnimator:
        return PerimeterCircleBurstRayInAnimator(
            enableHueTilt: enableMixedColor);
      case AnimationUndergroundType.perimeterNewCircleBurstMixRayOutAnimator:
        return PerimeterCircleBurstRayAnimator(enableHueTilt: enableMixedColor);
      // TODO: Handle this case.
    }
  }
}
