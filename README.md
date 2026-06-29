# iTunes App - Reproductor de Música Minimalista

## Descripción

Aplicación de música minimalista inspirada en iTunes con diseño glassmorphism moderno. Reproduce archivos MP3 y formatos de audio compatibles, permite modificar metadatos y recortar pistas de audio.

## Características

- **Reproducción de Audio**: MP3, FLAC, OGG, WAV, AAC
- **Editor de Metadatos**: Modificar título, artista, álbum, año, carátula
- **Recorte de Audio**: Recortar pistas largas con interfaz visual
- **Biblioteca**: Organizar por álbumes, artistas, playlists
- **Diseño Glass**: Efectos de vidrio esmerilado modernos
- **Minimalista**: Interfaz limpia y elegante tipo iTunes

## Requisitos

- Flutter SDK >= 3.0.0
- Android SDK / Xcode para móvil
- Archivo `libmp3lame.so` o dependencias de FFmpeg en `/android/app/src/main/jniLibs/`

## Dependencias Principales

```yaml
dependencies:
  just_audio: ^0.9.36          # Reproductor de audio
  audio_metadata_extract: ^2.0.0  # Leer/editar metadatos
  metadata_editor: ^2.0.0     # Editor de metadatos
  file_picker: ^6.0.0         # Seleccionar archivos
  permission_handler: ^10.0.0 # Permisos de almacenamiento
  path_provider: ^2.0.0       # Rutas del sistema
  audio_waveforms: ^1.0.0     # Waveform visual
```

## Estructura del Proyecto

```
itunes_app/
├── lib/
│   ├── main.dart              # Punto de entrada
│   ├── models/                # Modelos de datos
│   │   ├── song.dart          # Modelo de canción
│   │   └── playlist.dart      # Modelo de playlist
│   ├── screens/               # Pantallas
│   │   ├── home_screen.dart   # Pantalla principal
│   │   ├── player_screen.dart # Pantalla de reproducción
│   │   ├── editor_screen.dart # Editor de metadatos
│   │   └── trimmer_screen.dart # Recortador de audio
│   ├── widgets/               # Componentes UI
│   │   ├── glass_card.dart    # Tarjeta con efecto glass
│   │   ├── player_controls.dart # Controles de reproducción
│   │   ├── waveform_view.dart # Visualización de waveform
│   │   └── metadata_form.dart # Formulario de metadatos
│   ├── services/              # Servicios
│   │   ├── audio_service.dart # Servicio de reproducción
│   │   ├── metadata_service.dart # Servicio de metadatos
│   │   └── file_service.dart  # Servicio de archivos
│   └── utils/                 # Utilidades
│       ├── constants.dart     # Constantes
│       └── helpers.dart       # Funciones auxiliares
├── android/                   # Código Android
├── ios/                       # Código iOS
└── docs/                      # Documentación
```

## Instalación en Android

```bash
# Compilar APK
flutter build apk --release

# Instalar en dispositivo
adb install build/app/outputs/flutter-apk/app-release.apk

# O ejecutar directamente
flutter run
```

## Documentación

Ver `docs/` para documentación completa:
- `docs/ARCHITECTURE.md` - Arquitectura del proyecto
- `docs/API.md` - Documentación de servicios
- `docs/CONTRIBUTING.md` - Guía de contribución
- `docs/CHANGELOG.md` - Historial de cambios
