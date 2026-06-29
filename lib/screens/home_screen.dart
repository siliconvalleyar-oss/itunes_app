import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/audio_service.dart';
import '../services/file_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/song_tile.dart';

class HomeScreen extends StatefulWidget {
  final AudioService audioService;

  const HomeScreen({super.key, required this.audioService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FileService _fileService = FileService();
  List<Song> _songs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDemoSongs();
  }

  void _loadDemoSongs() {
    // Demo data - en producción se cargan desde archivos
    _songs = [
      Song(
        id: '1',
        filePath: '/demo/song1.mp3',
        title: 'Canción Ejemplo',
        artist: 'Artista 1',
        album: 'Álbum Demo',
        duration: const Duration(minutes: 3, seconds: 45),
      ),
      Song(
        id: '2',
        filePath: '/demo/song2.mp3',
        title: 'Otra Canción',
        artist: 'Artista 2',
        album: 'Álbum Demo',
        duration: const Duration(minutes: 4, seconds: 12),
      ),
    ];
    widget.audioService.setPlaylist(_songs);
  }

  Future<void> _pickFiles() async {
    setState(() => _isLoading = true);
    try {
      final paths = await _fileService.pickAudioFiles();
      if (paths.isNotEmpty) {
        final newSongs = await _fileService.loadSongsFromPaths(paths);
        setState(() {
          _songs.addAll(newSongs);
        });
        widget.audioService.setPlaylist(_songs);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
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
            Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Mi Música',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _pickFiles,
                        icon: const Icon(Icons.add, color: Colors.white),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.search, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Stats
            GlassCard(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat('Canciones', '${_songs.length}'),
                  _buildStat('Álbumes', '${_getAlbumCount()}'),
                  _buildStat('Duración', _getTotalDuration()),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Song list
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: _songs.length,
                      itemBuilder: (context, index) {
                        return SongTile(
                          song: _songs[index],
                          audioService: widget.audioService,
                          onLongPress: () => _showSongOptions(index),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }

  int _getAlbumCount() {
    final albums = _songs.map((s) => s.album).toSet();
    return albums.length;
  }

  String _getTotalDuration() {
    final total = _songs.fold(Duration.zero, (sum, s) => sum + s.duration);
    final hours = total.inHours;
    final minutes = total.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  void _showSongOptions(int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a2e),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _songs[index].title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.white),
                title: const Text('Editar Metadatos',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/editor',
                      arguments: _songs[index]);
                },
              ),
              ListTile(
                leading: const Icon(Icons.content_cut, color: Colors.white),
                title: const Text('Recortar Audio',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/trimmer',
                      arguments: _songs[index]);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Eliminar',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  setState(() => _songs.removeAt(index));
                  widget.audioService.setPlaylist(_songs);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
