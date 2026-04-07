import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For prefs
import 'package:tracker/l10n/app_localizations.dart';
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
      await HiveSetup.openSettingsBox(encryptionKey);
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

    return MaterialApp.router(
      title: 'Flutter Boilerplate',
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
      localizationsDelegates: const [
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
