import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cinemapedia/config/helpers/human_formats.dart';
import 'package:cinemapedia/config/i18n/app_strings.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';
import 'package:cinemapedia/presentation/widgets/widgets.dart';


class HomeView extends ConsumerStatefulWidget {
  const HomeView({ super.key });

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends ConsumerState<HomeView> with AutomaticKeepAliveClientMixin {

  @override
  void initState() {
    super.initState();
    _loadFirstPages();
  }

  void _loadFirstPages() {
    ref.read( nowPlayingMoviesProvider.notifier ).loadNextPage();
    ref.read( popularMoviesProvider.notifier ).loadNextPage();
    ref.read( topRatedMoviesProvider.notifier ).loadNextPage();
    ref.read( upcomingMoviesProvider.notifier ).loadNextPage();
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);

    //* Al cambiar de idioma los providers se reinician: hay que volver a pedir los datos
    ref.listen( languageProvider, (previous, next) {
      if ( previous == next ) return;

      // En un microtask para que Riverpod ya haya recreado los providers
      // con el nuevo idioma antes de pedir la primera página.
      Future.microtask(() {
        if ( mounted ) _loadFirstPages();
      });
    });

    final t = AppStrings.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;

    final initialLoading = ref.watch(initialLoadingProvider);
    if ( initialLoading ) return const FullScreenLoader();
    
    final slideShowMovies = ref.watch( moviesSlideshowProvider );
    final nowPlayingMovies = ref.watch( nowPlayingMoviesProvider );
    final topRatedMovies = ref.watch( topRatedMoviesProvider );
    final upcomingMovies = ref.watch( upcomingMoviesProvider );

    return CustomScrollView(
      slivers: [

        const SliverAppBar(
          floating: true,
          flexibleSpace: FlexibleSpaceBar(
            title: CustomAppbar(),
          ),
        ),


        SliverList(delegate: SliverChildBuilderDelegate(
          (context, index) {
              return Column(
                  children: [
              
                    // const CustomAppbar(),
              
                    MoviesSlideshow(movies: slideShowMovies ),
              
                    MovieHorizontalListview(
                      movies: nowPlayingMovies,
                      title: t.nowPlaying,
                      subTitle: HumanFormats.today(languageCode),
                      loadNextPage: () =>ref.read(nowPlayingMoviesProvider.notifier).loadNextPage()
                      
                    ),
              
                    MovieHorizontalListview(
                      movies: upcomingMovies,
                      title: t.upcoming,
                      subTitle: t.upcomingSub,
                      loadNextPage: () =>ref.read(upcomingMoviesProvider.notifier).loadNextPage()
                    ),
              
                    //* Ya no estará aquí, ahora es parte del menú inferior
                    // MovieHorizontalListview(
                    //   movies: popularMovies,
                    //   title: 'Populares',
                    //   // subTitle: '',
                    //   loadNextPage: () =>ref.read(popularMoviesProvider.notifier).loadNextPage()
                    // ),
              
                    MovieHorizontalListview(
                      movies: topRatedMovies,
                      title: t.topRated,
                      subTitle: t.topRatedSub,
                      loadNextPage: () =>ref.read(topRatedMoviesProvider.notifier).loadNextPage()
                    ),

                    const SizedBox( height: 10 ),
              
              
                  ],
                );
          },
          childCount: 1
        )),

      ]
    );
  }
  
  @override
  bool get wantKeepAlive => true;
}