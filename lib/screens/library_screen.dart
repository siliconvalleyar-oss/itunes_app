import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/audio_service.dart';
import '../services/library_service.dart';
import '../components/neu_card.dart';
import '../components/neu_button.dart';
import '../widgets/song_tile.dart';
import 'player_screen.dart';

class LibraryScreen extends StatefulWidget {
  final AudioService audioService;
  final LibraryService libraryService;

  LibraryScreen({
    super.key,
    required this.audioService,
    required this.libraryService,
  });

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  int _currentTab = 0;

  List<dynamic> get _currentList {
    switch (_currentTab) {
      case 0:
        return widget.libraryService.allSongs;
      case 1:
        return widget.libraryService.favorites;
      case 2:
        return widget.libraryService.mostPlayed;
      case 3:
        return widget.libraryService.recentlyPlayed;
      default:
        return widget.libraryService.allSongs;
    }
  }

  String get _currentTitle {
    switch (_currentTab) {
      case 0:
        return 'Todas';
      case 1:
        return 'Favoritos';
      case 2:
        return 'Más Escuchados';
      case 3:
        return 'Recientes';
      default:
        return 'Todas';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabs(),
            SizedBox(height: 8),
            _buildStats(),
            SizedBox(height: 16),
            Expanded(
              child: _buildSongList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          Text(
            'Biblioteca',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Spacer(),
          NeuButton(
            onPressed: () {},
            size: 40,
            child: Icon(Icons.filter_list, color: AppColors.textSecondary, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      height: 44,
      margin: EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          _buildTab(0, 'Todas'),
          _buildTab(1, 'Favoritos'),
          _buildTab(2, 'Top'),
          _buildTab(3, 'Recientes'),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label) {
    final isActive = _currentTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentTab = index),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 250),
          margin: EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: isActive ? AppColors.accent.withOpacity(0.15) : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: isActive ? [] : Neumorphic.inset,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppColors.accent : AppColors.textDisabled,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStats() {
    return ListenableBuilder(
      listenable: widget.libraryService,
      builder: (context, _) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              _buildStat('Canciones', '${widget.libraryService.allSongs.length}'),
              SizedBox(width: 12),
              _buildStat('Favoritos', '${widget.libraryService.favorites.length}'),
              SizedBox(width: 12),
              _buildStat('Escuchadas', '${widget.libraryService.mostPlayed.length}'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStat(String label, String value) {
    return Expanded(
      child: NeuCard(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        borderRadius: 16,
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11, color: AppColors.textDisabled)),
          ],
        ),
      ),
    );
  }

  Widget _buildSongList() {
    return ListenableBuilder(
      listenable: Listenable.merge([widget.libraryService, widget.audioService]),
      builder: (context, _) {
        final songs = _currentList;
        if (songs.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    boxShadow: Neumorphic.inset,
                  ),
                  child: Icon(Icons.music_off, color: AppColors.textDisabled, size: 32),
                ),
                SizedBox(height: 16),
                Text(
                  _currentTab == 1 ? 'No hay favoritos' : 'Sin canciones',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 24),
          itemCount: songs.length,
          itemBuilder: (context, index) {
            final song = songs[index];
            return SongTile(
              song: song,
              audioService: widget.audioService,
              isFavorite: widget.libraryService.isFavorite(song.id),
              onFavoriteToggle: () => widget.libraryService.toggleFavorite(song),
              onTap: () {
                widget.libraryService.recordPlay(song);
                widget.audioService.play(song);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlayerScreen(audioService: widget.audioService),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
