# cinemapedia

App de películas en Flutter (The Movie DB, Riverpod, go_router, Isar).

## Requisitos

- **Flutter estable reciente** (el proyecto está configurado con la plantilla de Flutter 3.47: Dart ^3.10, Gradle 9.3.1, AGP 9.1.0, Kotlin 2.4.0). Si tu Flutter es más viejo: `flutter upgrade`.
- **JDK 17 o superior** (el que trae Android Studio sirve).
- Android SDK 36 (Android Studio lo instala solo cuando se lo pide el build).

## Dev

1. Crear un archivo `.env` en la raíz con tu API key de The Movie DB:
   ```
   THE_MOVIEDB_KEY=tu_api_key
   ```
2. Instalar dependencias:
   ```
   flutter pub get
   ```
3. Correr en el celular (con depuración USB activada) o en un emulador:
   ```
   flutter devices
   flutter run
   ```

> La web no está soportada: Isar no corre en navegador.

## Cambios en la entidad `Movie` (Isar)

El código generado (`lib/domain/entities/movie.g.dart`) ya viene incluido, así que **no** hace falta correr nada para compilar.
Si algún día modificas la entidad, agrega el generador y vuelve a generar:

```
dart pub add dev:build_runner dev:isar_community_generator:3.4.1
dart run build_runner build --delete-conflicting-outputs
```

## Notas de la actualización

- `isar` / `isar_flutter_libs` (abandonados, no compilan con AGP 8+) → `isar_community` / `isar_community_flutter_libs` (fork mantenido, misma API).
- `Isar.open` ahora recibe `directory` (se usa `path_provider`).
- `go_router`: `state.params` → `state.pathParameters`.
- Android migrado al formato nuevo de Gradle (`*.gradle.kts`, plugins declarativos, `namespace`, Java 17).
- iOS: solo se subió el target mínimo a 13.0; no se migró al nuevo `SceneDelegate` (requiere una Mac para probarlo).
