import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/song.dart';
import '../services/audio_service.dart';
import '../services/library_service.dart';
import '../services/playlist_service.dart';
import '../components/neu_button.dart';
import '../widgets/song_tile.dart';
import 'player_screen.dart';

class GroupSongsScreen extends StatefulWidget {
  final String groupName;
  final List<Song> songs;
  final AudioService audioService;
  final LibraryService libraryService;
  final PlaylistService playlistService;

  GroupSongsScreen({
    super.key,
    required this.groupName,
    required this.songs,
    required this.audioService,
    required this.libraryService,
    required this.playlistService,
  });

  @override
  State<GroupSongsScreen> createState() => _GroupSongsScreenState();
}

class _GroupSongsScreenState extends State<GroupSongsScreen> {
  bool _selectionMode = false;
  final Set<String> _selectedIds = {};

  void _exitSelection() {
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
  }

  void _addSelectedToPlaylist() {
    final selectedSongs = widget.songs.where((s) => _selectedIds.contains(s.id)).toList();
    if (selectedSongs.isEmpty) return;

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
              Text('Agregar ${selectedSongs.length} canciones',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  _showCreatePlaylist(selectedSongs);
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
                          style: TextStyle(fontSize: 14, color: AppColors.accent, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
              ...widget.playlistService.playlists.map((pl) => GestureDetector(
                onTap: () {
                  for (final s in selectedSongs) {
                    widget.playlistService.addSongToPlaylist(pl.id, s);
                  }
                  Navigator.pop(ctx);
                  _exitSelection();
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
                      Icon(Icons.queue_music_outlined, color: AppColors.textSecondary, size: 20),
                      SizedBox(width: 12),
                      Expanded(child: Text(pl.name, style: TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w500))),
                    ],
                  ),
                ),
              )),
              SizedBox(height: 12),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    height: 40,
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
                    child: Center(child: Text('Cerrar', style: TextStyle(color: AppColors.textSecondary))),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreatePlaylist(List<Song> songs) {
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
              Text('Nueva Playlist', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18), boxShadow: Neumorphic.inset),
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
                        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18), boxShadow: Neumorphic.subtle),
                        child: Center(child: Text('Cancelar', style: TextStyle(color: AppColors.textSecondary))),
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
                          _exitSelection();
                        }
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(18), boxShadow: Neumorphic.subtle),
                        child: Center(child: Text('Crear y agregar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
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
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: NeuButton(
          onPressed: () => Navigator.pop(context),
          size: 40,
          child: Icon(Icons.arrow_back, color: AppColors.textSecondary, size: 20),
        ),
        title: Text(
          widget.groupName,
          style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          if (!_selectionMode)
            NeuButton(
              onPressed: () => setState(() => _selectionMode = true),
              size: 40,
              child: Icon(Icons.checklist, color: AppColors.textSecondary, size: 18),
            )
          else
            NeuButton(
              onPressed: _exitSelection,
              size: 40,
              child: Icon(Icons.close, color: AppColors.textSecondary, size: 18),
            ),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                itemCount: widget.songs.length,
                itemBuilder: (context, index) {
                  final song = widget.songs[index];
                  return SongTile(
                    song: song,
                    audioService: widget.audioService,
                    isFavorite: widget.libraryService.isFavorite(song.id),
                    onFavoriteToggle: () => widget.libraryService.toggleFavorite(song),
                    onHide: () => widget.libraryService.toggleIgnored(song),
                    selectionMode: _selectionMode,
                    isSelected: _selectedIds.contains(song.id),
                    onLongPress: _selectionMode
                        ? null
                        : () {
                            setState(() {
                              _selectionMode = true;
                              _selectedIds.add(song.id);
                            });
                          },
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
                            widget.audioService.play(song, playlist: widget.songs);
                            widget.libraryService.recordPlay(song);
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
            if (_selectionMode && _selectedIds.isNotEmpty)
              Container(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: Neumorphic.raised,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _addSelectedToPlaylist,
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
                            child: Icon(Icons.queue_music, color: AppColors.textSecondary, size: 20),
                          ),
                          SizedBox(height: 4),
                          Text('Agregar a lista', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
