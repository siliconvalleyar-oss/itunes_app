import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../components/neu_card.dart';
import '../components/neu_button.dart';

class EqualizerScreen extends StatefulWidget {
  EqualizerScreen({super.key});

  @override
  State<EqualizerScreen> createState() => _EqualizerScreenState();
}

class _EqualizerScreenState extends State<EqualizerScreen> {
  final List<String> _presets = ['Normal', 'Rock', 'Pop', 'Jazz', 'Clásica', 'Bass Boost', 'Vocal'];
  String _selectedPreset = 'Normal';

  final List<Map<String, dynamic>> _bands = [
    {'freq': '60', 'value': 0.0},
    {'freq': '170', 'value': 0.0},
    {'freq': '310', 'value': 0.0},
    {'freq': '600', 'value': 0.0},
    {'freq': '1K', 'value': 0.0},
    {'freq': '3K', 'value': 0.0},
    {'freq': '6K', 'value': 0.0},
    {'freq': '12K', 'value': 0.0},
    {'freq': '14K', 'value': 0.0},
    {'freq': '16K', 'value': 0.0},
  ];

  void _applyPreset(String preset) {
    setState(() {
      _selectedPreset = preset;
      switch (preset) {
        case 'Rock':
          _setBands([4, 2, -1, -2, 1, 3, 5, 5, 4, 3]);
          break;
        case 'Pop':
          _setBands([-1, 2, 4, 4, 3, 0, -1, -1, 2, 2]);
          break;
        case 'Jazz':
          _setBands([3, 1, -1, 2, -2, -2, 0, 1, 3, 4]);
          break;
        case 'Clásica':
          _setBands([5, 3, 0, -1, -2, -2, 0, 2, 4, 5]);
          break;
        case 'Bass Boost':
          _setBands([8, 6, 4, 1, -1, -2, -1, 0, 1, 2]);
          break;
        case 'Vocal':
          _setBands([-2, -1, 2, 5, 5, 4, 2, 0, -1, -2]);
          break;
        default:
          _setBands([0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
      }
    });
  }

  void _setBands(List<double> values) {
    for (int i = 0; i < _bands.length && i < values.length; i++) {
      _bands[i]['value'] = values[i];
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
            SizedBox(height: 24),
            _buildPresets(),
            SizedBox(height: 32),
            Expanded(child: _buildBands()),
            SizedBox(height: 24),
            _buildActions(),
            SizedBox(height: 24),
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
            'Ecualizador',
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

  Widget _buildPresets() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 24),
        itemCount: _presets.length,
        itemBuilder: (context, index) {
          final preset = _presets[index];
          final isActive = _selectedPreset == preset;
          return Padding(
            padding: EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => _applyPreset(preset),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 250),
                padding: EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.accent.withValues(alpha: 0.15) : AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: isActive ? [] : Neumorphic.inset,
                ),
                child: Center(
                  child: Text(
                    preset,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive ? AppColors.accent : AppColors.textDisabled,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBands() {
    return NeuCard(
      margin: EdgeInsets.symmetric(horizontal: 24),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_bands.length, (i) {
          return _buildBand(i);
        }),
      ),
    );
  }

  Widget _buildBand(int index) {
    final band = _bands[index];
    final value = band['value'] as double;

    return Column(
      children: [
        Text(
          '${value.round()}',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: value > 0
                ? AppColors.accent
                : value < 0
                    ? AppColors.accentAlt
                    : AppColors.textDisabled,
          ),
        ),
        SizedBox(height: 8),
        Expanded(
          child: RotatedBox(
            quarterTurns: -1,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 14),
                activeTrackColor: AppColors.accent,
                inactiveTrackColor: AppColors.surface,
                thumbColor: AppColors.background,
                overlayColor: Colors.transparent,
              ),
              child: Slider(
                value: value,
                min: -12,
                max: 12,
                onChanged: (v) => setState(() => _bands[index]['value'] = v),
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          band['freq'],
          style: TextStyle(fontSize: 10, color: AppColors.textDisabled),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: NeuButton(
              onPressed: () => _applyPreset('Normal'),
              size: 48,
              isCircle: false,
              child: Text('Reset', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: NeuButton(
              onPressed: () {},
              size: 48,
              isCircle: false,
              isActive: true,
              child: Text('Aplicar', style: TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
