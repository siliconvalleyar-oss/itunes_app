import 'dart:typed_data';

class Song {
  final String id;
  final String filePath;
  final String title;
  final String artist;
  final String album;
  final int? year;
  final int? track;
  final String? genre;
  final Uint8List? coverArt;
  final Duration duration;

  Song({
    required this.id,
    required this.filePath,
    required this.title,
    this.artist = 'Desconocido',
    this.album = 'Sin álbum',
    this.year,
    this.track,
    this.genre,
    this.coverArt,
    this.duration = Duration.zero,
  });

  Song copyWith({
    String? title,
    String? artist,
    String? album,
    int? year,
    int? track,
    String? genre,
    Uint8List? coverArt,
    Duration? duration,
  }) {
    return Song(
      id: id,
      filePath: filePath,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      year: year ?? this.year,
      track: track ?? this.track,
      genre: genre ?? this.genre,
      coverArt: coverArt ?? this.coverArt,
      duration: duration ?? this.duration,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'filePath': filePath,
      'title': title,
      'artist': artist,
      'album': album,
      'year': year,
      'track': track,
      'genre': genre,
      'durationMs': duration.inMilliseconds,
    };
  }

  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'],
      filePath: map['filePath'],
      title: map['title'],
      artist: map['artist'] ?? 'Desconocido',
      album: map['album'] ?? 'Sin álbum',
      year: map['year'],
      track: map['track'],
      genre: map['genre'],
      duration: Duration(milliseconds: map['durationMs'] ?? 0),
    );
  }
}
