import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/audio_service.dart';
import '../components/neu_card.dart';
import '../components/neu_button.dart';
import '../components/neu_slider.dart';
import '../widgets/player_controls.dart';

class PlayerScreen extends StatefulWidget {
  final AudioService audioService;

  PlayerScreen({super.key, required this.audioService});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool _showEqualizer = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.audioService,
          builder: (context, _) {
            final song = widget.audioService.currentSong;
            return Column(
              children: [
                _buildHeader(),
                SizedBox(height: 16),
                _buildAlbumArt(song),
                SizedBox(height: 28),
                _buildSongInfo(song),
                SizedBox(height: 24),
                _buildProgress(),
                SizedBox(height: 24),
                PlayerControls(audioService: widget.audioService),
                Spacer(),
                _buildBottomActions(),
                if (_showEqualizer) _buildEqualizer(),
                SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          NeuButton(
            onPressed: () => Navigator.pop(context),
            size: 40,
            child: Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary, size: 24),
          ),
          Text(
            'Reproduciendo',
            style: TextStyle(fontSize: 14, color: AppColors.textDisabled),
          ),
          NeuButton(
            onPressed: () => setState(() => _showEqualizer = !_showEqualizer),
            size: 40,
            isActive: _showEqualizer,
            child: Icon(
              Icons.equalizer,
              color: _showEqualizer ? AppColors.accent : AppColors.textSecondary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumArt(song) {
    return Center(
      child: NeuCard(
        padding: EdgeInsets.all(20),
        borderRadius: 28,
        child: Container(
          width: 260,
          height: 260,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: Neumorphic.inset,
          ),
          child: song?.coverArt != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.memory(song!.coverArt!, fit: BoxFit.cover),
                )
              : Icon(Icons.music_note, color: AppColors.textDisabled, size: 64),
        ),
      ),
    );
  }

  Widget _buildSongInfo(song) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Text(
            song?.title ?? 'Sin canción',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 6),
          Text(
            song?.artist ?? 'Artista',
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32),
      child: Column(
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
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_fmt(widget.audioService.position),
                  style: TextStyle(fontSize: 12, color: AppColors.textDisabled)),
              Text(_fmt(widget.audioService.duration),
                  style: TextStyle(fontSize: 12, color: AppColors.textDisabled)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          NeuButton(
            onPressed: () {},
            size: 40,
            child: Icon(Icons.share_outlined, color: AppColors.textSecondary, size: 18),
          ),
          NeuButton(
            onPressed: () {},
            size: 40,
            child: Icon(Icons.favorite_border, color: AppColors.textSecondary, size: 18),
          ),
          NeuButton(
            onPressed: () {},
            size: 40,
            child: Icon(Icons.queue_music_outlined, color: AppColors.textSecondary, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildEqualizer() {
    final presets = ['Normal', 'Rock', 'Pop', 'Jazz', 'Bass'];
    return Container(
      margin: EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: NeuCard(
        padding: EdgeInsets.all(16),
        borderRadius: 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ecualizador',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            SizedBox(height: 12),
            SizedBox(
              height: 32,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: presets.length,
                itemBuilder: (context, i) {
                  return Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: i == 0 ? AppColors.accent.withOpacity(0.15) : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: i == 0 ? [] : Neumorphic.inset,
                      ),
                      child: Center(
                        child: Text(presets[i],
                            style: TextStyle(
                                fontSize: 11,
                                color: i == 0 ? AppColors.accent : AppColors.textDisabled)),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(5, (i) {
                  return Column(
                    children: [
                      Expanded(
                        child: RotatedBox(
                          quarterTurns: -1,
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 3,
                              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
                              activeTrackColor: AppColors.accent,
                              inactiveTrackColor: AppColors.surface,
                              thumbColor: AppColors.background,
                            ),
                            child: Slider(value: 0, min: -12, max: 12, onChanged: (v) {}),
                          ),
                        ),
                      ),
                      Text(['60', '1K', '3K', '6K', '14K'][i],
                          style: TextStyle(fontSize: 9, color: AppColors.textDisabled)),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(Duration d) =>
      '${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
}
