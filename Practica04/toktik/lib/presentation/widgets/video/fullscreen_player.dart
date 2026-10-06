import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:toktik/presentation/widgets/video/video_background.dart';
import 'package:video_player/video_player.dart';

class FullScreenPlayer extends StatefulWidget {
  final String videoUrl;
  final String caption;
  final bool isActive;
  final ValueChanged<PointerSignalEvent>? onPointerSignal;
  final ValueChanged<PointerDownEvent>? onPointerDown;

  const FullScreenPlayer({
    super.key,
    required this.videoUrl,
    required this.caption,
    required this.isActive,
    this.onPointerSignal,
    this.onPointerDown,
  });

  @override
  State<FullScreenPlayer> createState() => _FullScreenPlayerState();
}

class _FullScreenPlayerState extends State<FullScreenPlayer> {
  late VideoPlayerController controller;
  late Future<void> _initialization;
  bool? _isMuted = false;
  bool? _isPlaying = false;

  @override
  void initState() {
    super.initState();

    controller = VideoPlayerController.asset(widget.videoUrl);
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

    await controller.setVolume(1.0);
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
          return const Center(child: Text('No se pudo cargar el video'));
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
                    child: _VideoCaption(caption: widget.caption),
                  ),
                  Positioned(
                    left: 16,
                    bottom: 128,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.42),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        tooltip: _isMuted == true
                            ? 'Activar sonido'
                            : 'Silenciar',
                        onPressed: () async {
                          final isMuted = _isMuted != true;
                          await controller.setVolume(isMuted ? 0 : 1);
                          if (mounted) {
                            setState(() => _isMuted = isMuted);
                          }
                        },
                        icon: Icon(
                          _isMuted == true
                              ? Icons.volume_off
                              : Icons.volume_up,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
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

class _VideoCaption extends StatelessWidget {
  final String caption;

  const _VideoCaption({required this.caption});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final titleStyle = Theme.of(context).textTheme.titleLarge;

    return SizedBox(
      width: size.width * 0.6,
      child: Text(caption, maxLines: 2, style: titleStyle),
    );
  }
}
