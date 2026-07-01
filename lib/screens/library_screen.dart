import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/song.dart';
import '../services/audio_service.dart';
import '../services/library_service.dart';
import '../services/playlist_service.dart';
import '../components/neu_card.dart';
import '../components/neu_button.dart';
import '../widgets/song_tile.dart';
import 'player_screen.dart';

class LibraryScreen extends StatefulWidget {
  final AudioService audioService;
  final LibraryService libraryService;
  final PlaylistService playlistService;

  LibraryScreen({
    super.key,
    required this.audioService,
    required this.libraryService,
    required this.playlistService,
  });

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  int _currentTab = 0;
  bool _selectionMode = false;
  final Set<String> _selectedIds = {};

  List<Song> get _currentList {
    switch (_currentTab) {
      case 0:
        return widget.libraryService.allSongs;
      case 1:
        return widget.libraryService.favorites;
      case 2:
        return widget.libraryService.mostPlayed;
      case 3:
        return widget.libraryService.recentlyPlayed;
      default:
        return widget.libraryService.allSongs;
    }
  }

  void _exitSelection() {
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
  }

  void _toggleSelectAll() {
    final songs = _currentList;
    if (_selectedIds.length == songs.length) {
      _selectedIds.clear();
    } else {
      _selectedIds.addAll(songs.map((s) => s.id));
    }
    setState(() {});
  }

  void _batchHide() {
    final songs = _currentList.where((s) => _selectedIds.contains(s.id));
    for (final s in songs) {
      widget.libraryService.toggleIgnored(s);
    }
    _exitSelection();
  }

