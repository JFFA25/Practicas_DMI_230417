import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toktik/infrastructure/datasource/video_preferences_datasource.dart';
import 'package:toktik/infrastructure/services/launcher_icon_service.dart';

enum SeasonalTheme {
  normal,
  halloween,
  christmas,
  valentinesDay;

  String get label => switch (this) {
    SeasonalTheme.normal => 'Normal',
    SeasonalTheme.halloween => 'Halloween',
    SeasonalTheme.christmas => 'Christmas',
    SeasonalTheme.valentinesDay => "Valentine's Day",
  };

  String get icon => switch (this) {
    SeasonalTheme.normal => '✨',
    SeasonalTheme.halloween => '🎃',
    SeasonalTheme.christmas => '🎄',
    SeasonalTheme.valentinesDay => '💝',
  };

  Color get primaryColor => switch (this) {
    SeasonalTheme.normal => const Color(0xFF16B8A6),
    SeasonalTheme.halloween => const Color(0xFFFF7A18),
    SeasonalTheme.christmas => const Color(0xFF36A66A),
    SeasonalTheme.valentinesDay => const Color(0xFFFF5C8A),
  };

  Color get secondaryColor => switch (this) {
    SeasonalTheme.normal => const Color(0xFF3972E6),
    SeasonalTheme.halloween => const Color(0xFF8F53D8),
    SeasonalTheme.christmas => const Color(0xFFC53248),
    SeasonalTheme.valentinesDay => const Color(0xFFD93370),
  };

  String get fontFamily => switch (this) {
    SeasonalTheme.normal => 'Poppins',
    // CF Halloween solo tiene MAYÚSCULAS (las minúsculas salen en blanco y
    // anchas), así que no sirve para texto corrido: solo para títulos/botones.
    SeasonalTheme.halloween => 'Poppins',
    SeasonalTheme.christmas => 'MerryChristmasStar',
    SeasonalTheme.valentinesDay => 'Pacifico',
  };

  /// Fuente decorativa solo para títulos cortos y botones (null = ninguna).
  String? get displayFontFamily => switch (this) {
    SeasonalTheme.halloween => 'CFHalloween',
    _ => null,
  };

  /// CF Halloween solo dibuja mayúsculas, por eso se convierte el texto.
  String displayText(String text) =>
      this == SeasonalTheme.halloween ? text.toUpperCase() : text;

  static SeasonalTheme? parse(String? value) {
    for (final theme in values) {
      if (theme.name == value) return theme;
    }
    return null;
  }

  static SeasonalTheme forDate(DateTime date) => switch (date.month) {
    10 => SeasonalTheme.halloween,
    12 => SeasonalTheme.christmas,
    2 => SeasonalTheme.valentinesDay,
    _ => SeasonalTheme.normal,
  };
}

class ThemeProvider extends ChangeNotifier {
  ThemeProvider({
    VideoPreferencesDatasource? datasource,
    this._iconService = const LauncherIconService(),
  }) : _datasource = datasource ?? VideoPreferencesDatasource();

  final VideoPreferencesDatasource _datasource;
  final LauncherIconService _iconService;
  Future<void>? _loading;
  SeasonalTheme? _override;
  SeasonalTheme _automaticTheme = SeasonalTheme.forDate(DateTime.now());
  bool _soundEnabled = true;
  bool isLoaded = false;
  String? errorMessage;

  SeasonalTheme get theme => _override ?? _automaticTheme;
  SeasonalTheme? get override => _override;
  bool get isAutomatic => _override == null;
  bool get soundEnabled => _soundEnabled;

  Future<void> load() {
    if (isLoaded) return Future<void>.value();
    return _loading ??= _load();
  }

  Future<void> _load() async {
    try {
      final savedTheme = await _datasource.loadThemeOverride();
      if (savedTheme != null) {
        _override = SeasonalTheme.parse(savedTheme);
        if (_override == null) {
          throw FormatException('Tema guardado desconocido: $savedTheme');
        }
      }
      _soundEnabled = await _datasource.loadThemeSoundEnabled();
      _automaticTheme = SeasonalTheme.forDate(DateTime.now());
    } catch (error) {
      errorMessage = 'No se pudo cargar la configuración visual. $error';
    } finally {
      // Al abrir la app NO se cambia el icono en caliente: si el sistema lo
      // dejó distinto al tema guardado, se corrige cuando la app pasa a segundo
      // plano (cambiarlo con la app abierta puede cerrarla en algunos teléfonos).
      await _syncLauncherIcon(theme);
      isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> selectTheme(SeasonalTheme theme) async {
    await load();
    final previous = _override;
    _override = theme;
    errorMessage = null;
    notifyListeners();
    try {
      await _datasource.saveThemeOverride(theme.name);
    } catch (error) {
      _override = previous;
      errorMessage = 'No se pudo guardar el tema. $error';
      notifyListeners();
      rethrow;
    }
    await _updateLauncherIcon(theme);
    await _playCue(theme);
  }

  Future<void> useAutomaticTheme() async {
    await load();
    final previous = _override;
    _override = null;
    _automaticTheme = SeasonalTheme.forDate(DateTime.now());
    errorMessage = null;
    notifyListeners();
    try {
      await _datasource.saveThemeOverride(null);
    } catch (error) {
      _override = previous;
      errorMessage = 'No se pudo activar el tema automático. $error';
      notifyListeners();
      rethrow;
    }
    await _updateLauncherIcon(theme);
    await _playCue(theme);
  }

  Future<void> setSoundEnabled(bool enabled) async {
    await load();
    final previous = _soundEnabled;
    _soundEnabled = enabled;
    errorMessage = null;
    notifyListeners();
    try {
      await _datasource.saveThemeSoundEnabled(enabled);
    } catch (error) {
      _soundEnabled = previous;
      errorMessage = 'No se pudo guardar la preferencia de sonido. $error';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _syncLauncherIcon(SeasonalTheme theme) async {
    try {
      await _iconService.syncTheme(theme.name);
    } catch (error) {
      errorMessage =
          'El tema se aplicó, pero no se pudo cambiar el icono. $error';
      notifyListeners();
    }
  }

  Future<void> _updateLauncherIcon(SeasonalTheme theme) async {
    try {
      await _iconService.setTheme(theme.name);
    } catch (error) {
      errorMessage =
          'El tema se aplicó, pero no se pudo cambiar el icono. $error';
      notifyListeners();
    }
  }

  Future<void> _playCue(SeasonalTheme theme) async {
    if (!_soundEnabled) return;
    final sounds = switch (theme) {
      SeasonalTheme.normal => [SystemSoundType.click],
      SeasonalTheme.halloween => [SystemSoundType.alert, SystemSoundType.click],
      SeasonalTheme.christmas => [
        SystemSoundType.click,
        SystemSoundType.click,
        SystemSoundType.alert,
      ],
      SeasonalTheme.valentinesDay => [
        SystemSoundType.alert,
        SystemSoundType.alert,
      ],
    };
    for (var index = 0; index < sounds.length; index++) {
      if (index > 0) {
        await Future<void>.delayed(const Duration(milliseconds: 110));
      }
      await SystemSound.play(sounds[index]);
    }
  }
}
