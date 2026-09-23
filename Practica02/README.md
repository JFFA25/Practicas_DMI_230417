# Práctica 02: Counter Functions

Aplicación móvil desarrollada con Flutter como parte de la materia de Desarrollo Móvil. El proyecto implementa un contador interactivo y muestra cómo administrar el estado de una interfaz con `StatefulWidget` y `setState`.

## Objetivo

Construir una primera aplicación funcional en Flutter que permita modificar el valor de un contador mediante acciones independientes:

- Incrementar el contador en una unidad.
- Disminuir el contador en una unidad.
- Restablecer el contador a cero.
- Cambiar el color del valor según su estado.

## Funcionalidades

La pantalla principal, `Counter Functions`, incluye tres botones flotantes:

| Botón | Acción |
| --- | --- |
| Reiniciar | Establece el contador en `0`. |
| Incrementar | Aumenta el valor en `1`. |
| Disminuir | Reduce el valor en `1`. |

El color del contador se actualiza de forma dinámica:

- **Azul:** el valor es igual a `0`.
- **Verde:** el valor es positivo.
- **Rojo:** el valor es negativo.

También se utiliza la fuente personalizada `tf2build.ttf` para el título, el contador y la etiqueta de la pantalla.

## Tecnologías utilizadas

- Flutter
- Dart
- Material Design 3
- `StatefulWidget` y `setState`
- `FloatingActionButton`
- Fuente personalizada incluida en los assets

## Estructura principal

```text
flutter_application_1/
├── assets/fonts/tf2build.ttf
├── images/
│   ├── cap1.png
│   ├── cap2.png
│   └── cap3.png
├── lib/
│   ├── main.dart
│   └── presentation/counter/counter_functions_screen.dart
├── test/widget_test.dart
└── pubspec.yaml
```

La aplicación inicia en `main.dart`, donde se configura `MaterialApp` y se carga `CounterFunctionsScreen`. La lógica del contador y la interfaz se encuentran en la pantalla ubicada dentro de `presentation/counter`.

## Evidencia de funcionamiento

| Estado inicial | Contador positivo | Contador negativo |
|:---:|:---:|:---:|
| ![Estado inicial](./flutter_application_1/images/cap1.png) | ![Contador positivo](./flutter_application_1/images/cap2.png) | ![Contador negativo](./flutter_application_1/images/cap3.png) |

## Requisitos

- Flutter instalado y configurado en el equipo.
- Dart incluido en el SDK de Flutter.
- Un dispositivo físico, emulador o navegador compatible.

## Instalación y ejecución

Desde la carpeta `Practica02`, ejecuta:

```bash
cd flutter_application_1
flutter pub get
flutter run
```

Para ejecutar las pruebas:

```bash
flutter test
```

## Conclusión

Esta práctica permitió crear una interfaz móvil sencilla y funcional, gestionar el estado de un contador y responder a las interacciones del usuario. Además, la separación de la pantalla en `presentation/counter` establece una estructura inicial para organizar futuras funcionalidades.

## Autor

**Jose Francisco Flores Amador**