  void _batchAddToPlaylist() {
    final songs = _currentList.where((s) => _selectedIds.contains(s.id)).toList();
    final plCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Agregar ${songs.length} canciones',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              SizedBox(height: 16),
              Text('Selecciona una playlist:',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              SizedBox(height: 12),
              // New playlist option
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  _batchCreatePlaylist(songs);
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.add_circle, color: AppColors.accent, size: 20),
                      SizedBox(width: 12),
                      Text('Crear nueva lista',
                          style: TextStyle(
                              fontSize: 14,
                              color: AppColors.accent,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
              ListenableBuilder(
                listenable: widget.playlistService,
                builder: (context, _) {
                  final playlists = widget.playlistService.playlists;
                  if (playlists.isEmpty) return SizedBox.shrink();
                  return ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 250),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: playlists.length,
                      itemBuilder: (context, i) {
                        final pl = playlists[i];
                        return GestureDetector(
                          onTap: () {
                            for (final s in songs) {
                              widget.playlistService.addSongToPlaylist(pl.id, s);
                            }
                            Navigator.pop(ctx);
                          },
                          child: Container(
                            margin: EdgeInsets.only(bottom: 8),
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.queue_music_outlined,
                                    color: AppColors.textSecondary, size: 20),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(pl.name,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w500)),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: 12),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    height: 40,
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text('Cerrar', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _batchCreatePlaylist(List<Song> songs) {
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Nueva Playlist',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: Neumorphic.inset,
                ),
                child: TextField(
                  controller: nameCtrl,
                  autofocus: true,
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Nombre de la playlist',
                    hintStyle: TextStyle(color: AppColors.textDisabled),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: Neumorphic.subtle,
                        ),
                        child: Center(
                          child: Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        final name = nameCtrl.text.trim();
                        if (name.isNotEmpty) {
                          widget.playlistService.addPlaylist(name);
                          final p = widget.playlistService.playlists.last;
                          for (final s in songs) {
                            widget.playlistService.addSongToPlaylist(p.id, s);
                          }
                          Navigator.pop(ctx);
                        }
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: Neumorphic.subtle,
                        ),
                        child: Center(
                          child: Text('Crear y agregar',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _batchEditMetadata() {
    final songs = _currentList.where((s) => _selectedIds.contains(s.id)).toList();
    final artistCtrl = TextEditingController();
    final albumCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Editar metadatos (${songs.length})',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              SizedBox(height: 8),
              Text('Los campos vacíos no se modificarán.',
                  style: TextStyle(fontSize: 12, color: AppColors.textDisabled)),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: Neumorphic.inset,
                ),
                child: TextField(
                  controller: artistCtrl,
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Artista',
                    labelStyle: TextStyle(color: AppColors.textDisabled, fontSize: 12),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: Neumorphic.inset,
                ),
                child: TextField(
                  controller: albumCtrl,
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Álbum',
                    labelStyle: TextStyle(color: AppColors.textDisabled, fontSize: 12),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: Neumorphic.subtle,
                        ),
                        child: Center(
                          child: Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        final artist = artistCtrl.text.trim();
                        final album = albumCtrl.text.trim();
                        for (final s in songs) {
                          widget.libraryService.updateSongMetadata(
                            s.id,
                            artist: artist.isNotEmpty ? artist : null,
                            album: album.isNotEmpty ? album : null,
                          );
                        }
                        Navigator.pop(ctx);
                        _exitSelection();
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: Neumorphic.subtle,
                        ),
                        child: Center(
                          child: Text('Guardar',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (!_selectionMode) _buildTabs(),
            SizedBox(height: 8),
            if (!_selectionMode) _buildStats(),
            SizedBox(height: 16),
            Expanded(
              child: _buildSongList(),
            ),
            if (_selectionMode && _selectedIds.isNotEmpty) _buildSelectionBar(),
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
          if (_selectionMode)
            NeuButton(
              onPressed: _exitSelection,
              size: 40,
              child: Icon(Icons.close, color: AppColors.textSecondary, size: 18),
            )
          else
            Text(
              'Biblioteca',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          Spacer(),
          if (_selectionMode)
            Text('${_selectedIds.length} seleccionados',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary))
          else
            Row(
              children: [
                NeuButton(
                  onPressed: () {
                    setState(() => _selectionMode = true);
                  },
                  size: 40,
                  child: Icon(Icons.checklist, color: AppColors.textSecondary, size: 18),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      height: 44,
      margin: EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          _buildTab(0, 'Todas'),
          _buildTab(1, 'Favoritos'),
          _buildTab(2, 'Top'),
          _buildTab(3, 'Recientes'),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label) {
    final isActive = _currentTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentTab = index),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 250),
          margin: EdgeInsets.symmetric(horizontal: 3),
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

  Widget _buildSongList() {
    return ListenableBuilder(
      listenable: Listenable.merge([widget.libraryService, widget.audioService]),
      builder: (context, _) {
        final songs = _currentList;
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
        return Column(
          children: [
            if (_selectionMode)
              GestureDetector(
                onTap: _toggleSelectAll,
                child: Container(
                  margin: EdgeInsets.fromLTRB(24, 0, 24, 8),
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        _selectedIds.length == songs.length
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        _selectedIds.length == songs.length
                            ? 'Deseleccionar todo'
                            : 'Seleccionar todo',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: ListView.builder(
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
                    selectionMode: _selectionMode,
                    isSelected: _selectedIds.contains(song.id),
                    onSelect: (val) {
                      setState(() {
                        if (val) {
                          _selectedIds.add(song.id);
                        } else {
                          _selectedIds.remove(song.id);
                        }
                      });
                    },
                    onTap: _selectionMode
                        ? null
                        : () {
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
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSelectionBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: Neumorphic.raised,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _selectionAction(Icons.visibility_off, 'Ocultar', _batchHide),
          _selectionAction(Icons.queue_music, 'Lista', _batchAddToPlaylist),
          _selectionAction(Icons.edit_outlined, 'Editar', _batchEditMetadata),
        ],
      ),
    );
  }

  Widget _selectionAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              boxShadow: Neumorphic.subtle,
            ),
            child: Icon(icon, color: AppColors.textSecondary, size: 20),
          ),
          SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
