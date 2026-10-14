import 'package:audioplayers/audioplayers.dart';
import 'package:toktik/presentation/providers/theme_provider.dart';

/// Reproduce la canción corta de arranque de cada temática mientras se ve la
/// splash. Los archivos ya vienen recortados (ver assets/audio/).
class IntroMusicService {
  AudioPlayer? _player;

  /// Clip de la temática y lo que dura de verdad el archivo.
  /// `null` = esa temática no tiene canción (la splash sale en silencio).
  static ({String asset, Duration duration})? clipFor(SeasonalTheme theme) =>
      switch (theme) {
        SeasonalTheme.halloween => (
          asset: 'audio/intro_halloween.mp3',
          duration: const Duration(milliseconds: 5950),
        ),
        SeasonalTheme.christmas => (
          asset: 'audio/intro_christmas.mp3',
          duration: const Duration(milliseconds: 5830),
        ),
        _ => null,
      };

  /// Empieza a sonar y devuelve la duración del clip, o `null` si no hay
  /// canción para ese tema o el audio no pudo arrancar (por ejemplo, Chrome
  /// bloquea el audio hasta que el usuario toca la página).
  Future<Duration?> play(SeasonalTheme theme) async {
    final clip = clipFor(theme);
    if (clip == null) return null;
    try {
      final player = _player ??= AudioPlayer();
      await player.setReleaseMode(ReleaseMode.stop);
      await player.play(AssetSource(clip.asset));
      return clip.duration;
    } catch (_) {
      return null;
    }
  }

  /// Libera el reproductor (y el foco de audio, para no estorbar a los videos).
  Future<void> dispose() async {
    final player = _player;
    _player = null;
    try {
      await player?.dispose();
    } catch (_) {}
  }
}
