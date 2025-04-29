import 'package:flutter/material.dart';

class MeasurementsSizeApp {
  static late double initSize;

  // Variabel untuk ukuran width
  static late double sizeSuperSmall;
  static late double sizeExtraSmall;
  static late double sizeSmall;
  static late double sizeSmallMedium;
  static late double sizeMedium;
  static late double sizeMediumLarge;
  static late double sizeLarge;
  static late double sizeExtraLarge;
  static late double sizeSuperLarge;

  // Variabel untuk ukuran font
  static late TextStyle bodySmall;
  static late TextStyle bodyMedium;
  static late TextStyle bodyLarge;
  static late TextStyle titleSmall;
  static late TextStyle titleMedium;
  static late TextStyle titleLarge;
  static late TextStyle headlineSmall;
  static late TextStyle headlineMedium;
  static late TextStyle headlineLarge;

  // Variabel untuk padding
  static late EdgeInsets paddingSuperSmall;
  static late EdgeInsets paddingExtraSmall;
  static late EdgeInsets paddingSmall;
  static late EdgeInsets paddingSmallMedium;
  static late EdgeInsets paddingMedium;
  static late EdgeInsets paddingLarge;
  static late EdgeInsets paddingMediumLarge;
  static late EdgeInsets paddingExtraLarge;
  static late EdgeInsets paddingSuperLarge;

  static late BorderRadius radiusSuperSmall;
  static late BorderRadius radiusExtraSmall;
  static late BorderRadius radiusSmall;
  static late BorderRadius radiusSmallMedium;
  static late BorderRadius radiusMedium;
  static late BorderRadius radiusLarge;
  static late BorderRadius radiusMediumLarge;
  static late BorderRadius radiusExtraLarge;
  static late BorderRadius radiusSuperLarge;
  static late double w100;
  static late Border borderSmallBlack;
  static late Border borderSmallMediumBlack;
  static late Border borderMediumBlack;
  static late double screenWidth;
  static late double screenHeight;
  static late double operationNumberSize;

  static void initialize(BuildContext context) {
    double screenEndpointWidth = MediaQuery.of(context).size.width;

    if (screenEndpointWidth < 400) {
      initSize = 1.5;
    } else if (screenEndpointWidth < 600) {
      initSize = 2.0;
    } else if (screenEndpointWidth >= 600 && screenEndpointWidth < 720) {
      initSize = 2.5;
    } else if (screenEndpointWidth >= 720 && screenEndpointWidth < 900) {
      initSize = 3.0;
    } else if (screenEndpointWidth >= 900 && screenEndpointWidth < 1200) {
      initSize = 3.5;
    } else {
      initSize = 4.0;
    }

    // Inisialisasi ukuran width
    sizeSuperSmall = calculatedSize(2);
    sizeExtraSmall = calculatedSize(4);
    sizeSmall = calculatedSize(8);
    sizeSmallMedium = calculatedSize(12);
    sizeMedium = calculatedSize(16);
    sizeMediumLarge = calculatedSize(20);
    sizeLarge = calculatedSize(26);
    sizeExtraLarge = calculatedSize(36);
    sizeSuperLarge = calculatedSize(40);

    // Inisialisasi ukuran font
    bodySmall = TextStyle(
        fontFamily: 'Inter',
        fontSize: calculatedSize(6),
        fontWeight: FontWeight.normal,
        color: Colors.white);
    bodyMedium = TextStyle(
        fontFamily: 'Inter',
        fontSize: calculatedSize(8),
        fontWeight: FontWeight.normal,
        color: Colors.white);
    bodyLarge = TextStyle(
        fontFamily: 'Inter',
        fontSize: calculatedSize(10),
        fontWeight: FontWeight.normal,
        color: Colors.white);
    titleSmall = TextStyle(
        fontFamily: 'Inter',
        fontSize: calculatedSize(12),
        fontWeight: FontWeight.normal,
        color: Colors.white);
    titleMedium = TextStyle(
        fontFamily: 'Inter',
        fontSize: calculatedSize(14),
        fontWeight: FontWeight.normal,
        color: Colors.white);
    titleLarge = TextStyle(
        fontFamily: 'Inter',
        fontSize: calculatedSize(16),
        fontWeight: FontWeight.normal,
        color: Colors.white);
    headlineSmall = TextStyle(
        fontFamily: 'Inter',
        fontSize: calculatedSize(20),
        fontWeight: FontWeight.bold,
        color: Colors.white);
    headlineMedium = TextStyle(
        fontFamily: 'Inter',
        fontSize: calculatedSize(24),
        fontWeight: FontWeight.bold,
        color: Colors.white);
    headlineLarge = TextStyle(
        fontFamily: 'Inter',
        fontSize: calculatedSize(28),
        fontWeight: FontWeight.bold,
        color: Colors.white);

    // Inisialisasi ukuran padding
    paddingSuperSmall = EdgeInsets.all(calculatedSize(2));
    paddingExtraSmall = EdgeInsets.all(calculatedSize(4));
    paddingSmall = EdgeInsets.all(calculatedSize(8));
    paddingSmallMedium = EdgeInsets.all(calculatedSize(12));
    paddingMedium = EdgeInsets.all(calculatedSize(16));
    paddingLarge = EdgeInsets.all(calculatedSize(20));
    paddingMediumLarge = EdgeInsets.all(calculatedSize(24));
    paddingExtraLarge = EdgeInsets.all(calculatedSize(28));
    paddingSuperLarge = EdgeInsets.all(calculatedSize(32));

    radiusSuperSmall = BorderRadius.circular(calculatedSize(2));
    radiusExtraSmall = BorderRadius.circular(calculatedSize(4));
    radiusSmall = BorderRadius.circular(calculatedSize(8));
    radiusSmallMedium = BorderRadius.circular(calculatedSize(12));
    radiusMedium = BorderRadius.circular(calculatedSize(16));
    radiusLarge = BorderRadius.circular(calculatedSize(20));
    radiusMediumLarge = BorderRadius.circular(calculatedSize(24));
    radiusExtraLarge = BorderRadius.circular(calculatedSize(28));
    radiusSuperLarge = BorderRadius.circular(calculatedSize(32));

    w100 = calculatedSize(100);
    operationNumberSize = calculatedSize(50);
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    borderSmallBlack =
        Border.all(color: Colors.black, width: calculatedSize(2));
    borderSmallMediumBlack =
        Border.all(color: Colors.black, width: calculatedSize(3));
    borderMediumBlack =
        Border.all(color: Colors.black, width: calculatedSize(4));
  }

  // Fungsi statik untuk menghitung ukuran berdasarkan initSize
  static double calculatedSize(double baseSize) {
    return baseSize * initSize;
  }
}
