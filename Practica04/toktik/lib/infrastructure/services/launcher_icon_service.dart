import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class LauncherIconService {
  const LauncherIconService();

  static const _channel = MethodChannel('toktik/launcher_icon');

  bool get _supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  String _iconName(String themeName) => switch (themeName) {
    'halloween' => 'halloween',
    'christmas' => 'christmas',
    'valentinesDay' => 'valentinesDay',
    _ => 'normal',
  };

  /// Cambia el icono de inmediato (cuando el usuario elige un tema).
  Future<void> setTheme(String themeName) async {
    if (!_supported) return;
    await _channel.invokeMethod<void>('setLauncherIcon', _iconName(themeName));
  }

  /// Revisa el icono al abrir la app. Si ya es el correcto no hace nada; si no,
  /// el cambio se aplica cuando la app pasa a segundo plano.
  Future<void> syncTheme(String themeName) async {
    if (!_supported) return;
    await _channel.invokeMethod<void>('syncLauncherIcon', _iconName(themeName));
  }
}
