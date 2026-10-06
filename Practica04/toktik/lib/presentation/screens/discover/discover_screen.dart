import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toktik/presentation/providers/discover_provider.dart';
import 'package:toktik/presentation/widgets/shared/video_scrollable_view.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  @override
  Widget build(BuildContext context) {
    final discoverProvider = context.watch<DiscoverProvider>();

    return Scaffold(
      body: Stack(
        children: [
          if (discoverProvider.videos.isNotEmpty)
            VideoScrollableView(
              videos: discoverProvider.videos,
              loadComments: discoverProvider.getComments,
            )
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: discoverProvider.initialLoading
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : Text(
                        discoverProvider.statusMessage ??
                            'No hay videos disponibles.',
                        textAlign: TextAlign.center,
                      ),
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (kDebugMode && !discoverProvider.initialLoading)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Locales: ${discoverProvider.localVideoCount} · '
                        'YouTube: ${discoverProvider.youtubeVideoCount}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  if (discoverProvider.statusMessage != null &&
                      discoverProvider.videos.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Material(
                        color: Colors.black.withValues(alpha: 0.72),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Text(
                            discoverProvider.statusMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (discoverProvider.initialLoading &&
              discoverProvider.videos.isNotEmpty)
            const Positioned(
              top: 8,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(minHeight: 2),
            ),
        ],
      ),
    );
  }
}
