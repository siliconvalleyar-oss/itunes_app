import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import '../models/song.dart';

class MetadataService extends ChangeNotifier {
  static const _channel = MethodChannel('com.mimocode.itunes_app/metadata');

  Future<SongMetadata> readMetadata(String filePath) async {
    return SongMetadata(
      title: _extractFileName(filePath),
      artist: 'Artista Desconocido',
      album: 'Álbum Desconocido',
    );
  }

  Future<bool> saveMetadata(Song song, {String? title, String? artist, String? album}) async {
    try {
      // Write to MediaStore database
      await _channel.invokeMethod<bool>('writeMetadata', {
        'contentUri': song.contentUri,
        'title': title,
        'artist': artist,
        'album': album,
      });

      // Write actual ID3 tags to the file
      await _channel.invokeMethod<bool>('writeId3Tags', {
        'filePath': song.filePath,
        'title': title,
        'artist': artist,
        'album': album,
      });

      return true;
    } catch (e) {
      debugPrint('Error saving metadata: $e');
      return false;
    }
  }

  Future<Uint8List?> extractCoverArt(String filePath) async {
    return null;
  }

  Future<void> updateCoverArt(String filePath, Uint8List coverImage) async {
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
