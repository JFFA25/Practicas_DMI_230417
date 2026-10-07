import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/domain/repositories/video_feed_repository.dart';
import 'package:toktik/infrastructure/datasource/local_video_datasource_impl.dart';
import 'package:toktik/infrastructure/services/dailymotion_api.dart';
import 'package:toktik/infrastructure/services/giphy_api.dart';
import 'package:toktik/infrastructure/services/youtube_data_api.dart';

class VideoFeedRepositoryImpl implements VideoFeedRepository {
  VideoFeedRepositoryImpl({
    required this.localVideos,
    required this.youtube,
    required this.giphy,
    required this.dailymotion,
  });

  final LocalVideoDatasourceImpl localVideos;
  final YoutubeDataApi youtube;
  final GiphyApi giphy;
  final DailymotionApi dailymotion;

  @override
  Future<VideoFeedResult> getDiscoverVideos(
    String query, {
    String? giphyQuery,
    String? dailymotionQuery,
  }) => _loadFeeds(
    query,
    giphyQuery: giphyQuery,
    dailymotionQuery: dailymotionQuery,
    includeLocalVideos: true,
    paginate: true,
  );

  @override
  Future<VideoFeedResult> getMoreDiscoverVideos({
    required String query,
    required String giphyQuery,
    required String dailymotionQuery,
    required String? youtubePageToken,
    required int? giphyOffset,
    required int? dailymotionPage,
  }) => _loadFeeds(
    query,
    youtubePageToken: youtubePageToken,
    giphyOffset: giphyOffset,
    dailymotionPage: dailymotionPage,
    includeLocalVideos: false,
    paginate: true,
  );

  @override
  Future<VideoFeedResult> getForYouVideos(
    String query, {
    String? giphyQuery,
    String? dailymotionQuery,
  }) => _loadFeeds(
    '$query trending',
    giphyQuery: '${giphyQuery ?? query} trending',
    dailymotionQuery: '${dailymotionQuery ?? query} trending',
    includeLocalVideos: true,
    paginate: false,
  );

  @override
  Future<VideoFeedResult> getFavoriteVideos(List<VideoPost> favorites) async =>
      VideoFeedResult(videos: List.unmodifiable(favorites));

  Future<VideoFeedResult> _loadFeeds(
    String query, {
    String? giphyQuery,
    String? dailymotionQuery,
    String? youtubePageToken,
    int? giphyOffset,
    int? dailymotionPage,
    required bool includeLocalVideos,
    required bool paginate,
  }) async {
    final messages = <String>[];
    final (youtubeResult, giphyResult, dailymotionResult) = await (
      _loadYoutube(query, pageToken: youtubePageToken, messages: messages),
      _loadGiphy(
        giphyQuery ?? query,
        offset: giphyOffset ?? 0,
        messages: messages,
      ),
      _loadDailymotion(
        dailymotionQuery ?? query,
        page: dailymotionPage ?? 1,
        messages: messages,
      ),
    ).wait;

    final sourceLists = <List<VideoPost>>[
      if (includeLocalVideos) localVideos.getVideos(),
      youtubeResult.videos,
      giphyResult.videos,
      dailymotionResult.videos,
    ];
    final videos = <VideoPost>[];
    final longestSource = sourceLists.fold<int>(
      0,
      (longest, source) => source.length > longest ? source.length : longest,
    );
    for (var index = 0; index < longestSource; index++) {
      for (final source in sourceLists) {
        if (index < source.length) videos.add(source[index]);
      }
    }

    return VideoFeedResult(
      videos: videos,
      messages: messages,
      youtubeNextPageToken: paginate
          ? youtubeResult.nextPageToken
          : null,
      giphyNextOffset: paginate ? giphyResult.nextOffset : null,
      dailymotionNextPage: paginate ? dailymotionResult.nextPage : null,
    );
  }

  Future<YoutubeVideoPage> _loadYoutube(
    String query, {
    String? pageToken,
    required List<String> messages,
  }) async {
    if (!youtube.isConfigured) {
      messages.add('Configura YOUTUBE_API_KEY para cargar videos de YouTube.');
      return const YoutubeVideoPage(videos: []);
    }
    try {
      final page = await youtube.searchShortsPage(query, pageToken: pageToken);
      if (page.videos.isEmpty && page.nextPageToken == null) {
        messages.add('YouTube no devolvió resultados.');
      }
      return page;
    } catch (error) {
      messages.add('No se pudo consultar YouTube. $error');
      return const YoutubeVideoPage(videos: []);
    }
  }

  Future<GiphyVideoPage> _loadGiphy(
    String query, {
    required int offset,
    required List<String> messages,
  }) async {
    if (!giphy.isConfigured) {
      messages.add('Configura GIPHY_API_KEY para cargar videos de Giphy.');
      return const GiphyVideoPage(videos: []);
    }
    try {
      final page = await giphy.searchVideosPage(query, offset: offset);
      if (page.videos.isEmpty && page.nextOffset == null) {
        messages.add('Giphy no devolvió resultados.');
      }
      return page;
    } catch (error) {
      messages.add('No se pudo consultar Giphy. $error');
      return const GiphyVideoPage(videos: []);
    }
  }

  Future<DailymotionVideoPage> _loadDailymotion(
    String query, {
    required int page,
    required List<String> messages,
  }) async {
    if (!dailymotion.isConfigured) {
      messages.add('Configura DAILYMOTION_API_KEY para cargar videos.');
      return const DailymotionVideoPage(videos: []);
    }
    try {
      final result = await dailymotion.searchVideosPage(query, page: page);
      if (result.videos.isEmpty && result.nextPage == null) {
        messages.add('Dailymotion no devolvió resultados.');
      }
      return result;
    } catch (error) {
      messages.add('No se pudo consultar Dailymotion. $error');
      return const DailymotionVideoPage(videos: []);
    }
  }
}
