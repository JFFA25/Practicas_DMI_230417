# Toktik - A Flutter Project

## Importante:
Los videos no están incluídos en el repositorio, debido a que son muy pesados y GitHub no lo permite.

Pueden descargar 8 videos de aquí:
[Pexels Free Videos](https://www.pexels.com/search/videos/vertical/)

Renombren esos videos así, ya que es lo que se encuentra en nuestro data source.
```
1.mp4
2.mp4
3.mp4
4.mp4
5.mp4
6.mp4
7.mp4
8.mp4
```

## YouTube Shorts (desarrollo)

La pantalla puede buscar videos públicos con YouTube Data API v3, mostrar sus
vistas y likes, abrir hasta 20 comentarios y reproducirlos con el reproductor
oficial de YouTube. La búsqueda usa `videoDuration=short` y añade `shorts` al
término cuando hace falta. YouTube no ofrece un filtro de Data API que garantice
que cada resultado sea un Short vertical.

1. En Google Cloud Console, habilita YouTube Data API v3 y crea una API key.
2. Restringe la clave a YouTube Data API v3 y al origen web donde se ejecuta la
   aplicación. Las claves incluidas en una app Flutter Web son visibles para sus
   usuarios; no son secretos. Para producción usa un backend que proteja la
   clave.
3. Inicia la aplicación desde esta carpeta:

   ```powershell
   flutter run -d chrome --dart-define=YOUTUBE_API_KEY=TU_CLAVE --dart-define=YOUTUBE_SEARCH_QUERY=musica
   ```

   El campo de búsqueda de la pantalla permite cambiar el término mientras la
   app está abierta. Sin una clave, se mantiene el feed local y se muestra un
   aviso de configuración.

La API entrega métricas públicas; dar like o publicar comentarios requiere
autenticación OAuth y no está habilitado por una API key. Algunos videos no
permiten comentarios. La reproducción incrustada está disponible en Chrome y
otras plataformas compatibles con `youtube_player_iframe`; Windows de escritorio
no es una plataforma soportada por ese reproductor.
