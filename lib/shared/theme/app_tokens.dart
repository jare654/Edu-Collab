import 'package:flutter/material.dart';

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double jumbo = 40;

  static const EdgeInsets screen = EdgeInsets.symmetric(horizontal: 20);
}

class AppRadius {
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 22;
  static const double pill = 999;
}

class AppElevations {
  static const List<BoxShadow> soft = [
    BoxShadow(
      color: Color(0x142563EB),
      blurRadius: 24,
      offset: Offset(0, 12),
    ),
  ];
  static const List<BoxShadow> lift = [
    BoxShadow(
      color: Color(0x1F1E3A8A),
      blurRadius: 34,
      offset: Offset(0, 18),
    ),
  ];
}
