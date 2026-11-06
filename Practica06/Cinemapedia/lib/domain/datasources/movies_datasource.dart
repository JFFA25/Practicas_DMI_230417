import 'package:cinemapedia/domain/entities/entities.dart';


abstract class MoviesDatasource {

  Future<List<Movie>> getNowPlaying({ int page = 1 });

  Future<List<Movie>> getPopular({ int page = 1 });

  Future<List<Movie>> getUpcoming({ int page = 1 });

  Future<List<Movie>> getTopRated({ int page = 1 });
  
  Future<Movie> getMovieById( String id );

  Future<List<Movie>> searchMovies( String query );

  Future<List<Movie>> getSimilarMovies( int movieId );

  Future<List<Video>> getYoutubeVideosById( int movieId );

  /// Clasificación de edad de la película en el país del idioma elegido.
  /// Devuelve '' si ese país no tiene clasificación.
  Future<String> getCertification( int movieId );
}