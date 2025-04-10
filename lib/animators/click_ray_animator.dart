import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/enums.dart';
import 'effect_animator.dart';

class ClickRayAnimator implements EffectAnimator {
  final int rayCount;
  final bool addSparkles;
  final bool addRipples;

  ClickRayAnimator({
    this.rayCount = 8,
    this.addSparkles = true,
    this.addRipples = true,
  });

  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final adjustedCenter = center + positionOffset;

    // Calculate widget dimensions
    final widgetRadius = math.min(size.width, size.height) * 0.5;

    // Animation phases:
    // 0.0-0.2: Quick explosive growth
    // 0.2-0.7: Energetic pulsing
    // 0.7-1.0: Fade out with bounce

    double scaleProgress;
    double opacityProgress = 1.0;
    double pulseEffect = 0.0;

    if (progress < 0.2) {
      // Explosive growth phase
      scaleProgress =
          _elasticOut(progress / 0.2); // Elastic overshoot for "pop" effect
      pulseEffect = progress / 0.2;
    } else if (progress < 0.7) {
      // Energetic pulsing phase
      scaleProgress = 1.0;
      final pulseProgress = (progress - 0.2) / 0.5;
      pulseEffect =
          0.7 + 0.3 * math.sin(pulseProgress * math.pi * 5); // Fast pulsing
    } else {
      // Fade out phase with bounce
      final fadeOutProgress = (progress - 0.7) / 0.3;
      scaleProgress = 1.0 +
          0.1 * math.sin(fadeOutProgress * math.pi * 3); // Bouncy fade-out
      opacityProgress = 1.0 - fadeOutProgress;
      pulseEffect = 0.5 + 0.5 * (1.0 - fadeOutProgress);
    }

    // Draw ripple effects (behind rays)
    if (addRipples) {
      _drawRippleEffects(canvas, adjustedCenter, color, widgetRadius, progress,
          opacityProgress);
    }

    // Draw the main rays
    _drawClickRays(canvas, adjustedCenter, color, widgetRadius, scaleProgress,
        opacityProgress, pulseEffect, radiusMultiplier);

