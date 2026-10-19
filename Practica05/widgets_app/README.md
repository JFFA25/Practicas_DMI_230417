# Práctica 05 — Widgets App

## Objetivo

Desarrollar una aplicación de ejemplo con Flutter para explorar widgets de Material 3, navegación entre pantallas y manejo de estado con Riverpod. Cada sección muestra una interacción o componente distinto dentro de una misma aplicación.


## Diagrama de arquitectura

[Ver el diagrama interactivo en GitHub Pages](https://jffa25.github.io/Practicas_DMI_230417/Practica05/arquitectura/arquitectura-practica05.html)


![Diagrama](/Practica05/arquitectura/arquitectura-practica05.visual-check.1440x900.dark.png)

## Funcionalidades

- **Navegación:** menú lateral y rutas declaradas con `GoRouter` para acceder a las demostraciones.
- **Botones y tarjetas:** variantes de botones de Material, tarjetas con distintos niveles de elevación, estilos y contenido de imágenes.
- **Indicadores de progreso:** indicadores circulares y lineales, incluidos ejemplos con progreso controlado.
- **Mensajes y diálogos:** muestra un `SnackBar`, un diálogo de confirmación y la información de licencias.
- **Animación:** cambia aleatoriamente el tamaño, color y radio de un `AnimatedContainer`.
- **Controles de interfaz:** ejemplos de interruptores, opciones de selección y casillas de verificación.
- **Tutorial:** carrusel de tres pantallas con imágenes locales y opciones para salir o comenzar.
- **Lista con actualización:** carga imágenes de `picsum.photos` al desplazarse y permite actualizar la lista con un gesto de arrastre.
- **Estado con Riverpod:** contador reactivo y selector global de modo claro/oscuro y color de acento.

## Descripción de la solución

`main.dart` inicia la aplicación dentro de `ProviderScope` y configura `MaterialApp.router`. `GoRouter` registra la pantalla de inicio y las diez demostraciones disponibles en el menú lateral.

El tema se construye con Material 3. `ThemeNotifier` mantiene el modo claro u oscuro y el índice de color seleccionado; `MainApp` observa ese estado para aplicar los cambios en toda la interfaz. El contador usa `counterProvider`, cuyo valor inicial es 5.

Las imágenes del tutorial y el indicador de carga se guardan en `assets/images/`. Las pantallas de tarjetas y lista infinita obtienen imágenes de `picsum.photos`.

## Tecnologías utilizadas

- Flutter y Dart
- Material 3
- `flutter_riverpod` para el estado del tema y el contador
- `go_router` para la navegación
- `animate_do` para animaciones de entrada y carga
- Imágenes remotas de `picsum.photos`

## Diagrama de arquitectura

[Ver el diagrama interactivo en GitHub Pages](https://jffa25.github.io/Practicas_DMI_230417/Practica05/arquitectura/arquitectura-practica05.html)

## Evidencia de funcionamiento

Agrega las capturas de la aplicación en los espacios siguientes.

| Inicio y navegación | Demostraciones de widgets | Tema y estado |
|:---:|:---:|:---:|
| *Espacio para captura* | *Espacio para captura* | *Espacio para captura* |

## Cómo ejecutar el proyecto

Desde la carpeta `Practica05/widgets_app`:

```bash
flutter pub get
flutter run
```

## Autor

- Jose Francisco Flores Amador
