import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:toktik/domain/entities/video_post.dart';

class DailymotionApi {
  DailymotionApi({http.Client? client}) : _client = client ?? http.Client();

  static const defaultSearchQuery = String.fromEnvironment(
    'DAILYMOTION_SEARCH_QUERY',
    defaultValue: 'short videos',
  );
  static const _host = 'api.dailymotion.com';
  final http.Client _client;

  bool get isConfigured => true;

  Future<List<VideoPost>> searchVideos(
    String query, {
    int limit = 12,
    int maxSeconds = 180,
    int page = 1,
  }) async =>
      (await searchVideosPage(
        query,
        limit: limit,
        maxSeconds: maxSeconds,
        page: page,
      )).videos;

  Future<DailymotionVideoPage> searchVideosPage(
    String query, {
    int limit = 12,
    int maxSeconds = 180,
    int page = 1,
  }) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) {
      throw const DailymotionApiException('Escribe un término de búsqueda.');
    }

    final uri = Uri.https(_host, '/videos', {
      'search': normalizedQuery,
      'limit': '$limit',
      'page': '$page',
      'fields': 'id,title,description,duration,views_total',
    });
    final response = await _client.get(uri);
    final data = _decode(response);
    final items = data['list'];
    if (items is! List) return const DailymotionVideoPage(videos: []);

    final videos = <VideoPost>[];
    for (final value in items) {
      final item = _object(value);
      final id = _string(item['id']);
      final duration = _integer(item['duration']);
      if (id.isEmpty || duration <= 0 || duration > maxSeconds) continue;
      final title = _string(item['title']);
      videos.add(
        VideoPost(
          caption: title.isEmpty ? 'Video de Dailymotion' : title,
          description: _string(item['description']),
          videoUrl: 'https://www.dailymotion.com/video/$id',
          views: _integer(item['views_total']),
          source: 'dailymotion',
          sourceId: id,
        ),
      );
    }
    final hasMore = data['has_more'] is bool
        ? data['has_more'] as bool
        : items.length >= limit;
    return DailymotionVideoPage(
      videos: videos,
      nextPage: hasMore && videos.isNotEmpty ? page + 1 : null,
    );
  }

  Map<String, dynamic> _decode(http.Response response) {
    Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw const DailymotionApiException(
        'Dailymotion devolvió una respuesta inválida.',
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = _string(_object(decoded)['error']);
      throw DailymotionApiException(
        message.isEmpty
            ? 'Dailymotion respondió con HTTP ${response.statusCode}.'
            : message,
      );
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

class DailymotionVideoPage {
  final List<VideoPost> videos;
  final int? nextPage;

  const DailymotionVideoPage({required this.videos, this.nextPage});
}

class DailymotionApiException implements Exception {
  final String message;

  const DailymotionApiException(this.message);

  @override
  String toString() => message;
}
