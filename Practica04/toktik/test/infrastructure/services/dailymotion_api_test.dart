import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:toktik/infrastructure/services/dailymotion_api.dart';

void main() {
  test(
    'maps public results and removes videos longer than three minutes',
    () async {
    final client = MockClient((request) async {
      expect(request.url.host, 'api.dailymotion.com');
      expect(request.url.queryParameters['search'], 'music');
        return http.Response(
          jsonEncode({
            'list': [
              {
                'id': 'short',
                'title': 'Short video',
                'description': 'description',
                'duration': 90,
                'views_total': 123,
              },
              {
                'id': 'long',
                'title': 'Long video',
                'duration': 240,
              },
            ],
          }),
          200,
        );
      });
      final api = DailymotionApi(client: client);
      addTearDown(api.close);

      final videos = await api.searchVideos('music');

      expect(videos, hasLength(1));
      expect(videos.single.source, 'dailymotion');
      expect(videos.single.sourceId, 'short');
      expect(videos.single.views, 123);
    },
  );

  test('requests the selected page and returns a next page when available', () async {
    final client = MockClient((request) async {
      expect(request.url.queryParameters['page'], '2');
      return http.Response(
        jsonEncode({
          'has_more': true,
          'list': [
            {
              'id': 'page-two',
              'title': 'Page two',
              'duration': 60,
            },
          ],
        }),
        200,
      );
    });
    final api = DailymotionApi(client: client);
    addTearDown(api.close);

    final result = await api.searchVideosPage('music', page: 2);

    expect(result.videos.single.sourceId, 'page-two');
    expect(result.nextPage, 3);
  });

  test('reports HTTP errors from Dailymotion', () async {
    final api = DailymotionApi(
      client: MockClient((_) async => http.Response('unavailable', 503)),
    );
    addTearDown(api.close);

    await expectLater(
      api.searchVideos('music'),
      throwsA(isA<DailymotionApiException>()),
    );
  });
}
