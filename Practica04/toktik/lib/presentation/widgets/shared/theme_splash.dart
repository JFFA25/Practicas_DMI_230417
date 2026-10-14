import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:provider/provider.dart';
import 'package:toktik/infrastructure/services/intro_music_service.dart';
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

/// Splash de ARRANQUE: se muestra al abrir la app, con la canción de la
/// temática (si tiene), y después deja ver [child] (el feed).
///
/// [child] no se construye hasta que termina la splash, así los videos no
/// empiezan a sonar debajo de la canción. Los providers sí cargan por debajo.
class StartupSplashGate extends StatefulWidget {
  const StartupSplashGate({super.key, required this.child});

  final Widget child;

  @override
  State<StartupSplashGate> createState() => _StartupSplashGateState();
}

class _StartupSplashGateState extends State<StartupSplashGate> {
  /// Duración de la splash cuando la temática no tiene canción.
  static const _silentDuration = Duration(milliseconds: 2500);

  final _music = IntroMusicService();
  SeasonalTheme? _theme;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    unawaited(_run());
  }

  Future<void> _run() async {
    final themes = context.read<ThemeProvider>();
    // Hay que esperar al tema guardado para mostrar el icono correcto.
    await themes.load();
    if (!mounted) return;

    final theme = themes.theme;
    setState(() => _theme = theme);

    final startedAt = DateTime.now();
    var minimum = _silentDuration;
    // El interruptor "Sonido de temporada" también controla la canción.
    if (themes.soundEnabled) {
      final clip = await _music.play(theme);
      if (clip != null) minimum = clip + const Duration(milliseconds: 250);
    }

    final remaining = minimum - DateTime.now().difference(startedAt);
    if (!remaining.isNegative) await Future<void>.delayed(remaining);
    await _music.dispose();
    if (!mounted) return;
    setState(() => _done = true);
  }

  @override
  void dispose() {
    unawaited(_music.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = _theme;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      layoutBuilder: (current, previous) => Stack(
        fit: StackFit.expand,
        children: [...previous, if (current != null) current],
      ),
      child: _done
          ? KeyedSubtree(key: const ValueKey('app'), child: widget.child)
          : theme == null
          // Mientras se lee el tema guardado: fondo liso (sin flashazo).
          ? const SizedBox.expand(
              key: ValueKey('boot'),
              child: ColoredBox(color: Color(0xFF101014)),
            )
          : ThemeSplashView(
              key: const ValueKey('splash'),
              theme: theme,
              title: 'TokTik',
            ),
    );
  }
}

/// Dibujo de la splash: icono de la temática, título y cargando.
///
/// Los colores y la fuente salen del tema de DESTINO ([theme]), no de
/// Theme.of(context): así se ve igual aunque el tema de la app cambie por debajo.
class ThemeSplashView extends StatelessWidget {
  const ThemeSplashView({super.key, required this.theme, this.title});

  final SeasonalTheme theme;

  /// Texto bajo el icono. Si es null se usa el nombre de la temática.
  final String? title;

  @override
  Widget build(BuildContext context) {
    final labelFont = theme.displayFontFamily ?? theme.fontFamily;

    return Material(
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
                            color: theme.primaryColor.withValues(alpha: 0.55),
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
                      theme.displayText(title ?? theme.label),
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
    );
  }
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
    return PopScope(
      canPop: false,
      child: PointerInterceptor(child: ThemeSplashView(theme: widget.theme)),
    );
  }
}
