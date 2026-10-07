import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:provider/provider.dart';
import 'package:toktik/presentation/providers/discover_provider.dart';
import 'package:toktik/presentation/providers/likes_provider.dart';
import 'package:toktik/presentation/providers/theme_provider.dart';
import 'package:toktik/presentation/widgets/shared/video_scrollable_view.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  Future<void> _selectSection(
    BuildContext context,
    VideoFeedSection section,
  ) async {
    final likes = context.read<LikesProvider>();
    await context.read<DiscoverProvider>().loadSection(
      section,
      favorites: likes.favorites,
    );
  }

  Future<void> _showThemeSettings(
    BuildContext context,
    ThemeProvider themes,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                themes.theme.displayText('Tema visual y sonido'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontFamily: themes.theme.displayFontFamily,
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.event_repeat),
                title: const Text('Automático por fecha'),
                subtitle: const Text('Usa la fecha local del dispositivo'),
                trailing: themes.isAutomatic
                    ? const Icon(Icons.check_circle)
                    : null,
                onTap: () async {
                  Navigator.pop(sheetContext);
                  try {
                    await themes.useAutomaticTheme();
                  } catch (error) {
                    if (!context.mounted) return;
                    _showError(context, error);
                  }
                },
              ),
              for (final season in SeasonalTheme.values)
                ListTile(
                  leading: Text(
                    season.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(season.label),
                  trailing: themes.theme == season && !themes.isAutomatic
                      ? const Icon(Icons.check_circle)
                      : null,
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    try {
                      await themes.selectTheme(season);
                    } catch (error) {
                      if (!context.mounted) return;
                      _showError(context, error);
                    }
                  },
                ),
              const Divider(),
              SwitchListTile(
                secondary: const Icon(Icons.music_note),
                title: const Text('Sonido de temporada'),
                subtitle: const Text('Reproduce un aviso al cambiar el tema'),
                value: themes.soundEnabled,
                onChanged: (enabled) async {
                  try {
                    await themes.setSoundEnabled(enabled);
                  } catch (error) {
                    if (sheetContext.mounted) _showError(context, error);
                  }
                },
              ),
              Text(
                'Tema actual: ${themes.theme.icon} ${themes.theme.label}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showError(BuildContext context, Object error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No se pudo guardar la configuración: $error')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final discoverProvider = context.watch<DiscoverProvider>();
    final likesProvider = context.watch<LikesProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final message =
        discoverProvider.statusMessage ??
        themeProvider.errorMessage ??
        likesProvider.errorMessage;

    return Scaffold(
      body: Stack(
        children: [
          if (discoverProvider.videos.isNotEmpty)
            VideoScrollableView(
              // Una vista nueva por sección: siempre empieza en el primer video.
              key: ValueKey(discoverProvider.section),
              videos: discoverProvider.videos,
              loadComments: discoverProvider.getComments,
              scrollDirection: Axis.vertical,
            )
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: discoverProvider.initialLoading
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : Text(
                        discoverProvider.section == VideoFeedSection.favorites
                            ? 'Aún no tienes favoritos.\nToca el corazón para guardar un video.'
                            : discoverProvider.statusMessage ??
                                  'No hay videos disponibles.',
                        textAlign: TextAlign.center,
                      ),
              ),
            ),
          SafeArea(
            // PointerInterceptor: sin esto, en Flutter Web el iframe/video que
            // queda debajo se come los clics de la barra de secciones.
            child: PointerInterceptor(
             child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _SectionButton(
                                label: 'Discover',
                                selected:
                                    discoverProvider.section ==
                                    VideoFeedSection.discover,
                                onPressed: () => _selectSection(
                                  context,
                                  VideoFeedSection.discover,
                                ),
                              ),
                              _SectionButton(
                                label: 'For You',
                                selected:
                                    discoverProvider.section ==
                                    VideoFeedSection.forYou,
                                onPressed: () => _selectSection(
                                  context,
                                  VideoFeedSection.forYou,
                                ),
                              ),
                              _SectionButton(
                                label: 'Favorites',
                                selected:
                                    discoverProvider.section ==
                                    VideoFeedSection.favorites,
                                onPressed: () => _selectSection(
                                  context,
                                  VideoFeedSection.favorites,
                                ),
                                count: likesProvider.favorites.length,
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton.filledTonal(
                        tooltip: 'Elegir tema visual',
                        onPressed: () =>
                            _showThemeSettings(context, themeProvider),
                        icon: Text(
                          themeProvider.theme.icon,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                  if (kDebugMode && !discoverProvider.initialLoading)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Locales: ${discoverProvider.localVideoCount} · '
                        'YouTube: ${discoverProvider.youtubeVideoCount} · '
                        'Giphy: ${discoverProvider.giphyVideoCount} · '
                        'Dailymotion: ${discoverProvider.dailymotionVideoCount}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                        ),
                      ),
                    ),
                  if (message != null && discoverProvider.videos.isNotEmpty)
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
                            message,
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
          ),
          if (discoverProvider.initialLoading &&
              discoverProvider.videos.isNotEmpty)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(minHeight: 2),
            ),
          if (discoverProvider.loadingMoreDiscover)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: LinearProgressIndicator(
                minHeight: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionButton extends StatelessWidget {
  const _SectionButton({
    required this.label,
    required this.selected,
    required this.onPressed,
    this.count,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final season = context.watch<ThemeProvider>().theme;
    final text = count == null ? label : '$label ($count)';
    return Padding(
    padding: const EdgeInsets.only(right: 6),
    child: TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: selected
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.86)
            : Colors.black.withValues(alpha: 0.48),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(
        season.displayText(text),
        style: TextStyle(
          fontFamily: season.displayFontFamily,
          fontSize: season.displayFontFamily == null ? null : 18,
        ),
      ),
    ),
  );
  }
}
