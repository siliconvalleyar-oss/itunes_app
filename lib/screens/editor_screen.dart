import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/audio_service.dart';
import '../services/metadata_service.dart';
import '../widgets/glass_card.dart';

class EditorScreen extends StatefulWidget {
  final AudioService audioService;

  const EditorScreen({super.key, required this.audioService});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final MetadataService _metadataService = MetadataService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _artistController;
  late TextEditingController _albumController;
  late TextEditingController _yearController;
  late TextEditingController _trackController;
  late TextEditingController _genreController;
  late TextEditingController _commentController;

  Song? _song;
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _artistController = TextEditingController();
    _albumController = TextEditingController();
    _yearController = TextEditingController();
    _trackController = TextEditingController();
    _genreController = TextEditingController();
    _commentController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final song = ModalRoute.of(context)?.settings.arguments as Song?;
    if (song != null && _song == null) {
      _song = song;
      _loadMetadata();
    }
  }

  Future<void> _loadMetadata() async {
    if (_song == null) return;
    setState(() => _isLoading = true);

    try {
      final metadata =
          await _metadataService.readMetadata(_song!.filePath);
      _titleController.text = metadata.title ?? _song!.title;
      _artistController.text = metadata.artist ?? _song!.artist;
      _albumController.text = metadata.album ?? _song!.album;
      _yearController.text = metadata.year?.toString() ?? '';
      _trackController.text = metadata.track?.toString() ?? '';
      _genreController.text = metadata.genre ?? '';
      _commentController.text = metadata.comment ?? '';
    } catch (e) {
      debugPrint('Error loading metadata: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _markChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  Future<void> _saveMetadata() async {
    if (_song == null) return;
    setState(() => _isLoading = true);

    try {
      final metadata = SongMetadata(
        title: _titleController.text,
        artist: _artistController.text,
        album: _albumController.text,
        year: int.tryParse(_yearController.text),
        track: int.tryParse(_trackController.text),
        genre: _genreController.text,
        comment: _commentController.text,
      );

      await _metadataService.saveMetadata(_song!.filePath, metadata);

      if (mounted) {
        setState(() => _hasChanges = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Metadatos guardados'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _albumController.dispose();
    _yearController.dispose();
    _trackController.dispose();
    _genreController.dispose();
    _commentController.dispose();
    super.dispose();
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
          title: const Text('Editar Metadatos'),
          actions: [
            if (_hasChanges)
              IconButton(
                onPressed: _isLoading ? null : _saveMetadata,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
              ),
          ],
        ),
        body: _isLoading && _song == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Cover art
                      GlassCard(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
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
                              size: 60,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Fields
                      _buildField(
                        controller: _titleController,
                        label: 'Título',
                        icon: Icons.title,
                        onChanged: (_) => _markChanged(),
                      ),
                      _buildField(
                        controller: _artistController,
                        label: 'Artista',
                        icon: Icons.person,
                        onChanged: (_) => _markChanged(),
                      ),
                      _buildField(
                        controller: _albumController,
                        label: 'Álbum',
                        icon: Icons.album,
                        onChanged: (_) => _markChanged(),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildField(
                              controller: _yearController,
                              label: 'Año',
                              icon: Icons.calendar_today,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => _markChanged(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildField(
                              controller: _trackController,
                              label: 'Pista',
                              icon: Icons.format_list_numbered,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => _markChanged(),
                            ),
                          ),
                        ],
                      ),
                      _buildField(
                        controller: _genreController,
                        label: 'Género',
                        icon: Icons.category,
                        onChanged: (_) => _markChanged(),
                      ),
                      _buildField(
                        controller: _commentController,
                        label: 'Comentario',
                        icon: Icons.comment,
                        maxLines: 3,
                        onChanged: (_) => _markChanged(),
                      ),
                      const SizedBox(height: 24),

                      // Save button
                      if (_hasChanges)
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveMetadata,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text(
                                    'Guardar Cambios',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        borderRadius: 12,
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: onChanged,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.white54),
            prefixIcon: Icon(icon, color: Colors.white54, size: 20),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
