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
  Set<String> _ignoredIds = {};
  Map<String, Map<String, dynamic>> _metadataOverrides = {};

  List<Song> get allSongs => _allSongs.where((s) => !_ignoredIds.contains(s.id)).toList();
  List<Song> get allSongsUnfiltered => _allSongs;
  List<Song> get favorites =>
      _favorites.where((s) => !_ignoredIds.contains(s.id)).toList();
  List<Song> get recentlyPlayed =>
      _recentlyPlayed.where((s) => !_ignoredIds.contains(s.id)).toList();
  Set<String> get ignoredIds => _ignoredIds;

  List<Song> get mostPlayed {
    final sorted = List<Song>.from(_allSongs);
    sorted.sort((a, b) => (_playCounts[b.id] ?? 0).compareTo(_playCounts[a.id] ?? 0));
    return sorted.where((s) => (_playCounts[s.id] ?? 0) > 0 && !_ignoredIds.contains(s.id)).toList();
  }

  Future<Directory> _getCoverDir() async {
    final dir = await _getDataDir();
    final coverDir = Directory('${dir.path}/covers');
    if (!await coverDir.exists()) {
      await coverDir.create(recursive: true);
    }
    return coverDir;
  }

  Future<String?> saveSongCover(String songId, String sourcePath) async {
    try {
      final coverDir = await _getCoverDir();
      final dest = '${coverDir.path}/$songId.jpg';
      await File(sourcePath).copy(dest);
      final idx = _allSongs.indexWhere((s) => s.id == songId);
      if (idx >= 0) {
        _allSongs[idx] = _allSongs[idx].copyWith(localCoverPath: dest);
        notifyListeners();
      }
      return dest;
    } catch (_) {
      return null;
    }
  }

  Future<void> removeSongCover(String songId) async {
    try {
      final coverDir = await _getCoverDir();
      final file = File('${coverDir.path}/$songId.jpg');
      if (await file.exists()) await file.delete();
      final idx = _allSongs.indexWhere((s) => s.id == songId);
      if (idx >= 0) {
        _allSongs[idx] = _allSongs[idx].copyWith(localCoverPath: null);
        notifyListeners();
      }
    } catch (_) {}
  }

  void setSongs(List<Song> songs) {
    _allSongs = songs;
    _applyMetadataOverrides();
    notifyListeners();
  }

  void _applyMetadataOverrides() {
    for (final entry in _metadataOverrides.entries) {
      final sid = entry.key;
      final overrides = entry.value;
      final idx = _allSongs.indexWhere((s) => s.id == sid);
      if (idx >= 0) {
        _allSongs[idx] = _allSongs[idx].copyWith(
          title: overrides['title'] as String?,
          artist: overrides['artist'] as String?,
          album: overrides['album'] as String?,
        );
      }
    }
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

  void toggleIgnored(Song song) {
    if (_ignoredIds.contains(song.id)) {
      _ignoredIds.remove(song.id);
    } else {
      _ignoredIds.add(song.id);
    }
    _saveIgnored();
    notifyListeners();
  }

  bool isIgnored(String songId) => _ignoredIds.contains(songId);

  Future<void> restoreIgnored(Song song) async {
    _ignoredIds.remove(song.id);
    _saveIgnored();
    notifyListeners();
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

  Future<void> _saveIgnored() async {
    try {
      final dir = await _getDataDir();
      final file = File('${dir.path}/ignored.json');
      await file.writeAsString(jsonEncode(_ignoredIds.toList()));
    } catch (_) {}
  }

  void updateSongMetadata(String songId, {String? title, String? artist, String? album}) {
    final idx = _allSongs.indexWhere((s) => s.id == songId);
    if (idx < 0) return;
    final overrides = <String, dynamic>{};
    if (title != null) overrides['title'] = title;
    if (artist != null) overrides['artist'] = artist;
    if (album != null) overrides['album'] = album;
    _metadataOverrides[songId] = overrides;
    _allSongs[idx] = _allSongs[idx].copyWith(title: title, artist: artist, album: album);
    _saveMetadataOverrides();
    notifyListeners();
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

      final ignoredFile = File('${dir.path}/ignored.json');
      if (await ignoredFile.exists()) {
        final data = jsonDecode(await ignoredFile.readAsString()) as List;
        _ignoredIds = data.map((e) => e.toString()).toSet();
      }

      await _loadMetadataOverrides();
    } catch (_) {}
    notifyListeners();
  }

  Future<void> _saveMetadataOverrides() async {
    try {
      final dir = await _getDataDir();
      final file = File('${dir.path}/metadata_overrides.json');
      await file.writeAsString(jsonEncode(_metadataOverrides));
    } catch (_) {}
  }

  Future<void> _loadMetadataOverrides() async {
    try {
      final dir = await _getDataDir();
      final file = File('${dir.path}/metadata_overrides.json');
      if (await file.exists()) {
        final data = jsonDecode(await file.readAsString()) as Map;
        _metadataOverrides = data.map((k, v) => MapEntry(k, Map<String, dynamic>.from(v)));
      }
    } catch (_) {}
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
