import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central font-size table.
/// All sizes in this app derive from these constants × the user's scale factor.
/// To change any size globally, edit here. To add runtime scaling, pass a
/// different [scale] to [AppTheme.lightTheme] / [AppTheme.darkTheme].
class AppTextSizes {
  AppTextSizes._();

  static const double displayLarge = 32;
  static const double displayMedium = 28;
  static const double displaySmall = 24;
  static const double headlineLarge = 36;
  static const double headlineMedium = 24;
  static const double headlineSmall = 20;
  static const double titleLarge = 22;
  static const double titleMedium = 18;
  static const double titleSmall = 16;
  static const double bodyLarge = 16;
  static const double bodyMedium = 14;
  static const double bodySmall = 12;
  static const double labelLarge = 14;
  static const double labelMedium = 12;
  static const double labelSmall = 10;
}

/// Central font-family list.
/// Add new families here to make them available in Settings.
class AppFonts {
  AppFonts._();

  static const String defaultFont = 'Tajawal';
  static const List<String> available = [
    'Tajawal',
    'DG-Sahabah',
    'Roboto',
    'Inter',
  ];
}

class AppTheme {
  // ── Palette ──────────────────────────────────────────────────────────────
  static const Color primaryTeal = Color(0xFF49D4D0); // Sard Teal
  static const Color secondaryTeal = Color(0xFF1A8F85);
  //static const Color accentGold = Color(0xFFC66900); // Updated Stroke Color
  static const Color accentGold = Color(0xFFC07F00); // Updated Stroke Color

  static const Color gradientStart = Color(0xFF0075A0); // New Gradient Start
  static const Color bgWhite = Color(
    0xFFE5F2F2,
  ); // Soft Ice Teal (Reduced glare)
  static const Color appBarTeal = bgWhite; // Matches background exactly
  static const Color darkCocoa = Color(0xFF3C2415); // Dark Cocoa
  static const Color sectionBgLight = bgWhite; // Soft Teal for sections
  static const Color textPrimaryLight = Color(
    0xFF3C2415,
  ); // Using Dark Cocoa for text
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color successGreen = Color(0xFF4CAF88);

