import 'package:toktik/domain/entities/video_post.dart';

class LocalVideoModel {
  final String description;
  final String videoUrl;
  final int likes;
  final int views;
  final int comments;

  LocalVideoModel({
    required this.description,
    required this.videoUrl,
    this.likes = 0,
    this.views = 0,
    this.comments = 0,
  });

  factory LocalVideoModel.fromJson(Map<String, dynamic> json) =>
      LocalVideoModel(
        description: json['description'] ?? json['name'] ?? 'No description',
        videoUrl: json['videoUrl'],
        likes: json['likes'] ?? 0,
        views: json['views'] ?? 0,
        comments: json['comments'] ?? 0,
      );

  VideoPost toVideoPostEntity() => VideoPost(
    caption: description,
    videoUrl: videoUrl,
    likes: likes,
    views: views,
    comments: comments,
  );
}
