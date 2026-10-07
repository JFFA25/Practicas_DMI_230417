import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:toktik/domain/entities/video_post.dart';

class YoutubeDataApi {
  static const defaultSearchQuery = String.fromEnvironment(
    'YOUTUBE_SEARCH_QUERY',
    defaultValue: 'shorts',
  );
  static const _defaultApiKey = String.fromEnvironment('YOUTUBE_API_KEY');

  final http.Client _client;
  final String apiKey;

  YoutubeDataApi({http.Client? client, String? apiKey})
    : _client = client ?? http.Client(),
      apiKey = apiKey ?? _defaultApiKey;

  bool get isConfigured => apiKey.trim().isNotEmpty;

  Future<List<VideoPost>> searchShorts(
    String query, {
    int maxResults = 10,
    String? pageToken,
  }) async =>
      (await searchShortsPage(
        query,
        maxResults: maxResults,
        pageToken: pageToken,
      )).videos;

  Future<YoutubeVideoPage> searchShortsPage(
    String query, {
    int maxResults = 10,
    String? pageToken,
  }) async {
    _checkConfiguration();
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) {
      throw const YoutubeApiException('Escribe un término de búsqueda.');
    }

    final searchQuery = normalizedQuery.toLowerCase().contains('short')
        ? normalizedQuery
        : '$normalizedQuery shorts';
    final searchParameters = <String, String>{
      'part': 'snippet',
      'type': 'video',
      'videoDuration': 'short',
      'q': searchQuery,
      'maxResults': '$maxResults',
    };
    if (pageToken != null && pageToken.isNotEmpty) {
      searchParameters['pageToken'] = pageToken;
    }
    final searchData = await _get('search', searchParameters);
    final searchItems = _items(searchData);
    final captionsById = <String, String>{};
    final videoIds = <String>[];
    for (final item in searchItems) {
      final videoId = _object(item['id'])['videoId'];
      if (videoId is! String || videoId.isEmpty) continue;

      videoIds.add(videoId);
      captionsById[videoId] = _string(_object(item['snippet'])['title']);
    }

    final nextPageToken = _string(searchData['nextPageToken']);
    if (videoIds.isEmpty) {
      return YoutubeVideoPage(
        videos: const [],
        nextPageToken: nextPageToken.isEmpty ? null : nextPageToken,
      );
    }

    final videosData = await _get('videos', {
      'part': 'snippet,statistics',
      'id': videoIds.join(','),
      'maxResults': '$maxResults',
    });
    final statisticsById = <String, Map<String, dynamic>>{
      for (final item in _items(videosData))
        _string(item['id']): _object(item['statistics']),
    };
    final descriptionsById = <String, String>{
      for (final item in _items(videosData))
        _string(item['id']): _string(_object(item['snippet'])['description']),
    };

    final videos = <VideoPost>[];
    for (final videoId in videoIds) {
      final statistics = statisticsById[videoId];
      if (statistics == null) continue;

      videos.add(
        VideoPost(
          caption: captionsById[videoId] ?? '',
          description: descriptionsById[videoId] ?? '',
          videoUrl: 'https://www.youtube.com/watch?v=$videoId',
          likes: _integer(statistics['likeCount']),
          comments: _integer(statistics['commentCount']),
          youtubeVideoId: videoId,
          sourceId: videoId,
          source: 'youtube',
        ),
      );
    }

    return YoutubeVideoPage(
      videos: videos,
      nextPageToken: nextPageToken.isEmpty ? null : nextPageToken,
    );
  }

  Future<List<YoutubeComment>> getComments(String videoId) async {
    _checkConfiguration();
    final data = await _get('commentThreads', {
      'part': 'snippet',
      'videoId': videoId,
      'maxResults': '20',
      'order': 'relevance',
      'textFormat': 'plainText',
    });

    return _items(data).map((item) {
      final thread = _object(item['snippet']);
      final comment = _object(thread['topLevelComment']);
      final snippet = _object(comment['snippet']);
      return YoutubeComment(
        author: _string(snippet['authorDisplayName']),
        text: _string(snippet['textDisplay']),
        likes: _integer(snippet['likeCount']),
      );
    }).toList();
  }

  Future<Map<String, dynamic>> _get(
    String endpoint,
    Map<String, String> parameters,
  ) async {
    final uri = Uri.https('www.googleapis.com', '/youtube/v3/$endpoint', {
      ...parameters,
      'key': apiKey,
    });
    final response = await _client.get(uri);
    final decoded = jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = _object(_object(decoded)['error']);
      final message = _string(error['message']);
      throw YoutubeApiException(
        message.isEmpty
            ? 'YouTube API respondió con HTTP ${response.statusCode}.'
            : message,
      );
    }

    return _object(decoded);
  }

  List<Map<String, dynamic>> _items(Map<String, dynamic> data) {
    final items = data['items'];
    if (items is! List) return [];
    return items.map(_object).toList();
  }

  Map<String, dynamic> _object(Object? value) {
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return {};
  }

  String _string(Object? value) => value is String ? value : '';

  int _integer(Object? value) => int.tryParse(value.toString()) ?? 0;

  void _checkConfiguration() {
    if (!isConfigured) {
      throw const YoutubeApiException(
        'Configura YOUTUBE_API_KEY para buscar videos de YouTube.',
      );
    }
  }

  void close() => _client.close();
}

class YoutubeVideoPage {
  final List<VideoPost> videos;
  final String? nextPageToken;

  const YoutubeVideoPage({required this.videos, this.nextPageToken});
}

class YoutubeComment {
  final String author;
  final String text;
  final int likes;

  const YoutubeComment({
    required this.author,
    required this.text,
    required this.likes,
  });
}

class YoutubeApiException implements Exception {
  final String message;

  const YoutubeApiException(this.message);

  @override
  String toString() => message;
}
