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
  perimeterRadialBurst,
  perimeterShapeExplosion,
  perimeterShapeImplode,
  perimeterShapeRetractImplode,
  perimeterShapeExplodeOut,
  perimeterOrbitBloom,
  perimeterRayBurst,
  perimeterCircleBurst,
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
  ripple,
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
  pulseWave,
  dotBurst,
  dotAbsorbBurst,
  rayLine,
  circleOrbitSequential,
  multiRingOrbit,
  sequentialRingOrbit,
  flowerCircle,
  magicalOrbitDots,
  // rippleBeautiful,
  // whirlpoolNew,
  // firework,
  // ripple,
  // confetti,
  // orbital,
  // radialFirework,
  // sparkel,
  // breathAnimation,
  // clickRay,
  // // Tambahkan animasi baru di sini
  // pulseWave,
  // sparkleEffect,
  // lightning,
  // glowingOutline,
  // rotatingOrbs,
  // explodingStars,
  // rippleRings,
  // energyField,
  // particleSwarm,
  // shockwave,

  // // Second batch of new animators
  // bubblePop,
  // digitalGlitch,
  // geometricBloom,
  // soundWave,
  // smokePuff,
  // colorSpectrum,
  // pixelExplosion,
  // magicDust,
  // neonTrace,
  // waterRipple,
  // portalEffect,
  // electricArc,
  // paperShred,
  // bouncingBalls,
  // rainDrops,
  // starburstParticles,
  // fireflies,
  // magicSparkles,
  // emoticonExplosion,
  // magicPotionBubbles,
  // bubbleLetters,
  // mathicleCloud,
  // multiplicationRings,
  // numberOrbit,
  // algebraicTermWalk,
  // ray, // Pancaran cahaya bergaya kartun
  // whirlpool, // Pusaran air bergaya kartun
  // thudLines, // Garis getaran saat mendarat
  // cushion, // Efek mendarat di bantalan
}
