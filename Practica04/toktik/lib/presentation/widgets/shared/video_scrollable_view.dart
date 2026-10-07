import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:provider/provider.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/infrastructure/services/youtube_data_api.dart';
import 'package:toktik/presentation/providers/discover_provider.dart';
import 'package:toktik/presentation/providers/likes_provider.dart';
import 'package:toktik/presentation/widgets/shared/video_buttons.dart';
import 'package:toktik/presentation/widgets/shared/video_comments_sheet.dart';
import 'package:toktik/presentation/widgets/video/dailymotion_player.dart';
import 'package:toktik/presentation/widgets/video/fullscreen_player.dart';
import 'package:toktik/presentation/widgets/video/youtube_fullscreen_player.dart';

class VideoScrollableView extends StatefulWidget {
  final List<VideoPost> videos;
  final Future<List<YoutubeComment>> Function(String videoId) loadComments;
  final Axis scrollDirection;

  const VideoScrollableView({
    super.key,
    required this.videos,
    required this.loadComments,
    this.scrollDirection = Axis.vertical,
  });

  @override
  State<VideoScrollableView> createState() => _VideoScrollableViewState();
}

class _VideoScrollableViewState extends State<VideoScrollableView> {
  static const _pageDuration = Duration(milliseconds: 300);
  static const _wheelCooldown = Duration(milliseconds: 450);

  final PageController _pageController = PageController();
  final FocusNode _focusNode = FocusNode();
  int _currentIndex = 0;
  bool _wheelLocked = false;
  bool _isMuted = true;

  @override
  void didUpdateWidget(covariant VideoScrollableView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videos.isEmpty) {
      _currentIndex = 0;
      return;
    }
    if (_currentIndex >= widget.videos.length) {
      _currentIndex = widget.videos.length - 1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pageController.hasClients) {
          _pageController.jumpToPage(_currentIndex);
        }
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    GestureBinding.instance.pointerSignalResolver.register(event, (_) {
      if (_wheelLocked || !_pageController.hasClients) return;
      final delta = widget.scrollDirection == Axis.vertical
          ? event.scrollDelta.dy
          : event.scrollDelta.dx;
      final scrollDelta = delta.abs() < 1
          ? widget.scrollDirection == Axis.vertical
                ? event.scrollDelta.dx
                : event.scrollDelta.dy
          : delta;
      if (scrollDelta.abs() < 1) return;
      _wheelLocked = true;
      _goToPage(_currentIndex + (scrollDelta > 0 ? 1 : -1));
      Future<void>.delayed(_wheelCooldown, () => _wheelLocked = false);
    });
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final nextKey = widget.scrollDirection == Axis.vertical
        ? LogicalKeyboardKey.arrowDown
        : LogicalKeyboardKey.arrowRight;
    final previousKey = widget.scrollDirection == Axis.vertical
        ? LogicalKeyboardKey.arrowUp
        : LogicalKeyboardKey.arrowLeft;
    if (event.logicalKey == nextKey) {
      _goToPage(_currentIndex + 1);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == previousKey) {
      _goToPage(_currentIndex - 1);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Future<void> _goToPage(int index) async {
    if (!_pageController.hasClients || widget.videos.isEmpty) return;
    final target = index.clamp(0, widget.videos.length - 1);
    if (target == _currentIndex) return;
    await _pageController.animateToPage(
      target,
      duration: _pageDuration,
      curve: Curves.easeOut,
    );
  }

  Future<void> _toggleLike(VideoPost video, LikesProvider likes) async {
    try {
      await likes.toggleLike(video);
      if (mounted) {
        final discover = context.read<DiscoverProvider>();
        if (discover.section == VideoFeedSection.favorites) {
          await discover.loadSection(
            VideoFeedSection.favorites,
            favorites: likes.favorites,
          );
        }
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar el me gusta: $error')),
      );
    }
  }

  Future<void> _likeOnDoubleTap(VideoPost video, LikesProvider likes) async {
    if (!likes.isLiked(video)) {
      await _toggleLike(video, likes);
    }
  }

  @override
  Widget build(BuildContext context) {
    final likes = context.watch<LikesProvider>();
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: ScrollConfiguration(
        behavior: const _FeedScrollBehavior(),
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) => _focusNode.requestFocus(),
          onPointerSignal: _handlePointerSignal,
          child: PageView.builder(
            controller: _pageController,
            scrollDirection: widget.scrollDirection,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.videos.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
              if (index >= widget.videos.length - 3) {
                context.read<DiscoverProvider>().loadMoreDiscover();
              }
            },
            itemBuilder: (context, index) {
              final video = widget.videos[index];
              final isActive = index == _currentIndex;
              final buttons = Positioned(
                bottom: 40,
                right: 12,
                child: PointerInterceptor(
                  child: VideoButtons(
                  video: video,
                  likeCount: likes.likeCount(video),
                  isLiked: likes.isLiked(video),
                  onLikePressed: () => _toggleLike(video, likes),
                  isMuted: _isMuted,
                  onMutePressed: () => setState(() => _isMuted = !_isMuted),
                  canGoPrevious: index > 0,
                  canGoNext: index < widget.videos.length - 1,
                  onPreviousPressed: () => _goToPage(index - 1),
                  onNextPressed: () => _goToPage(index + 1),
                  onCommentsPressed: video.youtubeVideoId == null
                      ? null
                      : () => showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => VideoCommentsSheet(
                            loadComments: () =>
                                widget.loadComments(video.youtubeVideoId!),
                          ),
                        ),
                  ),
                ),
              );

              final Widget player;
              if (video.youtubeVideoId != null) {
                player = YoutubeFullscreenPlayer(
                  key: ValueKey(video.storageId),
                  videoId: video.youtubeVideoId!,
                  caption: video.caption,
                  description: video.description,
                  isActive: isActive,
                  isMuted: _isMuted,
                  scrollDirection: widget.scrollDirection,
                  onDoubleTap: () => _likeOnDoubleTap(video, likes),
                  onPointerSignal: _handlePointerSignal,
                  onPointerDown: (_) => _focusNode.requestFocus(),
                  onSwipeNext: () => _goToPage(index + 1),
                  onSwipePrevious: () => _goToPage(index - 1),
                  overlay: buttons,
                );
              } else if (video.source == 'dailymotion') {
                player = DailymotionPlayer(
                  key: ValueKey(video.storageId),
                  videoId: video.sourceId!,
                  caption: video.caption,
                  description: video.description,
                  isActive: isActive,
                  isMuted: _isMuted,
                  onDoubleTap: () => _likeOnDoubleTap(video, likes),
                  onPointerSignal: _handlePointerSignal,
                  onPointerDown: (_) => _focusNode.requestFocus(),
                );
              } else {
                player = FullScreenPlayer(
                  key: ValueKey(video.storageId),
                  videoUrl: video.videoUrl,
                  caption: video.caption,
                  description: video.description,
                  isActive: isActive,
                  isMuted: _isMuted,
                  onDoubleTap: () => _likeOnDoubleTap(video, likes),
                  onPointerSignal: _handlePointerSignal,
                  onPointerDown: (_) => _focusNode.requestFocus(),
                );
              }

              return Stack(
                fit: StackFit.expand,
                children: [
                  player,
                  if (video.source == 'giphy')
                    const IgnorePointer(
                      child: SafeArea(
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: EdgeInsets.only(top: 8, right: 16),
                            child: Text(
                              'Powered by GIPHY',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (video.youtubeVideoId == null) buttons,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FeedScrollBehavior extends MaterialScrollBehavior {
  const _FeedScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}
