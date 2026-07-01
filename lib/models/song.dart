import 'dart:typed_data';

class Song {
  final String id;
  final String filePath;
  final String contentUri;
  final String title;
  final String artist;
  final String album;
  final int? year;
  final int? track;
  final String? genre;
  final Uint8List? coverArt;
  final String? localCoverPath;
  final Duration duration;
  final int? fileSize;

  Song({
    required this.id,
    required this.filePath,
    this.contentUri = '',
    required this.title,
    this.artist = 'Desconocido',
    this.album = 'Sin álbum',
    this.year,
    this.track,
    this.genre,
    this.coverArt,
    this.localCoverPath,
    this.duration = Duration.zero,
    this.fileSize,
  });

  String get playableUri => contentUri.isNotEmpty ? contentUri : filePath;

  Song copyWith({
    String? title,
    String? artist,
    String? album,
    int? year,
    int? track,
    String? genre,
    Uint8List? coverArt,
    Duration? duration,
    String? contentUri,
    String? localCoverPath,
  }) {
    return Song(
      id: id,
      filePath: filePath,
      contentUri: contentUri ?? this.contentUri,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      year: year ?? this.year,
      track: track ?? this.track,
      genre: genre ?? this.genre,
      coverArt: coverArt ?? this.coverArt,
      localCoverPath: localCoverPath ?? this.localCoverPath,
      duration: duration ?? this.duration,
      fileSize: fileSize,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'filePath': filePath,
      'contentUri': contentUri,
      'title': title,
      'artist': artist,
      'album': album,
      'year': year,
      'track': track,
      'genre': genre,
      'durationMs': duration.inMilliseconds,
      'fileSize': fileSize,
      'localCoverPath': localCoverPath,
    };
  }

  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'].toString(),
      filePath: map['filePath'] ?? '',
      contentUri: map['contentUri'] ?? '',
      title: map['title'],
      artist: map['artist'] ?? 'Desconocido',
      album: map['album'] ?? 'Sin álbum',
      year: map['year'],
      track: map['track'],
      genre: map['genre'],
      duration: Duration(milliseconds: map['durationMs'] ?? 0),
      fileSize: map['fileSize'],
      localCoverPath: map['localCoverPath'],
    );
  }
}
