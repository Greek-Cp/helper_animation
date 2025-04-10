import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/enums.dart';
import 'effect_animator.dart';

class BreathAnimator implements EffectAnimator {
  final int ringCount;
  final int auraWaveCount;

  BreathAnimator({this.ringCount = 4, this.auraWaveCount = 5});

  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    final adjustedCenter = center + positionOffset;

    // Base size calculation
    final maxDimension = math.max(size.width, size.height);
    final baseRadius = maxDimension * 0.4 * radiusMultiplier;

    // Create breathing animation with sine wave
    final breathCycle = math.sin(progress * math.pi * 2);
    final breathProgress = 0.6 + 0.4 * (0.5 + 0.5 * breathCycle);

    // Draw aura-like pulse waves
    _drawAuraPulseWaves(
        canvas, adjustedCenter, progress, color, baseRadius, breathProgress);

    // Draw base green circles (from the image)
    _drawBaseGradientCircles(
        canvas, adjustedCenter, breathProgress, color, baseRadius);

    // Draw center glow
    _drawCenterGlow(
        canvas, adjustedCenter, progress, color, baseRadius, breathProgress);
  }

  void _drawAuraPulseWaves(Canvas canvas, Offset center, double progress,
      Color color, double baseRadius, double breathProgress) {
    // Draw multiple aura-like pulse waves
    for (int i = 0; i < auraWaveCount; i++) {
      // Calculate the progress of each wave
      final waveOffset = i * (1.0 / auraWaveCount);
      final waveProgress = (progress + waveOffset) % 1.0;

      // Create expansion effect with easing
      final expansion = math.pow(waveProgress, 0.6).toDouble();

      // Calculate opacity that fades out as the wave expands
      final fadePoint = 0.7; // Start fading at 70% expansion
      final opacity = waveProgress < fadePoint
          ? 0.6 * (1.0 - waveProgress / fadePoint)
          : 0.0;

      // Calculate radius for an expanding aura wave
      final waveRadius = baseRadius * (0.6 + 1.8 * expansion);

      // Create an aura-like effect with multiple overlapping circles of varying opacity
      for (int j = 0; j < 3; j++) {
        final layerRatio = j / 2.0;
        final layerRadius = waveRadius * (1.0 - layerRatio * 0.1);
        final layerOpacity = opacity * (1.0 - layerRatio * 0.3);

        // Create a gradient from the center to simulate aura glow
        final gradient = RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            color.withOpacity(layerOpacity * 0.8),
            color.withOpacity(0),
          ],
          stops: [0.7, 1.0],
        );

        // Create a shader from the gradient
        final rect = Rect.fromCircle(
          center: center,
          radius: layerRadius,
        );
        final shader = gradient.createShader(rect);

        // Draw the aura layer
        final auraPaint = Paint()
          ..shader = shader
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8.0 - layerRatio * 3.0 // Thicker inner layers
          ..maskFilter =
              MaskFilter.blur(BlurStyle.normal, 6.0 - layerRatio * 2.0);

        canvas.drawCircle(center, layerRadius, auraPaint);
      }

      // Add additional thin bright ring at the edge for definition
      if (opacity > 0.1) {
        final edgePaint = Paint()
          ..color = color.withOpacity(opacity * 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1.0);

        canvas.drawCircle(center, waveRadius, edgePaint);
      }
    }

    // Add a subtle pulsing aura around the widget
    final auraPaint = Paint()
      ..color = color.withOpacity(0.15 * (0.7 + 0.3 * breathProgress))
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 15.0 * breathProgress);

    canvas.drawCircle(center, baseRadius * 1.2 * breathProgress, auraPaint);
  }

  void _drawBaseGradientCircles(Canvas canvas, Offset center,
      double breathProgress, Color color, double baseRadius) {
    // Draw concentric circles from outside in (like in the image)
    for (int i = ringCount; i >= 0; i--) {
      final ratio = i / ringCount;
      final ringRadius =
          baseRadius * 0.7 * breathProgress * (1.0 - ratio * 0.2);

      // Calculate opacity - more transparent toward edges (like in example)
      final opacity = math.pow(1.0 - ratio, 0.6).toDouble() * 0.9;

      // Adjust color - brighter in center
      final ringColor = _adjustGreenShade(color, ratio);

      // Use radial gradient for more aura-like appearance
      final gradient = RadialGradient(
        center: Alignment.center,
        radius: 0.7,
        colors: [
          ringColor.withOpacity(opacity),
          ringColor.withOpacity(opacity * 0.6),
        ],
        stops: [0.5, 1.0],
      );

      final rect = Rect.fromCircle(
        center: center,
        radius: ringRadius,
      );

      final ringPaint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4.0 * ratio);

      canvas.drawCircle(center, ringRadius, ringPaint);
    }
  }

  void _drawCenterGlow(Canvas canvas, Offset center, double progress,
      Color color, double baseRadius, double breathProgress) {
    // Pulsating center effect
    final pulseFactor =
        0.9 + 0.1 * math.sin(progress * math.pi * 5); // Fast pulse

    // Bright center - main green circle
    final centerColor = _brightenColor(color, 0.2);

    // Main center circle with gradient for better depth
    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: [
        centerColor,
        color,
      ],
      stops: [0.7, 1.0],
    );

    final rect = Rect.fromCircle(
      center: center,
      radius: baseRadius * 0.3 * breathProgress * pulseFactor,
    );

    final centerPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
        center, baseRadius * 0.3 * breathProgress * pulseFactor, centerPaint);

    // Add inner glow
    final glowPaint = Paint()
      ..color = centerColor.withOpacity(0.7)
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8.0 * breathProgress);

    canvas.drawCircle(center, baseRadius * 0.36 * breathProgress, glowPaint);

    // Add tiny bright spot in the very center for extra luminosity
    final brightSpotPaint = Paint()
      ..color = Colors.white.withOpacity(0.9 * pulseFactor)
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3.0);

    canvas.drawCircle(center, baseRadius * 0.1 * breathProgress * pulseFactor,
        brightSpotPaint);
  }

  // Create the green gradient effect seen in the example
  Color _adjustGreenShade(Color baseColor, double ratio) {
    final hsl = HSLColor.fromColor(baseColor);

    // Center is brighter, edges are deeper color
    final lightnessAdjustment = (1.0 - ratio) * 0.4; // Brighter in center

    return HSLColor.fromAHSL(
      1.0,
      hsl.hue,
      math.max(0,
          hsl.saturation * (0.8 + 0.2 * ratio)), // Slightly desaturate center
      math.min(1.0, hsl.lightness + lightnessAdjustment),
    ).toColor();
  }

  // Simple utility to brighten a color
  Color _brightenColor(Color color, double amount) {
    return Color.fromARGB(
      color.alpha,
      math.min(255, color.red + (amount * 255).toInt()),
      math.min(255, color.green + (amount * 255).toInt()),
      math.min(255, color.blue + (amount * 255).toInt()),
    );
  }

  @override
  bool shouldRepaint(EffectAnimator oldAnimator) => true;

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  @override
  double getDefaultRadiusMultiplier() => 1.4; // Increased for better visibility

  @override
  double getOuterPadding() => 80.0; // Increased to accommodate aura waves
}
