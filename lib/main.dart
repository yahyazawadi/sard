import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For prefs
import 'package:tracker/l10n/app_localizations.dart';
import 'package:tracker/providers/cycle_provider.dart';
import 'package:tracker/providers/settings_provider.dart';

import 'routes/routes.dart';
import 'custom/app_theme.dart';
import 'hive/hive_setup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const HiveLoadingApp());
}

class HiveLoadingApp extends StatefulWidget {
  const HiveLoadingApp({super.key});

  @override
  State<HiveLoadingApp> createState() => _HiveLoadingAppState();
}

class _HiveLoadingAppState extends State<HiveLoadingApp> {
  bool _hiveReady = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHive();
  }

  Future<void> _loadHive() async {
    try {
      await HiveSetup.initialize();
      final encryptionKey = await HiveSetup.getEncryptionKey();
      await HiveSetup.openCyclesBox(encryptionKey);
      print('✅ Hive fully ready');
      setState(() => _hiveReady = true);
    } catch (e) {
      print('Hive error: $e');
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Error loading data:\n$_error')),
        ),
      );
    }

    if (!_hiveReady) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text('جاري تحميل التطبيق...'),
              ],
            ),
          ),
        ),
      );
    }

    // Hive is ready → run normal app
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        final prefs = snapshot.data!;
        final appSettingsProvider = AppSettingsProvider(prefs);

        return MultiProvider(
          providers: [
            ChangeNotifierProvider<AppSettingsProvider>(
              create: (_) => appSettingsProvider,
            ),
            ChangeNotifierProvider<CycleProvider>(
              create: (_) => CycleProvider(),
            ),
          ],
          child: const MyApp(),
        );
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<AppSettingsProvider>(context);

    // final baseLight = AppTheme.lightTheme(prov.selectedScheme);
    // final baseDark = AppTheme.darkTheme(prov.selectedScheme);

    return MaterialApp.router(
      title: 'Tracker',
      // theme: baseLight.copyWith(
      //   textTheme: baseLight.textTheme
      //       .apply(fontFamily: 'DG Sahabah')
      //       .copyWith(
      //         displayLarge: const TextStyle(fontWeight: FontWeight.w300),
      //         displayMedium: const TextStyle(fontWeight: FontWeight.w300),
      //         displaySmall: const TextStyle(fontWeight: FontWeight.w300),
      //         headlineLarge: const TextStyle(fontWeight: FontWeight.w300),
      //         headlineMedium: const TextStyle(fontWeight: FontWeight.w300),
      //         headlineSmall: const TextStyle(fontWeight: FontWeight.w300),
      //         titleLarge: const TextStyle(fontWeight: FontWeight.w300),
      //         titleMedium: const TextStyle(fontWeight: FontWeight.w300),
      //         titleSmall: const TextStyle(fontWeight: FontWeight.w300),
      //         bodyLarge: const TextStyle(fontWeight: FontWeight.w300),
      //         bodyMedium: const TextStyle(fontWeight: FontWeight.w300),
      //         bodySmall: const TextStyle(fontWeight: FontWeight.w300),
      //         labelLarge: const TextStyle(fontWeight: FontWeight.w300),
      //         labelMedium: const TextStyle(fontWeight: FontWeight.w300),
      //         labelSmall: const TextStyle(fontWeight: FontWeight.w300),
      //       ),
      //   appBarTheme: baseLight.appBarTheme.copyWith(
      //     titleTextStyle: baseLight.textTheme.titleLarge?.copyWith(
      //       fontFamily: 'DG Sahabah',
      //       fontWeight: FontWeight.w300,
      //       fontSize: 20,
      //     ),
      //   ),
      //   bottomNavigationBarTheme: baseLight.bottomNavigationBarTheme.copyWith(
      //     selectedLabelStyle: baseLight.textTheme.labelMedium?.copyWith(
      //       fontFamily: 'DG Sahabah',
      //       fontWeight: FontWeight.w300,
      //     ),
      //     unselectedLabelStyle: baseLight.textTheme.labelMedium?.copyWith(
      //       fontFamily: 'DG Sahabah',
      //       fontWeight: FontWeight.w300,
      //     ),
      //   ),
      // ),
      // darkTheme: baseDark.copyWith(
      //   textTheme: baseDark.textTheme
      //       .apply(fontFamily: 'DG Sahabah')
      //       .copyWith(
      //         displayLarge: const TextStyle(fontWeight: FontWeight.w300),
      //         displayMedium: const TextStyle(fontWeight: FontWeight.w300),
      //         displaySmall: const TextStyle(fontWeight: FontWeight.w300),
      //         headlineLarge: const TextStyle(fontWeight: FontWeight.w300),
      //         headlineMedium: const TextStyle(fontWeight: FontWeight.w300),
      //         headlineSmall: const TextStyle(fontWeight: FontWeight.w300),
      //         titleLarge: const TextStyle(fontWeight: FontWeight.w300),
      //         titleMedium: const TextStyle(fontWeight: FontWeight.w300),
      //         titleSmall: const TextStyle(fontWeight: FontWeight.w300),
      //         bodyLarge: const TextStyle(fontWeight: FontWeight.w300),
      //         bodyMedium: const TextStyle(fontWeight: FontWeight.w300),
      //         bodySmall: const TextStyle(fontWeight: FontWeight.w300),
      //         labelLarge: const TextStyle(fontWeight: FontWeight.w300),
      //         labelMedium: const TextStyle(fontWeight: FontWeight.w300),
      //         labelSmall: const TextStyle(fontWeight: FontWeight.w300),
      //       ),
      //   appBarTheme: baseDark.appBarTheme.copyWith(
      //     titleTextStyle: baseDark.textTheme.titleLarge?.copyWith(
      //       fontFamily: 'DG Sahabah',
      //       fontWeight: FontWeight.w300,
      //       fontSize: 20,
      //     ),
      //   ),
      //   bottomNavigationBarTheme: baseDark.bottomNavigationBarTheme.copyWith(
      //     selectedLabelStyle: baseDark.textTheme.labelMedium?.copyWith(
      //       fontFamily: 'DG Sahabah',
      //       fontWeight: FontWeight.w300,
      //     ),
      //     unselectedLabelStyle: baseDark.textTheme.labelMedium?.copyWith(
      //       fontFamily: 'DG Sahabah',
      //       fontWeight: FontWeight.w300,
      //     ),
      //   ),
      // ),
      theme: AppTheme.lightTheme(prov.selectedScheme).copyWith(
        textTheme: AppTheme.lightTheme(
          prov.selectedScheme,
        ).textTheme.apply(fontFamily: 'DG Sahabah'),
      ),
      darkTheme: AppTheme.darkTheme(prov.selectedScheme).copyWith(
        textTheme: AppTheme.darkTheme(
          prov.selectedScheme,
        ).textTheme.apply(fontFamily: 'DG Sahabah'),
      ),
      themeMode: prov.themeMode,
      locale: prov.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: [
        AppLocalizations.delegate,
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
