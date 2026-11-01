import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:go_router/go_router.dart';


class MoviesSlideshow extends StatefulWidget {
  
  final List<Movie> movies;
  
  const MoviesSlideshow({
    super.key, 
    required this.movies
  });

  @override
  State<MoviesSlideshow> createState() => _MoviesSlideshowState();
}

class _MoviesSlideshowState extends State<MoviesSlideshow> {

  final SwiperController _controller = SwiperController();

  @override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      height: 210,
      width: double.infinity,
      child: Stack(
        children: [

          Swiper(
            controller: _controller,
            viewportFraction: 0.8,
            scale: 0.9,
            autoplay: true,
            pagination: SwiperPagination(
              margin: const EdgeInsets.only(top: 0),
              builder: DotSwiperPaginationBuilder(
                activeColor: colors.primary,
                color: colors.secondary
              )
            ),
            itemCount: widget.movies.length,
            itemBuilder: (context, index) => _Slide(movie: widget.movies[index] ),
          ),

          // Flechas para cambiar de película (el bottom: 30 compensa el espacio de los puntos)
          Positioned.fill(
            bottom: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ArrowButton(
                  icon: Icons.chevron_left_rounded,
                  tooltip: 'Anterior',
                  onPressed: () => _controller.previous(),
                ),
                _ArrowButton(
                  icon: Icons.chevron_right_rounded,
                  tooltip: 'Siguiente',
                  onPressed: () => _controller.next(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _ArrowButton extends StatelessWidget {

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _ArrowButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Center(
        child: Material(
          color: Colors.black54,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: IconButton(
            tooltip: tooltip,
            onPressed: onPressed,
            icon: Icon(icon, color: Colors.white, size: 30),
          ),
        ),
      ),
    );
  }
}


class _Slide extends StatelessWidget {

  final Movie movie;

  const _Slide({required this.movie});

  @override
  Widget build(BuildContext context) {

    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: Colors.black45,
          blurRadius: 10,
          offset: Offset(0, 10)
        )
      ]
    );

      
    return Padding(
      padding: const EdgeInsets.only( bottom: 30 ),
      child: DecoratedBox(
        decoration: decoration,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: GestureDetector(
            onTap: () => context.push('/home/0/movie/${ movie.id }'),
            child: FadeInImage(
              fit: BoxFit.cover,
              placeholder: const AssetImage('assets/loaders/bottle-loader.gif'),
              image: NetworkImage(movie.backdropPath),
            ),
          )
        )
      ),
    );
  }
}
