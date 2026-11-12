import 'package:flutter/material.dart';

ThemeData buildNightTheme() {
  const bg = Color(0xFF000000);
  const accent = Color(0xFF7CFC9A);
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.dark(
      primary: accent,
      onPrimary: Colors.black,
      surface: Color(0xFF14181C),
      error: Color(0xFFFF6B6B),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: bg,
      foregroundColor: Colors.white,
      centerTitle: true,
    ),
  );
}