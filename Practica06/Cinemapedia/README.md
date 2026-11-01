<div align="center">

<img src="assets/icon/app_icon.png" alt="Icono de Cinemapedia" width="140" />

# Cinemapedia

**Tu enciclopedia de Cine, En una sola app.**
Descubre qué hay en cines, qué viene pronto y qué películas son las mejor calificadas.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.10+-0175C2?logo=dart&logoColor=white)
![Riverpod](https://img.shields.io/badge/Estado-Riverpod-8C5A9B)
![Plataformas](https://img.shields.io/badge/Plataformas-Windows%20%7C%20Android%20%7C%20iOS-5F3A70)

</div>

## Sobre la app

**Cinemapedia** es una aplicación de películas hecha con Flutter que consume la API de
[The Movie DB](https://www.themoviedb.org/) en español (`es-MX`). Muestra la cartelera,
los próximos estrenos y las películas mejor calificadas, y permite ver el detalle de cada
película con su reparto, tráilers y películas similares.

## Capturas

<table>
  <tr>
    <th>Pantalla de Carga</th>
    <th>Inicio y Navegación</th>
    <th>Detalles de la Película</th>
    <th>Favoritos</th>
  </tr>
  <tr>
    <td align="center"><img src="assets/images/LoadScreen.gif" alt="Pantalla de Carga" width="210" height="450" style="object-fit: cover;" /></td>
    <td align="center"><img src="assets/images/Inicio.jpeg" alt="Inicio" width="210" height="450" style="object-fit: cover;" /></td>
    <td align="center"><img src="assets/images/Descripcion.jpeg" alt="Detalle" width="210" height="450" style="object-fit: cover;" /></td>
    <td align="center"><img src="assets/images/Favoritos.jpeg" alt="Favoritos" width="210" height="450" style="object-fit: cover;" /></td>
  </tr>
</table>


## Funcionalidades

- **Pantalla de carga animada:** la "C" de Cinemapedia se dibuja sobre fondo negro, aparece el
  nombre y hace zoom hacia la pantalla principal.
- **Carrusel de estrenos** con autoplay y flechas para cambiar de película.
- **Listas horizontales** con scroll infinito: _En cines_, _Próximamente_ y _Mejor calificadas_.
- **Populares** en una vista de cuadrícula tipo masonry.
- **Detalle de película:** sinopsis, géneros, reparto, tráilers de YouTube y películas similares.
- **Búsqueda** de películas con sugerencias en tiempo real.
- **Favoritos** guardados en el dispositivo (base de datos local con Isar).
- **Tema oscuro** con fondo negro puro.

## Icono de la App

El icono de Cinemapedia es una **"C" de papel cortado** en tonos morados, con sombreado de
papel doblado: un tono más oscuro en la punta de abajo y uno más claro en la de arriba, sobre
fondo negro.

<div align="center">

<img src="assets/icon/app_icon.png" alt="Icono de la app" width="220" />

</div>

- Es el mismo dibujo en toda la app: icono del sistema, barra superior, pantalla de carga y
  loader (se dibuja en código con `CustomPainter`, por eso se ve nítido a cualquier tamaño).
- El archivo base en 1024 px está en [`assets/icon/app_icon.png`](assets/icon/app_icon.png).
- Hay versiones para Android (adaptativo), iOS, macOS, Windows (`.ico`) y web.

## Paleta de colores

![Paleta de colores](/Practica06/Cinemapedia/assets/images/Colors.png)

| Color                 |    Hex    | Uso                                                  |
| --------------------- | :-------: | ---------------------------------------------------- |
| Morado base           | `#8C5A9B` | Cuerpo de la "C" y color principal de la marca       |
| Morado oscuro         | `#5F3A70` | Sombra de la punta inferior de la "C"                |
| Morado claro          | `#A97DBB` | Brillo de la punta superior de la "C"                |
| Negro                 | `#000000` | Fondo de la app, de la pantalla de carga y del icono |
| Blanco                | `#FFFFFF` | Textos e iconos sobre fondo oscuro                   |
| Amarillo calificación | `#F9A825` | Estrellas y puntuación de las películas              |

## Tecnologías

| Para qué             | Paquete                       |
| -------------------- | ----------------------------- |
| Estado               | `flutter_riverpod`            |
| Navegación           | `go_router`                   |
| Peticiones HTTP      | `dio`                         |
| Base de datos local  | `isar_community`              |
| Carrusel             | `card_swiper`                 |
| Animaciones          | `animate_do`                  |
| Cuadrícula           | `flutter_staggered_grid_view` |
| Tráilers             | `youtube_player_flutter`      |
| Variables de entorno | `flutter_dotenv`              |
| Fechas               | `intl`                        |

## Requisitos

- **Flutter estable reciente** (el proyecto está configurado con la plantilla de Flutter 3.47:
  Dart ^3.10, Gradle 9.3.1, AGP 9.1.0, Kotlin 2.4.0). Si tu Flutter es más viejo: `flutter upgrade`.
- **JDK 17 o superior** (el que trae Android Studio sirve).
- Android SDK 36 (Android Studio lo instala solo cuando se lo pide el build).
- Una API key gratuita de [The Movie DB](https://www.themoviedb.org/settings/api).

## Cómo ejecutarlo

1. Crea un archivo `.env` en la raíz del proyecto con tu API key:
   ```
   THE_MOVIEDB_KEY=tu_api_key
   ```
2. Instala las dependencias:
   ```
   flutter pub get
   ```
3. Ejecútalo en Windows, en un emulador o en tu celular (con depuración USB activada):
   ```
   flutter devices
   flutter run
   ```

> **La web no está soportada:** Isar no corre en navegador.

## Créditos

- Datos de películas: [The Movie DB](https://www.themoviedb.org/). Esta app usa la API de TMDB
  pero no está avalada ni certificada por TMDB.
- Desarrollado por **Jose Francisco Flores Amador** ([@JFFA25](https://github.com/JFFA25)).
