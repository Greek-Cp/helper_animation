import '../constants/enums.dart';
import 'dart:math' as math;
import 'dart:math';
import 'effect_animator.dart';
import 'package:flutter/material.dart';

class FireworkAnimator implements EffectAnimator {
  @override
  void paint(
      Canvas canvas, Size size, double progress, Offset center, Color color,
      {double radiusMultiplier = 1.0, Offset positionOffset = Offset.zero}) {
    // Aplikasikan offset ke center
    final adjustedCenter = center + positionOffset;

    // Identifikasi fase animasi
    final bool isPhase1 = progress < 0.25; // Fade-In (circles)
    final bool isPhase2 =
        progress >= 0.25 && progress < 0.5; // Stretch-Out (lines)
    final bool isPhase3 =
        progress >= 0.5 && progress < 0.75; // Close Circle (rings)
    final bool isPhase4 = progress >= 0.75; // Final Bloom & Fade (arcs)

    // Menentukan radius orbit (jarak dari pusat ke titik) - sekarang dengan radiusMultiplier
    final double orbitRadius =
        size.width * 0.7 * radiusMultiplier; // Jarak dari pusat ke titik
    final double dotRadius = 8.0; // Ukuran titik/lingkaran

    // Membuat 8 titik dengan interval 45 derajat
    for (int i = 0; i < 8; i++) {
      final double angle = (i * 45) * (math.pi / 180); // Convert to radians

      if (isPhase1) {
        // FASE 1: Fade-In dengan lingkaran solid
        final double phaseProgress = progress / 0.25;
        final Paint circlePaint = Paint()
          ..color = color.withOpacity(phaseProgress)
          ..style = PaintingStyle.fill;

        final Offset dotPosition = Offset(
          adjustedCenter.dx + math.cos(angle) * orbitRadius,
          adjustedCenter.dy + math.sin(angle) * orbitRadius,
        );

        canvas.drawCircle(dotPosition, dotRadius, circlePaint);
      } else if (isPhase2) {
        // FASE 2: Stretch-Out dengan garis
        final double phaseProgress = (progress - 0.25) / 0.25;
        final Paint linePaint = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12.0
          ..strokeCap = StrokeCap.round;

        // Posisi ujung dalam dan luar
        final Offset innerPoint = adjustedCenter;
        final Offset outerPoint = Offset(
          adjustedCenter.dx + math.cos(angle) * orbitRadius,
          adjustedCenter.dy + math.sin(angle) * orbitRadius,
        );

        // Menggambar garis dari pusat ke luar
        canvas.drawLine(innerPoint, outerPoint, linePaint);
      } else if (isPhase3) {
        // FASE 3: Close Circle dengan lingkaran hollow
        final double phaseProgress = (progress - 0.5) / 0.25;
        final Paint ringPaint = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0;

        final Offset dotPosition = Offset(
          adjustedCenter.dx + math.cos(angle) * orbitRadius,
          adjustedCenter.dy + math.sin(angle) * orbitRadius,
        );

        // Menggambar lingkaran hollow
        canvas.drawCircle(dotPosition, dotRadius, ringPaint);
      } else if (isPhase4) {
        // FASE 4: Final Bloom & Fade dengan arc
        final double phaseProgress = (progress - 0.75) / 0.25;
        final Paint arcPaint = Paint()
          ..color = color.withOpacity(1.0 - phaseProgress)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0;

        // Menghitung posisi arc
        final Rect arcRect = Rect.fromCenter(
          center: Offset(
            adjustedCenter.dx + math.cos(angle) * orbitRadius,
            adjustedCenter.dy + math.sin(angle) * orbitRadius,
          ),
          width: dotRadius * 3 * (1 + phaseProgress),
          height: dotRadius * 3 * (1 + phaseProgress),
        );

        // Menentukan sudut untuk arc (menghadap pusat)
        final double startAngle = angle + math.pi - 0.8;
        final double sweepAngle = 1.6; // Arc sebesar ~90 derajat

        canvas.drawArc(arcRect, startAngle, sweepAngle, false, arcPaint);
      }
    }
  }

  @override
  bool shouldRepaint(EffectAnimator oldAnimator) {
    return true; // Selalu repaint jika progress berubah (logika ini sudah ditangani di CustomPainter)
  }

  @override
  AnimationPosition getDefaultPosition() => AnimationPosition.outside;

  @override
  double getDefaultRadiusMultiplier() => 1.0;

  @override
  double getOuterPadding() => 15.0;
}
