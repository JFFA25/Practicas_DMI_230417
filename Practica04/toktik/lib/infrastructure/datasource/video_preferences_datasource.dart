import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:toktik/domain/entities/video_post.dart';

class StoredVideoLike {
  final bool liked;
  final int likes;
  final VideoPost video;

  const StoredVideoLike({
    required this.liked,
    required this.likes,
    required this.video,
  });

  factory StoredVideoLike.fromJson(Map<String, dynamic> json) {
    final videoData = json['video'];
    if (videoData is! Map) {
      throw const FormatException('Falta la información del video guardado.');
    }
    final video = videoData.map(
      (key, value) => MapEntry(key.toString(), value),
    );
    return StoredVideoLike(
      liked: json['liked'] == true,
      likes: _integer(json['likes']),
      video: VideoPost(
        caption: _string(video['caption']),
        description: _string(video['description']),
        videoUrl: _string(video['videoUrl']),
        likes: _integer(video['likes']),
        views: _integer(video['views']),
        comments: _integer(video['comments']),
        youtubeVideoId: video['youtubeVideoId'] as String?,
        sourceId: video['sourceId'] as String?,
        source: _string(video['source']),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'liked': liked,
    'likes': likes,
    'video': {
      'caption': video.caption,
      'description': video.description,
      'videoUrl': video.videoUrl,
      'likes': video.likes,
      'views': video.views,
      'comments': video.comments,
      'youtubeVideoId': video.youtubeVideoId,
      'sourceId': video.sourceId,
      'source': video.source,
    },
  };

  static int _integer(Object? value) =>
      value is int ? value : int.tryParse(value.toString()) ?? 0;

  static String _string(Object? value) => value is String ? value : '';
}

class VideoPreferencesDatasource {
  VideoPreferencesDatasource({
    Future<SharedPreferences> Function()? getPreferences,
  }) : _getPreferences = getPreferences ?? SharedPreferences.getInstance;

  static const _likesKey = 'toktik.video_likes.v1';
  static const _themeKey = 'toktik.seasonal_theme.v1';
  static const _themeSoundKey = 'toktik.seasonal_theme_sound.v1';

  final Future<SharedPreferences> Function() _getPreferences;

  Future<Map<String, StoredVideoLike>> loadLikes() async {
    final preferences = await _getPreferences();
    final value = preferences.getString(_likesKey);
    if (value == null) return {};
    final decoded = jsonDecode(value);
    if (decoded is! Map) {
      throw const FormatException('Los me gusta guardados no son válidos.');
    }
    return decoded.map((key, value) {
      if (value is! Map) {
        throw const FormatException('Un me gusta guardado no es válido.');
      }
      final json = value.map((key, value) => MapEntry(key.toString(), value));
      return MapEntry(key.toString(), StoredVideoLike.fromJson(json));
    });
  }

  Future<void> saveLikes(Map<String, StoredVideoLike> likes) async {
    final preferences = await _getPreferences();
    final saved = await preferences.setString(
      _likesKey,
      jsonEncode(likes.map((key, value) => MapEntry(key, value.toJson()))),
    );
    if (!saved) throw StateError('No se pudieron guardar los me gusta.');
  }

  Future<String?> loadThemeOverride() async {
    final preferences = await _getPreferences();
    return preferences.getString(_themeKey);
  }

  Future<void> saveThemeOverride(String? theme) async {
    final preferences = await _getPreferences();
    final saved = theme == null
        ? await preferences.remove(_themeKey)
        : await preferences.setString(_themeKey, theme);
    if (!saved) throw StateError('No se pudo guardar el tema seleccionado.');
  }

  Future<bool> loadThemeSoundEnabled() async {
    final preferences = await _getPreferences();
    return preferences.getBool(_themeSoundKey) ?? true;
  }

  Future<void> saveThemeSoundEnabled(bool enabled) async {
    final preferences = await _getPreferences();
    final saved = await preferences.setBool(_themeSoundKey, enabled);
    if (!saved) throw StateError('No se pudo guardar el sonido del tema.');
  }
}
