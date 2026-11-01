import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Logo de Cinemapedia: una "C" morada con sombreado de papel doblado.
///
/// Es el mismo dibujo del icono de la aplicación. [progress] permite
/// "dibujar" la letra de forma animada (0 = nada, 1 = completa).
class CinemapediaLogo extends StatelessWidget {
  final double size;
  final double progress;

  const CinemapediaLogo({
    super.key,
    this.size = 28,
    this.progress = 1,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: CinemapediaLogoPainter(progress: progress),
    );
  }
}

class CinemapediaLogoPainter extends CustomPainter {
  final double progress;

  CinemapediaLogoPainter({required this.progress});

  static const _base = Color(0xFF8C5A9B);
  static const _dark = Color(0xFF5F3A70);
  static const _light = Color(0xFFA97DBB);

  // Media apertura de la C (en grados) y relación radio interior / exterior.
  static const double _open = 38;
  static const double _innerRatio = 56 / 120;

  @override
  void paint(Canvas canvas, Size size) {
    final side = math.min(size.width, size.height);
    final outer = side / 2;
    final inner = outer * _innerRatio;

    // La C está abierta a la derecha: se desplaza un poco para centrar el glifo.
    final center = Offset(size.width / 2 + 0.106 * outer, size.height / 2);

    final start = _open;
    final end = 360 - _open;
    final current = start + (end - start) * progress.clamp(0.0, 1.0);

    final segments = <(double, double, Color)>[
      (_open, 90, _dark),
      (90, 270, _base),
      (270, 360 - _open, _light),
    ];

    for (final (from, to, color) in segments) {
      final segEnd = math.min(to, current);
      if (segEnd <= from) continue;
      canvas.drawPath(
        _ring(center, outer, inner, from, segEnd),
        Paint()
          ..color = color
          ..isAntiAlias = true,
      );
    }
  }

  Path _ring(Offset c, double outer, double inner, double fromDeg, double toDeg) {
    final a0 = fromDeg * math.pi / 180;
    final sweep = (toDeg - fromDeg) * math.pi / 180;

    final path = Path()
      ..arcTo(Rect.fromCircle(center: c, radius: outer), a0, sweep, true)
      ..arcTo(Rect.fromCircle(center: c, radius: inner), a0 + sweep, -sweep, false)
      ..close();
    return path;
  }

  @override
  bool shouldRepaint(CinemapediaLogoPainter old) => old.progress != progress;
}
