import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NeuCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double borderRadius;
  final bool isInset;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const NeuCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 24,
    this.isInset = false,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        height: height,
        margin: margin,
        padding: padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isInset ? AppColors.surface : AppColors.background,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: isInset ? Neumorphic.inset : Neumorphic.raised,
        ),
        child: child,
      ),
    );
  }
}
