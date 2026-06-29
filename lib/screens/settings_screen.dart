import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../components/neu_card.dart';
import '../components/neu_button.dart';
import '../components/neu_switch.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _notifications = true;
  bool _autoSave = true;
  bool _highQuality = false;

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
                    _buildSection('General', [
                      _buildSwitchTile('Modo oscuro', Icons.dark_mode_outlined, _darkMode, (v) => setState(() => _darkMode = v)),
                      _buildSwitchTile('Notificaciones', Icons.notifications_outlined, _notifications, (v) => setState(() => _notifications = v)),
                      _buildSwitchTile('Guardado automático', Icons.save_outlined, _autoSave, (v) => setState(() => _autoSave = v)),
                    ]),
                    const SizedBox(height: 20),
                    _buildSection('Audio', [
                      _buildSwitchTile('Alta calidad', Icons.high_quality_outlined, _highQuality, (v) => setState(() => _highQuality = v)),
                      _buildInfoTile('Formato de exportación', Icons.audio_file_outlined, 'MP3 320kbps'),
                      _buildInfoTile('Ubicación de descargas', Icons.folder_outlined, '/Music/Downloads'),
                    ]),
                    const SizedBox(height: 20),
                    _buildSection('Acerca de', [
                      _buildInfoTile('Versión', Icons.info_outline, '1.0.0'),
                      _buildInfoTile('Desarrollador', Icons.code_outlined, 'MiMoCode'),
                    ]),
                    const SizedBox(height: 100),
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
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          const Text(
            'Configuración',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        NeuCard(
          padding: const EdgeInsets.symmetric(vertical: 4),
          borderRadius: 20,
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(String title, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              boxShadow: Neumorphic.subtle,
            ),
            child: Icon(icon, color: AppColors.textSecondary, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 15, color: AppColors.textPrimary)),
          ),
          NeuSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String title, IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              boxShadow: Neumorphic.subtle,
            ),
            child: Icon(icon, color: AppColors.textSecondary, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 15, color: AppColors.textPrimary)),
          ),
          Text(value, style: const TextStyle(fontSize: 13, color: AppColors.textDisabled)),
        ],
      ),
    );
  }
}
