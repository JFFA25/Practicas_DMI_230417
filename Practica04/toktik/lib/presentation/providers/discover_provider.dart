import 'package:flutter/material.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/infrastructure/models/local_video_model.dart';
import 'package:toktik/infrastructure/services/youtube_data_api.dart';
import 'package:toktik/shared/data/local_video_post.dart';

class DiscoverProvider extends ChangeNotifier {
  DiscoverProvider({YoutubeDataApi? youtubeApi})
    : _youtubeApi = youtubeApi ?? YoutubeDataApi();

  final YoutubeDataApi _youtubeApi;
  bool initialLoading = true;
  List<VideoPost> videos = [];
  String? statusMessage;

  late final List<VideoPost> _localVideos = videoPosts
      .map((video) => LocalVideoModel.fromJson(video).toVideoPostEntity())
      .toList();

  int get localVideoCount => _localVideos.length;

  int get youtubeVideoCount =>
      videos.where((video) => video.youtubeVideoId != null).length;

  Future<void> loadNextPage() =>
      searchVideos(YoutubeDataApi.defaultSearchQuery);

  Future<void> searchVideos(String query) async {
    initialLoading = true;
    statusMessage = null;
    videos = List.of(_localVideos);
    notifyListeners();

    try {
      if (!_youtubeApi.isConfigured) {
        statusMessage =
            'Configura YOUTUBE_API_KEY para cargar videos de YouTube. '
            'Se muestran los videos locales.';
      } else {
        final youtubeVideos = await _youtubeApi.searchShorts(query);
        videos = _interleaveVideos(_localVideos, youtubeVideos);
        if (youtubeVideos.isEmpty) {
          statusMessage =
              'YouTube no devolvió resultados; se muestran los videos locales.';
        }
      }
    } catch (error) {
      videos = List.of(_localVideos);
      statusMessage =
          'No se pudo consultar YouTube; se muestran los videos locales. '
          '$error';
    } finally {
      initialLoading = false;
      notifyListeners();
    }
  }

  Future<List<YoutubeComment>> getComments(String videoId) =>
      _youtubeApi.getComments(videoId);

  List<VideoPost> _interleaveVideos(
    List<VideoPost> localVideos,
    List<VideoPost> youtubeVideos,
  ) {
    final combined = <VideoPost>[];
    final maxLength = localVideos.length > youtubeVideos.length
        ? localVideos.length
        : youtubeVideos.length;

    for (var index = 0; index < maxLength; index++) {
      if (index < localVideos.length) combined.add(localVideos[index]);
      if (index < youtubeVideos.length) combined.add(youtubeVideos[index]);
    }

    return combined;
  }

  @override
  void dispose() {
    _youtubeApi.close();
    super.dispose();
  }
}
