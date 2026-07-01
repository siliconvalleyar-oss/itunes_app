import 'package:flutter/foundation.dart';

class MetadataService extends ChangeNotifier {
  Future<SongMetadata> readMetadata(String filePath) async {
    // Placeholder - integrar con paquete de metadatos real
    // Por ejemplo: audio_metadata_extract o tag
    return SongMetadata(
      title: _extractFileName(filePath),
      artist: 'Artista Desconocido',
      album: 'Álbum Desconocido',
    );
  }

  Future<void> saveMetadata(String filePath, SongMetadata metadata) async {
    // Placeholder - integrar con paquete de metadatos real
    debugPrint('Guardando metadatos en: $filePath');
    debugPrint('Título: ${metadata.title}');
    debugPrint('Artista: ${metadata.artist}');
    notifyListeners();
  }

  Future<Uint8List?> extractCoverArt(String filePath) async {
    // Placeholder - extraer carátula del archivo
    return null;
  }

  Future<void> updateCoverArt(String filePath, Uint8List coverImage) async {
    // Placeholder - actualizar carátula
    debugPrint('Actualizando carátula en: $filePath');
    notifyListeners();
  }

  String _extractFileName(String path) {
    final parts = path.split('/');
    final fileName = parts.last;
    return fileName.replaceAll(RegExp(r'\.[^.]+$'), '');
  }
}

class SongMetadata {
  String? title;
  String? artist;
  String? album;
  int? year;
  int? track;
  String? genre;
  String? comment;
  Uint8List? coverArt;

  SongMetadata({
    this.title,
    this.artist,
    this.album,
    this.year,
    this.track,
    this.genre,
    this.comment,
    this.coverArt,
  });
}
