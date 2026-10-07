

class VideoPost {
  final String caption;
  final String description;
  final String videoUrl;
  final int likes;
  final int views;
  final int comments;
  final String? youtubeVideoId;
  final String? sourceId;

  /// Origen del video: 'local', 'youtube' o 'giphy'.
  final String source;

  VideoPost({
    required this.caption,
    this.description = '',
    required this.videoUrl,
    this.likes = 0,
    this.views = 0,
    this.comments = 0,
    this.youtubeVideoId,
    this.sourceId,
    this.source = 'local',
  });

  String get storageId =>
      '$source:${sourceId ?? youtubeVideoId ?? videoUrl}';
}