// File: lib/constants/app_size_minigame.dart

import 'package:flutter/material.dart';

class AppSizeMinigame {
  AppSizeMinigame._(); // private constructor untuk mencegah instansiasi

  static const double borderRadiusGlobalMinigame = 30.0;
  static const double sizePaddingSymetric = 13.0;
  static const EdgeInsets paddingGlobalMinigame = EdgeInsets.only(
      left: sizePaddingSymetric,
      right: sizePaddingSymetric,
      top: sizePaddingSymetric - 2);
}
