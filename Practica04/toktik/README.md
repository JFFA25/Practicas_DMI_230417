# Práctica 04 - TokTik

## Objetivo de la práctica

Desarrollar una aplicación de videos cortos con Flutter que integre videos locales y videos de YouTube en un feed vertical. La aplicación reproduce el elemento activo y permite navegar entre videos con gestos y controles en pantalla.

## Diagrama de arquitectura



## Funcionalidades

- Reproducir videos locales y de YouTube en un mismo feed vertical.
- Desplazarse entre videos mediante gestos táctiles.
- Navegar con botones anterior y siguiente; en escritorio también con flechas y rueda del mouse.
- Pausar el video anterior y reproducir el video de la página activa.
- Mostrar likes y vistas para los videos locales.
- Mostrar likes y cantidad de comentarios para los videos de YouTube.
- Consultar comentarios públicos de YouTube.
- Mantener el aspecto original de los videos locales.
- Conservar los videos locales cuando la API no está disponible.

## Tecnologías utilizadas

- Flutter y Dart
- Material Design
- `provider` para administrar el estado del feed
- `video_player` para reproducir videos locales
- `youtube_player_iframe` para reproducir videos de YouTube
- `http` para consultar YouTube Data API v3

## Descripción de la solución

`VideoPost` representa los videos locales y los resultados de YouTube. `DiscoverProvider` carga los videos locales, solicita Shorts a `YoutubeDataApi` y combina ambas listas para mostrarlas en el feed.

`VideoScrollableView` construye el feed con un `PageView` vertical. Según el contenido de cada elemento, utiliza `FullScreenPlayer` para un asset local o `YoutubeFullscreenPlayer` para un video de YouTube. `VideoButtons` presenta las estadísticas y la navegación; para YouTube, permite abrir `VideoCommentsSheet`.

Los datos de los videos locales se encuentran en `lib/shared/data/local_video_post.dart`. Los archivos de video deben colocarse en `assets/videos/` con los nombres `1.mp4` a `8.mp4`.

Para obtener contenido de YouTube, se debe habilitar YouTube Data API v3 en Google Cloud Console y guardar la clave y el término de búsqueda en un archivo local `env.json`:

```json
{
  "YOUTUBE_API_KEY": "TU_CLAVE",
  "YOUTUBE_SEARCH_QUERY": "musica"
}
```

El archivo `env.json` está excluido del repositorio. La clave incluida en una app compilada puede extraerse; debe restringirse a YouTube Data API v3 y, para producción, conviene realizar las solicitudes desde un backend.

## Resultados obtenidos

| Contenido | Reproductor | Información mostrada |
| --- | --- | --- |
| Video local | `video_player` | Likes y vistas |
| Video de YouTube | `youtube_player_iframe` | Likes y comentarios disponibles |

Ambos tipos de contenido se presentan dentro de la pantalla `DiscoverScreen` y comparten la navegación vertical del feed.

## Conclusiones

La práctica integra reproducción de video local, consumo de una API y administración de estado en una sola interfaz. El feed unificado permite alternar entre distintas fuentes de contenido, conservando controles y navegación consistentes.

## Cómo ejecutar el proyecto

Desde la carpeta `yes_no_app`, ejecuta:

```bash
flutter pub get
flutter run
```

## Autor

- Jose Francisco Flores Amador
