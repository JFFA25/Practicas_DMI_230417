<div align="center">

<img src="assets/icon/app_icon.png" alt="Icono de Cinemapedia" width="150" />

# Cinemapedia

**Tu enciclopedia de cine, en una sola app.**
Descubre qué hay en cines, qué viene pronto y qué películas son las mejor calificadas, en 5 idiomas.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.10+-0175C2?logo=dart&logoColor=white)
![Riverpod](https://img.shields.io/badge/Estado-Riverpod-8C5A9B)
![Plataformas](https://img.shields.io/badge/Plataformas-Windows%20%7C%20Android%20%7C%20iOS-5F3A70)
![Idiomas](https://img.shields.io/badge/Idiomas-ES%20%7C%20EN%20%7C%20DE%20%7C%20ZH%20%7C%20AR-A97DBB)

<br />

[![Probar en Appetize](https://img.shields.io/badge/Probar%20la%20app%20en%20Appetize-8C5A9B?style=for-the-badge&logo=android&logoColor=white)](https://appetize.io/app/b_dqbrzni6n2opryfcgrwoifjnvq)

</div>

## Contenido

- [Sobre la app](#sobre-la-app)
- [Probar la app en línea](#probar-la-app-en-línea-appetize)
- [Capturas](#capturas)
- [Funcionalidades](#funcionalidades)
- [Idiomas de la app](#idiomas-de-la-app)
- [Icono de la app](#icono-de-la-app)
- [Paleta de colores](#paleta-de-colores)
- [Tecnologías](#tecnologías)
- [Arquitectura](#arquitectura)
- [Requisitos](#requisitos)
- [Cómo ejecutarlo](#cómo-ejecutarlo)
- [Generar el APK](#generar-el-apk)
- [Créditos](#créditos)


## Sobre la app

**Cinemapedia** es una aplicación de películas hecha con Flutter que consume la API de
[The Movie DB](https://www.themoviedb.org/). Muestra la cartelera, los próximos estrenos y las
películas mejor calificadas, y permite ver el detalle de cada película con su reparto, tráilers y
películas similares.

La app está disponible en **5 idiomas** (español de México, inglés, alemán, chino y árabe) y se
cambia desde el menú lateral: se traducen tanto los textos de la app como los datos de las
películas que llegan de la API.

## Probar la app en línea (Appetize)

No necesitas instalar nada: puedes abrir Cinemapedia en un celular Android virtual directamente
desde el navegador.

<div align="center">

### [**Abrir Cinemapedia en Appetize**](https://appetize.io/app/b_dqbrzni6n2opryfcgrwoifjnvq)

[Cinemapedia](https://appetize.io)


</div>

| Dato                | Valor                         |
| ------------------- | ----------------------------- |
| **Plataforma**      | Android                       |
| **Paquete**         | `com.example.cinemapedia`     |
| **Archivo**         | `Cinemapedia.apk` (release)   |

> El plan gratuito de Appetize limita el tiempo de uso por sesión y por mes. Si la sesión no
> inicia, es posible que ya se hayan agotado los minutos del mes.

## Cinemapedia v0.1.0 en Appetize

![Cinemapedia APK - Appetize ](/assets/images/Cinemapedia-Appetize.png)

Captura de pantalla de la plataforma Appetize.io que muestra el panel de administración de la aplicación "Cinemapedia" (paquete com.example.cinemapedia). Se observa el detalle de la versión 0.1.0, el historial de compilación (Build History) con una carga registrada el 5 de noviembre de 2026, y los controles de simulación listos para iniciar la prueba del APK.

## Capturas

<div align="center">

| Pantalla de carga | Inicio y navegación | Detalle de la película |
| :---: | :---: | :---: |
| <img src="assets/images/LoadScreen.gif" alt="Pantalla de carga" width="215" /> | <img src="assets/images/Inicio.jpeg" alt="Inicio" width="215" /> | <img src="assets/images/Descripcion.jpeg" alt="Detalle" width="215" /> |

| Elenco | Favoritos | Menú lateral |
| :---: | :---: | :---: |
| <img src="assets/images/Detalles.jpeg" alt="Elenco" width="215" /> | <img src="assets/images/Favoritos.jpeg" alt="Favoritos" width="215" /> | <img src="assets/images/Menu.jpeg" alt="Menú lateral" width="215" /> |

</div>

### Idiomas

La app cambia de idioma desde el menú lateral, y se traducen los textos y los datos de las películas.

<div align="center">

| MX (Español) | US (English) | DE (Deutsch) |
| :---: | :---: | :---: |
| <img src="assets/images/Inicio.jpeg" alt="Español" width="215" /> | <img src="assets/images/English.jpeg" alt="English" width="215" /> | <img src="assets/images/Aleman.jpeg" alt="Deutsch" width="215" /> |

| CN (中文) | EG (العربية) |  APK |
| :---: | :---: | :---: |
| <img src="assets/images/Chino.jpeg" alt="中文" width="215" /> | <img src="assets/images/Arabe.jpeg" alt="العربية" width="215" /> | <img src="assets/images/APK.jpeg" alt="APK" width="215" /> |

</div>

## Funcionalidades

- **Pantalla de carga animada:** la "C" de Cinemapedia se dibuja sobre fondo negro, aparece el
  nombre y hace zoom hacia la pantalla principal. Mientras cargan las películas, la "C" late
  en el centro de la pantalla.
- **Carrusel de estrenos** con autoplay y flechas para cambiar de película.
- **Listas horizontales** con scroll infinito: _En cines_, _Próximamente_ y _Mejor calificadas_.
- **Populares** en una vista de cuadrícula tipo masonry.
- **Detalle de película:** sinopsis, géneros, reparto, tráilers de YouTube y películas similares.
- **Búsqueda** de películas con sugerencias en tiempo real.
- **Favoritos** guardados en el dispositivo (base de datos local con Isar).
- **Menú lateral** que se abre con el botón de la barra o deslizando desde el borde de la pantalla.
- **Selector de idioma** con banderas: español, inglés, alemán, chino y árabe (ver [Idiomas](#idiomas-de-la-app)).
- **Tema oscuro** con fondo negro puro y acentos morados.

## Idiomas de la app

Al elegir un idioma en el menú lateral cambia **todo**: los textos de la app (menú inferior,
secciones, búsqueda, favoritos, pantalla de carga, detalle) y los datos de la API (títulos,
sinopsis, géneros, reparto y tráilers). Las películas se recargan solas con el nuevo idioma.

| Bandera | Idioma  | Código API |
| :-----: | ------- | :--------: |
| MX    | Español |  `es-MX`   |
| US    | English |  `en-US`   |
| DE    | Deutsch |  `de-DE`   |
| CN    | 中文    |  `zh-CN`   |
| EG    | العربية |  `ar-EG`   |

- **Respaldo en inglés:** si una película no tiene traducción en el idioma elegido, The Movie DB
  devuelve el título original y la sinopsis vacía. En ese caso la app pide también la versión en
  inglés y la usa como respaldo.
- **Diseño de izquierda a derecha:** la pantalla no se voltea, ni siquiera en árabe.
- **Fechas:** el formato de fecha del detalle y la etiqueta del día en _En cines_ siguen el idioma elegido.
- El idioma elegido no se guarda: al cerrar la app vuelve a español (MX).
- Los favoritos conservan el título y la sinopsis en el idioma en que se guardaron.

<details>
<summary><b>Cómo agregar otro idioma</b></summary>

<br />

1. Agrégalo a la lista `AppLanguages.all` en `lib/config/i18n/app_language.dart`.
2. Agrega sus textos en `lib/config/i18n/app_strings.dart` (mapa `_values` y lista `supportedCodes`).
3. Si usa una bandera nueva, dibújala en `lib/presentation/widgets/shared/flag_icon.dart`.

</details>

## Icono de la app

El icono de Cinemapedia es una **"C" de papel cortado** en tonos morados, con sombreado de
papel doblado: un tono más oscuro en la punta de abajo y uno más claro en la de arriba, sobre
fondo negro.

<div align="center">

<img src="assets/icon/app_icon.png" alt="Icono de la app" width="220" />

</div>

- Es el mismo dibujo en toda la app: icono del sistema, barra superior, menú lateral y pantalla
  de carga (se dibuja en código con `CustomPainter`, por eso se ve nítido a cualquier tamaño).
- **Icono adaptativo en Android:** la "C" está centrada y dentro de la zona segura, así que se ve
  completa y pareja con cualquier forma de icono (círculo, cuadrado, squircle, etc.).
- El loader de los pósters (`assets/loaders/bottle-loader.gif`) también está en morado.
- El archivo base en 1024 px está en [`assets/icon/app_icon.png`](assets/icon/app_icon.png).
- Hay versiones para Android (adaptativo), iOS, macOS, Windows (`.ico`) y web.

## Paleta de colores

![Paleta de colores](assets/images/Colors.png)

| Color                     |     Hex      | Uso                                                                                                                 |
| :------------------------ | :----------: | :------------------------------------------------------------------------------------------------------------------ |
| **Morado base**           | `#8C5A9B` | Cuerpo de la "C", color de la marca y semilla del tema                                                              |
| **Morado oscuro**         | `#5F3A70` | Sombra de la punta inferior de la "C"                                                                               |
| **Morado claro**          | `#A97DBB` | Brillo de la punta superior de la "C" y color principal de la interfaz (puntos del carrusel, menú inferior, iconos) |
| **Negro**                 | `#000000` | Fondo de la app, de la pantalla de carga y del icono                                                                |
| **Blanco**                | `#FFFFFF` | Textos e iconos sobre fondo oscuro                                                                                  |
| **Amarillo calificación** | `#F9A825` | Estrellas y puntuación de las películas                                                                             |

## Tecnologías

| Para qué             | Paquete                          |
| -------------------- | -------------------------------- |
| Estado               | `flutter_riverpod`               |
| Navegación           | `go_router`                      |
| Peticiones HTTP      | `dio`                            |
| Base de datos local  | `isar_community`                 |
| Carrusel             | `card_swiper`                    |
| Animaciones          | `animate_do`                     |
| Cuadrícula           | `flutter_staggered_grid_view`    |
| Tráilers             | `youtube_player_flutter`         |
| Variables de entorno | `flutter_dotenv`                 |
| Fechas e idiomas     | `intl` y `flutter_localizations` |

## Arquitectura

**[Ver el diagrama interactivo en GitHub Pages](https://jffa25.github.io/Practicas_DMI_230417/Practica06/Arquitectura/Arquitectura_de_Cinemapedia.html)**: vistas guiadas (flujo de películas, cambio de idioma, favoritos, pósters y tráiler), detalle de cada caja y modo presentación.

<div align="center">

<a href="https://jffa25.github.io/Practicas_DMI_230417/Practica06/Arquitectura/Arquitectura_de_Cinemapedia.html">
  <img src="../Arquitectura/Arquitectura-Cinemapedia-dark.png" alt="Diagrama de arquitectura de Cinemapedia" width="900" />
</a>

</div>

La app se divide en capas: **configuración y arranque**, **presentación y estado** (pantallas, vistas,
widgets y providers de Riverpod), **dominio e infraestructura** (contratos, repositorios, datasources y
mappers), **servicios externos** (The Movie DB, imágenes de TMDB y YouTube) y **almacenamiento local**
con Isar. Los providers piden las películas al repositorio, que las trae de The Movie DB y las
convierte a entidades con mappers.

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

## Generar el APK

Desde la raíz del proyecto, en PowerShell, este comando genera el APK y lo copia al escritorio como
`Cinemapedia.apk`:

```powershell
flutter build apk --release; if ($?) { Copy-Item build\app\outputs\flutter-apk\app-release.apk "$([Environment]::GetFolderPath('Desktop'))\Cinemapedia.apk" -Force }
```

El archivo original queda en `build/app/outputs/flutter-apk/app-release.apk`.

> **Para subirlo a Appetize** usa el APK completo, sin `--split-per-abi`. Ese parámetro genera un
> APK por arquitectura y Appetize puede no abrirlo. Súbelo en <https://appetize.io/upload> o por
> su API.

> El `.env` va dentro del APK, así que no lo subas a una tienda pública. Además, el APK sale
> firmado con la llave de depuración: sirve para instalarlo y mostrarlo, no para publicarlo.

## Créditos

- Datos de películas: [The Movie DB](https://www.themoviedb.org/). Esta app usa la API de TMDB
  pero no está avalada ni certificada por TMDB.
- Desarrollado por **Jose Francisco Flores Amador** ([@JFFA25](https://github.com/JFFA25)).