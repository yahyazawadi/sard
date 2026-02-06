import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

class AppTheme {
  // Your 11 schemes
  static const List<FlexScheme> availableSchemes = [
    FlexScheme.mandyRed, // Red tornado / redMadder (bright mandy red)
    FlexScheme.redWine, // Red red wine / redWine (rich red wine)
    FlexScheme.deepPurple, // Deep purple / deepPurple (deep purple daisy)
    FlexScheme.sakura, // Lipstick pink / lipstickPink (vibrant pink sakura)
    FlexScheme
        .purpleBrown, // Eggplant purple / purpleBrown (aubergine eggplant)
    FlexScheme.jungle, // Green forest / jungle (lush green jungle)
    FlexScheme.shadBlue, // Shaden blue / shadeBlue (shadcn blue shades)
    FlexScheme
        .sanJuanBlue, // Indigo san marino / indigoSanMarino (san juan blue, close name/color)
    FlexScheme.indigo, // Indigo nights / indigo (deep indigo purple)
    FlexScheme
        .brandBlue, // Example red & blue / redBlue (brand blues with potential red accents)
    FlexScheme.purpleM3, // Material 3 purple / purpleM3 (Material-3 purple)
  ];

  // Light theme for any scheme
  static ThemeData lightTheme(FlexScheme scheme) {
    return FlexThemeData.light(
      scheme: scheme,
      useMaterial3: true,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 10,
        useTextTheme: true,
        elevatedButtonRadius: 12,
        outlinedButtonRadius: 12,
      ),
    );
  }

  // Dark theme for any scheme
  static ThemeData darkTheme(FlexScheme scheme) {
    return FlexThemeData.dark(
      scheme: scheme,
      useMaterial3: true,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 15,
        useTextTheme: true,
        elevatedButtonRadius: 12,
        outlinedButtonRadius: 12,
      ),
    );
  }
}
