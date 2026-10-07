import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:toktik/infrastructure/services/giphy_api.dart';

void main() {
  test('uses GIPHY offsets and exposes the next page offset', () async {
    final offsets = <String?>[];
    final client = MockClient((request) async {
      offsets.add(request.url.queryParameters['offset']);
      return http.Response(
        jsonEncode({
          'data': [
            {
              'id': 'gif-${request.url.queryParameters['offset']}',
              'title': 'Clip',
              'images': {
                'original_mp4': {'mp4': 'https://example.com/clip.mp4'},
              },
            },
          ],
          'pagination': {'count': 25, 'total_count': 80},
        }),
        200,
      );
    });
    final api = GiphyApi(client: client, apiKey: 'test-key');
    addTearDown(api.close);

    final firstPage = await api.searchVideosPage('music');
    final secondPage = await api.searchVideosPage(
      'music',
      offset: firstPage.nextOffset!,
    );

    expect(offsets, ['0', '25']);
    expect(firstPage.nextOffset, 25);
    expect(secondPage.nextOffset, 50);
    expect(secondPage.videos.single.sourceId, 'gif-25');
  });
}
