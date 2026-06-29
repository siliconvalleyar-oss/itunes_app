import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/song.dart';

class LibraryService extends ChangeNotifier {
  List<Song> _allSongs = [];
  List<Song> _favorites = [];
  List<Song> _recentlyPlayed = [];
  Map<String, int> _playCounts = {};

  List<Song> get allSongs => _allSongs;
  List<Song> get favorites => _favorites;
  List<Song> get recentlyPlayed => _recentlyPlayed;

  List<Song> get mostPlayed {
    final sorted = List<Song>.from(_allSongs);
    sorted.sort((a, b) => (_playCounts[b.id] ?? 0).compareTo(_playCounts[a.id] ?? 0));
    return sorted.where((s) => (_playCounts[s.id] ?? 0) > 0).toList();
  }

  void setSongs(List<Song> songs) {
    _allSongs = songs;
    notifyListeners();
  }

  void toggleFavorite(Song song) {
    final index = _favorites.indexWhere((s) => s.id == song.id);
    if (index >= 0) {
      _favorites.removeAt(index);
    } else {
      _favorites.add(song);
    }
    _saveFavorites();
    notifyListeners();
  }

  bool isFavorite(String songId) {
    return _favorites.any((s) => s.id == songId);
  }

  void recordPlay(Song song) {
    _playCounts[song.id] = (_playCounts[song.id] ?? 0) + 1;

    _recentlyPlayed.removeWhere((s) => s.id == song.id);
    _recentlyPlayed.insert(0, song);
    if (_recentlyPlayed.length > 50) {
      _recentlyPlayed = _recentlyPlayed.sublist(0, 50);
    }

    _savePlayData();
    notifyListeners();
  }

  Future<void> _saveFavorites() async {
    try {
      final dir = await _getDataDir();
      final file = File('${dir.path}/favorites.json');
      final data = _favorites.map((s) => s.toMap()).toList();
      await file.writeAsString(jsonEncode(data));
    } catch (_) {}
  }

  Future<void> _savePlayData() async {
    try {
      final dir = await _getDataDir();
      final file = File('${dir.path}/play_data.json');
      await file.writeAsString(jsonEncode({
        'playCounts': _playCounts,
        'recentlyPlayed': _recentlyPlayed.map((s) => s.toMap()).toList(),
      }));
    } catch (_) {}
  }

  Future<void> loadSavedData() async {
    try {
      final dir = await _getDataDir();

      final favFile = File('${dir.path}/favorites.json');
      if (await favFile.exists()) {
        final data = jsonDecode(await favFile.readAsString()) as List;
        _favorites = data.map((m) => Song.fromMap(m)).toList();
      }

      final playFile = File('${dir.path}/play_data.json');
      if (await playFile.exists()) {
        final data = jsonDecode(await playFile.readAsString()) as Map;
        _playCounts = Map<String, int>.from(data['playCounts'] ?? {});
        _recentlyPlayed = (data['recentlyPlayed'] as List? ?? [])
            .map((m) => Song.fromMap(m))
            .toList();
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<Directory> _getDataDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final dataDir = Directory('${dir.path}/data');
    if (!await dataDir.exists()) {
      await dataDir.create(recursive: true);
    }
    return dataDir;
  }
}
