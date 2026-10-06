import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/infrastructure/services/youtube_data_api.dart';
import 'package:toktik/presentation/widgets/shared/video_buttons.dart';
import 'package:toktik/presentation/widgets/shared/video_comments_sheet.dart';
import 'package:toktik/presentation/widgets/video/fullscreen_player.dart';
import 'package:toktik/presentation/widgets/video/youtube_fullscreen_player.dart';

class VideoScrollableView extends StatefulWidget {
  final List<VideoPost> videos;
  final Future<List<YoutubeComment>> Function(String videoId) loadComments;

  const VideoScrollableView({
    super.key,
    required this.videos,
    required this.loadComments,
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
      final delta = event.scrollDelta.dy;
      if (delta.abs() < 1) return;

      _wheelLocked = true;
      _goToPage(_currentIndex + (delta > 0 ? 1 : -1));
      Future<void>.delayed(_wheelCooldown, () => _wheelLocked = false);
    });
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _goToPage(_currentIndex + 1);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
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

  @override
  Widget build(BuildContext context) {
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
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.videos.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              final VideoPost videoPost = widget.videos[index];

              return Stack(
                children: [
                  SizedBox.expand(
                    child: videoPost.youtubeVideoId == null
                        ? FullScreenPlayer(
                            caption: videoPost.caption,
                            videoUrl: videoPost.videoUrl,
                            isActive: index == _currentIndex,
                            onPointerSignal: _handlePointerSignal,
                            onPointerDown: (_) => _focusNode.requestFocus(),
                          )
                        : YoutubeFullscreenPlayer(
                            videoId: videoPost.youtubeVideoId!,
                            caption: videoPost.caption,
                            isActive: index == _currentIndex,
                            onPointerSignal: _handlePointerSignal,
                            onPointerDown: (_) => _focusNode.requestFocus(),
                          ),
                  ),
                  Positioned(
                    bottom: 40,
                    right: 20,
                    child: VideoButtons(
                      video: videoPost,
                      canGoPrevious: index > 0,
                      canGoNext: index < widget.videos.length - 1,
                      onPreviousPressed: () => _goToPage(index - 1),
                      onNextPressed: () => _goToPage(index + 1),
                      onCommentsPressed: videoPost.youtubeVideoId == null
                          ? null
                          : () => showModalBottomSheet<void>(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) => VideoCommentsSheet(
                                loadComments: () => widget.loadComments(
                                  videoPost.youtubeVideoId!,
                                ),
                              ),
                            ),
                    ),
                  ),
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