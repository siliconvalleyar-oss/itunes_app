import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NeuSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final ValueChanged<double>? onChanged;
  final double height;
  final Color? activeColor;

  const NeuSlider({
    super.key,
    required this.value,
    this.min = 0,
    this.max = 1,
    this.onChanged,
    this.height = 6,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? AppColors.accent;
    final progress = max > min ? (value - min) / (max - min) : 0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        return GestureDetector(
          onHorizontalDragUpdate: (details) {
            final newValue = (details.localPosition.dx / w)
                .clamp(0.0, 1.0) * (max - min) + min;
            onChanged?.call(newValue);
          },
          child: Container(
            height: 40,
            alignment: Alignment.centerLeft,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Track background
                Positioned(
                  top: (40 - height) / 2,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: height,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(height / 2),
                      boxShadow: Neumorphic.inset,
                    ),
                  ),
                ),
                // Active track
                Positioned(
                  top: (40 - height) / 2,
                  left: 0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    width: w * progress,
                    height: height,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(height / 2),
                    ),
                  ),
                ),
                // Thumb
                Positioned(
                  top: (40 - 20) / 2,
                  left: (w * progress) - 10,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      shape: BoxShape.circle,
                      boxShadow: Neumorphic.subtle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
