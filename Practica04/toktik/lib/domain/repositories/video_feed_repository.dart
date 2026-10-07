import 'package:toktik/domain/entities/video_post.dart';

abstract interface class VideoFeedRepository {
  Future<VideoFeedResult> getDiscoverVideos(
    String query, {
    String? giphyQuery,
    String? dailymotionQuery,
  });

  Future<VideoFeedResult> getMoreDiscoverVideos({
    required String query,
    required String giphyQuery,
    required String dailymotionQuery,
    required String? youtubePageToken,
    required int? giphyOffset,
    required int? dailymotionPage,
  });

  Future<VideoFeedResult> getForYouVideos(
    String query, {
    String? giphyQuery,
    String? dailymotionQuery,
  });

  Future<VideoFeedResult> getFavoriteVideos(List<VideoPost> favorites);
}

class VideoFeedResult {
  final List<VideoPost> videos;
  final List<String> messages;
  final String? youtubeNextPageToken;
  final int? giphyNextOffset;
  final int? dailymotionNextPage;

  const VideoFeedResult({
    required this.videos,
    this.messages = const [],
    this.youtubeNextPageToken,
    this.giphyNextOffset,
    this.dailymotionNextPage,
  });

  bool get hasMore =>
      youtubeNextPageToken != null ||
      giphyNextOffset != null ||
      dailymotionNextPage != null;
}
