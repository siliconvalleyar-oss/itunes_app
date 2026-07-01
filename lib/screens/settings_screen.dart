import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../components/neu_card.dart';
import '../components/neu_switch.dart';

class SettingsScreen extends StatelessWidget {
  final ThemeProvider themeProvider;

  SettingsScreen({super.key, required this.themeProvider});

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
                child: ListenableBuilder(
                  listenable: themeProvider,
                  builder: (context, _) {
                    return Column(
                      children: [
                        SizedBox(height: 24),
                        _buildSection('Apariencia', [
                          _buildSwitchTile(
                            'Modo oscuro',
                            Icons.dark_mode_outlined,
                            themeProvider.isDark,
                            (v) => themeProvider.setDark(v),
                          ),
                        ]),
                        SizedBox(height: 20),
                        _buildSection('General', [
                          _buildInfoTile('Notificaciones', Icons.notifications_outlined, 'Activadas'),
                          _buildInfoTile('Idioma', Icons.language, 'Español'),
                        ]),
                        SizedBox(height: 20),
                        _buildSection('Audio', [
                          _buildInfoTile('Calidad', Icons.high_quality_outlined, '320kbps'),
                          _buildInfoTile('Formato', Icons.audio_file_outlined, 'MP3'),
                        ]),
                        SizedBox(height: 20),
                        _buildSection('Acerca de', [
                          _buildInfoTile('Versión', Icons.info_outline, '1.0.0'),
                          _buildInfoTile('Desarrollador', Icons.code_outlined, 'MiMoCode'),
                        ]),
                        SizedBox(height: 100),
                      ],
                    );
                  },
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
      child: Text(
        'Configuración',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 12),
        NeuCard(
          padding: EdgeInsets.symmetric(vertical: 4),
          borderRadius: 20,
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(String title, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
          SizedBox(width: 14),
          Expanded(
            child: Text(title, style: TextStyle(fontSize: 15, color: AppColors.textPrimary)),
          ),
          NeuSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String title, IconData icon, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          SizedBox(width: 14),
          Expanded(
            child: Text(title, style: TextStyle(fontSize: 15, color: AppColors.textPrimary)),
          ),
          Text(value, style: TextStyle(fontSize: 13, color: AppColors.textDisabled)),
        ],
      ),
    );
  }
}
