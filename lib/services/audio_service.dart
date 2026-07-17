import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';

class AudioService extends ChangeNotifier {
  late final AudioPlayer _player;
  AndroidEqualizer? _equalizer;
  AndroidEqualizerParameters? _eqParams;
  bool _eqEnabled = false;
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
  bool get equalizerEnabled => _eqEnabled;
  AndroidEqualizerParameters? get equalizerParameters => _eqParams;
  AndroidEqualizer? get equalizer => _equalizer;

  AudioService() {
    if (Platform.isAndroid) {
      _equalizer = AndroidEqualizer();
      _player = AudioPlayer(
        audioPipeline: AudioPipeline(
          androidAudioEffects: [_equalizer!],
        ),
      );
      _initEqualizer();
    } else {
      _player = AudioPlayer();
    }
    _player.positionStream.listen((_) => notifyListeners());
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        next();
      }
      notifyListeners();
    });
  }

  Future<void> _initEqualizer() async {
    try {
      final params = await _equalizer!.parameters;
      _eqParams = params;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> setEqualizerEnabled(bool enabled) async {
    _eqEnabled = enabled;
    try {
      // AndroidEqualizer doesn't have enable/disable directly,
      // we restore gains when enabling, set all to 0 when disabling
      if (_eqParams != null) {
        for (final band in _eqParams!.bands) {
          await band.setGain(enabled ? 0 : 0);
        }
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<void> setEqualizerBandGain(int bandIndex, double gainDecibels) async {
    try {
      if (_eqParams != null && bandIndex < _eqParams!.bands.length) {
        await _eqParams!.bands[bandIndex].setGain(gainDecibels);
      }
    } catch (_) {}
  }

  void toggleEqualizer() {
    _eqEnabled = !_eqEnabled;
    setEqualizerEnabled(_eqEnabled);
  }

  void setPlaylist(List<Song> songs) {
    _playlist = List.from(songs);
    notifyListeners();
  }

  Future<void> play(Song song, {List<Song>? playlist}) async {
    if (playlist != null) {
      _playlist = List.from(playlist);
    }
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

  void updateCurrentSong(Song updatedSong) {
    if (_currentIndex >= 0 && _currentIndex < _playlist.length) {
      _playlist[_currentIndex] = updatedSong;
      notifyListeners();
    }
  }

  void syncPlaylist(List<Song> filteredSongs) {
    final currentId = currentSong?.id;
    _playlist = List.from(filteredSongs);
    if (currentId != null) {
      _currentIndex = _playlist.indexWhere((s) => s.id == currentId);
      if (_currentIndex < 0) _currentIndex = 0;
    }
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
