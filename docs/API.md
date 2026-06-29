# API - Servicios de iTunes App

## AudioService

Servicio principal de reproducción de audio.

### Propiedades

| Propiedad | Tipo | Descripción |
|-----------|------|-------------|
| `isPlaying` | `bool` | Estado de reproducción |
| `currentSong` | `Song?` | Canción actual |
| `position` | `Duration` | Posición actual |
| `duration` | `Duration` | Duración total |
| `volume` | `double` | Volumen (0.0 - 1.0) |

### Métodos

```dart
// Reproducir canción
Future<void> play(Song song);

// Pausar
Future<void> pause();

// Detener
Future<void> stop();

// Buscar posición
Future<void> seek(Duration position);

// Siguiente canción
Future<void> next();

// Anterior canción
Future<void> previous();

// Establecer volumen
Future<void> setVolume(double volume);

// Liberar recursos
Future<void> dispose();
```

### Ejemplo

```dart
final audioService = AudioService();

// Reproducir canción
await audioService.play(mySong);

// Escuchar cambios
audioService.addListener(() {
  print('Position: ${audioService.position}');
});
```

---

## MetadataService

Servicio para leer y modificar metadatos MP3.

### Métodos

```dart
// Leer metadatos de archivo
Future<SongMetadata> readMetadata(String filePath);

// Guardar metadatos
Future<void> saveMetadata(String filePath, SongMetadata metadata);

// Extraer carátula
Future<Uint8List?> extractCoverArt(String filePath);

// Actualizar carátula
Future<void> updateCoverArt(String filePath, Uint8List coverImage);
```

### Modelo SongMetadata

```dart
class SongMetadata {
  String? title;
  String? artist;
  String? album;
  int? year;
  int? track;
  String? genre;
  String? comment;
  Uint8List? coverArt;
}
```

---

## FileService

Servicio de gestión de archivos.

### Métodos

```dart
// Seleccionar archivos de audio
Future<List<String>> pickAudioFiles();

// Copiar archivo a directorio de app
Future<String> copyToAppDir(String sourcePath);

// Obtener directorio de la app
Future<String> getAppDirectory();

// Obtener directorio de documentos
Future<String> getDocumentsDirectory();

// Eliminar archivo
Future<void> deleteFile(String path);
```

---

## TrimmerService

Servicio de recorte de audio (implementado con FFmpeg).

### Métodos

```dart
// Recortar archivo de audio
Future<String> trimAudio({
  required String inputPath,
  required Duration start,
  required Duration end,
  required String outputPath,
});

// Obtener waveform
Future<List<double>> getWaveform(String filePath);
```
