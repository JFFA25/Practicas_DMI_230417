import 'package:toktik/domain/entities/video_post.dart';

abstract class VideoPostRepostiories {

Future<List<VideoPost>> getFavoriteVieosByUser( String userID);

Future<List<VideoPost>> getTrendingVideosByPage(int page);

}