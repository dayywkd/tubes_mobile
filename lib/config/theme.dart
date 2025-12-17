import 'package:flutter/material.dart';

class AppTheme {
  static const primary = Color(0xFFb86f44);

  static ThemeData lightTheme = ThemeData(
    primaryColor: primary,
    colorScheme: ColorScheme.fromSwatch().copyWith(secondary: primary),
    scaffoldBackgroundColor: Colors.grey.shade50,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}
