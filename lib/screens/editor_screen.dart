import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/song.dart';
import '../services/audio_service.dart';
import '../components/neu_card.dart';

class EditorScreen extends StatelessWidget {
  final AudioService audioService;

  EditorScreen({super.key, required this.audioService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: audioService,
          builder: (context, _) {
            final song = audioService.currentSong;
            return Column(
              children: [
                _buildHeader(song),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        SizedBox(height: 24),
                        _buildCoverArt(song),
                        SizedBox(height: 24),
                        _buildProperties(song),
                        SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(Song? song) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          Text(
            'Propiedades',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          Spacer(),
          if (song != null)
            Text(
              song.title,
              style: TextStyle(fontSize: 12, color: AppColors.textDisabled),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  Widget _buildCoverArt(Song? song) {
    return Center(
      child: NeuCard(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: Neumorphic.inset,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: song?.localCoverPath != null
                    ? Image.file(File(song!.localCoverPath!), fit: BoxFit.cover)
                    : Icon(Icons.music_note, color: AppColors.textDisabled, size: 56),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProperties(Song? song) {
    if (song == null) {
      return Column(
        children: [
          SizedBox(height: 60),
          Icon(Icons.info_outline, color: AppColors.textDisabled, size: 48),
          SizedBox(height: 16),
          Text('Reproduce una canción para ver sus propiedades',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        ],
      );
    }

    return Column(
      children: [
        _propRow('Título', song.title),
        _propRow('Artista', song.artist.isNotEmpty ? song.artist : 'Desconocido'),
        _propRow('Álbum', song.album.isNotEmpty ? song.album : 'Sin álbum'),
        _propRow('Duración', _formatDuration(song.duration.inSeconds)),
        _propRow('Ruta', song.filePath),
        _propRow('ID', song.id),
      ],
    );
  }

  Widget _propRow(String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: Neumorphic.inset,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(label,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(value,
                style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
