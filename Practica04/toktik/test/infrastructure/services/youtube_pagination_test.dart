import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:toktik/infrastructure/services/youtube_data_api.dart';

void main() {
  test('passes the continuation token and returns the following token', () async {
    final requestedTokens = <String?>[];
    final client = MockClient((request) async {
      if (request.url.path.endsWith('/search')) {
        final token = request.url.queryParameters['pageToken'];
        requestedTokens.add(token);
        return http.Response(
          jsonEncode({
            'nextPageToken': token == null ? 'page-two' : 'page-three',
            'items': [
              {
                'id': {'videoId': token ?? 'video-one'},
                'snippet': {'title': 'Short'},
              },
            ],
          }),
          200,
        );
      }
      return http.Response(
        jsonEncode({
          'items': [
            {
              'id': request.url.queryParameters['id'],
              'snippet': {'description': 'Full description'},
              'statistics': {'likeCount': '0'},
            },
          ],
        }),
        200,
      );
    });
    final api = YoutubeDataApi(client: client, apiKey: 'test-key');
    addTearDown(api.close);

    final firstPage = await api.searchShortsPage('music');
    final secondPage = await api.searchShortsPage(
      'music',
      pageToken: firstPage.nextPageToken,
    );

    expect(requestedTokens, [null, 'page-two']);
    expect(firstPage.nextPageToken, 'page-two');
    expect(firstPage.videos.single.description, 'Full description');
    expect(secondPage.nextPageToken, 'page-three');
  });
}
