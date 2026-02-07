import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ← New import
import 'package:tracker/hive/hive.dart';
import 'package:tracker/providers/settings_provider.dart';

import 'routes/routes.dart';
import 'models/entry_model.dart'; // CycleEntryAdapter
import 'custom/app_theme.dart';
import 'custom/system_locale.dart';
import 'custom/system_theme_mode.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive for cycles only (encrypted)
  await initEncryptedHive(); // From your hive_init.dart
  final cyclesBox = Hive.box<CycleEntry>('cycles');

  // SharedPreferences for settings (faster, unencrypted)
  final prefs = await SharedPreferences.getInstance();

  // Provider
  final appSettingsProvider = AppSettingsProvider(prefs);

  // Load defaults only if no saved values
  if (!prefs.containsKey('language')) {
    appSettingsProvider.locale = SystemLocale.getDefault();
  }

  if (!prefs.containsKey('themeMode')) {
    appSettingsProvider.themeMode = SystemThemeMode.getDefault();
  }

  final double systemTextScaleFactor =
      ui.PlatformDispatcher.instance.textScaleFactor;
  if (!prefs.containsKey('textScale')) {
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

    return MaterialApp.router(
      title: 'Tracker',
      theme: AppTheme.lightTheme(prov.selectedScheme).copyWith(
        textTheme: TextTheme(
          bodyMedium: TextStyle(
            fontFamily: prov.locale.languageCode == 'ar'
                ? 'DG Sahabah'
                : 'Roboto',
          ),
        ),
      ),
      darkTheme: AppTheme.darkTheme(prov.selectedScheme).copyWith(
        textTheme: TextTheme(
          bodyMedium: TextStyle(
            fontFamily: prov.locale.languageCode == 'ar'
                ? 'DG Sahabah'
                : 'Roboto',
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
