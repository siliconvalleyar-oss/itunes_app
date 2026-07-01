import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/song.dart';
import '../services/audio_service.dart';
import '../components/neu_card.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final AudioService audioService;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onHide;

  const SongTile({
    super.key,
    required this.song,
    required this.audioService,
    this.isFavorite = false,
    this.onTap,
    this.onFavoriteToggle,
    this.onHide,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: audioService,
      builder: (context, _) {
        final isPlaying = audioService.currentSong?.id == song.id;
        return GestureDetector(
          onLongPress: () {
            if (onHide != null) {
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
                        Icon(Icons.visibility_off, color: AppColors.textDisabled, size: 40),
                        SizedBox(height: 16),
                        Text('Ocultar canción',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        SizedBox(height: 8),
                        Text(song.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        SizedBox(height: 20),
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
                                  Navigator.pop(ctx);
                                  onHide?.call();
                                },
                                child: Container(
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: Text('Ocultar',
                                        style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
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
          },
          child: NeuCard(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            borderRadius: 18,
            onTap: onTap,
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
                  child: isPlaying
                      ? Icon(Icons.equalizer, color: AppColors.accent, size: 20)
                      : Icon(Icons.music_note, color: AppColors.textDisabled, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isPlaying ? AppColors.accent : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        song.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                if (onFavoriteToggle != null)
                  GestureDetector(
                    onTap: onFavoriteToggle,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(left: 4),
                      decoration: BoxDecoration(
                        color: isFavorite ? AppColors.error.withValues(alpha: 0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? AppColors.error : AppColors.textDisabled,
                        size: 22,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
