import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cinemapedia/config/i18n/app_language.dart';

/// Idioma actual de la app (textos + datos de la API).
/// Al cambiarlo se reconstruyen los repositorios y se recargan las películas.
final languageProvider = StateProvider<AppLanguage>((ref) => AppLanguages.defaultLanguage);
