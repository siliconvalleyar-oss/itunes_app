import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/audio_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/player_controls.dart';

class TrimmerScreen extends StatefulWidget {
  final AudioService audioService;

  const TrimmerScreen({super.key, required this.audioService});

  @override
  State<TrimmerScreen> createState() => _TrimmerScreenState();
}

class _TrimmerScreenState extends State<TrimmerScreen> {
  Song? _song;
  RangeValues _trimRange = const RangeValues(0.0, 1.0);
  Duration _startPosition = Duration.zero;
  Duration _endPosition = Duration.zero;
  bool _isPlaying = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final song = ModalRoute.of(context)?.settings.arguments as Song?;
    if (song != null && _song == null) {
      _song = song;
      _endPosition = song.duration;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1a1a2e),
            const Color(0xFF16213e),
            Theme.of(context).colorScheme.primary.withOpacity(0.2),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Recortar Audio'),
          actions: [
            TextButton(
              onPressed: _saveTrim,
              child: const Text(
                'Guardar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Song info
            if (_song != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            colors: [
                              Colors.purple.withOpacity(0.5),
                              Colors.blue.withOpacity(0.5),
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.music_note,
                          color: Colors.white38,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _song!.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${_song!.artist} • ${_formatDuration(_song!.duration)}',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Waveform visualization
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Selecciona el rango a recortar',
                        style: TextStyle(color: Colors.white54),
                      ),
                      const SizedBox(height: 16),

                      // Waveform placeholder
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white.withOpacity(0.05),
                          ),
                          child: Center(
                            child: _buildWaveform(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Trim controls
                      RangeSlider(
                        values: _trimRange,
                        min: 0,
                        max: 1,
                        onChanged: (values) {
                          setState(() {
                            _trimRange = values;
                            if (_song != null) {
                              final totalMs = _song!.duration.inMilliseconds;
                              _startPosition = Duration(
                                milliseconds: (values.start * totalMs).round(),
                              );
                              _endPosition = Duration(
                                milliseconds: (values.end * totalMs).round(),
                              );
                            }
                          });
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                        inactiveColor: Colors.white24,
                      ),

                      // Time display
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildTimeChip(
                            'Inicio',
                            _startPosition,
                            Icons.arrow_back,
                          ),
                          _buildTimeChip(
                            'Fin',
                            _endPosition,
                            Icons.arrow_forward,
                          ),
                          _buildTimeChip(
                            'Duración',
                            _endPosition - _startPosition,
                            Icons.timer,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Preview controls
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GlassButton(
                    onPressed: _previewTrim,
                    size: 50,
                    child: Icon(
                      _isPlaying ? Icons.stop : Icons.play_arrow,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  GlassButton(
                    onPressed: _resetRange,
                    size: 50,
                    child: const Icon(
                      Icons.refresh,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaveform() {
    // Placeholder - en producción usar audio_waveforms
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        50,
        (index) => Container(
          width: 4,
          height: (20 + (index * 3) % 40).toDouble(),
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: index >= (_trimRange.start * 50).toInt() &&
                    index <= (_trimRange.end * 50).toInt()
                ? Theme.of(context).colorScheme.primary
                : Colors.white24,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeChip(String label, Duration time, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white54, size: 14),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                ),
              ),
              Text(
                _formatDuration(time),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    final ms = duration.inMilliseconds % 1000;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${(ms ~/ 100).toString()}';
  }

  void _previewTrim() {
    // Simular preview del recorte
    setState(() => _isPlaying = !_isPlaying);
    if (_isPlaying) {
      Future.delayed(
        _endPosition - _startPosition,
        () {
          if (mounted) {
            setState(() => _isPlaying = false);
          }
        },
      );
    }
  }

  void _resetRange() {
    setState(() {
      _trimRange = const RangeValues(0.0, 1.0);
      _startPosition = Duration.zero;
      _endPosition = _song?.duration ?? Duration.zero;
    });
  }

  Future<void> _saveTrim() async {
    if (_song == null) return;

    // Placeholder - integrar con FFmpeg para recorte real
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Función de guardado pendiente de implementación'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}
