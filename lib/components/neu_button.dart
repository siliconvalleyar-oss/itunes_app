import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NeuButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double size;
  final bool isCircle;
  final bool isActive;
  final bool isInset;

  const NeuButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.size = 56,
    this.isCircle = true,
    this.isActive = false,
    this.isInset = false,
  });

  @override
  State<NeuButton> createState() => _NeuButtonState();
}

class _NeuButtonState extends State<NeuButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final pressed = _isPressed || widget.isInset;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.isActive
              ? AppColors.accent.withValues(alpha: 0.15)
              : AppColors.background,
          shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: widget.isCircle ? null : BorderRadius.circular(18),
          boxShadow: pressed ? Neumorphic.inset : Neumorphic.raised,
        ),
        child: Center(child: widget.child),
      ),
    );
  }
}
