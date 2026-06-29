import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }

  void setDark(bool value) {
    _isDark = value;
    notifyListeners();
  }
}

class AppColors {
  static Color background = const Color(0xFFF3F4F6);
  static Color surface = const Color(0xFFECEEF2);
  static Color elevation = const Color(0xFFF7F8FA);
  static Color textPrimary = const Color(0xFF353535);
  static Color textSecondary = const Color(0xFF7A7A7A);
  static Color textDisabled = const Color(0xFFA8A8A8);
  static const accent = Color(0xFFFF9F1C);
  static const accentAlt = Color(0xFF5B8DEF);
  static const error = Color(0xFFFF5A5A);
  static const success = Color(0xFF4CAF50);

  static const lightBg = Color(0xFFF3F4F6);
  static const lightSurface = Color(0xFFECEEF2);
  static const lightText = Color(0xFF353535);
  static const lightTextSec = Color(0xFF7A7A7A);
  static const lightTextDis = Color(0xFFA8A8A8);

  static const darkBg = Color(0xFF1A1B23);
  static const darkSurface = Color(0xFF232430);
  static const darkText = Color(0xFFECEEF2);
  static const darkTextSec = Color(0xFF9A9BA0);
  static const darkTextDis = Color(0xFF5A5B60);

  static void applyTheme(bool isDark) {
    if (isDark) {
      background = darkBg;
      surface = darkSurface;
      elevation = const Color(0xFF2A2B38);
      textPrimary = darkText;
      textSecondary = darkTextSec;
      textDisabled = darkTextDis;
    } else {
      background = lightBg;
      surface = lightSurface;
      elevation = const Color(0xFFF7F8FA);
      textPrimary = lightText;
      textSecondary = lightTextSec;
      textDisabled = lightTextDis;
    }
  }
}

class Neumorphic {
  static Color light = const Color(0xFFFFFFFF);
  static Color dark = const Color(0xFF000000);

  static void applyTheme(bool isDark) {
    if (isDark) {
      light = const Color(0xFF2E2F3C);
      dark = const Color(0xFF0A0A0F);
    } else {
      light = const Color(0xFFFFFFFF);
      dark = const Color(0xFF000000);
    }
  }

  static List<BoxShadow> get raised => [
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

  static List<BoxShadow> get inset => [
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

  static List<BoxShadow> get subtle => [
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
      scaffoldBackgroundColor: const Color(0xFFF3F4F6),
      fontFamily: 'Inter',
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF1A1B23),
      fontFamily: 'Inter',
    );
  }
}
