import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cinemapedia/presentation/providers/series/series_providers.dart';
import 'package:cinemapedia/presentation/providers/settings/catalog_type_provider.dart';

import 'movies_providers.dart';

/// true mientras faltan por cargar las listas del catálogo que se está viendo
/// (películas o series).
final initialLoadingProvider = Provider<bool>((ref) {

  final isSeries = ref.watch( catalogTypeProvider ) == CatalogType.series;

  final step1 = ref.watch( isSeries ? onTheAirSeriesProvider : nowPlayingMoviesProvider ).isEmpty;
  final step2 = ref.watch( isSeries ? popularSeriesProvider : popularMoviesProvider ).isEmpty;
  final step3 = ref.watch( isSeries ? topRatedSeriesProvider : topRatedMoviesProvider ).isEmpty;
  final step4 = ref.watch( isSeries ? airingTodaySeriesProvider : upcomingMoviesProvider ).isEmpty;

  if( step1 || step2 || step3 || step4 ) return true;

  return false; // terminamos de cargar
});
