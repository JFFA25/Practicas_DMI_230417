import 'package:flutter_test/flutter_test.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/infrastructure/services/dailymotion_api.dart';
import 'package:toktik/infrastructure/services/youtube_data_api.dart';
import 'package:toktik/presentation/providers/discover_provider.dart';
import 'package:toktik/shared/data/local_video_post.dart' as local_data;

class _FakeYoutubeDataApi extends YoutubeDataApi {
  _FakeYoutubeDataApi({
    required this.results,
    this.nextPageResults = const [],
    this.nextPageToken,
    this.error,
    this.configured = true,
  }) : super(apiKey: configured ? 'test-key' : '');

  final List<VideoPost> results;
  final List<VideoPost> nextPageResults;
  final String? nextPageToken;
  final Object? error;
  final bool configured;

  @override
  bool get isConfigured => configured;

  @override
  Future<List<VideoPost>> searchShorts(
    String query, {
    int maxResults = 10,
    String? pageToken,
  }) {
    final failure = error;
    if (failure != null) throw failure;
    return Future.value(results);
  }

  @override
  Future<YoutubeVideoPage> searchShortsPage(
    String query, {
    int maxResults = 10,
    String? pageToken,
  }) async {
    final failure = error;
    if (failure != null) throw failure;
    return YoutubeVideoPage(
      videos: pageToken == null ? results : nextPageResults,
      nextPageToken: pageToken == null ? nextPageToken : null,
    );
  }

  @override
  Future<List<YoutubeComment>> getComments(String videoId) async => [];

  @override
  void close() {}
}

class _FakeDailymotionApi extends DailymotionApi {
  @override
  bool get isConfigured => false;

  @override
  Future<List<VideoPost>> searchVideos(
    String query, {
    int limit = 12,
    int maxSeconds = 180,
    int page = 1,
  }) async => [];

  @override
  void close() {}
}

void main() {
  final youtubeVideos = [
    VideoPost(
      caption: 'YouTube 1',
      videoUrl: 'https://youtube.com/watch?v=one',
      youtubeVideoId: 'one',
      source: 'youtube',
    ),
    VideoPost(
      caption: 'YouTube 2',
      videoUrl: 'https://youtube.com/watch?v=two',
      youtubeVideoId: 'two',
      source: 'youtube',
    ),
  ];

  test('interleaves every YouTube result with all local videos', () async {
    final provider = DiscoverProvider(
      youtubeApi: _FakeYoutubeDataApi(results: youtubeVideos),
      dailymotionApi: _FakeDailymotionApi(),
    );
    addTearDown(provider.dispose);

    await provider.loadNextPage();

    expect(provider.localVideoCount, local_data.videoPosts.length);
    expect(provider.youtubeVideoCount, 2);
    expect(provider.videos, hasLength(local_data.videoPosts.length + 2));
    expect(provider.videos[0].youtubeVideoId, isNull);
    expect(provider.videos[1].youtubeVideoId, 'one');
    expect(provider.videos[2].youtubeVideoId, isNull);
    expect(provider.videos[3].youtubeVideoId, 'two');
    expect(
      provider.videos.where((video) => video.youtubeVideoId == null),
      hasLength(local_data.videoPosts.length),
    );
  });

  test('keeps local videos when the API key is missing', () async {
    final provider = DiscoverProvider(
      youtubeApi: _FakeYoutubeDataApi(results: [], configured: false),
      dailymotionApi: _FakeDailymotionApi(),
    );
    addTearDown(provider.dispose);

    await provider.loadNextPage();

    expect(provider.videos, hasLength(local_data.videoPosts.length));
    expect(provider.statusMessage, contains('YOUTUBE_API_KEY'));
  });

  test('keeps local videos when the API returns no results', () async {
    final provider = DiscoverProvider(
      youtubeApi: _FakeYoutubeDataApi(results: []),
      dailymotionApi: _FakeDailymotionApi(),
    );
    addTearDown(provider.dispose);

    await provider.loadNextPage();

    expect(provider.videos, hasLength(local_data.videoPosts.length));
    expect(provider.statusMessage, contains('no devolvió resultados'));
  });

  test('keeps local videos when the API request fails', () async {
    final provider = DiscoverProvider(
      youtubeApi: _FakeYoutubeDataApi(
        results: [],
        error: Exception('network failed'),
      ),
      dailymotionApi: _FakeDailymotionApi(),
    );
    addTearDown(provider.dispose);

    await provider.loadNextPage();

    expect(provider.videos, hasLength(local_data.videoPosts.length));
    expect(provider.statusMessage, contains('network failed'));
  });

  test(
    'Discover appends the next YouTube page as the feed reaches its end',
    () async {
      final nextVideo = VideoPost(
        caption: 'YouTube next page',
        videoUrl: 'https://youtube.com/watch?v=next',
        youtubeVideoId: 'next',
        source: 'youtube',
      );
      final provider = DiscoverProvider(
        youtubeApi: _FakeYoutubeDataApi(
          results: youtubeVideos,
          nextPageToken: 'next-token',
          nextPageResults: [nextVideo],
        ),
        dailymotionApi: _FakeDailymotionApi(),
      );
      addTearDown(provider.dispose);

      await provider.loadNextPage();
      final initialLength = provider.videos.length;
      expect(provider.hasMoreDiscover, isTrue);

      await provider.loadMoreDiscover();

      expect(provider.videos, hasLength(initialLength + 1));
      expect(provider.videos.last.youtubeVideoId, 'next');
      expect(provider.hasMoreDiscover, isFalse);
    },
  );
}
