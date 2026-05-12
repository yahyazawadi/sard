import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
  static const double headlineSmall = 24;
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
  static const Color primaryTeal = Color(0xFF804326); // Rich Reddish Cocoa (Middle Color)
  static const Color secondaryTeal = Color(0xFF6F4E37); // Slightly darker cocoa
  //static const Color accentGold = Color(0xFFC66900); // Updated Stroke Color
  static const Color accentGold = Color(0xFFC07F00); // Updated Stroke Color
  static const Color highContrastGold = Color(0xFFF1DBBC); // High Contrast Color for Icons/Cards

  static const Color gradientStart = Color(0xFF6F4E37); // Warm Cocoa Start
  static const Color bgWhite = Color(0xFFF9F3E7); // Clean Vanilla Cream Background
  static const Color appBarTeal = bgWhite; 
  static const Color darkCocoa = Color(0xFF3C2415); // Dark Cocoa
  static const Color sectionBgLight = bgWhite; // Soft Teal for sections
  static const Color textPrimaryLight = Color(
    0xFF3C2415,
  ); // Using Dark Cocoa for text
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color successGreen = Color(0xFF4CAF88);

  static const Color navbarTeal = Color(0xFFEADBC8); // Light Creamy Navbar
  static const Color bgDarkTeal = Color(0xFF2D160B); // Deep Dark Cocoa Background
  static const Color sectionBgDark = Color(0xFF7B462B); // Specific Card Color
  static const Color textPrimaryDark = Color(0xFFF9F3E7); // Vanilla Cream Text
  static const Color textSecondaryDark = Color(0xFFB0B8B8);

  // Background Assets
  static const String bgSvgLight = 'assets/images/white.svg';
  static const String bgSvgDark = 'assets/images/dark.svg';

  static String getBackgroundPath(ThemeData theme) {
    return theme.brightness == Brightness.light ? bgSvgLight : bgSvgDark;
  }

  // Card specific backgrounds (Dark Chocolate with Gold Content)
  static const Color cardBgLight = primaryTeal;
  static const Color cardBgDark = primaryTeal;
  static const Color onCardLight = highContrastGold;
  static const Color onCardDark = highContrastGold;

  static Color getCardColor(ThemeData theme) {
    return theme.brightness == Brightness.light ? cardBgLight : cardBgDark;
  }

  static LinearGradient getCardGradient(ThemeData theme) {
    final color = getCardColor(theme);
    return LinearGradient(
      colors: [color, color],
    );
  }

  static Color getOnCardColor(ThemeData theme) {
    return theme.brightness == Brightness.light ? onCardLight : onCardDark;
  }

  static Color getCardBorderColor(ThemeData theme) {
    // For Dark Chocolate cards, use a Gold border
    return highContrastGold.withValues(alpha: 0.3);
  }

  static Color getFeaturedBorderColor(ThemeData theme) {
    // For Featured Dark banners, use a solid Gold border (100% opacity)
    return highContrastGold;
  }

  static Color getIconColor(ThemeData theme) {
    // Icons on the main background (Dark in dark mode, Cream in light mode)
    return theme.brightness == Brightness.dark ? highContrastGold : primaryTeal;
  }

  static Color getInvertedIconColor(ThemeData theme) {
    // Icons on top of high-contrast gold elements (like search bar/chips)
    // Always returns Cocoa since the background is Gold in both modes
    return primaryTeal;
  }

  static Color getButtonBorderColor(ThemeData theme) {
    // Using the vanilla cream for button outlines as requested
    return getOnCardColor(theme).withValues(alpha: 0.2);
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
        primaryContainer: Color(0xFFFFECB3),
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
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: primaryTeal,
        scaffoldBackgroundColor: bgWhite,
        textTheme: CupertinoTextThemeData(
          primaryColor: primaryTeal,
          textStyle: GoogleFonts.tajawal(color: textPrimaryLight),
        ),
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
        primaryContainer: sectionBgDark,
        tertiary: accentGold,
        onTertiary: textPrimaryDark,
        surface: bgDarkTeal,
        surfaceContainerHighest: sectionBgDark,
        error: Colors.redAccent,
        onPrimary: textPrimaryDark,
        onSecondary: textPrimaryDark,
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
          foregroundColor: textPrimaryDark,
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
          color: textPrimaryDark,
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
        backgroundColor: const Color(0xFF1A0D06), // Even darker for navbar separation
        indicatorColor: Colors.transparent,
        indicatorShape: const CircleBorder(),
        overlayColor: WidgetStateProperty.all(
          gradientStart.withValues(alpha: 0.1),
        ),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        height: 70,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryTeal, size: 32);
          }
          return IconThemeData(
            color: primaryTeal.withValues(alpha: 0.5),
            size: 24,
          );
        }),
      ),
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: primaryTeal,
        scaffoldBackgroundColor: bgDarkTeal,
        barBackgroundColor: const Color(0xFF1A0D06),
        textTheme: CupertinoTextThemeData(
          primaryColor: primaryTeal,
          textStyle: GoogleFonts.tajawal(color: textPrimaryDark),
        ),
      ),
    );
  }
}
