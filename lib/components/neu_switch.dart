import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NeuSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const NeuSwitch({super.key, required this.value, this.onChanged});

  @override
  State<NeuSwitch> createState() => _NeuSwitchState();
}

class _NeuSwitchState extends State<NeuSwitch> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onChanged?.call(!widget.value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: 52,
        height: 30,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(15),
          boxShadow: widget.value ? [] : Neumorphic.inset,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: widget.value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: widget.value ? AppColors.accent : AppColors.background,
              shape: BoxShape.circle,
              boxShadow: widget.value ? [] : Neumorphic.subtle,
            ),
          ),
        ),
      ),
    );
  }
}
