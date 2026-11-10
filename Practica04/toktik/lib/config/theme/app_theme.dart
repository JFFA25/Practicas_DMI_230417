import 'package:flutter/material.dart';

class AppTheme {

  // Morado de la marca (el mismo de la "C" del icono)
  static const Color brandPurple = Color(0xFF8C5A9B);
  static const Color brandPurpleLight = Color(0xFFA97DBB);

  ThemeData getTheme() {

    // Esquema generado a partir del morado de la marca, con superficie negra pura.
    // `primary` (puntos del carrusel, menú inferior, iconos...) usa el morado claro
    // para que se lea bien sobre el fondo negro.
    final colorScheme = ColorScheme.fromSeed(
      seedColor: brandPurple,
      brightness: Brightness.dark,
      surface: Colors.black,
    ).copyWith(
      primary: brandPurpleLight,
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