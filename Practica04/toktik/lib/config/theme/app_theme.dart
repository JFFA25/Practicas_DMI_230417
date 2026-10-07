import 'package:flutter/material.dart';
import 'package:toktik/presentation/providers/theme_provider.dart';

class AppTheme {
  AppTheme(this.season);

  final SeasonalTheme season;

  ThemeData getTheme() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: season.fontFamily,
    // Si la fuente temática no tiene un carácter (acentos, signos), se usa Poppins.
    fontFamilyFallback: const ['Poppins'],
    colorScheme: ColorScheme.fromSeed(
      seedColor: season.primaryColor,
      secondary: season.secondaryColor,
      brightness: Brightness.dark,
      surface: const Color(0xFF101014),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: season.primaryColor.withValues(alpha: 0.94),
      foregroundColor: Colors.white,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: season.primaryColor,
      foregroundColor: Colors.white,
    ),
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: season.secondaryColor.withValues(alpha: 0.35),
    ),
  );
}
