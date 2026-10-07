import 'package:flutter/material.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/domain/repositories/video_feed_repository.dart';
import 'package:toktik/infrastructure/datasource/local_video_datasource_impl.dart';
import 'package:toktik/infrastructure/repositories/video_feed_repository_impl.dart';
import 'package:toktik/infrastructure/services/dailymotion_api.dart';
import 'package:toktik/infrastructure/services/giphy_api.dart';
import 'package:toktik/infrastructure/services/youtube_data_api.dart';

enum VideoFeedSection { discover, forYou, favorites }

class DiscoverProvider extends ChangeNotifier {
  DiscoverProvider({
    YoutubeDataApi? youtubeApi,
    GiphyApi? giphyApi,
    DailymotionApi? dailymotionApi,
    VideoFeedRepository? repository,
  }) : _youtubeApi = youtubeApi ?? YoutubeDataApi(),
       _giphyApi = giphyApi ?? GiphyApi(),
       _dailymotionApi = dailymotionApi ?? DailymotionApi() {
    _repository =
        repository ??
        VideoFeedRepositoryImpl(
          localVideos: LocalVideoDatasourceImpl(),
          youtube: _youtubeApi,
          giphy: _giphyApi,
          dailymotion: _dailymotionApi,
        );
  }

  final YoutubeDataApi _youtubeApi;
  final GiphyApi _giphyApi;
  final DailymotionApi _dailymotionApi;
  late final VideoFeedRepository _repository;

  bool initialLoading = true;
  List<VideoPost> videos = [];
  String? statusMessage;
  VideoFeedSection section = VideoFeedSection.discover;
  String? _youtubeNextPageToken;
  int? _giphyNextOffset;
  int? _dailymotionNextPage;
  bool _loadingMoreDiscover = false;
  int _sectionLoadGeneration = 0;
  String _discoverQuery = YoutubeDataApi.defaultSearchQuery;
  String _discoverGiphyQuery = GiphyApi.defaultSearchQuery;
  String _discoverDailymotionQuery = DailymotionApi.defaultSearchQuery;

  bool get hasMoreDiscover =>
      _youtubeNextPageToken != null ||
      _giphyNextOffset != null ||
      _dailymotionNextPage != null;
  bool get loadingMoreDiscover => _loadingMoreDiscover;

  int get localVideoCount => videos.where((video) => video.source == 'local').length;

  int get youtubeVideoCount =>
      videos.where((video) => video.youtubeVideoId != null).length;

  int get giphyVideoCount =>
      videos.where((video) => video.source == 'giphy').length;

  int get dailymotionVideoCount =>
      videos.where((video) => video.source == 'dailymotion').length;

  Future<void> loadNextPage() => loadSection(VideoFeedSection.discover);

  Future<void> searchVideos(String query, {String? giphyQuery}) {
    final generation = ++_sectionLoadGeneration;
    _discoverQuery = query;
    _discoverGiphyQuery = giphyQuery ?? query;
    _discoverDailymotionQuery = query;
    return _loadResult(
      _repository.getDiscoverVideos(
        query,
        giphyQuery: _discoverGiphyQuery,
        dailymotionQuery: _discoverDailymotionQuery,
      ),
      generation: generation,
    );
  }

  Future<void> loadSection(
    VideoFeedSection nextSection, {
    List<VideoPost> favorites = const [],
  }) async {
    final generation = ++_sectionLoadGeneration;
    section = nextSection;
    if (nextSection == VideoFeedSection.discover) {
      _discoverQuery = YoutubeDataApi.defaultSearchQuery;
      _discoverGiphyQuery = GiphyApi.defaultSearchQuery;
      _discoverDailymotionQuery = DailymotionApi.defaultSearchQuery;
    }
    _loadingMoreDiscover = false;
    _youtubeNextPageToken = null;
    _giphyNextOffset = null;
    _dailymotionNextPage = null;
    statusMessage = null;
    initialLoading = true;
    notifyListeners();

    final Future<VideoFeedResult> result = switch (nextSection) {
      VideoFeedSection.discover =>
        _repository.getDiscoverVideos(
          YoutubeDataApi.defaultSearchQuery,
          giphyQuery: GiphyApi.defaultSearchQuery,
          dailymotionQuery: DailymotionApi.defaultSearchQuery,
        ),
      VideoFeedSection.forYou =>
        _repository.getForYouVideos(
          YoutubeDataApi.defaultSearchQuery,
          giphyQuery: GiphyApi.defaultSearchQuery,
          dailymotionQuery: DailymotionApi.defaultSearchQuery,
        ),
      VideoFeedSection.favorites => _repository.getFavoriteVideos(favorites),
    };
    await _loadResult(result, generation: generation);
  }

  Future<void> loadMoreDiscover() async {
    if (section != VideoFeedSection.discover ||
        initialLoading ||
        _loadingMoreDiscover ||
        !hasMoreDiscover) {
      return;
    }

    _loadingMoreDiscover = true;
    final generation = _sectionLoadGeneration;
    notifyListeners();
    try {
      final page = await _repository.getMoreDiscoverVideos(
        query: _discoverQuery,
        giphyQuery: _discoverGiphyQuery,
        dailymotionQuery: _discoverDailymotionQuery,
        youtubePageToken: _youtubeNextPageToken,
        giphyOffset: _giphyNextOffset,
        dailymotionPage: _dailymotionNextPage,
      );
      if (generation != _sectionLoadGeneration ||
          section != VideoFeedSection.discover) {
        return;
      }
      final existingIds = videos.map((video) => video.storageId).toSet();
      videos = [
        ...videos,
        ...page.videos.where((video) => existingIds.add(video.storageId)),
      ];
      _updateDiscoverCursors(page);
      statusMessage = page.messages.isEmpty ? null : page.messages.join('\n');
    } catch (error) {
      if (generation == _sectionLoadGeneration) {
        statusMessage = 'No se pudo cargar más contenido. $error';
      }
    } finally {
      if (generation == _sectionLoadGeneration) {
        _loadingMoreDiscover = false;
        notifyListeners();
      }
    }
  }

  Future<void> _loadResult(
    Future<VideoFeedResult> result, {
    required int generation,
  }) async {
    initialLoading = true;
    statusMessage = null;
    notifyListeners();
    try {
      final feed = await result;
      if (generation != _sectionLoadGeneration) return;
      videos = feed.videos;
      if (section == VideoFeedSection.discover) {
        _updateDiscoverCursors(feed);
      }
      statusMessage = feed.messages.isEmpty ? null : feed.messages.join('\n');
    } catch (error) {
      if (generation != _sectionLoadGeneration) return;
      videos = [];
      statusMessage = 'No se pudo cargar esta sección. $error';
    } finally {
      if (generation == _sectionLoadGeneration) {
        initialLoading = false;
        notifyListeners();
      }
    }
  }

  void _updateDiscoverCursors(VideoFeedResult result) {
    _youtubeNextPageToken = result.youtubeNextPageToken;
    _giphyNextOffset = result.giphyNextOffset;
    _dailymotionNextPage = result.dailymotionNextPage;
  }

  Future<List<YoutubeComment>> getComments(String videoId) =>
      _youtubeApi.getComments(videoId);

  @override
  void dispose() {
    _youtubeApi.close();
    _giphyApi.close();
    _dailymotionApi.close();
    super.dispose();
  }
}
