import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFFF3F4F6);
  static const surface = Color(0xFFECEEF2);
  static const elevation = Color(0xFFF7F8FA);
  static const textPrimary = Color(0xFF353535);
  static const textSecondary = Color(0xFF7A7A7A);
  static const textDisabled = Color(0xFFA8A8A8);
  static const accent = Color(0xFFFF9F1C);
  static const accentAlt = Color(0xFF5B8DEF);
  static const error = Color(0xFFFF5A5A);
  static const success = Color(0xFF4CAF50);
}

class Neumorphic {
  static const light = Color(0xFFFFFFFF);
  static const dark = Color(0xFF000000);

  static List<BoxShadow> raised = [
    BoxShadow(
      color: light.withOpacity(0.95),
      offset: const Offset(-8, -8),
      blurRadius: 18,
    ),
    BoxShadow(
      color: dark.withOpacity(0.12),
      offset: const Offset(8, 8),
      blurRadius: 18,
    ),
  ];

  static List<BoxShadow> inset = [
    BoxShadow(
      color: dark.withOpacity(0.12),
      offset: const Offset(4, 4),
      blurRadius: 8,
    ),
    BoxShadow(
      color: light.withOpacity(0.95),
      offset: const Offset(-4, -4),
      blurRadius: 8,
    ),
  ];

  static List<BoxShadow> subtle = [
    BoxShadow(
      color: light.withOpacity(0.8),
      offset: const Offset(-4, -4),
      blurRadius: 10,
    ),
    BoxShadow(
      color: dark.withOpacity(0.08),
      offset: const Offset(4, 4),
      blurRadius: 10,
    ),
  ];
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Inter',
      colorScheme: const ColorScheme.light(
        primary: AppColors.accent,
        secondary: AppColors.accentAlt,
        error: AppColors.error,
        surface: AppColors.surface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        labelSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textDisabled,
        ),
      ),
    );
  }
}
