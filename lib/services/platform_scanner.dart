import 'dart:io';
import 'package:flutter/services.dart';
import '../models/song.dart';

class PlatformScanner {
  static const _channel = MethodChannel('com.mimocode.itunes_app/scanner');

  static final _excludePatterns = [
    '/WhatsApp/',
    '/WhatsApp Audio/',
    '/Telegram/',
    '/Notifications/',
    '/Alarms/',
    '/Ringtones/',
    '/recordings',
    '/Voice Recorder',
  ];

  static Future<List<Song>> scanAudioFiles() async {
    try {
      final result = await _channel.invokeMethod<List<dynamic>>('getAudioFiles');
      if (result == null) return [];

      return result
          .map((item) {
            final map = Map<String, dynamic>.from(item as Map);
            return Song(
              id: map['id'].toString(),
              filePath: map['filePath'] ?? '',
              contentUri: map['contentUri'] ?? '',
              title: map['title'] ?? 'Desconocido',
              artist: map['artist'] ?? 'Desconocido',
              album: map['album'] ?? 'Sin álbum',
              duration: Duration(milliseconds: (map['duration'] as num?)?.toInt() ?? 0),
              fileSize: (map['size'] as num?)?.toInt(),
            );
          })
          .where((s) => _isMusicFile(s))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static bool _isMusicFile(Song song) {
    final path = song.filePath.toLowerCase();
    final uri = song.contentUri.toLowerCase();

    if (!path.endsWith('.mp3') && !uri.endsWith('.mp3')) return false;

    for (final pattern in _excludePatterns) {
      if (path.contains(pattern.toLowerCase())) return false;
    }

    return true;
  }
}
