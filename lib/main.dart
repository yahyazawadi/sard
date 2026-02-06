import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tracker/providers/theme_provider.dart';

import 'routes/routes.dart';
import 'custom/app_theme.dart';
import 'custom/system_locale.dart';
import 'custom/system_theme_mode.dart';
import 'hive/hive_setup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive setup in one call
  await HiveSetup.initialize();
  final encryptionKey = await HiveSetup.getEncryptionKey();
  final boxes = await HiveSetup.openBoxes(encryptionKey);

  final settingsBox = boxes['settingsBox'] as Box;

  // Provider
  final appSettingsProvider = AppSettingsProvider(settingsBox);

  // Load defaults only if no saved values
  if (!settingsBox.containsKey('language')) {
    appSettingsProvider.locale = SystemLocale.getDefault();
  }

  if (!settingsBox.containsKey('themeMode')) {
    appSettingsProvider.themeMode = SystemThemeMode.getDefault();
  }
  // Load text scale factor from system if not overridden
  final double systemTextScaleFactor =
      ui.PlatformDispatcher.instance.textScaleFactor;
  if (!settingsBox.containsKey('textScale')) {
    appSettingsProvider.textScale = systemTextScaleFactor.clamp(0.8, 2.0);
    appSettingsProvider.hasTextScaleOverride = false;
  }

  runApp(
    ChangeNotifierProvider<AppSettingsProvider>(
      create: (_) => appSettingsProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<AppSettingsProvider>(context);

    final baseLight = AppTheme.lightTheme(prov.selectedScheme);
    final baseDark = AppTheme.darkTheme(prov.selectedScheme);

    return MaterialApp.router(
      title: 'Tracker',
      theme: baseLight.copyWith(
        textTheme: baseLight.textTheme
            .apply(fontFamily: 'DG Sahabah')
            .copyWith(
              displayLarge: const TextStyle(fontWeight: FontWeight.w300),
              displayMedium: const TextStyle(fontWeight: FontWeight.w300),
              displaySmall: const TextStyle(fontWeight: FontWeight.w300),
              headlineLarge: const TextStyle(fontWeight: FontWeight.w300),
              headlineMedium: const TextStyle(fontWeight: FontWeight.w300),
              headlineSmall: const TextStyle(fontWeight: FontWeight.w300),
              titleLarge: const TextStyle(fontWeight: FontWeight.w300),
              titleMedium: const TextStyle(fontWeight: FontWeight.w300),
              titleSmall: const TextStyle(fontWeight: FontWeight.w300),
              bodyLarge: const TextStyle(fontWeight: FontWeight.w300),
              bodyMedium: const TextStyle(fontWeight: FontWeight.w300),
              bodySmall: const TextStyle(fontWeight: FontWeight.w300),
              labelLarge: const TextStyle(fontWeight: FontWeight.w300),
              labelMedium: const TextStyle(fontWeight: FontWeight.w300),
              labelSmall: const TextStyle(fontWeight: FontWeight.w300),
            ),
        appBarTheme: baseLight.appBarTheme.copyWith(
          titleTextStyle: baseLight.textTheme.titleLarge?.copyWith(
            fontFamily: 'DG Sahabah',
            fontWeight: FontWeight.w300,
            fontSize: 20,
          ),
        ),
        bottomNavigationBarTheme: baseLight.bottomNavigationBarTheme.copyWith(
          selectedLabelStyle: baseLight.textTheme.labelMedium?.copyWith(
            fontFamily: 'DG Sahabah',
            fontWeight: FontWeight.w300,
          ),
          unselectedLabelStyle: baseLight.textTheme.labelMedium?.copyWith(
            fontFamily: 'DG Sahabah',
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
      darkTheme: baseDark.copyWith(
        textTheme: baseDark.textTheme
            .apply(fontFamily: 'DG Sahabah')
            .copyWith(
              displayLarge: const TextStyle(fontWeight: FontWeight.w300),
              displayMedium: const TextStyle(fontWeight: FontWeight.w300),
              displaySmall: const TextStyle(fontWeight: FontWeight.w300),
              headlineLarge: const TextStyle(fontWeight: FontWeight.w300),
              headlineMedium: const TextStyle(fontWeight: FontWeight.w300),
              headlineSmall: const TextStyle(fontWeight: FontWeight.w300),
              titleLarge: const TextStyle(fontWeight: FontWeight.w300),
              titleMedium: const TextStyle(fontWeight: FontWeight.w300),
              titleSmall: const TextStyle(fontWeight: FontWeight.w300),
              bodyLarge: const TextStyle(fontWeight: FontWeight.w300),
              bodyMedium: const TextStyle(fontWeight: FontWeight.w300),
              bodySmall: const TextStyle(fontWeight: FontWeight.w300),
              labelLarge: const TextStyle(fontWeight: FontWeight.w300),
              labelMedium: const TextStyle(fontWeight: FontWeight.w300),
              labelSmall: const TextStyle(fontWeight: FontWeight.w300),
            ),
        appBarTheme: baseDark.appBarTheme.copyWith(
          titleTextStyle: baseDark.textTheme.titleLarge?.copyWith(
            fontFamily: 'DG Sahabah',
            fontWeight: FontWeight.w300,
            fontSize: 20,
          ),
        ),
        bottomNavigationBarTheme: baseDark.bottomNavigationBarTheme.copyWith(
          selectedLabelStyle: baseDark.textTheme.labelMedium?.copyWith(
            fontFamily: 'DG Sahabah',
            fontWeight: FontWeight.w300,
          ),
          unselectedLabelStyle: baseDark.textTheme.labelMedium?.copyWith(
            fontFamily: 'DG Sahabah',
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
      themeMode: prov.themeMode,
      locale: prov.locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: prov.hasTextScaleOverride
                ? TextScaler.linear(prov.textScale)
                : null,
          ),
          child: Directionality(
            textDirection: prov.locale.languageCode == 'ar'
                ? TextDirection.rtl
                : TextDirection.ltr,
            child: child!,
          ),
        );
      },
      routerConfig: router,
    );
  }
}
