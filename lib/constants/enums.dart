import 'package:flutter/material.dart';

enum AnimationPosition {
  inside, // Di dalam widget
  outside, // Di luar widget (secara otomatis)
  top, // Di atas widget
  right, // Di kanan widget
  bottom, // Di bawah widget
  left, // Di kiri widget
  topLeft, // Di kiri atas widget
  topRight, // Di kanan atas widget
  bottomLeft, // Di kiri bawah widget
  bottomRight, // Di kanan bawah widget
}

enum AnimationUndergroundType {
  // Tipe baru yang ditambahkan
  // 6 Tipe animasi perimeter baru
  perimeterNewCircleBurstMixRayInAnimator,
  perimeterNewCircleBurstMixRayOutAnimator,
  perimeterNewRadialBurstIn,
  perimeterNewRadialBurstOut,

  perimeterNewCircleBurstOutAnimator,
  perimeterNewCircleBurstInAnimator,
  perimeterCirclePulsar,
  perimeterCircleOrbit,
  perimeterCircleWave,
  perimeterCircleTeleport,
  perimeterCircleRipple,
  perimeterPulseCascadeAnimator,
  perimeterConvergeBurstAnimator,
  perimeterPulsatingOrbit,
  perimeterSparkleTrail,
  perimeterRainbowRibbon,
  perimeterNeonPulse,
  perimeterEnergyField,
  perimeterParticleSwarm,
  perimeterGradientShimmer,

  // Animator perimeter blossoming untuk drop target
  perimeterBlossomOrbit,
  perimeterRadialBurst,
  perimeterShapeExplosion,
  perimeterShapeImplode,
  perimeterShapeRetractImplode,
  perimeterShapeExplodeOut,
  perimeterOrbitBloom,
  perimeterRayBurst,
  perimeterCircleBurst,
  perimeterCircleBurstDirectOut,
  perimeterCircleBurstDirectIn,
  perimeterCircleOrbitSequential,
  perimeterMultiRingOrbit,
  perimeterSequentialRingOrbit,
  shapeExplode,
  shapeVortex,
  shapePulse,
  shapeWave,
  shapeMorph,
  radialBurst,
  bounceOutward,
  spiralOutward,
  radialFirework,
  firework,
  spiral,
  shapeExplosion,
  shapeImplode,
  shapeRetractImplode,
  shapeExplodeOut,
  orbitBloom,
  circleBurst,
  circleBurstClean,
  magicDust,
  pixelExplosion,
  dotBurst,
  dotAbsorbBurst,
  rayLine,
  circleOrbitSequential,
  multiRingOrbit,
  sequentialRingOrbit,
  flowerCircle,
  magicalOrbitDots,
  perimeterCircleBurstDotRayOut,
  perimeterCircleBurstDotRayIn,
}
