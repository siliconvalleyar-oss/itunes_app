import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/audio_service.dart';
import 'neu_card.dart';

class MiniPlayer extends StatelessWidget {
  final AudioService audioService;
  final VoidCallback? onTap;

  MiniPlayer({
    super.key,
    required this.audioService,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: audioService,
      builder: (context, _) {
        final song = audioService.currentSong;
        if (song == null) return SizedBox.shrink();

        return GestureDetector(
          onTap: onTap,
          child: Container(
            margin: EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: NeuCard(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              borderRadius: 18,
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.accent.withValues(alpha: 0.3),
                          AppColors.accentAlt.withValues(alpha: 0.3),
                        ],
                      ),
                      boxShadow: Neumorphic.subtle,
                    ),
                    child: Icon(Icons.music_note, color: AppColors.textSecondary, size: 20),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          song.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          song.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (audioService.isPlaying) {
                        audioService.pause();
                      } else {
                        audioService.resume();
                      }
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        shape: BoxShape.circle,
                        boxShadow: Neumorphic.subtle,
                      ),
                      child: Icon(
                        audioService.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: AppColors.accent,
                        size: 18,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: audioService.next,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        shape: BoxShape.circle,
                        boxShadow: Neumorphic.subtle,
                      ),
                      child: Icon(
                        Icons.skip_next,
                        color: AppColors.textSecondary,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
