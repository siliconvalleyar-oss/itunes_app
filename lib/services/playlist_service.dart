import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/song.dart';

class Playlist {
  final String id;
  String name;
  List<Song> songs;
  final DateTime createdAt;
  String? coverPath;

  Playlist({
    required this.id,
    required this.name,
    List<Song>? songs,
    DateTime? createdAt,
    this.coverPath,
  })  : songs = songs ?? [],
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'songs': songs.map((s) => s.toMap()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'coverPath': coverPath,
  };

  factory Playlist.fromMap(Map<String, dynamic> m) => Playlist(
    id: m['id'],
    name: m['name'],
    songs: (m['songs'] as List? ?? []).map((s) => Song.fromMap(s)).toList(),
    createdAt: DateTime.parse(m['createdAt']),
    coverPath: m['coverPath'],
  );
}

class PlaylistService extends ChangeNotifier {
  List<Playlist> _playlists = [];
  List<Playlist> get playlists => _playlists;

  void addPlaylist(String name) {
    final playlist = Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
    );
    _playlists.add(playlist);
    _savePlaylists();
    notifyListeners();
  }

  void removePlaylist(String id) {
    _playlists.removeWhere((p) => p.id == id);
    _savePlaylists();
    notifyListeners();
  }

  void addSongToPlaylist(String playlistId, Song song) {
    final pl = _playlists.firstWhere((p) => p.id == playlistId);
    if (!pl.songs.any((s) => s.id == song.id)) {
      pl.songs.add(song);
      _savePlaylists();
      notifyListeners();
    }
  }

  void removeSongFromPlaylist(String playlistId, String songId) {
    final pl = _playlists.firstWhere((p) => p.id == playlistId);
    pl.songs.removeWhere((s) => s.id == songId);
    _savePlaylists();
    notifyListeners();
  }

  void renamePlaylist(String id, String newName) {
    final pl = _playlists.firstWhere((p) => p.id == id);
    pl.name = newName;
    _savePlaylists();
    notifyListeners();
  }

  Future<void> _savePlaylists() async {
    try {
      final dir = await _getDataDir();
      final file = File('${dir.path}/playlists.json');
      final data = _playlists.map((p) => p.toMap()).toList();
      await file.writeAsString(jsonEncode(data));
    } catch (_) {}
  }

  Future<void> loadPlaylists() async {
    try {
      final dir = await _getDataDir();
      final file = File('${dir.path}/playlists.json');
      if (await file.exists()) {
        final data = jsonDecode(await file.readAsString()) as List;
        _playlists = data.map((m) => Playlist.fromMap(m)).toList();
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<String?> savePlaylistCover(String playlistId, String sourcePath) async {
    try {
      final dir = await _getDataDir();
      final coverDir = Directory('${dir.path}/covers');
      if (!await coverDir.exists()) {
        await coverDir.create(recursive: true);
      }
      final dest = '${coverDir.path}/pl_$playlistId.jpg';
      await File(sourcePath).copy(dest);
      final pl = _playlists.firstWhere((p) => p.id == playlistId);
      pl.coverPath = dest;
      _savePlaylists();
      notifyListeners();
      return dest;
    } catch (_) {
      return null;
    }
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