    // Draw sparkles for extra pizzazz
    if (addSparkles) {
      _drawSparkles(canvas, adjustedCenter, color, widgetRadius, progress,
          opacityProgress, scaleProgress);
    }
  }

  // Elastic easing function for explosive "pop" effect
  double _elasticOut(double t) {
    return math.pow(2, -10 * t) * math.sin((t - 0.075) * (2 * math.pi) / 0.3) +
        1;
  }

  void _drawClickRays(
      Canvas canvas,
      Offset center,
      Color color,
      double widgetRadius,
      double scale,
      double opacity,
      double pulseEffect,
      double radiusMultiplier) {
    // Gap between widget and ray start (to ensure rays are outside widget)
    final rayStartGap = widgetRadius * 0.18;

    // Maximum ray length (adjusted by scale and radiusMultiplier)
    final baseRayLength = widgetRadius * 0.85 * radiusMultiplier;
    final currentRayLength = baseRayLength * scale;

    // Layer 1: Outer glow behind rays (for more energy)
    final glowPaint = Paint()
      ..color = color.withOpacity(0.2 * opacity * pulseEffect)
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 20.0 * pulseEffect);

    canvas.drawCircle(center, widgetRadius + currentRayLength, glowPaint);

    // Draw rays with staggered lengths for more dynamic look
    for (int i = 0; i < rayCount; i++) {
      final angle = i * (2 * math.pi / rayCount);

      // Vary ray length slightly for more dynamic look
      final rayLengthVariation =
          0.8 + 0.4 * math.sin(i * 0.7 + pulseEffect * math.pi * 3);
      final thisRayLength = currentRayLength * rayLengthVariation;

      // Calculate ray thickness with pulsing effect
      final baseThickness = math.max(widgetRadius * 0.14, 7.0);
      final rayThickness = baseThickness * (0.9 + 0.2 * pulseEffect);

      // Calculate ray start point (outside widget boundary with a gap)
      final startPoint = Offset(
          center.dx + math.cos(angle) * (widgetRadius + rayStartGap),
          center.dy + math.sin(angle) * (widgetRadius + rayStartGap));

      // Calculate ray end point
      final endPoint = Offset(
          center.dx +
              math.cos(angle) * (widgetRadius + rayStartGap + thisRayLength),
          center.dy +
              math.sin(angle) * (widgetRadius + rayStartGap + thisRayLength));

      // Give each ray a slightly different hue for rainbow effect
      final hueShift = (i * 8) % 30;
      final rayColor = _shiftHue(color, hueShift.toDouble());

      // Create ray glow for extra energy
      final rayGlowPaint = Paint()
        ..color = rayColor.withOpacity(0.3 * opacity * pulseEffect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = rayThickness * 1.8
        ..strokeCap = StrokeCap.round
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, rayThickness * 0.8);

      canvas.drawLine(startPoint, endPoint, rayGlowPaint);

      // Create main ray
      final rayPaint = Paint()
        ..color = rayColor.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = rayThickness
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(startPoint, endPoint, rayPaint);

      // Add bright core to each ray
      final rayCenterPaint = Paint()
        ..color = Colors.white.withOpacity(0.7 * opacity * pulseEffect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = rayThickness * 0.4
        ..strokeCap = StrokeCap.round
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1.0);

      canvas.drawLine(startPoint, endPoint, rayCenterPaint);
    }
  }

  void _drawSparkles(Canvas canvas, Offset center, Color color,
      double widgetRadius, double progress, double opacity, double scale) {
    final random = math.Random(42); // Fixed seed for deterministic animation
    final sparkleCount = 12;

    // Skip sparkles at the very beginning for better timing
    if (progress < 0.05) return;

    // Gradually increase sparkle distance over time for "expanding" effect
    final minDistance = widgetRadius * 1.2;
    final maxDistance = widgetRadius * 2.0 * scale;

    for (int i = 0; i < sparkleCount; i++) {
      // Randomize sparkle positions
      final angle = random.nextDouble() * math.pi * 2;
      final distance =
          minDistance + random.nextDouble() * (maxDistance - minDistance);

      // Sparkle position
      final sparkleX = center.dx + math.cos(angle) * distance;
      final sparkleY = center.dy + math.sin(angle) * distance;
      final sparklePos = Offset(sparkleX, sparkleY);

      // Make sparkles appear at different times for twinkling effect
      final sparkleDelay = 0.1 * i / sparkleCount;
      final sparkleProgress =
          math.max(0.0, math.min(1.0, (progress - sparkleDelay) * 2));

      // Skip if not yet visible
      if (sparkleProgress <= 0) continue;

      // Sparkle size pulsates and varies between sparkles
      final baseSize = widgetRadius * 0.08;
      final sparkleSize = baseSize *
          (0.5 + 0.8 * random.nextDouble()) *
          sparkleProgress *
          (0.7 + 0.3 * math.sin(progress * math.pi * 8 + i));

      // Sparkle color varies slightly
      final sparkleColor = _shiftHue(color, (i * 15) % 60);
      final sparklePaint = Paint()
        ..color = sparkleColor.withOpacity(opacity * sparkleProgress)
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, sparkleSize * 0.5);

      // Draw sparkle (as a small circle)
      canvas.drawCircle(sparklePos, sparkleSize, sparklePaint);

      // Add bright center to sparkle
      final centerPaint = Paint()
        ..color = Colors.white.withOpacity(opacity * sparkleProgress * 0.8)
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, sparkleSize * 0.2);

      canvas.drawCircle(sparklePos, sparkleSize * 0.4, centerPaint);
    }
  }

  void _drawRippleEffects(Canvas canvas, Offset center, Color color,
      double widgetRadius, double progress, double opacity) {
    // Create 3 expanding ripples at different phases
    for (int i = 0; i < 3; i++) {
      // Stagger the ripples
      final rippleOffset = i * (1.0 / 3);
      final rippleProgress = (progress + rippleOffset) % 1.0;

      // Ripples should expand and fade out
      final rippleExpansion =
          math.pow(rippleProgress, 0.8).toDouble(); // Slightly slower expansion
      final rippleOpacity =
          math.max(0.0, 1.0 - rippleExpansion) * 0.3; // Fade out as they expand

      // Skip if barely visible
      if (rippleOpacity < 0.03) continue;

      // Calculate ripple size
      final maxRippleSize = widgetRadius * 2.5;
      final rippleSize = widgetRadius + rippleExpansion * maxRippleSize;

      // Create ripple paint
      final ripplePaint = Paint()
        ..color = color.withOpacity(rippleOpacity * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = widgetRadius *
            0.03 *
            (1.0 - rippleExpansion * 0.5) // Thinner as they expand
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, widgetRadius * 0.05);

      // Draw the ripple
      canvas.drawCircle(center, rippleSize, ripplePaint);
    }
  }

  // Helper to shift the hue of a color
  Color _shiftHue(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return HSLColor.fromAHSL(
      color.opacity,
      (hsl.hue + amount) % 360,
      hsl.saturation,
      hsl.lightness,
    ).toColor();
  }

  @override
  bool shouldRepaint(EffectAnimator oldAnimator) => true;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  @override
  double getDefaultRadiusMultiplier() => 1.2; // Increased for more impact

  @override
  double getOuterPadding() =>
      120.0; // Significantly increased for all the effects
}
