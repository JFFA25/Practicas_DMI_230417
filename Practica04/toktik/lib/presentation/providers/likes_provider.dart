import 'package:flutter/material.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/infrastructure/datasource/video_preferences_datasource.dart';

class LikesProvider extends ChangeNotifier {
  LikesProvider({VideoPreferencesDatasource? datasource})
    : _datasource = datasource ?? VideoPreferencesDatasource();

  final VideoPreferencesDatasource _datasource;
  Map<String, StoredVideoLike> _likes = {};
  Future<void>? _loading;
  bool isLoaded = false;
  String? errorMessage;

  List<VideoPost> get favorites => _likes.values
      .where((entry) => entry.liked)
      .map((entry) => entry.video)
      .toList(growable: false);

  bool isLiked(VideoPost video) => _likes[video.storageId]?.liked ?? false;

  int likeCount(VideoPost video) =>
      _likes[video.storageId]?.likes ?? video.likes;

  Future<void> load() {
    if (isLoaded) return Future<void>.value();
    return _loading ??= _load();
  }

  Future<void> _load() async {
    try {
      _likes = await _datasource.loadLikes();
    } catch (error) {
      errorMessage = 'No se pudieron restaurar los me gusta. $error';
    } finally {
      isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> toggleLike(VideoPost video) async {
    await load();
    final key = video.storageId;
    final previous = _likes[key];
    final wasLiked = previous?.liked ?? false;
    final count = previous?.likes ?? video.likes;
    final next = Map<String, StoredVideoLike>.of(_likes);
    next[key] = StoredVideoLike(
      liked: !wasLiked,
      likes: (count + (wasLiked ? -1 : 1)).clamp(0, 0x7fffffff),
      video: video,
    );
    _likes = next;
    errorMessage = null;
    notifyListeners();

    try {
      await _datasource.saveLikes(next);
    } catch (error) {
      _likes = Map<String, StoredVideoLike>.of(_likes)
        ..remove(key)
        ..addEntries(
          previous == null ? const [] : [MapEntry(key, previous)],
        );
      errorMessage = 'No se pudo guardar el me gusta. $error';
      notifyListeners();
      rethrow;
    }
  }
}
