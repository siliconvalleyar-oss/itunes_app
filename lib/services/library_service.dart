import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:crypto/crypto.dart';
import '../models/song.dart';

class LibraryService extends ChangeNotifier {
  List<Song> _allSongs = [];
  Set<String> _favoriteIds = {};
  List<Song> _recentlyPlayed = [];
  Map<String, int> _playCounts = {};
  Set<String> _ignoredIds = {};
  Map<String, Map<String, dynamic>> _metadataOverrides = {};
  Map<String, String> _coverPaths = {};
  String? _lastSongId;
  int _lastTab = 0;
  String? _lastGroupName;
  int _lastGroupType = 0; // 0=ninguno, 1=artista, 2=álbum

  String? get lastSongId => _lastSongId;
  int get lastTab => _lastTab;
  String? get lastGroupName => _lastGroupName;
  int get lastGroupType => _lastGroupType;

  void setLastTab(int tab) {
    _lastTab = tab;
    _saveLastState();
  }

  void setLastGroup(String name, int type) {
    _lastGroupName = name;
    _lastGroupType = type;
    _saveLastState();
  }

  List<Song> get allSongs => _allSongs.where((s) => !_ignoredIds.contains(s.id)).toList();
  List<Song> get allSongsUnfiltered => _allSongs;
  List<Song> get favorites =>
      _allSongs.where((s) => _favoriteIds.contains(s.id) && !_ignoredIds.contains(s.id)).toList();
  List<Song> get recentlyPlayed =>
      _recentlyPlayed.where((s) => !_ignoredIds.contains(s.id)).toList();
  Set<String> get ignoredIds => _ignoredIds;

  List<Song> get mostPlayed {
    final sorted = List<Song>.from(_allSongs);
    sorted.sort((a, b) => (_playCounts[b.id] ?? 0).compareTo(_playCounts[a.id] ?? 0));
    return sorted.where((s) => (_playCounts[s.id] ?? 0) > 0 && !_ignoredIds.contains(s.id)).toList();
  }

  Future<Directory> _getCoverDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final coverDir = Directory('${dir.path}/.itunes_app_image');
    if (!await coverDir.exists()) {
      await coverDir.create(recursive: true);
    }
    return coverDir;
  }

  String _computeImageHash(String filePath) {
    final bytes = File(filePath).readAsBytesSync();
    return sha256.convert(bytes).toString();
  }

  Future<String?> saveSongCover(String songId, String sourcePath) async {
    try {
      final coverDir = await _getCoverDir();
      final hash = _computeImageHash(sourcePath);
      final dest = '${coverDir.path}/$hash.jpg';
      final destFile = File(dest);
      if (!await destFile.exists()) {
        await File(sourcePath).copy(dest);
      }
      _coverPaths[songId] = dest;
      _saveCoverPaths();
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
      _coverPaths.remove(songId);
      _saveCoverPaths();
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
    _applyCoverPaths();
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
    _normalizeMetadata();
  }

  void _applyCoverPaths() {
    for (final entry in _coverPaths.entries) {
      final sid = entry.key;
      final path = entry.value;
      final idx = _allSongs.indexWhere((s) => s.id == sid);
      if (idx >= 0) {
        _allSongs[idx] = _allSongs[idx].copyWith(localCoverPath: path);
      }
    }
  }

  void _normalizeMetadata() {
    for (var i = 0; i < _allSongs.length; i++) {
      final s = _allSongs[i];
      String? clean(String? v) {
        if (v == null) return null;
        final trimmed = v.trim();
        if (trimmed.isEmpty || trimmed.toLowerCase() == '<unknown>') return '';
        return trimmed;
      }
      final title = clean(s.title);
      final artist = clean(s.artist);
      final album = clean(s.album);
      if (title != s.title || artist != s.artist || album != s.album) {
        _allSongs[i] = s.copyWith(
          title: title,
          artist: artist,
          album: album,
        );
      }
    }
  }

  void toggleFavorite(Song song) {
    if (_favoriteIds.contains(song.id)) {
      _favoriteIds.remove(song.id);
    } else {
      _favoriteIds.add(song.id);
    }
    _saveFavorites();
    notifyListeners();
  }

  bool isFavorite(String songId) {
    return _favoriteIds.contains(songId);
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

    _lastSongId = song.id;
    _savePlayData();
    _saveLastState();
    notifyListeners();
  }

  Song? get lastSong => _lastSongId != null
      ? _allSongs.where((s) => s.id == _lastSongId).firstOrNull
      : null;

  Future<void> _saveLastState() async {
    try {
      final dir = await _getDataDir();
      final file = File('${dir.path}/last_state.json');
      await file.writeAsString(jsonEncode({
        'lastSongId': _lastSongId,
        'lastTab': _lastTab,
        'lastGroupName': _lastGroupName,
        'lastGroupType': _lastGroupType,
      }));
    } catch (_) {}
  }

  Future<void> _loadLastState() async {
    try {
      final dir = await _getDataDir();
      final file = File('${dir.path}/last_state.json');
      if (await file.exists()) {
        final data = jsonDecode(await file.readAsString()) as Map;
        _lastSongId = data['lastSongId'] as String?;
        _lastTab = data['lastTab'] as int? ?? 0;
        _lastGroupName = data['lastGroupName'] as String?;
        _lastGroupType = data['lastGroupType'] as int? ?? 0;
      }
    } catch (_) {}
  }

  Future<void> _saveFavorites() async {
    try {
      final dir = await _getDataDir();
      final file = File('${dir.path}/favorites.json');
      await file.writeAsString(jsonEncode(_favoriteIds.toList()));
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
    _normalizeMetadata();
    _saveMetadataOverrides();
    notifyListeners();
  }

  Future<void> loadSavedData() async {
    try {
      final dir = await _getDataDir();

      final favFile = File('${dir.path}/favorites.json');
      if (await favFile.exists()) {
        final data = jsonDecode(await favFile.readAsString());
        if (data is List) {
          _favoriteIds = data.map((e) => e.toString()).toSet();
        }
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
      await _loadCoverPaths();
      await _loadLastState();
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

  Future<void> _saveCoverPaths() async {
    try {
      final dir = await _getDataDir();
      final file = File('${dir.path}/cover_paths.json');
      await file.writeAsString(jsonEncode(_coverPaths));
    } catch (_) {}
  }

  Future<void> _loadCoverPaths() async {
    try {
      final dir = await _getDataDir();
      final file = File('${dir.path}/cover_paths.json');
      if (await file.exists()) {
        final data = jsonDecode(await file.readAsString()) as Map;
        _coverPaths = data.map((k, v) => MapEntry(k, v.toString()));
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
