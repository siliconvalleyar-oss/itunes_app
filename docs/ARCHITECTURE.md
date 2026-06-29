# Arquitectura del Proyecto

## Visión General

La app sigue una arquitectura de capas con separación de responsabilidades:

```
┌─────────────────────────────────────────┐
│              UI Layer                   │
│  (Screens, Widgets, Components)         │
├─────────────────────────────────────────┤
│           Business Logic                │
│  (State Management, Services)           │
├─────────────────────────────────────────┤
│            Data Layer                   │
│  (Models, Repositories, Database)       │
├─────────────────────────────────────────┤
│         Platform Layer                  │
│  (Android/iOS Native, FFmpeg)           │
└─────────────────────────────────────────┘
```

## Flujo de Datos

```
User Action → Widget → Service → Database/Storage → Update UI
```

## Modelos de Datos

### Song
```dart
class Song {
  final String id;
  final String filePath;
  final String title;
  final String artist;
  final String album;
  final int? year;
  final Uint8List? coverArt;
  final Duration duration;
  // Metadata adicional
}
```

### Playlist
```dart
class Playlist {
  final String id;
  final String name;
  final List<Song> songs;
  final DateTime createdAt;
}
```

## Servicios Principales

### AudioService
- Reproducir/pausar/stop
- Seek a posición
- Control de volumen
- Callbacks de estado

### MetadataService
- Leer metadatos de archivo
- Guardar metadatos modificados
- Extraer carátula del álbum

### FileService
- Seleccionar archivos
- Copiar a directorio de la app
- Gestionar almacenamiento

## Estado

Se usa `ChangeNotifier` con `Provider` para gestión simple de estado.

## Navegación

Rutas nombradas con `Navigator 2.0`:
- `/` → Home
- `/player` → Player
- `/editor` → Editor
- `/trimmer` → Trimmer
