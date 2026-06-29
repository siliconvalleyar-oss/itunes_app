import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/audio_service.dart';
import 'glass_card.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final AudioService audioService;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const SongTile({
    super.key,
    required this.song,
    required this.audioService,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: audioService,
      builder: (context, child) {
        final isPlaying = audioService.currentSong?.id == song.id;

        return GlassCard(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.all(12),
          borderRadius: 16,
          child: InkWell(
            onTap: onTap ?? () => audioService.play(song),
            onLongPress: onLongPress,
            borderRadius: BorderRadius.circular(16),
            child: Row(
              children: [
                // Cover art
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white.withOpacity(0.1),
                  ),
                  child: song.coverArt != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            song.coverArt!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(
                          Icons.music_note,
                          color: Colors.white54,
                          size: 28,
                        ),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        style: TextStyle(
                          color: isPlaying
                              ? Theme.of(context).colorScheme.primary
                              : Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${song.artist} • ${song.album}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Duration
                if (song.duration > Duration.zero)
                  Text(
                    _formatDuration(song.duration),
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),

                // Playing indicator
                if (isPlaying) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.equalizer,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
