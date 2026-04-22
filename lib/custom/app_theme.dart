import 'package:flutter/material.dart';

class AppTheme {
  // Light Palette
  static const Color primaryTeal = Color(0xFF26C6B8);
  static const Color secondaryTeal = Color(0xFF1A8F85);
  static const Color accentGold = Color(0xFFD4A017);
  static const Color bgWhite = Color(0xFFFFFFFF);
  static const Color sectionBgLight = Color(0xFFE6F9F6);
  static const Color textPrimaryLight = Color(0xFF1F2A2E);
  static const Color textSecondaryLight = Color(0xFF555555);
  static const Color successGreen = Color(0xFF4CAF88);

  // Dark Palette
  static const Color bgDarkTeal = Color(0xFF0F2A2A);
  static const Color sectionBgDark = Color(0xFF1E3F3D);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B8B8);

  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: TextStyle(color: primary, fontSize: 32, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: primary, fontSize: 28, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(color: primary, fontSize: 24, fontWeight: FontWeight.bold),
      headlineLarge: TextStyle(color: primary, fontSize: 36, fontWeight: FontWeight.w900),
      headlineMedium: TextStyle(color: primary, fontSize: 24, fontWeight: FontWeight.w800),
      headlineSmall: TextStyle(color: primary, fontSize: 20, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(color: primary, fontSize: 22, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: primary, fontSize: 18, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(color: primary, fontSize: 16, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(color: primary, fontSize: 16),
      bodyMedium: TextStyle(color: secondary, fontSize: 14),
      bodySmall: TextStyle(color: secondary, fontSize: 12),
      labelLarge: TextStyle(color: primary, fontSize: 14, fontWeight: FontWeight.bold),
      labelMedium: TextStyle(color: secondary, fontSize: 12, fontWeight: FontWeight.w500),
      labelSmall: TextStyle(color: secondary, fontSize: 10),
    );
  }

  // Light theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryTeal,
      scaffoldBackgroundColor: bgWhite,
      colorScheme: const ColorScheme.light(
        primary: primaryTeal,
        secondary: secondaryTeal,
        primaryContainer: Color(0xFFB2EBF2), // Light cyan/teal for buttons
        tertiary: accentGold,
        surface: bgWhite,
        surfaceContainerHighest: sectionBgLight,
        error: Colors.redAccent,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimaryLight,
        onSurfaceVariant: textSecondaryLight,
      ),
      textTheme: _buildTextTheme(textPrimaryLight, textSecondaryLight),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgWhite,
        foregroundColor: primaryTeal,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }

  // Dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryTeal,
      scaffoldBackgroundColor: bgDarkTeal,
      colorScheme: const ColorScheme.dark(
        primary: primaryTeal,
        secondary: secondaryTeal,
        primaryContainer: Color(0xFF0F3E3E),
        tertiary: accentGold,
        surface: bgDarkTeal,
        surfaceContainerHighest: sectionBgDark,
        error: Colors.redAccent,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimaryDark,
        onSurfaceVariant: textSecondaryDark,
      ),
      textTheme: _buildTextTheme(textPrimaryDark, textSecondaryDark),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgDarkTeal,
        foregroundColor: primaryTeal,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
