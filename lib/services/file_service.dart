import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/song.dart';

class FileService {
  Future<List<String>> pickAudioFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'flac', 'ogg', 'wav', 'aac', 'm4a'],
      allowMultiple: true,
    );

    if (result == null) return [];
    return result.files.map((file) => file.path!).toList();
  }

  Future<List<Song>> loadSongsFromPaths(List<String> paths) async {
    final songs = <Song>[];
    for (final path in paths) {
      final file = File(path);
      if (await file.exists()) {
        songs.add(Song(
          id: path.hashCode.toString(),
          filePath: path,
          title: _getFileName(path),
        ));
      }
    }
    return songs;
  }

  Future<String> getAppDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<String> getAudioDirectory() async {
    final appDir = await getAppDirectory();
    final audioDir = Directory('$appDir/audio');
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    return audioDir.path;
  }

  Future<String> copyToAppDir(String sourcePath) async {
    final audioDir = await getAudioDirectory();
    final fileName = sourcePath.split('/').last;
    final destPath = '$audioDir/$fileName';
    await File(sourcePath).copy(destPath);
    return destPath;
  }

  Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<bool> fileExists(String path) async {
    return File(path).exists();
  }

  String _getFileName(String path) {
    final parts = path.split('/');
    final fileName = parts.last;
    return fileName.replaceAll(RegExp(r'\.[^.]+$'), '');
  }
}
