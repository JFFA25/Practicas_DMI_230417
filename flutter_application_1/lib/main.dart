import 'package:flutter/material.dart';
import 'presentation/counter/counter_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CounterScreen(), // Ahora sí reconocerá el widget sin errores
    );
  }
}
