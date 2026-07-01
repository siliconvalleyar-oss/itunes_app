import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../theme/app_theme.dart';
import '../services/audio_service.dart';
import '../components/neu_button.dart';

class PlayerControls extends StatelessWidget {
  final AudioService audioService;

  const PlayerControls({super.key, required this.audioService});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: audioService,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NeuButton(
              onPressed: audioService.toggleShuffle,
              size: 44,
              isActive: audioService.isShuffled,
              child: Icon(
                Icons.shuffle,
                color: audioService.isShuffled ? AppColors.accent : AppColors.textDisabled,
                size: 18,
              ),
            ),
            const SizedBox(width: 16),
            NeuButton(
              onPressed: audioService.previous,
              size: 52,
              child: Icon(Icons.skip_previous, color: AppColors.textPrimary, size: 26),
            ),
            const SizedBox(width: 16),
            NeuButton(
              onPressed: () {
                if (audioService.isPlaying) {
                  audioService.pause();
                } else {
                  audioService.resume();
                }
              },
              size: 68,
              isInset: audioService.isPlaying,
              child: Icon(
                audioService.isPlaying ? Icons.pause : Icons.play_arrow,
                color: AppColors.accent,
                size: 34,
              ),
            ),
            const SizedBox(width: 16),
            NeuButton(
              onPressed: audioService.next,
              size: 52,
              child: Icon(Icons.skip_next, color: AppColors.textPrimary, size: 26),
            ),
            const SizedBox(width: 16),
            NeuButton(
              onPressed: audioService.cycleLoopMode,
              size: 44,
              isActive: audioService.loopMode != LoopMode.off,
              child: Icon(
                audioService.loopMode == LoopMode.one ? Icons.repeat_one : Icons.repeat,
                color: audioService.loopMode != LoopMode.off ? AppColors.accent : AppColors.textDisabled,
                size: 18,
              ),
            ),
          ],
        );
      },
    );
  }
}
