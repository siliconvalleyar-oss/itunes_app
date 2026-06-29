import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/song.dart';

class MusicScanner {
  static const List<String> _audioExtensions = ['.mp3'];

  Future<List<Song>> scanDevice() async {
    final songs = <Song>[];
    final directories = await _getScanDirectories();

    for (final dir in directories) {
      if (await dir.exists()) {
        await _scanDirectory(dir, songs);
      }
    }

    songs.sort((a, b) => a.title.compareTo(b.title));
    return songs;
  }

  Future<List<Directory>> _getScanDirectories() async {
    final dirs = <Directory>[];

    if (Platform.isAndroid) {
      dirs.addAll([
        Directory('/storage/emulated/0/Music'),
        Directory('/storage/emulated/0/Download'),
        Directory('/storage/emulated/0/DCIM'),
        Directory('/storage/emulated/0/WhatsApp/Media/WhatsApp Audio'),
      ]);
    } else if (Platform.isLinux) {
      final home = Platform.environment['HOME'] ?? '';
      dirs.addAll([
        Directory('$home/Music'),
        Directory('$home/Downloads'),
      ]);
    } else if (Platform.isWindows) {
      final userProfile = Platform.environment['USERPROFILE'] ?? '';
      dirs.addAll([
        Directory('$userProfile\\Music'),
        Directory('$userProfile\\Downloads'),
      ]);
    } else if (Platform.isMacOS) {
      final home = Platform.environment['HOME'] ?? '';
      dirs.addAll([
        Directory('$home/Music'),
        Directory('$home/Downloads'),
      ]);
    }

    try {
      final appDir = await getApplicationDocumentsDirectory();
      dirs.add(appDir);
    } catch (_) {}

    return dirs;
  }

  Future<void> _scanDirectory(Directory dir, List<Song> songs) async {
    try {
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          final ext = entity.path.toLowerCase();
          if (_audioExtensions.any((e) => ext.endsWith(e))) {
            final song = await _fileToSong(entity);
            if (song != null && !songs.any((s) => s.filePath == song.filePath)) {
              songs.add(song);
            }
          }
        }
      }
    } catch (_) {}
  }

  Future<Song?> _fileToSong(File file) async {
    try {
      final stat = await file.stat();
      final name = file.path.split(Platform.pathSeparator).last;
      final title = name.replaceAll(RegExp(r'\.[^.]+$'), '');

      return Song(
        id: file.path.hashCode.toString(),
        filePath: file.path,
        title: title,
        artist: 'Desconocido',
        album: 'Sin álbum',
        fileSize: stat.size,
      );
    } catch (_) {
      return null;
    }
  }
}
