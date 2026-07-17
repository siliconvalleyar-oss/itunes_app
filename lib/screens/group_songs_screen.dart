import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/song.dart';
import '../services/audio_service.dart';
import '../services/library_service.dart';
import '../services/playlist_service.dart';
import '../components/neu_button.dart';
import '../widgets/song_tile.dart';
import 'player_screen.dart';

class GroupSongsScreen extends StatefulWidget {
  final String groupName;
  final List<Song> songs;
  final AudioService audioService;
  final LibraryService libraryService;
  final PlaylistService playlistService;

  GroupSongsScreen({
    super.key,
    required this.groupName,
    required this.songs,
    required this.audioService,
    required this.libraryService,
    required this.playlistService,
  });

  @override
  State<GroupSongsScreen> createState() => _GroupSongsScreenState();
}

class _GroupSongsScreenState extends State<GroupSongsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: NeuButton(
          onPressed: () => Navigator.pop(context),
          size: 40,
          child: Icon(Icons.arrow_back, color: AppColors.textSecondary, size: 20),
        ),
        title: Text(
          widget.groupName,
          style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          itemCount: widget.songs.length,
          itemBuilder: (context, index) {
            final song = widget.songs[index];
            return SongTile(
              song: song,
              audioService: widget.audioService,
              isFavorite: widget.libraryService.isFavorite(song.id),
              onFavoriteToggle: () => widget.libraryService.toggleFavorite(song),
              onHide: () => widget.libraryService.toggleIgnored(song),
              onTap: () {
                widget.audioService.setPlaylist(widget.songs);
                widget.audioService.play(song);
                widget.libraryService.recordPlay(song);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlayerScreen(
                      audioService: widget.audioService,
                      libraryService: widget.libraryService,
                      playlistService: widget.playlistService,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
