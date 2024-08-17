import 'package:flutter/material.dart';

class ThemeSystem {
  static ThemeData get light =>
      ThemeData(scaffoldBackgroundColor: Colors.white);

  static ThemeData get dark => ThemeData();

  static ThemeData currentThemeSystem = ThemeSystem.light;

  static toogleThemeSystem() {
    if (currentThemeSystem == ThemeSystem.light) {
      currentThemeSystem = ThemeSystem.dark;
    } else {
      currentThemeSystem = ThemeSystem.light;
    }
  }
}
