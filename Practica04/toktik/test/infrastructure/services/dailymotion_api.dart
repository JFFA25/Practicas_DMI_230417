import 'dart:convert';
import 'package:http/http.dart' as http;

class DailymotionVideo {
  final String id;
  final String title;
  final int duration;
  final String? thumbnail;

  DailymotionVideo({
    required this.id,
    required this.title,
    required this.duration,
    this.thumbnail,
  });

  factory DailymotionVideo.fromJson(Map<String, dynamic> json) =>
      DailymotionVideo(
        id: json['id'] as String,
        title: (json['title'] ?? '') as String,
        duration: (json['duration'] ?? 0) as int,
        thumbnail: json['thumbnail_480_url'] as String?,
      );
}

class DailymotionApi {
  Future<List<DailymotionVideo>> search(
    String query, {
    int page = 1,
    int limit = 20,
    int maxSeconds = 120, // para que se sientan como "shorts"
  }) async {
    final uri = Uri.https('api.dailymotion.com', '/videos', {
      'search': query,
      'page': '$page',
      'limit': '$limit',
      'fields': 'id,title,duration,thumbnail_480_url',
    });

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Dailymotion error ${res.statusCode}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (data['list'] as List).cast<Map<String, dynamic>>();

    return list
        .map(DailymotionVideo.fromJson)
        .where((v) => v.duration > 0 && v.duration <= maxSeconds)
        .toList();
  }
}