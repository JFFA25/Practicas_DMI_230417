import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:toktik/infrastructure/services/youtube_data_api.dart';

void main() {
  group('YoutubeDataApi', () {
    test('reports when the API key is missing', () async {
      final api = YoutubeDataApi(apiKey: '');
      addTearDown(api.close);

      await expectLater(
        api.searchShorts('music'),
        throwsA(
          isA<YoutubeApiException>().having(
            (error) => error.message,
            'message',
            contains('YOUTUBE_API_KEY'),
          ),
        ),
      );
    });

    test('searches Shorts and maps public video statistics', () async {
      final client = MockClient((request) async {
        if (request.url.path.endsWith('/search')) {
          expect(request.url.queryParameters['q'], 'music shorts');
          expect(request.url.queryParameters['videoDuration'], 'short');
          return http.Response(
            jsonEncode({
              'items': [
                {
                  'id': {'videoId': 'short-id'},
                  'snippet': {'title': 'A public Short'},
                },
              ],
            }),
            200,
          );
        }
        if (request.url.path.endsWith('/videos')) {
          expect(request.url.queryParameters['part'], 'statistics');
          return http.Response(
            jsonEncode({
              'items': [
                {
                  'id': 'short-id',
                  'statistics': {'likeCount': '56', 'commentCount': '7'},
                },
              ],
            }),
            200,
          );
        }
        throw StateError('Unexpected request: ${request.url}');
      });
      final api = YoutubeDataApi(client: client, apiKey: 'test-key');
      addTearDown(api.close);

      final videos = await api.searchShorts('music');

      expect(videos, hasLength(1));
      expect(videos.single.youtubeVideoId, 'short-id');
      expect(videos.single.caption, 'A public Short');
      expect(videos.single.views, 0);
      expect(videos.single.likes, 56);
      expect(videos.single.comments, 7);
    });

    test('loads public top-level comments', () async {
      final client = MockClient((request) async {
        expect(request.url.path, endsWith('/commentThreads'));
        expect(request.url.queryParameters['videoId'], 'short-id');
        return http.Response(
          jsonEncode({
            'items': [
              {
                'snippet': {
                  'topLevelComment': {
                    'snippet': {
                      'authorDisplayName': 'Viewer',
                      'textDisplay': 'Nice video',
                      'likeCount': 3,
                    },
                  },
                },
              },
            ],
          }),
          200,
        );
      });
      final api = YoutubeDataApi(client: client, apiKey: 'test-key');
      addTearDown(api.close);

      final comments = await api.getComments('short-id');

      expect(comments, hasLength(1));
      expect(comments.single.author, 'Viewer');
      expect(comments.single.text, 'Nice video');
      expect(comments.single.likes, 3);
    });

    test('surfaces YouTube API error messages', () async {
      final client = MockClient(
        (_) async => http.Response(
          jsonEncode({
            'error': {'message': 'The request cannot be completed.'},
          }),
          403,
        ),
      );
      final api = YoutubeDataApi(client: client, apiKey: 'test-key');
      addTearDown(api.close);

      await expectLater(
        api.searchShorts('music'),
        throwsA(
          isA<YoutubeApiException>().having(
            (error) => error.message,
            'message',
            'The request cannot be completed.',
          ),
        ),
      );
    });
  });
}
