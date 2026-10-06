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

  const YoutubeFullscreenPlayer({
    super.key,
    required this.videoId,
    required this.caption,
    required this.isActive,
    required this.onPointerSignal,
    required this.onPointerDown,
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
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        mute: true,
        showControls: false,
        showFullscreenButton: false,
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

  @override
  void dispose() {
    _closeController();
    super.dispose();
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

    return Stack(
      fit: StackFit.expand,
      children: [
        YoutubePlayer(controller: controller, aspectRatio: 9 / 16),
        PointerInterceptor(
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerSignal: widget.onPointerSignal,
            onPointerDown: widget.onPointerDown,
            child: Stack(
              fit: StackFit.expand,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _togglePlayback,
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
                  top: 88,
                  left: 16,
                  child: IconButton(
                    tooltip: _isMuted == true ? 'Activar sonido' : 'Silenciar',
                    onPressed: _toggleMute,
                    icon: Icon(
                      _isMuted == true ? Icons.volume_off : Icons.volume_up,
                      color: Colors.white,
                      size: 30,
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
              ],
            ),
          ),
        ),
      ],
    );
  }
}
