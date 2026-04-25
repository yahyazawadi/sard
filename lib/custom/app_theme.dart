import 'package:flutter/material.dart';

/// Central font-size table.
/// All sizes in this app derive from these constants × the user's scale factor.
/// To change any size globally, edit here. To add runtime scaling, pass a
/// different [scale] to [AppTheme.lightTheme] / [AppTheme.darkTheme].
class AppTextSizes {
  AppTextSizes._();

  static const double displayLarge  = 32;
  static const double displayMedium = 28;
  static const double displaySmall  = 24;
  static const double headlineLarge  = 36;
  static const double headlineMedium = 24;
  static const double headlineSmall  = 20;
  static const double titleLarge   = 22;
  static const double titleMedium  = 18;
  static const double titleSmall   = 16;
  static const double bodyLarge    = 16;
  static const double bodyMedium   = 14;
  static const double bodySmall    = 12;
  static const double labelLarge   = 14;
  static const double labelMedium  = 12;
  static const double labelSmall   = 10;
}

/// Central font-family list.
/// Add new families here to make them available in Settings.
class AppFonts {
  AppFonts._();

  static const String defaultFont = 'DG-Sahabah';
  static const List<String> available = [
    'DG-Sahabah',
    'Roboto',
    'Inter',
  ];
}

class AppTheme {
  // ── Palette ──────────────────────────────────────────────────────────────
  static const Color primaryTeal          = Color(0xFF49D4D0); // Sard Teal
  static const Color secondaryTeal        = Color(0xFF1A8F85);
  static const Color accentGold           = Color(0xFFC5A359); // Elegant Gold
  static const Color bgWhite              = Color(0xFFFFFFFF); // Pure White
  static const Color darkCocoa            = Color(0xFF3C2415); // Dark Cocoa
  static const Color sectionBgLight       = Color(0xFFF7FDFD);
  static const Color textPrimaryLight     = Color(0xFF3C2415); // Using Dark Cocoa for text
  static const Color textSecondaryLight   = Color(0xFF757575);
  static const Color successGreen         = Color(0xFF4CAF88);

  static const Color bgDarkTeal           = Color(0xFF0F2A2A);
  static const Color sectionBgDark        = Color(0xFF1E3F3D);
  static const Color textPrimaryDark      = Color(0xFFFFFFFF);
  static const Color textSecondaryDark    = Color(0xFFB0B8B8);

  // ── Text theme factory ────────────────────────────────────────────────────
  static TextTheme _buildTextTheme(
    Color primary,
    Color secondary, {
    double scale = 1.0,
    String? fontFamily,
  }) {
    double s(double base) => base * scale;

    TextStyle style(
      Color color,
      double size, {
      FontWeight weight = FontWeight.normal,
    }) =>
        TextStyle(
          color: color,
          fontSize: s(size),
          fontWeight: weight,
          fontFamily: fontFamily,
        );

    return TextTheme(
      displayLarge:   style(primary, AppTextSizes.displayLarge,  weight: FontWeight.bold),
      displayMedium:  style(primary, AppTextSizes.displayMedium, weight: FontWeight.bold),
      displaySmall:   style(primary, AppTextSizes.displaySmall,  weight: FontWeight.bold),
      headlineLarge:  style(primary, AppTextSizes.headlineLarge,  weight: FontWeight.w900),
      headlineMedium: style(primary, AppTextSizes.headlineMedium, weight: FontWeight.w800),
      headlineSmall:  style(primary, AppTextSizes.headlineSmall,  weight: FontWeight.bold),
      titleLarge:     style(primary, AppTextSizes.titleLarge,  weight: FontWeight.bold),
      titleMedium:    style(primary, AppTextSizes.titleMedium, weight: FontWeight.w600),
      titleSmall:     style(primary, AppTextSizes.titleSmall,  weight: FontWeight.w500),
      bodyLarge:      style(primary,   AppTextSizes.bodyLarge),
      bodyMedium:     style(secondary, AppTextSizes.bodyMedium),
      bodySmall:      style(secondary, AppTextSizes.bodySmall),
      labelLarge:     style(primary,   AppTextSizes.labelLarge,  weight: FontWeight.bold),
      labelMedium:    style(secondary, AppTextSizes.labelMedium, weight: FontWeight.w500),
      labelSmall:     style(secondary, AppTextSizes.labelSmall),
    );
  }

  // ── Public theme builders ─────────────────────────────────────────────────
  /// [scale]      – multiplier applied to every font size (default 1.0).
  /// [fontFamily] – override the font family for the entire app.
  static ThemeData lightTheme({double scale = 1.0, String? fontFamily}) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryTeal,
      scaffoldBackgroundColor: bgWhite,
      fontFamily: fontFamily,
      colorScheme: const ColorScheme.light(
        primary: primaryTeal,
        secondary: secondaryTeal,
        primaryContainer: Color(0xFFB2EBF2),
        tertiary: accentGold,
        surface: bgWhite,
        surfaceContainerHighest: sectionBgLight,
        error: Colors.redAccent,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimaryLight,
        onSurfaceVariant: textSecondaryLight,
      ),
      textTheme: _buildTextTheme(
        textPrimaryLight, textSecondaryLight,
        scale: scale, fontFamily: fontFamily,
      ),
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
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: primaryTeal,
        behavior: SnackBarBehavior.floating,
        contentTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  static ThemeData darkTheme({double scale = 1.0, String? fontFamily}) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryTeal,
      scaffoldBackgroundColor: bgDarkTeal,
      fontFamily: fontFamily,
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
      textTheme: _buildTextTheme(
        textPrimaryDark, textSecondaryDark,
        scale: scale, fontFamily: fontFamily,
      ),
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
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: primaryTeal,
        behavior: SnackBarBehavior.floating,
        contentTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
