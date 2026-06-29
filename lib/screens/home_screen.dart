import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/song.dart';
import '../services/audio_service.dart';
import '../services/library_service.dart';
import '../services/music_scanner.dart';
import '../components/neu_card.dart';
import '../components/neu_button.dart';
import '../components/neu_slider.dart';
import '../components/mini_player.dart';
import '../widgets/song_tile.dart';
import 'player_screen.dart';

class HomeScreen extends StatefulWidget {
  final AudioService audioService;
  final LibraryService libraryService;

  const HomeScreen({
    super.key,
    required this.audioService,
    required this.libraryService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MusicScanner _scanner = MusicScanner();
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _scanMusic();
  }

  Future<void> _scanMusic() async {
    setState(() => _isScanning = true);
    try {
      final songs = await _scanner.scanDevice();
      widget.libraryService.setSongs(songs);
      widget.audioService.setPlaylist(songs);
    } catch (_) {}
    setState(() => _isScanning = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    _buildNowPlaying(),
                    const SizedBox(height: 32),
                    _buildControls(),
                    const SizedBox(height: 24),
                    _buildProgressBar(),
                    const SizedBox(height: 24),
                    _buildInfoChips(),
                    const SizedBox(height: 24),
                    _buildVisualizer(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: MiniPlayer(
        audioService: widget.audioService,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PlayerScreen(audioService: widget.audioService),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          NeuButton(
            onPressed: () {},
            size: 44,
            child: const Icon(Icons.menu, color: AppColors.textSecondary, size: 20),
          ),
          const Text(
            'Music Studio',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          NeuButton(
            onPressed: () {},
            size: 44,
            child: const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildNowPlaying() {
    return ListenableBuilder(
      listenable: widget.audioService,
      builder: (context, _) {
        final song = widget.audioService.currentSong;
        return NeuCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.accent.withOpacity(0.15),
                      AppColors.accentAlt.withOpacity(0.15),
                    ],
                  ),
                  boxShadow: Neumorphic.inset,
                ),
                child: song?.coverArt != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.memory(song!.coverArt!, fit: BoxFit.cover),
                      )
                    : const Icon(
                        Icons.music_note,
                        color: AppColors.textDisabled,
                        size: 72,
                      ),
              ),
              const SizedBox(height: 24),
              Text(
                song?.title ?? 'Selecciona una canción',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                song?.artist ?? 'Artista',
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                song?.album ?? 'Álbum',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textDisabled,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControls() {
    return ListenableBuilder(
      listenable: widget.audioService,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NeuButton(
              onPressed: widget.audioService.toggleShuffle,
              size: 48,
              isActive: widget.audioService.isShuffled,
              child: Icon(
                Icons.shuffle,
                color: widget.audioService.isShuffled
                    ? AppColors.accent
                    : AppColors.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 20),
            NeuButton(
              onPressed: widget.audioService.previous,
              size: 56,
              child: const Icon(Icons.skip_previous, color: AppColors.textPrimary, size: 28),
            ),
            const SizedBox(width: 20),
            NeuButton(
              onPressed: () {
                if (widget.audioService.isPlaying) {
                  widget.audioService.pause();
                } else {
                  widget.audioService.resume();
                }
              },
              size: 72,
              isInset: widget.audioService.isPlaying,
              child: Icon(
                widget.audioService.isPlaying ? Icons.pause : Icons.play_arrow,
                color: AppColors.accent,
                size: 36,
              ),
            ),
            const SizedBox(width: 20),
            NeuButton(
              onPressed: widget.audioService.next,
              size: 56,
              child: const Icon(Icons.skip_next, color: AppColors.textPrimary, size: 28),
            ),
            const SizedBox(width: 20),
            NeuButton(
              onPressed: widget.audioService.cycleLoopMode,
              size: 48,
              isActive: widget.audioService.loopMode != 0,
              child: Icon(
                widget.audioService.loopMode == 2 ? Icons.repeat_one : Icons.repeat,
                color: widget.audioService.loopMode != 0
                    ? AppColors.accent
                    : AppColors.textSecondary,
                size: 20,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProgressBar() {
    return ListenableBuilder(
      listenable: widget.audioService,
      builder: (context, _) {
        return Column(
          children: [
            NeuSlider(
              value: widget.audioService.duration.inMilliseconds > 0
                  ? widget.audioService.position.inMilliseconds /
                      widget.audioService.duration.inMilliseconds
                  : 0,
              onChanged: (v) {
                final pos = Duration(
                  milliseconds: (v * widget.audioService.duration.inMilliseconds).round(),
                );
                widget.audioService.seek(pos);
              },
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _fmt(widget.audioService.position),
                  style: const TextStyle(fontSize: 12, color: AppColors.textDisabled),
                ),
                Text(
                  _fmt(widget.audioService.duration),
                  style: const TextStyle(fontSize: 12, color: AppColors.textDisabled),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoChips() {
    return ListenableBuilder(
      listenable: widget.audioService,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildChip('320', 'kbps'),
            const SizedBox(width: 12),
            _buildChip('MP3', 'fmt'),
            const SizedBox(width: 12),
            _buildChip('44.1', 'kHz'),
          ],
        );
      },
    );
  }

  Widget _buildChip(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: Neumorphic.subtle,
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textDisabled)),
        ],
      ),
    );
  }

  Widget _buildVisualizer() {
    return NeuCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(24, (i) {
            final h = 10 + (i * 3 % 30).toDouble();
            return AnimatedContainer(
              duration: Duration(milliseconds: 300 + (i * 50)),
              width: 4,
              height: h,
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.3 + (i % 3) * 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),
      ),
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
