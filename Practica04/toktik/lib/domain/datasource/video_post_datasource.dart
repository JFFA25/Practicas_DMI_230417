import 'package:toktik/domain/entities/video_post.dart';

abstract class VideoPostDatasource {

Future<List<VideoPost>> getFavoriteVideoByUser( String userID);

Future<List<VideoPost>> getTredingVideoByPage(int page);

}