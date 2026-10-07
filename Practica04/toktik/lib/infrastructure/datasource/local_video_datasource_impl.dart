import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/infrastructure/models/local_video_model.dart';
import 'package:toktik/shared/data/local_video_post.dart' as local_data;

class LocalVideoDatasourceImpl {
  List<VideoPost> getVideos() => local_data.videoPosts
      .map((video) => LocalVideoModel.fromJson(video).toVideoPostEntity())
      .toList(growable: false);
}