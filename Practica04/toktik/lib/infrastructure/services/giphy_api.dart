import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:toktik/domain/entities/video_post.dart';

/// Cliente de la API de GIPHY (https://developers.giphy.com).
///
/// Devuelve clips en MP4 directo, así que se reproducen con video_player
/// sin WebView ni la interfaz de ningún sitio externo.
class GiphyApi {
  static const defaultSearchQuery = String.fromEnvironment(
    'GIPHY_SEARCH_QUERY',
    defaultValue: 'funny',
  );
  static const _defaultApiKey = String.fromEnvironment('GIPHY_API_KEY');
  static const _host = 'api.giphy.com';

  final http.Client _client;
  final String apiKey;

  GiphyApi({http.Client? client, String? apiKey})
    : _client = client ?? http.Client(),
      apiKey = apiKey ?? _defaultApiKey;

  bool get isConfigured => apiKey.trim().isNotEmpty;

  Future<List<VideoPost>> searchVideos(
    String query, {
    int limit = 25,
    int offset = 0,
  }) async =>
      (await searchVideosPage(query, limit: limit, offset: offset)).videos;

  Future<GiphyVideoPage> searchVideosPage(
    String query, {
    int limit = 25,
    int offset = 0,
  }) async {
    if (!isConfigured) {
      throw const GiphyApiException(
        'Configura GIPHY_API_KEY para buscar videos de Giphy.',
      );
    }
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) {
      throw const GiphyApiException('Escribe un término de búsqueda.');
    }

    final uri = Uri.https(_host, '/v1/gifs/search', {
      'api_key': apiKey.trim(),
      'q': normalizedQuery,
      'limit': '$limit',
      'offset': '$offset',
      'rating': 'pg-13',
      'lang': 'es',
    });
    final response = await _client.get(uri);
    final data = _decode(response);

    final items = data['data'];
    if (items is! List) return const GiphyVideoPage(videos: []);

    final videos = <VideoPost>[];
    for (final item in items) {
      final video = _toVideoPost(_object(item));
      if (video != null) videos.add(video);
    }
    final pagination = _object(data['pagination']);
    final count = _integer(pagination['count']);
    final totalCount = _integer(pagination['total_count']);
    final nextOffset = count > 0 && offset + count < totalCount
        ? offset + count
        : null;
    return GiphyVideoPage(videos: videos, nextOffset: nextOffset);
  }

  VideoPost? _toVideoPost(Map<String, dynamic> item) {
    final link = _mp4Link(_object(item['images']));
    if (link == null) return null;

    final title = _string(item['title']).trim();
    final user = _object(item['user']);
    var author = _string(user['display_name']);
    if (author.isEmpty) author = _string(item['username']);
    final pageUrl = _string(item['url']);

    final credit = author.isEmpty
        ? 'GIF en GIPHY.'
        : 'GIF de $author en GIPHY.';

    return VideoPost(
      caption: title.isEmpty ? 'GIF de GIPHY' : title,
      description: pageUrl.isEmpty ? credit : '$credit\n$pageUrl',
      videoUrl: link,
      source: 'giphy',
      sourceId: _string(item['id']),
    );
  }

  /// Busca el MP4 en las distintas versiones que entrega GIPHY.
  String? _mp4Link(Map<String, dynamic> images) {
    final candidates = [
      _string(_object(images['original_mp4'])['mp4']),
      _string(_object(images['original'])['mp4']),
      _string(_object(images['fixed_height'])['mp4']),
      _string(_object(images['fixed_width'])['mp4']),
    ];
    for (final link in candidates) {
      if (link.isNotEmpty) return link;
    }
    return null;
  }

  Map<String, dynamic> _decode(http.Response response) {
    Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {
      decoded = null;
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message;
      if (response.statusCode == 401 || response.statusCode == 403) {
        message = 'La clave de Giphy no es válida.';
      } else if (response.statusCode == 429) {
        message = 'Se alcanzó el límite de solicitudes de Giphy.';
      } else {
        message = _string(_object(_object(decoded)['meta'])['msg']);
        if (message.isEmpty) {
          message = 'Giphy respondió con HTTP ${response.statusCode}.';
        }
      }
      throw GiphyApiException(message);
    }

    return _object(decoded);
  }

  Map<String, dynamic> _object(Object? value) {
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return {};
  }

  String _string(Object? value) => value is String ? value : '';

  int _integer(Object? value) =>
      value is int ? value : int.tryParse(value.toString()) ?? 0;

  void close() => _client.close();
}

class GiphyVideoPage {
  final List<VideoPost> videos;
  final int? nextOffset;

  const GiphyVideoPage({required this.videos, this.nextOffset});
}

class GiphyApiException implements Exception {
  final String message;

  const GiphyApiException(this.message);

  @override
  String toString() => message;
}
