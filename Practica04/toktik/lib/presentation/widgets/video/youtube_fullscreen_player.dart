import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class YoutubeFullscreenPlayer extends StatefulWidget {
  final String videoId;
  final String caption;
  final bool isActive;
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
    required this.isActive,
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
  bool? _isMuted = true;

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
  }

  void _createController() {
    if (_controller != null) return;
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        mute: true,
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

  Future<void> _toggleMute() async {
    final controller = _controller;
    if (controller == null) return;
    final isMuted = _isMuted != true;
    if (isMuted) {
      await controller.mute();
    } else {
      await controller.unMute();
    }
    if (mounted) setState(() => _isMuted = isMuted);
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
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
                onVerticalDragEnd: _handleVerticalDragEnd,
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
                bottom: 128,
                left: 16,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.42),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    tooltip:
                        _isMuted == true ? 'Activar sonido' : 'Silenciar',
                    onPressed: _toggleMute,
                    icon: Icon(
                      _isMuted == true ? Icons.volume_off : Icons.volume_up,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 48,
                left: 20,
                child: SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.6,
                  child: Text(
                    widget.caption,
                    maxLines: 2,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      shadows: const [
                        Shadow(blurRadius: 8, color: Colors.black),
                      ],
                    ),
                  ),
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