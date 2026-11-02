import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cinemapedia/config/i18n/app_language.dart';
import 'package:cinemapedia/config/i18n/app_strings.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';
import 'package:cinemapedia/presentation/widgets/shared/cinemapedia_logo.dart';
import 'package:cinemapedia/presentation/widgets/shared/flag_icon.dart';

/// Menú lateral (drawer). Se abre con el botón de la barra o deslizando
/// desde el borde de la pantalla, y se cierra deslizando hacia el borde.
class SideMenu extends ConsumerWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final t = AppStrings.of(context);
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final current = ref.watch(languageProvider);

    return Drawer(
      backgroundColor: Colors.black,
      surfaceTintColor: Colors.transparent,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            //* Cabecera con el logo
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Row(
                children: [
                  const CinemapediaLogo(size: 44),
                  const SizedBox(width: 12),
                  Text('Cinemapedia', style: textStyles.titleLarge),
                ],
              ),
            ),

            const Divider(height: 32),

            //* Título de la sección
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.language_rounded, color: colors.primary),
                  const SizedBox(width: 10),
                  Text(t.language, style: textStyles.titleMedium),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Text(
                t.chooseLanguage,
                style: textStyles.bodySmall?.copyWith(color: Colors.white60),
              ),
            ),

            //* Lista de idiomas con bandera
            for (final language in AppLanguages.all)
              _LanguageTile(
                language: language,
                selected: language == current,
                onTap: () {
                  ref.read(languageProvider.notifier).state = language;
                  Navigator.of(context).pop(); // cierra el menú
                },
              ),
          ],
        ),
      ),
    );
  }
}


class _LanguageTile extends StatelessWidget {

  final AppLanguage language;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.language,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme;

    return ListTile(
      selected: selected,
      selectedColor: colors.primary,
      selectedTileColor: Colors.white10,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: FlagIcon(country: language.country, width: 42),
      title: Text(language.label),
      trailing: selected ? const Icon(Icons.check_rounded) : null,
      onTap: onTap,
    );
  }
}
