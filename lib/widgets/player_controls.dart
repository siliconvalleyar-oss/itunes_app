import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../services/audio_service.dart';
import 'glass_card.dart';

class PlayerControls extends StatelessWidget {
  final AudioService audioService;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final VoidCallback? onShuffle;
  final VoidCallback? onLoop;

  const PlayerControls({
    super.key,
    required this.audioService,
    this.onNext,
    this.onPrevious,
    this.onShuffle,
    this.onLoop,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: audioService,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Shuffle
            GlassButton(
              onPressed: onShuffle ?? audioService.toggleShuffle,
              size: 44,
              child: Icon(
                Icons.shuffle,
                color: audioService.isShuffled
                    ? Theme.of(context).colorScheme.primary
                    : Colors.white70,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Previous
            GlassButton(
              onPressed: onPrevious ?? audioService.previous,
              size: 50,
              child: const Icon(
                Icons.skip_previous,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),

            // Play/Pause
            GlassButton(
              onPressed: () {
                if (audioService.isPlaying) {
                  audioService.pause();
                } else {
                  audioService.resume();
                }
              },
              size: 70,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
              child: Icon(
                audioService.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 36,
              ),
            ),
            const SizedBox(width: 16),

            // Next
            GlassButton(
              onPressed: onNext ?? audioService.next,
              size: 50,
              child: const Icon(
                Icons.skip_next,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),

            // Loop
            GlassButton(
              onPressed: onLoop ?? audioService.cycleLoopMode,
              size: 44,
              child: Icon(
                audioService.loopMode == LoopMode.one
                    ? Icons.repeat_one
                    : Icons.repeat,
                color: audioService.loopMode != LoopMode.off
                    ? Theme.of(context).colorScheme.primary
                    : Colors.white70,
                size: 20,
              ),
            ),
          ],
        );
      },
    );
  }
}

class ProgressBar extends StatelessWidget {
  final AudioService audioService;

  const ProgressBar({super.key, required this.audioService});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: audioService,
      builder: (context, child) {
        final position = audioService.position;
        final duration = audioService.duration;

        return Column(
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                activeTrackColor: Theme.of(context).colorScheme.primary,
                inactiveTrackColor: Colors.white24,
                thumbColor: Colors.white,
              ),
              child: Slider(
                value: duration.inMilliseconds > 0
                    ? position.inMilliseconds / duration.inMilliseconds
                    : 0.0,
                onChanged: (value) {
                  final newPosition = Duration(
                    milliseconds: (value * duration.inMilliseconds).round(),
                  );
                  audioService.seek(newPosition);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(position),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    _formatDuration(duration),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
