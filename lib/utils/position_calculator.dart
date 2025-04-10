import '../animators/effect_animator.dart';
import '../constants/enums.dart';
import 'package:flutter/material.dart';


class PositionCalculator {
  static Offset calculatePosition(
      AnimationPosition position, Size childSize, EffectAnimator animator) {
    final padding = animator.getOuterPadding();
    final halfWidth = childSize.width / 2;
    final halfHeight = childSize.height / 2;

    switch (position) {
      case AnimationPosition.inside:
        return Offset.zero;
      case AnimationPosition.top:
        return Offset(0, -halfHeight - padding);
      case AnimationPosition.right:
        return Offset(halfWidth + padding, 0);
      case AnimationPosition.bottom:
        return Offset(0, halfHeight + padding);
      case AnimationPosition.left:
        return Offset(-halfWidth - padding, 0);
      case AnimationPosition.topLeft:
        return Offset(-halfWidth - padding, -halfHeight - padding);
      case AnimationPosition.topRight:
        return Offset(halfWidth + padding, -halfHeight - padding);
      case AnimationPosition.bottomLeft:
        return Offset(-halfWidth - padding, halfHeight + padding);
      case AnimationPosition.bottomRight:
        return Offset(halfWidth + padding, halfHeight + padding);
      case AnimationPosition.outside:
        // Default dinamis berdasarkan ukuran widget
        // Ini adalah posisi 'terluar' yang otomatis menyesuaikan
        return Offset(0, -halfHeight - padding);
    }
  }
}

