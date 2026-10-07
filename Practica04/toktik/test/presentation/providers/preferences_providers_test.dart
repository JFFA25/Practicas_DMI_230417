import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/presentation/providers/likes_provider.dart';
import 'package:toktik/presentation/providers/theme_provider.dart';
import 'package:toktik/infrastructure/models/local_video_model.dart';
import 'package:toktik/shared/data/local_video_post.dart' as local_data;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('toktik/launcher_icon'),
          (methodCall) async => null,
        );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('toktik/launcher_icon'),
          null,
        );
  });

  test('like toggles increment and decrement a persisted count', () async {
    final video = VideoPost(
      caption: 'Test',
      videoUrl: 'assets/videos/1.mp4',
      likes: 40,
    );
    final likes = LikesProvider();

    await likes.toggleLike(video);
    expect(likes.likeCount(video), 41);
    expect(likes.isLiked(video), isTrue);

    await likes.toggleLike(video);
    expect(likes.likeCount(video), 40);
    expect(likes.isLiked(video), isFalse);

    final restored = LikesProvider();
    await restored.load();
    expect(restored.likeCount(video), 40);
    expect(restored.isLiked(video), isFalse);
  });

  test(
    'the zero-like local video displays and persists its test count',
    () async {
      final video = local_data.videoPosts
          .map((item) => LocalVideoModel.fromJson(item).toVideoPostEntity())
          .singleWhere((item) => item.likes == 0);
      expect(video.comments, 0);

      final likes = LikesProvider();
      await likes.toggleLike(video);
      expect(likes.likeCount(video), 1);
      expect(likes.isLiked(video), isTrue);

      final restored = LikesProvider();
      await restored.load();
      expect(restored.likeCount(video), 1);
      expect(restored.isLiked(video), isTrue);
    },
  );

  test('liked videos remain available as favorites after reloading', () async {
    final video = VideoPost(
      caption: 'Saved clip',
      description: 'Details',
      videoUrl: 'https://example.com/video.mp4',
      source: 'giphy',
      sourceId: 'saved-clip',
    );
    final likes = LikesProvider();
    await likes.toggleLike(video);

    final restored = LikesProvider();
    await restored.load();
    expect(restored.favorites, hasLength(1));
    expect(restored.favorites.single.caption, 'Saved clip');
    expect(restored.favorites.single.description, 'Details');
  });

  test('automatic season uses the local calendar month', () {
    expect(
      SeasonalTheme.forDate(DateTime(2026, 10, 31)),
      SeasonalTheme.halloween,
    );
    expect(
      SeasonalTheme.forDate(DateTime(2026, 12, 25)),
      SeasonalTheme.christmas,
    );
    expect(
      SeasonalTheme.forDate(DateTime(2026, 2, 14)),
      SeasonalTheme.valentinesDay,
    );
    expect(SeasonalTheme.forDate(DateTime(2026, 6, 1)), SeasonalTheme.normal);
  });

  test('manual seasonal selection survives a provider restart', () async {
    final iconChanges = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('toktik/launcher_icon'), (
          methodCall,
        ) async {
          iconChanges.add(methodCall.arguments as String);
          return null;
        });
    final themes = ThemeProvider();
    await themes.setSoundEnabled(false);
    await themes.selectTheme(SeasonalTheme.halloween);
    expect(iconChanges.last, 'halloween');
    final callsBeforeRestart = iconChanges.length;

    final restored = ThemeProvider();
    await restored.load();
    expect(restored.theme, SeasonalTheme.halloween);
    expect(restored.isAutomatic, isFalse);
    expect(restored.soundEnabled, isFalse);
    expect(iconChanges.length, callsBeforeRestart + 1);
    expect(iconChanges.last, 'halloween');
  });

  test('Valentines selection requests its matching launcher icon', () async {
    String? selectedIcon;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('toktik/launcher_icon'), (
          methodCall,
        ) async {
          selectedIcon = methodCall.arguments as String;
          return null;
        });
    final themes = ThemeProvider();

    await themes.selectTheme(SeasonalTheme.valentinesDay);

    expect(selectedIcon, 'valentinesDay');
  });
}
