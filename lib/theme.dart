import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  const seed = Color(0xFF6750A4);
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -1.2),
      headlineMedium: TextStyle(fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(height: 1.2),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}
