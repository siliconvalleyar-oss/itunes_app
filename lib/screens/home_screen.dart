import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../theme/app_theme.dart';
import '../models/song.dart';
import '../services/audio_service.dart';
import '../services/library_service.dart';
import '../services/music_scanner.dart';
import '../services/permission_service.dart';
import '../services/playlist_service.dart';
import '../components/neu_card.dart';
import '../components/neu_button.dart';
import '../components/neu_slider.dart';
import '../widgets/song_tile.dart';
import 'player_screen.dart';
import 'group_songs_screen.dart';

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
  int _currentTab = 0;
  bool _selectionMode = false;
  final Set<String> _selectedIds = {};

  List<Song> get _currentList {
    switch (_currentTab) {
      case 0:
        return widget.libraryService.allSongs;
      case 1:
        return widget.libraryService.allSongs;
      case 2:
        return widget.libraryService.allSongs;
      case 3:
        return widget.libraryService.favorites;
      case 4:
        return widget.libraryService.mostPlayed;
      case 5:
        return widget.libraryService.recentlyPlayed;
      default:
        return widget.libraryService.allSongs;
    }
  }

  Map<String, List<Song>> get _groupedByArtist {
    final map = <String, List<Song>>{};
    for (final s in widget.libraryService.allSongs) {
      final key = s.artist.isNotEmpty ? s.artist : 'Desconocido';
      map.putIfAbsent(key, () => []).add(s);
    }
    return map;
  }

  Map<String, List<Song>> get _groupedByAlbum {
    final map = <String, List<Song>>{};
    for (final s in widget.libraryService.allSongs) {
      final key = s.album.isNotEmpty ? s.album : 'Sin álbum';
      map.putIfAbsent(key, () => []).add(s);
    }
    return map;
  }

  void _exitSelection() {
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentTab = widget.libraryService.lastTab;
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
                      if (!_selectionMode) _buildTabs(),
                      SizedBox(height: 8),
                      if (!_selectionMode) _buildStats(),
                      SizedBox(height: 16),
                      Expanded(child: _buildSongList()),
                    ],
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
        children: [
          Text(
            'Inicio',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    final tabs = ['Todas', 'Artistas', 'Álbumes', 'Favoritos', 'Top', 'Recientes'];
    return Container(
      height: 44,
      margin: EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (context, i) => _buildTab(i, tabs[i]),
      ),
    );
  }

  Widget _buildTab(int index, String label) {
    final isActive = _currentTab == index;
    return GestureDetector(
      onTap: () {
        setState(() => _currentTab = index);
        widget.libraryService.setLastTab(index);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accent.withValues(alpha: 0.15) : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isActive ? [] : Neumorphic.inset,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? AppColors.accent : AppColors.textDisabled,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStats() {
    return ListenableBuilder(
      listenable: widget.libraryService,
      builder: (context, _) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              _buildStat('Canciones', '${widget.libraryService.allSongs.length}'),
              SizedBox(width: 12),
              _buildStat('Favoritos', '${widget.libraryService.favorites.length}'),
              SizedBox(width: 12),
              _buildStat('Escuchadas', '${widget.libraryService.mostPlayed.length}'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStat(String label, String value) {
    return Expanded(
      child: NeuCard(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        borderRadius: 16,
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11, color: AppColors.textDisabled)),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupView(Map<String, List<Song>> groups, IconData fallbackIcon) {
    final sortedKeys = groups.keys.toList()..sort();
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 24),
      itemCount: sortedKeys.length,
      itemBuilder: (context, i) {
        final key = sortedKeys[i];
        final songs = groups[key]!;
        return Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GroupSongsScreen(
                    groupName: key,
                    songs: songs,
                    audioService: widget.audioService,
                    libraryService: widget.libraryService,
                    playlistService: widget.playlistService,
                  ),
                ),
              );
            },
            child: NeuCard(
              padding: EdgeInsets.all(12),
              borderRadius: 16,
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: Neumorphic.inset,
                    ),
                    child: Icon(
                      fallbackIcon,
                      color: AppColors.accent,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          key,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2),
                        Text(
                          '${songs.length} ${songs.length == 1 ? 'canción' : 'canciones'}',
                          style: TextStyle(fontSize: 12, color: AppColors.textDisabled),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: AppColors.textDisabled, size: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSongList() {
    return ListenableBuilder(
      listenable: Listenable.merge([widget.libraryService, widget.audioService]),
      builder: (context, _) {
        final songs = _currentList;
        if (_currentTab == 1) {
          return _buildGroupView(_groupedByArtist, Icons.person);
        }
        if (_currentTab == 2) {
          return _buildGroupView(_groupedByAlbum, Icons.album);
        }
        if (songs.isEmpty) {
          return Center(
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
                  child: Icon(Icons.music_off, color: AppColors.textDisabled, size: 32),
                ),
                SizedBox(height: 16),
                Text(
                  _currentTab == 1 ? 'No hay favoritos' : 'Sin canciones',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 24),
          itemCount: songs.length,
          itemBuilder: (context, index) {
            final song = songs[index];
            return SongTile(
              song: song,
              audioService: widget.audioService,
              isFavorite: widget.libraryService.isFavorite(song.id),
              onFavoriteToggle: () => widget.libraryService.toggleFavorite(song),
              onHide: () => widget.libraryService.toggleIgnored(song),
              onTap: () {
                widget.libraryService.recordPlay(song);
                widget.audioService.play(song);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlayerScreen(
                      audioService: widget.audioService,
                      libraryService: widget.libraryService,
                      playlistService: widget.playlistService,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
