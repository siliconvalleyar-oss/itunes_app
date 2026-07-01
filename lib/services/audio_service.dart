import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';

class AudioService extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  List<Song> _playlist = [];
  int _currentIndex = -1;
  bool _isShuffled = false;
  LoopMode _loopMode = LoopMode.off;

  AudioPlayer get player => _player;
  List<Song> get playlist => _playlist;
  int get currentIndex => _currentIndex;
  Song? get currentSong =>
      _currentIndex >= 0 && _currentIndex < _playlist.length
          ? _playlist[_currentIndex]
          : null;
  bool get isPlaying => _player.playing;
  Duration get position => _player.position;
  Duration get duration => _player.duration ?? Duration.zero;
  bool get isShuffled => _isShuffled;
  LoopMode get loopMode => _loopMode;

  AudioService() {
    _player.positionStream.listen((_) => notifyListeners());
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        next();
      }
      notifyListeners();
    });
  }

  void setPlaylist(List<Song> songs) {
    _playlist = List.from(songs);
    notifyListeners();
  }

  Future<void> play(Song song) async {
    final index = _playlist.indexWhere((s) => s.id == song.id);
    if (index >= 0) {
      _currentIndex = index;
    } else {
      _playlist.add(song);
      _currentIndex = _playlist.length - 1;
    }
    await _player.setAudioSource(
      AudioSource.uri(Uri.parse(song.playableUri)),
    );
    await _player.play();
    notifyListeners();
  }

  Future<void> pause() async {
    await _player.pause();
    notifyListeners();
  }

  Future<void> resume() async {
    await _player.play();
    notifyListeners();
  }

  Future<void> stop() async {
    await _player.stop();
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
    notifyListeners();
  }

  Future<void> next() async {
    if (_playlist.isEmpty) return;
    if (_isShuffled) {
      _currentIndex = (DateTime.now().millisecondsSinceEpoch % _playlist.length);
    } else {
      _currentIndex = (_currentIndex + 1) % _playlist.length;
    }
    await play(_playlist[_currentIndex]);
  }

  Future<void> previous() async {
    if (_playlist.isEmpty) return;
    if (position.inSeconds > 3) {
      await seek(Duration.zero);
    } else {
      _currentIndex =
          (_currentIndex - 1 + _playlist.length) % _playlist.length;
      await play(_playlist[_currentIndex]);
    }
  }

  void toggleShuffle() {
    _isShuffled = !_isShuffled;
    notifyListeners();
  }

  void cycleLoopMode() {
    final modes = [LoopMode.off, LoopMode.all, LoopMode.one];
    final nextIndex = (modes.indexOf(_loopMode) + 1) % modes.length;
    _loopMode = modes[nextIndex];
    _player.setLoopMode(_loopMode);
    notifyListeners();
  }

  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    await _player.dispose();
    super.dispose();
  }
}
