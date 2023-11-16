import 'package:flutter/material.dart';

abstract class AppColors {
  static Color white = const Color(0xffffffff);
  static Color grey = const Color(0xffF5F5F5);
  static Color greyDark = const Color(0xff898989);
  static Color black = const Color(0xff000000);

  static Color lowPriority = const Color(0xff7995b0);
  static Color lowLightPriority = const Color(0xfff6f6f6);

  static Color primaryColor = const Color(0xF42560DF); //0xff4e4edd
  static Color secondaryColor = const Color(0x56295bff);
  static Color darkColor = const Color(0xf4153b4f);
  static Color scaffoldColor = const Color(0xf4257cdf);
  static Color appBarColor = const Color(0xf42f4de1);
  static Color primaryLight = const Color(0xffa8afe0);
  static Color greenColor = const Color(0xf461df25);
  static Color backgroundColor = const Color(0xFF212EBF);

  static Color redColor = const Color(0xf4df2535);
}

extension HexColor on Color {
  static Color fromHex(String hexColorString) {
    hexColorString = hexColorString.replaceAll('#', '');
    if (hexColorString.length == 6) {
      hexColorString = "FF$hexColorString"; // 8 char with opacity 100%
    }
    return Color(int.parse(hexColorString, radix: 16));
  }
}
