import 'package:flutter/material.dart';

class AppTheme {

  ThemeData getTheme() {

    // Esquema de colores morado (el de la app) con la superficie en negro puro.
    // Todo lo que antes salía azul (puntitos del carrusel, barra inferior,
    // corazón de favoritos, chip de fecha, botones) sale de este esquema.
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF8C5A9B),
      brightness: Brightness.dark,
      surface: Colors.black,
    ).copyWith(
      primary: const Color(0xFFA97DBB), // morado claro del logo, buen contraste sobre negro
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.black,
      ),
    );
  }

}