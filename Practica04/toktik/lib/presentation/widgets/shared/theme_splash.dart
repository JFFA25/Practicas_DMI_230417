import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:toktik/presentation/providers/theme_provider.dart';

/// Muestra una splash screen a pantalla completa con el icono de la temática.
///
/// Orden: aparece (fade) -> se ejecuta [apply] (cambio de tema/icono/sonido)
/// por debajo -> se mantiene un mínimo de tiempo -> desaparece.
/// Así el usuario nunca ve el salto brusco de colores/fuente/icono.
/// Si [apply] lanza un error, se cierra la splash y el error se vuelve a lanzar.
Future<void> showThemeSplash(
  BuildContext context, {
  required SeasonalTheme target,
  required Future<void> Function() apply,
  Duration minimumDuration = const Duration(milliseconds: 1800),
}) async {
  final error = await showGeneralDialog<Object>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'Cambiando tema',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, _, _) => _ThemeSplash(
      theme: target,
      apply: apply,
      minimumDuration: minimumDuration,
    ),
    transitionBuilder: (_, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
  );
  if (error != null) throw error;
}

class _ThemeSplash extends StatefulWidget {
  const _ThemeSplash({
    required this.theme,
    required this.apply,
    required this.minimumDuration,
  });

  final SeasonalTheme theme;
  final Future<void> Function() apply;
  final Duration minimumDuration;

  @override
  State<_ThemeSplash> createState() => _ThemeSplashState();
}

class _ThemeSplashState extends State<_ThemeSplash> {
  @override
  void initState() {
    super.initState();
    unawaited(_run());
  }

  Future<void> _run() async {
    Object? error;
    final startedAt = DateTime.now();
    // Espera a que termine el fade-in para que el cambio ocurra "tapado".
    await Future<void>.delayed(const Duration(milliseconds: 320));
    try {
      await widget.apply();
    } catch (e) {
      error = e;
    }
    final remaining =
        widget.minimumDuration - DateTime.now().difference(startedAt);
    if (error == null && !remaining.isNegative) {
      await Future<void>.delayed(remaining);
    }
    if (!mounted) return;
    Navigator.of(context).pop<Object>(error);
  }

  @override
  Widget build(BuildContext context) {
    // Colores y fuente salen del tema de DESTINO, no de Theme.of(context):
    // así la splash se ve igual aunque el tema de la app cambie por debajo.
    final theme = widget.theme;
    final labelFont = theme.displayFontFamily ?? theme.fontFamily;

    return PopScope(
      canPop: false,
      child: PointerInterceptor(
        child: Material(
          color: const Color(0xFF101014),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.2),
                radius: 1.0,
                colors: [
                  theme.primaryColor.withValues(alpha: 0.35),
                  theme.secondaryColor.withValues(alpha: 0.12),
                  const Color(0xFF101014),
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) => Transform.scale(
                      scale: 0.6 + 0.4 * value,
                      child: Opacity(
                        opacity: value.clamp(0.0, 1.0).toDouble(),
                        child: child,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 168,
                          height: 168,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(38),
                            boxShadow: [
                              BoxShadow(
                                color: theme.primaryColor.withValues(
                                  alpha: 0.55,
                                ),
                                blurRadius: 48,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(38),
                            child: Image.asset(
                              theme.splashAsset,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Center(
                                child: Text(
                                  theme.icon,
                                  style: const TextStyle(fontSize: 80),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          theme.displayText(theme.label),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: labelFont,
                            fontFamilyFallback: const ['Poppins'],
                            fontSize: theme.displayFontFamily == null ? 28 : 34,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: theme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
