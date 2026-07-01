import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/audio_service.dart';
import '../services/playlist_service.dart';
import '../models/song.dart';
import '../components/neu_card.dart';
import '../components/neu_button.dart';
import '../components/neu_slider.dart';
import '../widgets/player_controls.dart';

class PlayerScreen extends StatefulWidget {
  final AudioService audioService;
  final PlaylistService playlistService;

  PlayerScreen({super.key, required this.audioService, required this.playlistService});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool _showEqualizer = false;
  List<double> _bandGains = List.filled(5, 0.0);

  static const _presets = [
    _EQPreset('Normal', [0, 0, 0, 0, 0]),
    _EQPreset('Rock', [5, 3, -1, 2, 4]),
    _EQPreset('Pop', [-1, 3, 4, 2, 1]),
    _EQPreset('Jazz', [4, 2, -1, 1, 4]),
    _EQPreset('Bass', [7, 5, 2, -1, -2]),
    _EQPreset('Vocal', [-2, 1, 5, 4, 1]),
  ];

  static const _freqLabels = ['60', '230', '910', '3.6K', '14K'];

  @override
  void initState() {
    super.initState();
    _loadEqualizerBands();
  }

  void _loadEqualizerBands() {
    final params = widget.audioService.equalizerParameters;
    if (params != null && params.bands.length >= 5) {
      _bandGains = params.bands.take(5).map((b) => b.gain).toList();
    }
  }

  Future<void> _setBandGain(int index, double value) async {
    _bandGains[index] = value;
    await widget.audioService.setEqualizerBandGain(index, value);
  }

  Future<void> _applyPreset(_EQPreset preset) async {
    for (int i = 0; i < preset.gains.length && i < _bandGains.length; i++) {
      _bandGains[i] = preset.gains[i].toDouble();
      await widget.audioService.setEqualizerBandGain(i, _bandGains[i]);
    }
    if (mounted) setState(() {});
  }

  void _showAddToPlaylist() {
    final song = widget.audioService.currentSong;
    if (song == null) return;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Agregar a playlist',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              SizedBox(height: 16),
              Text(song.title,
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              SizedBox(height: 16),
              ListenableBuilder(
                listenable: widget.playlistService,
                builder: (context, _) {
                  final playlists = widget.playlistService.playlists;
                  if (playlists.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text('No hay playlists. Crea una primero.',
                            style: TextStyle(color: AppColors.textDisabled)),
                      ),
                    );
                  }
                  return ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 250),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: playlists.length,
                      itemBuilder: (context, i) {
                        final pl = playlists[i];
                        final isInPlaylist = pl.songs.any((s) => s.id == song.id);
                        return GestureDetector(
                          onTap: () {
                            if (isInPlaylist) {
                              widget.playlistService.removeSongFromPlaylist(pl.id, song.id);
                            } else {
                              widget.playlistService.addSongToPlaylist(pl.id, song);
                            }
                            setState(() {});
                          },
                          child: Container(
                            margin: EdgeInsets.only(bottom: 8),
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isInPlaylist ? AppColors.accent.withValues(alpha: 0.1) : AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isInPlaylist ? Icons.check_circle : Icons.add_circle_outline,
                                  color: isInPlaylist ? AppColors.accent : AppColors.textSecondary,
                                  size: 20,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(pl.name,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w500)),
                                ),
                                Text('${pl.songs.length}',
                                    style: TextStyle(fontSize: 12, color: AppColors.textDisabled)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: 12),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    height: 40,
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text('Cerrar', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
            onPressed: () {
              setState(() => _showEqualizer = !_showEqualizer);
              if (_showEqualizer) _loadEqualizerBands();
            },
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
            onPressed: _showAddToPlaylist,
            size: 40,
            child: Icon(Icons.queue_music_outlined, color: AppColors.textSecondary, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildEqualizer() {
    return Container(
      margin: EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: NeuCard(
        padding: EdgeInsets.all(16),
        borderRadius: 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Ecualizador',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                GestureDetector(
                  onTap: () {
                    widget.audioService.toggleEqualizer();
                    if (mounted) setState(() {});
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.audioService.equalizerEnabled
                          ? AppColors.accent.withValues(alpha: 0.15)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      widget.audioService.equalizerEnabled ? 'ON' : 'OFF',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: widget.audioService.equalizerEnabled
                            ? AppColors.accent
                            : AppColors.textDisabled,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            SizedBox(
              height: 32,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _presets.length,
                itemBuilder: (context, i) {
                  return Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => _applyPreset(_presets[i]),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: i == 0 ? AppColors.accent.withValues(alpha: 0.15) : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: i == 0 ? [] : Neumorphic.inset,
                        ),
                        child: Center(
                          child: Text(_presets[i].name,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: i == 0 ? AppColors.accent : AppColors.textDisabled)),
                        ),
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
                children: List.generate(_bandGains.length, (i) {
                  return Column(
                    children: [
                      Expanded(
                        child: RotatedBox(
                          quarterTurns: -1,
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 3,
                              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
                              activeTrackColor: _bandGains[i] >= 0
                                  ? AppColors.accent
                                  : AppColors.accentAlt,
                              inactiveTrackColor: AppColors.surface,
                              thumbColor: AppColors.background,
                            ),
                            child: Slider(
                              value: _bandGains[i],
                              min: -12,
                              max: 12,
                              divisions: 24,
                              onChanged: (v) {
                                setState(() => _bandGains[i] = v);
                                _setBandGain(i, v);
                              },
                            ),
                          ),
                        ),
                      ),
                      Text(_freqLabels[i],
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

class _EQPreset {
  final String name;
  final List<int> gains;
  const _EQPreset(this.name, this.gains);
}
