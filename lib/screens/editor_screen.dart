import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/song.dart';
import '../services/audio_service.dart';
import '../services/metadata_service.dart';
import '../components/neu_card.dart';
import '../components/neu_button.dart';
import '../components/neu_input.dart';

class EditorScreen extends StatefulWidget {
  final AudioService audioService;

  EditorScreen({super.key, required this.audioService});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final MetadataService _metaService = MetadataService();
  final _titleCtrl = TextEditingController();
  final _artistCtrl = TextEditingController();
  final _albumCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _genreCtrl = TextEditingController();
  final _trackCtrl = TextEditingController();
  final _discCtrl = TextEditingController();
  final _commentCtrl = TextEditingController();
  final _lyricsCtrl = TextEditingController();
  Song? _song;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadSong();
  }

  void _loadSong() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final song = ModalRoute.of(context)?.settings.arguments as Song?;
      if (song != null) {
        setState(() => _song = song);
        _titleCtrl.text = song.title;
        _artistCtrl.text = song.artist;
        _albumCtrl.text = song.album;
      }
    });
  }

  void _markChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  Future<void> _save() async {
    if (_song == null) return;
    try {
      await _metaService.saveMetadata(
        _song!.filePath,
        SongMetadata(
          title: _titleCtrl.text,
          artist: _artistCtrl.text,
          album: _albumCtrl.text,
          year: int.tryParse(_yearCtrl.text),
          genre: _genreCtrl.text,
          track: int.tryParse(_trackCtrl.text),
        ),
      );
      if (mounted) {
        setState(() => _hasChanges = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Guardado'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _artistCtrl.dispose();
    _albumCtrl.dispose();
    _yearCtrl.dispose();
    _genreCtrl.dispose();
    _trackCtrl.dispose();
    _discCtrl.dispose();
    _commentCtrl.dispose();
    _lyricsCtrl.dispose();
    super.dispose();
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
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    SizedBox(height: 24),
                    _buildCoverArt(),
                    SizedBox(height: 24),
                    _buildForm(),
                    SizedBox(height: 24),
                    _buildActions(),
                    SizedBox(height: 40),
                  ],
                ),
              ),
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
          NeuButton(
            onPressed: () => Navigator.pop(context),
            size: 40,
            child: Icon(Icons.arrow_back_ios_new, color: AppColors.textSecondary, size: 16),
          ),
          SizedBox(width: 16),
          Text(
            'Editor',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Spacer(),
          if (_hasChanges)
            NeuButton(
              onPressed: _save,
              size: 40,
              isActive: true,
              child: Icon(Icons.check, color: AppColors.accent, size: 20),
            ),
        ],
      ),
    );
  }

  Widget _buildCoverArt() {
    return Center(
      child: NeuCard(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: Neumorphic.inset,
              ),
              child: Icon(Icons.music_note, color: AppColors.textDisabled, size: 64),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NeuButton(
                  onPressed: () {},
                  size: 36,
                  child: Icon(Icons.photo_camera, color: AppColors.textSecondary, size: 16),
                ),
                SizedBox(width: 12),
                NeuButton(
                  onPressed: () {},
                  size: 36,
                  child: Icon(Icons.delete_outline, color: AppColors.error, size: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        NeuInput(controller: _titleCtrl, label: 'Título', icon: Icons.title, onChanged: (_) => _markChanged()),
        NeuInput(controller: _artistCtrl, label: 'Artista', icon: Icons.person_outline, onChanged: (_) => _markChanged()),
        NeuInput(controller: _albumCtrl, label: 'Álbum', icon: Icons.album_outlined, onChanged: (_) => _markChanged()),
        Row(
          children: [
            Expanded(child: NeuInput(controller: _yearCtrl, label: 'Año', keyboardType: TextInputType.number, onChanged: (_) => _markChanged())),
            SizedBox(width: 12),
            Expanded(child: NeuInput(controller: _genreCtrl, label: 'Género', icon: Icons.category_outlined, onChanged: (_) => _markChanged())),
          ],
        ),
        Row(
          children: [
            Expanded(child: NeuInput(controller: _trackCtrl, label: 'Pista', keyboardType: TextInputType.number, onChanged: (_) => _markChanged())),
            SizedBox(width: 12),
            Expanded(child: NeuInput(controller: _discCtrl, label: 'Disco', keyboardType: TextInputType.number, onChanged: (_) => _markChanged())),
          ],
        ),
        NeuInput(controller: _commentCtrl, label: 'Comentario', icon: Icons.comment_outlined, onChanged: (_) => _markChanged()),
        NeuInput(controller: _lyricsCtrl, label: 'Letra', maxLines: 4, onChanged: (_) => _markChanged()),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: NeuButton(
            onPressed: () => Navigator.pop(context),
            size: 52,
            isCircle: false,
            child: Text('Cancelar', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: NeuButton(
            onPressed: _hasChanges ? _save : null,
            size: 52,
            isCircle: false,
            isActive: _hasChanges,
            child: Text(
              'Guardar',
              style: TextStyle(
                color: _hasChanges ? AppColors.accent : AppColors.textDisabled,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
