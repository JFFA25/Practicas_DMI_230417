import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:toktik/presentation/widgets/shared/expandable_caption.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class DailymotionPlayer extends StatefulWidget {
  final String videoId;
  final String caption;
  final String description;
  final bool isActive;
  final bool isMuted;
  final VoidCallback? onDoubleTap;
  final ValueChanged<PointerSignalEvent>? onPointerSignal;
  final ValueChanged<PointerDownEvent>? onPointerDown;

  const DailymotionPlayer({
    super.key,
    required this.videoId,
    required this.caption,
    required this.description,
    required this.isActive,
    required this.isMuted,
    this.onDoubleTap,
    this.onPointerSignal,
    this.onPointerDown,
  });

  @override
  State<DailymotionPlayer> createState() => _DailymotionPlayerState();
}

class _DailymotionPlayerState extends State<DailymotionPlayer> {
  late final WebViewController _controller;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController();
    _configureController();
    if (widget.isActive) _loadVideo();
  }

  /// En Android el WebView trae JavaScript APAGADO y bloquea el autoplay, y el
  /// reproductor de Dailymotion necesita ambas cosas para mostrar el video.
  /// En Flutter Web estos métodos no existen (es un iframe), por eso se omiten.
  void _configureController() {
    if (kIsWeb) return;
    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (error) {
            if (!mounted || error.isForMainFrame == false) return;
            setState(() {
              _loading = false;
              _error = 'No se pudo cargar el video (${error.description}).';
            });
          },
        ),
      );
    final platform = _controller.platform;
    if (platform is AndroidWebViewController) {
      platform.setMediaPlaybackRequiresUserGesture(false);
    }
  }

  @override
  void didUpdateWidget(covariant DailymotionPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoId != widget.videoId ||
        oldWidget.isActive != widget.isActive ||
        oldWidget.isMuted != widget.isMuted) {
      if (widget.isActive) {
        _loadVideo();
      } else {
        _controller.loadRequest(Uri.parse('about:blank'));
      }
    }
  }

  void _loadVideo() {
    _error = null;
    _loading = !kIsWeb;
    final url = Uri.https(
      'www.dailymotion.com',
      '/embed/video/${widget.videoId}',
      {
        'autoplay': 'true',
        'mute': widget.isMuted ? 'true' : 'false',
        'loop': 'true',
        'queue-enable': 'false',
        'sharing-enable': 'false',
        'ui-logo': 'false',
        'ui-start-screen-info': 'false',
      },
    );
    _controller.loadRequest(url);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return const ColoredBox(color: Colors.black);
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: Colors.black),
        // En móvil el toque pasa al PageView/gestos de Flutter (IgnorePointer).
        IgnorePointer(child: WebViewWidget(controller: _controller)),
        const IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Color(0xDD000000), Colors.transparent],
                stops: [0, 0.5],
              ),
            ),
          ),
        ),
        // En Flutter Web el iframe se traga la rueda del mouse y los clics;
        // PointerInterceptor + Listener se los devuelven al PageView.
        Positioned.fill(
          child: PointerInterceptor(
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerSignal: widget.onPointerSignal,
              onPointerDown: widget.onPointerDown,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onDoubleTap: widget.onDoubleTap,
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
        if (_loading)
          const IgnorePointer(
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        if (_error != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ),
        Positioned(
          bottom: 50,
          left: 20,
          child: PointerInterceptor(
            child: ExpandableCaption(
              title: widget.caption,
              description: widget.description,
            ),
          ),
        ),
      ],
    );
  }
}
