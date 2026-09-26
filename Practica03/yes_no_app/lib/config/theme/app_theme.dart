import 'package:flutter/material.dart';

const Color _customColor = Color(0xFF5C11D4);

const List<Color> colorThemes = [
  _customColor,
  Colors.blue,
  Colors.teal,
  Colors.green,
  Colors.yellow,
  Colors.orange,
  Colors.pink,
];

class AppTheme {
  final int selectedColor;

  AppTheme({
    this.selectedColor = 0
  }): assert(selectedColor >= 0 && selectedColor < colorThemes.length, 'selectedColor must be between 0 and ${colorThemes.length - 1}');




  ThemeData theme() {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: colorThemes[selectedColor], 
      //brightness: Brightness.dark,
    );
  }
}
