import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../services/playlist_service.dart';
import '../services/audio_service.dart';
import '../services/library_service.dart';
import '../components/neu_card.dart';
import '../components/neu_button.dart';
import '../widgets/song_tile.dart';
import 'player_screen.dart';

class PlaylistsScreen extends StatefulWidget {
  final PlaylistService playlistService;
  final AudioService audioService;
  final LibraryService libraryService;

  PlaylistsScreen({
    super.key,
    required this.playlistService,
    required this.audioService,
    required this.libraryService,
  });

  @override
  State<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _openPlaylist(Playlist pl) {
    if (pl.songs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Esta playlist está vacía'),
          backgroundColor: AppColors.textDisabled,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _PlaylistDetailScreen(
          playlist: pl,
          audioService: widget.audioService,
          libraryService: widget.libraryService,
          playlistService: widget.playlistService,
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
            SizedBox(height: 16),
            Expanded(
              child: ListenableBuilder(
                listenable: widget.playlistService,
                builder: (context, _) {
                  final playlists = widget.playlistService.playlists;
                  if (playlists.isEmpty) {
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
                            child: Icon(Icons.queue_music, color: AppColors.textDisabled, size: 32),
                          ),
                          SizedBox(height: 16),
                          Text('No hay playlists',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                          SizedBox(height: 8),
                          Text('Toca + para crear una',
                              style: TextStyle(color: AppColors.textDisabled, fontSize: 13)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    itemCount: playlists.length,
                    itemBuilder: (context, index) {
                      final pl = playlists[index];
                      return GestureDetector(
                        onTap: () => _openPlaylist(pl),
                        child: NeuCard(
                          margin: EdgeInsets.only(bottom: 16),
                          padding: EdgeInsets.all(16),
                          borderRadius: 20,
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: Neumorphic.inset,
                                  ),
                                  child: pl.coverPath != null
                                      ? Image.file(File(pl.coverPath!), fit: BoxFit.cover)
                                      : Icon(Icons.music_note, color: AppColors.accent, size: 24),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      pl.name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '${pl.songs.length} canciones',
                                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              NeuButton(
                                onPressed: () => _showRenameDialog(pl),
                                size: 32,
                                child: Icon(Icons.edit_outlined, color: AppColors.textSecondary, size: 14),
                              ),
                              SizedBox(width: 8),
                              NeuButton(
                                onPressed: () => _showDeleteDialog(pl.id),
                                size: 32,
                                child: Icon(Icons.delete_outline, color: AppColors.error, size: 16),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
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
            'Playlists',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Spacer(),
          NeuButton(
            onPressed: _showCreateDialog,
            size: 40,
            child: Icon(Icons.add, color: AppColors.accent, size: 20),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog() {
    _nameController.clear();
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
              Text(
                'Nueva Playlist',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: Neumorphic.inset,
                ),
                child: TextField(
                  controller: _nameController,
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
                        final name = _nameController.text.trim();
                        if (name.isNotEmpty) {
                          widget.playlistService.addPlaylist(name);
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
                          child: Text('Crear',
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

  void _showRenameDialog(Playlist pl) {
    final ctrl = TextEditingController(text: pl.name);
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
              Text(
                'Renombrar',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: Neumorphic.inset,
                ),
                child: TextField(
                  controller: ctrl,
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
                        final name = ctrl.text.trim();
                        if (name.isNotEmpty) {
                          widget.playlistService.renamePlaylist(pl.id, name);
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

  void _showDeleteDialog(String id) {
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
              Text('Eliminar playlist',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              SizedBox(height: 16),
              Text('¿Estás seguro?',
                  style: TextStyle(color: AppColors.textSecondary)),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: Neumorphic.subtle,
                        ),
                        child: Center(
                          child: Text('No', style: TextStyle(color: AppColors.textSecondary)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        widget.playlistService.removePlaylist(id);
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text('Eliminar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
}

class _PlaylistDetailScreen extends StatefulWidget {
  final Playlist playlist;
  final AudioService audioService;
  final LibraryService libraryService;
  final PlaylistService playlistService;

  _PlaylistDetailScreen({
    super.key,
    required this.playlist,
    required this.audioService,
    required this.libraryService,
    required this.playlistService,
  });

  @override
  State<_PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<_PlaylistDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            SizedBox(height: 16),
            Expanded(
              child: widget.playlist.songs.isEmpty
                  ? Center(
                      child: Text('Playlist vacía',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      itemCount: widget.playlist.songs.length,
                      itemBuilder: (context, index) {
                        final song = widget.playlist.songs[index];
                        return SongTile(
                          song: song,
                          audioService: widget.audioService,
                          isFavorite: widget.libraryService.isFavorite(song.id),
                          onFavoriteToggle: () => widget.libraryService.toggleFavorite(song),
                          onTap: () {
                            widget.libraryService.recordPlay(song);
                            widget.audioService.setPlaylist(widget.playlist.songs);
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
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              NeuButton(
                onPressed: () => Navigator.pop(context),
                size: 40,
                child: Icon(Icons.arrow_back_ios_new, color: AppColors.textSecondary, size: 16),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.playlist.name,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
              ),
              if (widget.playlist.songs.isNotEmpty)
                NeuButton(
                  onPressed: () {
                    widget.audioService.setPlaylist(widget.playlist.songs);
                    widget.audioService.play(widget.playlist.songs.first);
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
                  size: 40,
                  child: Icon(Icons.play_arrow, color: AppColors.accent, size: 20),
                ),
            ],
          ),
          SizedBox(height: 12),
          GestureDetector(
            onTap: _pickPlaylistCover,
            child: Center(
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: Neumorphic.inset,
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: widget.playlist.coverPath != null
                          ? Image.file(File(widget.playlist.coverPath!), fit: BoxFit.cover, width: 180, height: 180)
                          : Center(child: Icon(Icons.music_note, color: AppColors.textDisabled, size: 48)),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.background.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.camera_alt_outlined, size: 14, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 12),
          Text('${widget.playlist.songs.length} canciones',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          SizedBox(height: 8),
        ],
      ),
    );
  }

  void _pickPlaylistCover() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Imagen de portada',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            SizedBox(height: 24),
            GestureDetector(
              onTap: () async {
                Navigator.pop(ctx);
                final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                if (picked != null) {
                  await widget.playlistService.savePlaylistCover(widget.playlist.id, picked.path);
                  if (mounted) setState(() {});
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo_library_outlined, color: AppColors.textSecondary, size: 20),
                    SizedBox(width: 12),
                    Text('Seleccionar de galería',
                        style: TextStyle(fontSize: 15, color: AppColors.textPrimary)),
                  ],
                ),
              ),
            ),
            if (widget.playlist.coverPath != null) ...[
              SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  Navigator.pop(ctx);
                  widget.playlist.coverPath = null;
                  widget.playlistService.notifyListeners();
                  if (mounted) setState(() {});
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                      SizedBox(width: 12),
                      Text('Quitar imagen',
                          style: TextStyle(fontSize: 15, color: AppColors.error)),
                    ],
                  ),
                ),
              ),
            ],
            SizedBox(height: 8),
            GestureDetector(
              onTap: () => Navigator.pop(ctx),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
