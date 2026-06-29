import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/playlist_service.dart';
import '../services/audio_service.dart';
import '../components/neu_card.dart';
import '../components/neu_button.dart';

class PlaylistsScreen extends StatefulWidget {
  final PlaylistService playlistService;
  final AudioService audioService;

  PlaylistsScreen({
    super.key,
    required this.playlistService,
    required this.audioService,
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
                      return NeuCard(
                        margin: EdgeInsets.only(bottom: 16),
                        padding: EdgeInsets.all(16),
                        borderRadius: 20,
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: Neumorphic.inset,
                              ),
                              child: Icon(Icons.music_note, color: AppColors.accent, size: 24),
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
                              onPressed: () => _showDeleteDialog(pl.id),
                              size: 32,
                              child: Icon(Icons.delete_outline, color: AppColors.error, size: 16),
                            ),
                          ],
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
