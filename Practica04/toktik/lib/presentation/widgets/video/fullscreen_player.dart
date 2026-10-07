import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:toktik/presentation/widgets/shared/expandable_caption.dart';
import 'package:toktik/presentation/widgets/video/video_background.dart';
import 'package:video_player/video_player.dart';

class FullScreenPlayer extends StatefulWidget {
  final String videoUrl;
  final String caption;
  final String description;
  final bool isActive;
  final bool isMuted;
  final VoidCallback? onDoubleTap;
  final ValueChanged<PointerSignalEvent>? onPointerSignal;
  final ValueChanged<PointerDownEvent>? onPointerDown;

  const FullScreenPlayer({
    super.key,
    required this.videoUrl,
    required this.caption,
    this.description = '',
    required this.isActive,
    required this.isMuted,
    this.onDoubleTap,
    this.onPointerSignal,
    this.onPointerDown,
  });

  @override
  State<FullScreenPlayer> createState() => _FullScreenPlayerState();
}

class _FullScreenPlayerState extends State<FullScreenPlayer> {
  late VideoPlayerController controller;
  late Future<void> _initialization;
  bool? _isPlaying = false;

  @override
  void initState() {
    super.initState();

    controller = widget.videoUrl.startsWith('http')
        ? VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
        : VideoPlayerController.asset(widget.videoUrl);
    controller.addListener(_updatePlaybackState);
    _initialization = _initializePlayer();
  }

  void _updatePlaybackState() {
    if (!mounted || _isPlaying == controller.value.isPlaying) return;
    setState(() => _isPlaying = controller.value.isPlaying);
  }

  Future<void> _initializePlayer() async {
    await controller.initialize();
    if (!mounted) return;

    await controller.setVolume(widget.isMuted ? 0 : 1);
    await controller.setLooping(true);
    if (widget.isActive) {
      await controller.play();
    }
  }

  void _togglePlayback() {
    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
  }

  @override
  void didUpdateWidget(covariant FullScreenPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isMuted != widget.isMuted &&
        controller.value.isInitialized) {
      controller.setVolume(widget.isMuted ? 0 : 1);
    }
    if (oldWidget.isActive != widget.isActive &&
        controller.value.isInitialized) {
      if (widget.isActive) {
        controller.play();
      } else {
        controller.pause();
      }
    }
  }

  @override
  void dispose() {
    controller.removeListener(_updatePlaybackState);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No se pudo cargar el video\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }

        // En Flutter Web el <video> es una vista de plataforma que se traga la
        // rueda del mouse. PointerInterceptor + Listener devuelven esos
        // eventos a Flutter para que el PageView pueda hacer scroll.
        return PointerInterceptor(
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerSignal: widget.onPointerSignal,
            onPointerDown: widget.onPointerDown,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _togglePlayback,
              onDoubleTap: widget.onDoubleTap,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Center(
                    child: AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: VideoPlayer(controller),
                    ),
                  ),
                  VideoBackground(stops: const [0.8, 1.0]),
                  if (_isPlaying != true)
                    Center(
                      child: IconButton(
                        tooltip: 'Reproducir video',
                        onPressed: controller.play,
                        icon: const Icon(
                          Icons.play_circle_fill,
                          color: Colors.white,
                          size: 72,
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 50,
                    left: 20,
                    child: ExpandableCaption(
                      title: widget.caption,
                      description: widget.description,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