  static const Color navbarTeal = Color(0xFFD9E8E8);
  static const Color bgDarkTeal = Color(0xFF0F2A2A);
  static const Color sectionBgDark = Color(0xFF1E3F3D);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B8B8);

  // Card specific backgrounds
  static const Color cardBgLight = primaryTeal; // Sard Teal
  static const Color cardBgDark = Color(0xFF163333); // Deep Teal
  static const Color onCardLight =
      Colors.white; // High contrast white for content
  static const Color onCardDark = Colors.white;

  static Color getCardColor(ThemeData theme) {
    return theme.brightness == Brightness.light ? cardBgLight : cardBgDark;
  }

  static LinearGradient getCardGradient(ThemeData theme) {
    return const LinearGradient(
      colors: [gradientStart, primaryTeal],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static Color getOnCardColor(ThemeData theme) {
    return theme.brightness == Brightness.light ? onCardLight : onCardDark;
  }

  // ── Style Tokens (Centralized UI Consistency) ────────────────────────────
  static final cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static final goldShadow = [
    BoxShadow(
      color: accentGold.withValues(alpha: 0.2),
      blurRadius: 8,
      spreadRadius: 1,
    ),
  ];

  static const double cardRadius = 16.0;
  static const double buttonRadius = 24.0;

  // ── Text theme factory ────────────────────────────────────────────────────
  static TextTheme _buildTextTheme(
    Color primary,
    Color secondary, {
    double scale = 1.0,
  }) {
    double s(double base) => base * scale;

    TextStyle style(
      Color color,
      double size, {
      FontWeight weight = FontWeight.normal,
      double? height,
      double? letterSpacing,
    }) => GoogleFonts.tajawal(
      color: color,
      fontSize: s(size),
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
    );

    return TextTheme(
      displayLarge: style(
        primary,
        AppTextSizes.displayLarge,
        weight: FontWeight.bold,
        height: 1.1,
      ),
      displayMedium: style(
        primary,
        AppTextSizes.displayMedium,
        weight: FontWeight.bold,
        height: 1.1,
      ),
      displaySmall: style(
        primary,
        AppTextSizes.displaySmall,
        weight: FontWeight.bold,
        height: 1.1,
      ),
      headlineLarge: style(
        primary,
        AppTextSizes.headlineLarge,
        weight: FontWeight.w900,
        height: 1.2,
      ),
      headlineMedium: style(
        primary,
        AppTextSizes.headlineMedium,
        weight: FontWeight.w800,
        height: 1.2,
      ),
      headlineSmall: style(
        primary,
        AppTextSizes.headlineSmall,
        weight: FontWeight.bold,
        height: 1.2,
      ),
      titleLarge: style(
        primary,
        AppTextSizes.titleLarge,
        weight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
      titleMedium: style(
        primary,
        AppTextSizes.titleMedium,
        weight: FontWeight.w600,
      ),
      titleSmall: style(
        primary,
        AppTextSizes.titleSmall,
        weight: FontWeight.w500,
      ),
      bodyLarge: style(primary, AppTextSizes.bodyLarge),
      bodyMedium: style(secondary, AppTextSizes.bodyMedium),
      bodySmall: style(secondary, AppTextSizes.bodySmall),
      labelLarge: style(
        primary,
        AppTextSizes.labelLarge,
        weight: FontWeight.bold,
        letterSpacing: 1.1,
      ),
      labelMedium: style(
        secondary,
        AppTextSizes.labelMedium,
        weight: FontWeight.w500,
      ),
      labelSmall: style(secondary, AppTextSizes.labelSmall),
    );
  }

  // ── Public theme builders ─────────────────────────────────────────────────
  static ThemeData lightTheme({double scale = 1.0, String? fontFamily}) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryTeal,
      scaffoldBackgroundColor: bgWhite,
      fontFamily: GoogleFonts.tajawal().fontFamily,
      colorScheme: const ColorScheme.light(
        primary: primaryTeal,
        secondary: secondaryTeal,
        primaryContainer: Color(0xFFB2EBF2),
        tertiary: accentGold,
        onTertiary: Colors.white,
        surface: bgWhite,
        surfaceContainerHighest: sectionBgLight,
        error: Colors.redAccent,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimaryLight,
        onSurfaceVariant: textSecondaryLight,
      ),
      textTheme: _buildTextTheme(
        textPrimaryLight,
        textSecondaryLight,
        scale: scale,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      cardTheme: CardThemeData(
        color: bgWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: appBarTeal,
        foregroundColor: primaryTeal,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: gradientStart,
        behavior: SnackBarBehavior.floating,
        contentTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: navbarTeal,
        selectedItemColor: gradientStart,
        unselectedItemColor: gradientStart.withValues(alpha: 0.5),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: navbarTeal,
        indicatorColor: Colors.transparent,
        indicatorShape: const CircleBorder(),
        overlayColor: WidgetStateProperty.all(
          gradientStart.withValues(alpha: 0.1),
        ),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        height: 70,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: gradientStart, size: 32);
          }
          return IconThemeData(
            color: gradientStart.withValues(alpha: 0.5),
            size: 24,
          );
        }),
      ),
    );
  }

  static ThemeData darkTheme({double scale = 1.0, String? fontFamily}) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryTeal,
      scaffoldBackgroundColor: bgDarkTeal,
      fontFamily: GoogleFonts.tajawal().fontFamily,
      colorScheme: const ColorScheme.dark(
        primary: primaryTeal,
        secondary: secondaryTeal,
        primaryContainer: Color(0xFF0F3E3E),
        tertiary: accentGold,
        onTertiary: Colors.white,
        surface: bgDarkTeal,
        surfaceContainerHighest: sectionBgDark,
        error: Colors.redAccent,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimaryDark,
        onSurfaceVariant: textSecondaryDark,
      ),
      textTheme: _buildTextTheme(
        textPrimaryDark,
        textSecondaryDark,
        scale: scale,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgDarkTeal,
        foregroundColor: primaryTeal,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: gradientStart,
        behavior: SnackBarBehavior.floating,
        contentTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.black,
        selectedItemColor: gradientStart,
        unselectedItemColor: gradientStart.withValues(alpha: 0.5),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.black,
        indicatorColor: Colors.transparent,
        indicatorShape: const CircleBorder(),
        overlayColor: WidgetStateProperty.all(
          gradientStart.withValues(alpha: 0.1),
        ),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        height: 70,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: gradientStart, size: 32);
          }
          return IconThemeData(
            color: gradientStart.withValues(alpha: 0.5),
            size: 24,
          );
        }),
      ),
    );
  }
}
