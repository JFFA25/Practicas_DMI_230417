import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toktik/infrastructure/services/youtube_data_api.dart';
import 'package:toktik/presentation/providers/discover_provider.dart';
import 'package:toktik/presentation/widgets/shared/video_scrollable_view.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  late final TextEditingController _queryController;

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController(
      text: YoutubeDataApi.defaultSearchQuery,
    );
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

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
                  Material(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(28),
                    child: TextField(
                      controller: _queryController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _search(context),
                      decoration: InputDecoration(
                        hintText: 'Buscar Shorts',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          tooltip: 'Buscar videos',
                          onPressed: () => _search(context),
                          icon: const Icon(Icons.arrow_forward),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
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
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            discoverProvider.statusMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12),
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
              top: 76,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(minHeight: 2),
            ),
        ],
      ),
    );
  }

  void _search(BuildContext context) {
    context.read<DiscoverProvider>().searchVideos(_queryController.text);
  }
}
