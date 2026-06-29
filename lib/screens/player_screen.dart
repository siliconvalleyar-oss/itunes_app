import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/player_controls.dart';

class PlayerScreen extends StatelessWidget {
  final AudioService audioService;

  const PlayerScreen({super.key, required this.audioService});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: audioService,
      builder: (context, child) {
        final song = audioService.currentSong;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF0f0c29),
                const Color(0xFF302b63),
                const Color(0xFF24243e),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.keyboard_arrow_down,
                            color: Colors.white, size: 32),
                      ),
                      const Text(
                        'Reproduciendo',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.more_vert,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Album Art
                GlassCard(
                  borderRadius: 24,
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.purple.withOpacity(0.5),
                          Colors.blue.withOpacity(0.5),
                        ],
                      ),
                    ),
                    child: song?.coverArt != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.memory(
                              song!.coverArt!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(
                            Icons.music_note,
                            color: Colors.white38,
                            size: 80,
                          ),
                  ),
                ),

                const Spacer(flex: 2),

                // Song info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      Text(
                        song?.title ?? 'Sin canción',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${song?.artist ?? "Desconocido"} • ${song?.album ?? ""}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Progress
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ProgressBar(audioService: audioService),
                ),

                const SizedBox(height: 16),

                // Controls
                PlayerControls(audioService: audioService),

                const Spacer(),

                // Bottom actions
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GlassButton(
                        onPressed: () {},
                        size: 44,
                        child: const Icon(Icons.share,
                            color: Colors.white54, size: 20),
                      ),
                      GlassButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/editor',
                              arguments: song);
                        },
                        size: 44,
                        child: const Icon(Icons.edit,
                            color: Colors.white54, size: 20),
                      ),
                      GlassButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/trimmer',
                              arguments: song);
                        },
                        size: 44,
                        child: const Icon(Icons.content_cut,
                            color: Colors.white54, size: 20),
                      ),
                    ],
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
