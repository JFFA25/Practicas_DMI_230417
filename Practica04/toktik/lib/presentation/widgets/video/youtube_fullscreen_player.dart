import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:toktik/presentation/widgets/shared/expandable_caption.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class YoutubeFullscreenPlayer extends StatefulWidget {
  final String videoId;
  final String caption;
  final String description;
  final bool isActive;
  final bool isMuted;
  final Axis scrollDirection;
  final VoidCallback? onDoubleTap;
  final ValueChanged<PointerSignalEvent> onPointerSignal;
  final ValueChanged<PointerDownEvent> onPointerDown;

  /// Se llama al deslizar hacia arriba (siguiente video).
  final VoidCallback? onSwipeNext;

  /// Se llama al deslizar hacia abajo (video anterior).
  final VoidCallback? onSwipePrevious;

  /// Widget (normalmente un Positioned con los botones de likes/comentarios)
  /// que se dibuja ENCIMA del video, dentro del reproductor.
  final Widget? overlay;

  const YoutubeFullscreenPlayer({
    super.key,
    required this.videoId,
    required this.caption,
    this.description = '',
    required this.isActive,
    required this.isMuted,
    this.scrollDirection = Axis.vertical,
    this.onDoubleTap,
    required this.onPointerSignal,
    required this.onPointerDown,
    this.onSwipeNext,
    this.onSwipePrevious,
    this.overlay,
  });

  @override
  State<YoutubeFullscreenPlayer> createState() =>
      _YoutubeFullscreenPlayerState();
}

class _YoutubeFullscreenPlayerState extends State<YoutubeFullscreenPlayer> {
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.isActive) _createController();
  }

  @override
  void didUpdateWidget(covariant YoutubeFullscreenPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoId != widget.videoId) {
      _closeController();
      if (widget.isActive) _createController();
    } else if (oldWidget.isActive != widget.isActive) {
      if (widget.isActive) {
        _createController();
        _controller?.playVideo();
      } else {
        _controller?.pauseVideo();
      }
    }
    if (oldWidget.isMuted != widget.isMuted) {
      if (widget.isMuted) {
        _controller?.mute();
      } else {
        _controller?.unMute();
      }
    }
  }

  void _createController() {
    if (_controller != null) return;
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: true,
      params: YoutubePlayerParams(
        mute: widget.isMuted,
        loop: true,
        showControls: false,
        showFullscreenButton: false,
        showVideoAnnotations: false,
        enableCaption: false,
        strictRelatedVideos: true,
      ),
    );
  }

  void _closeController() {
    final controller = _controller;
    _controller = null;
    controller?.close();
  }

  void _togglePlayback() {
    final controller = _controller;
    if (controller == null) return;
    if (controller.value.playerState == PlayerState.playing ||
        controller.value.playerState == PlayerState.buffering) {
      controller.pauseVideo();
    } else {
      controller.playVideo();
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < -150) {
      widget.onSwipeNext?.call();
    } else if (velocity > 150) {
      widget.onSwipePrevious?.call();
    }
  }

  @override
  void dispose() {
    _closeController();
    super.dispose();
  }

  /// En móvil, youtube_player_iframe dibuja el WebView en un Overlay que
  /// queda POR ENCIMA de toda la pantalla. Por eso todo lo que debe verse
  /// sobre el video (botones, texto, gestos) se construye aquí, dentro de
  /// controlsBuilder, que sí se dibuja encima del WebView.
  Widget _buildControls(YoutubePlayerController controller) {
    return Material(
      type: MaterialType.transparency,
      child: PointerInterceptor(
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerSignal: widget.onPointerSignal,
          onPointerDown: widget.onPointerDown,
          child: Stack(
            fit: StackFit.expand,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _togglePlayback,
                onDoubleTap: widget.onDoubleTap,
                onHorizontalDragEnd: widget.scrollDirection == Axis.horizontal
                    ? _handleDragEnd
                    : null,
                child: const SizedBox.expand(),
              ),
              YoutubeValueBuilder(
                controller: controller,
                buildWhen: (previous, current) =>
                    previous.playerState != current.playerState,
                builder: (context, value) {
                  if (value.playerState == PlayerState.playing ||
                      value.playerState == PlayerState.buffering) {
                    return const SizedBox.shrink();
                  }
                  return Center(
                    child: IconButton(
                      tooltip: 'Reproducir video',
                      onPressed: controller.playVideo,
                      icon: const Icon(
                        Icons.play_circle_fill,
                        color: Colors.white,
                        size: 72,
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                bottom: 48,
                left: 20,
                child: ExpandableCaption(
                  title: widget.caption,
                  description: widget.description,
                ),
              ),
              if (widget.overlay != null) widget.overlay!,
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) {
      return ColoredBox(
        color: Colors.black,
        child: Center(
          child: Image.network(
            'https://i.ytimg.com/vi/${widget.videoId}/hqdefault.jpg',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.smart_display, color: Colors.white, size: 72),
          ),
        ),
      );
    }

    return YoutubePlayer(
      controller: controller,
      aspectRatio: 9 / 16,
      // Evita que deslizar el dedo active la pantalla completa del paquete.
      enableFullScreenOnVerticalDrag: false,
      autoFullScreen: false,
      controlsBuilder: (context, isFullscreen) => _buildControls(controller),
    );
  }
}
