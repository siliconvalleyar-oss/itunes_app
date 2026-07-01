import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../theme/app_theme.dart';
import '../services/audio_service.dart';
import '../services/library_service.dart';
import '../services/music_scanner.dart';
import '../services/permission_service.dart';
import '../services/playlist_service.dart';
import '../components/neu_card.dart';
import '../components/neu_button.dart';
import '../components/neu_slider.dart';
import '../components/mini_player.dart';
import 'player_screen.dart';

class HomeScreen extends StatefulWidget {
  final AudioService audioService;
  final LibraryService libraryService;
  final PlaylistService playlistService;

  HomeScreen({
    super.key,
    required this.audioService,
    required this.libraryService,
    required this.playlistService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final MusicScanner _scanner = MusicScanner();
  bool _permissionGranted = false;
  bool _permissionLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissionAndScan();
    widget.libraryService.addListener(_onLibraryChanged);
  }

  void _onLibraryChanged() {
    widget.audioService.syncPlaylist(widget.libraryService.allSongs);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.libraryService.removeListener(_onLibraryChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_permissionGranted) {
      _checkPermissionAndScan();
    }
  }

  Future<void> _checkPermissionAndScan() async {
    final granted = await PermissionService.hasAudioPermission();
    if (!mounted) return;
    if (granted) {
      setState(() {
        _permissionGranted = true;
        _permissionLoading = false;
      });
      _scanMusic();
      return;
    }
    final requested = await PermissionService.requestAudioPermission();
    if (!mounted) return;
    setState(() {
      _permissionGranted = requested;
      _permissionLoading = false;
    });
    if (requested) {
      _scanMusic();
    }
  }

  Future<void> _scanMusic() async {
    try {
      final songs = await _scanner.scanDevice();
      widget.libraryService.setSongs(songs);
      widget.audioService.setPlaylist(widget.libraryService.allSongs);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _permissionLoading
            ? const Center(child: CircularProgressIndicator())
            : !_permissionGranted
                ? _buildPermissionDenied()
                : Column(
                    children: [
                      _buildHeader(),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              SizedBox(height: 24),
                              _buildNowPlaying(),
                              SizedBox(height: 32),
                              _buildControls(),
                              SizedBox(height: 24),
                              _buildProgressBar(),
                              SizedBox(height: 24),
                              _buildInfoChips(),
                              SizedBox(height: 24),
                              _buildVisualizer(),
                              SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
      bottomNavigationBar: MiniPlayer(
        audioService: widget.audioService,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
                builder: (_) => PlayerScreen(audioService: widget.audioService, libraryService: widget.libraryService, playlistService: widget.playlistService),
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionDenied() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                boxShadow: Neumorphic.inset,
              ),
              child: Icon(Icons.music_off, color: AppColors.textDisabled, size: 36),
            ),
            SizedBox(height: 24),
            Text(
              'Permiso necesario',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Para leer tus canciones, concede permiso de acceso a audio.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            SizedBox(height: 24),
            GestureDetector(
              onTap: () async {
                final granted = await PermissionService.requestAudioPermission();
                if (mounted) {
                  setState(() => _permissionGranted = granted);
                  if (granted) _scanMusic();
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: Neumorphic.raised,
                ),
                child: Text(
                  'Conceder permiso',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          NeuButton(
            onPressed: () {},
            size: 44,
            child: Icon(Icons.menu, color: AppColors.textSecondary, size: 20),
          ),
          Text(
            'Music Studio',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          NeuButton(
            onPressed: () {},
            size: 44,
            child: Icon(Icons.search, color: AppColors.textSecondary, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildNowPlaying() {
    return ListenableBuilder(
      listenable: widget.audioService,
      builder: (context, _) {
        final song = widget.audioService.currentSong;
        return NeuCard(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.accent.withValues(alpha: 0.15),
                      AppColors.accentAlt.withValues(alpha: 0.15),
                    ],
                  ),
                  boxShadow: Neumorphic.inset,
                ),
                child: song?.localCoverPath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.file(File(song!.localCoverPath!), fit: BoxFit.cover),
                      )
                    : song?.coverArt != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.memory(song!.coverArt!, fit: BoxFit.cover),
                      )
                    : Icon(
                        Icons.music_note,
                        color: AppColors.textDisabled,
                        size: 72,
                      ),
              ),
              SizedBox(height: 24),
              Text(
                song?.title ?? 'Selecciona una canción',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 6),
              Text(
                song?.artist ?? 'Artista',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                song?.album ?? 'Álbum',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textDisabled,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControls() {
    return ListenableBuilder(
      listenable: widget.audioService,
      builder: (context, _) {
        return FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NeuButton(
                onPressed: widget.audioService.toggleShuffle,
                size: 48,
                isActive: widget.audioService.isShuffled,
                child: Icon(
                  Icons.shuffle,
                  color: widget.audioService.isShuffled
                      ? AppColors.accent
                      : AppColors.textSecondary,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              NeuButton(
                onPressed: widget.audioService.previous,
                size: 52,
                child: Icon(Icons.skip_previous, color: AppColors.textPrimary, size: 26),
              ),
              SizedBox(width: 12),
              NeuButton(
                onPressed: () {
                  if (widget.audioService.isPlaying) {
                    widget.audioService.pause();
                  } else {
                    widget.audioService.resume();
                  }
                },
                size: 64,
                isInset: widget.audioService.isPlaying,
                child: Icon(
                  widget.audioService.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: AppColors.accent,
                  size: 32,
                ),
              ),
              SizedBox(width: 12),
              NeuButton(
                onPressed: widget.audioService.next,
                size: 52,
                child: Icon(Icons.skip_next, color: AppColors.textPrimary, size: 26),
              ),
              SizedBox(width: 12),
              NeuButton(
                onPressed: widget.audioService.cycleLoopMode,
                size: 48,
                isActive: widget.audioService.loopMode != LoopMode.off,
                child: Icon(
                  widget.audioService.loopMode == LoopMode.one ? Icons.repeat_one : Icons.repeat,
                  color: widget.audioService.loopMode != LoopMode.off
                      ? AppColors.accent
                      : AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressBar() {
    return ListenableBuilder(
      listenable: widget.audioService,
      builder: (context, _) {
        return Column(
          children: [
            NeuSlider(
              value: widget.audioService.duration.inMilliseconds > 0
                  ? widget.audioService.position.inMilliseconds /
                      widget.audioService.duration.inMilliseconds
                  : 0,
              onChanged: (v) {
                final pos = Duration(
                  milliseconds: (v * widget.audioService.duration.inMilliseconds).round(),
                );
                widget.audioService.seek(pos);
              },
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _fmt(widget.audioService.position),
                  style: TextStyle(fontSize: 12, color: AppColors.textDisabled),
                ),
                Text(
                  _fmt(widget.audioService.duration),
                  style: TextStyle(fontSize: 12, color: AppColors.textDisabled),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoChips() {
    return ListenableBuilder(
      listenable: widget.audioService,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildChip('320', 'kbps'),
            SizedBox(width: 12),
            _buildChip('MP3', 'fmt'),
            SizedBox(width: 12),
            _buildChip('44.1', 'kHz'),
          ],
        );
      },
    );
  }

  Widget _buildChip(String value, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: Neumorphic.subtle,
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          Text(label, style: TextStyle(fontSize: 10, color: AppColors.textDisabled)),
        ],
      ),
    );
  }

  Widget _buildVisualizer() {
    return NeuCard(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(24, (i) {
            final h = 10 + (i * 3 % 30).toDouble();
            return AnimatedContainer(
              duration: Duration(milliseconds: 300 + (i * 50)),
              width: 4,
              height: h,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.3 + (i % 3) * 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),
      ),
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
