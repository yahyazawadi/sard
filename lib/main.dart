import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:sard/l10n/app_localizations.dart'; 
import 'routes/routes.dart';
import 'routes/app_routes.dart';
import 'custom/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/settings_provider.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, ChangeNotifierProvider;

import 'providers/isar_provider.dart';
import 'providers/sync_provider.dart';
import 'providers/prefs_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  final isar = await initIsar();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(isar),
        prefsProvider.overrideWithValue(prefs),
      ],
      child: const SardAppConfigurator(),
    ),
  );
}

class SardAppConfigurator extends ConsumerWidget {
  const SardAppConfigurator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We still use MultiProvider for Auth (ChangeNotifier) to support GoRouter's refreshListenable easily
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(ref.read(prefsProvider)),
        ),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late final GoRouter _router;
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    // Initialize the router once. It will refresh automatically because of refreshListenable.
    final auth = context.read<AuthProvider>();
    _router = createRouter(auth);
    _initDeepLinks();
    
    // Seed database
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final container = ProviderScope.containerOf(context);
      container.read(syncProvider).performInitialSeed();
    });
  }

  void _initDeepLinks() {
    _appLinks = AppLinks();

    // Handle links when app is in foreground or background
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      print('!!! RAW DEEP LINK DETECTED: $uri');
      _handleDeepLink(uri);
    });

    // Handle link that opened the app
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        debugPrint('Initial Deep Link: $uri');
        _handleDeepLink(uri);
      }
    });
  }

  void _handleDeepLink(Uri uri) {
    try {
      final linkStr = uri.toString();
      print('!!! Processing Link: $linkStr (scheme: ${uri.scheme})');

      String? firebaseLink;

      if (uri.scheme == 'sarad') {
        firebaseLink = uri.queryParameters['link'] ?? uri.queryParameters['continueUrl'];
        if (firebaseLink == null && linkStr.contains('oobCode')) {
          firebaseLink = linkStr;
        }
      } else if (linkStr.contains('apiKey') || linkStr.contains('oobCode')) {
        firebaseLink = linkStr;
      }

      if (firebaseLink != null) {
        final firebaseUri = Uri.parse(firebaseLink);
        final mode = firebaseUri.queryParameters['mode'];
        final oobCode = firebaseUri.queryParameters['oobCode'];
        
        print('!!! Detected Firebase mode: $mode');

        Future.delayed(const Duration(milliseconds: 500), () async {
          if (mode == 'resetPassword' && oobCode != null) {
            // Navigate directly to sign up (which handles recovery) with the code
            final email = await FirebaseAuth.instance.verifyPasswordResetCode(oobCode);
            final target = '${AppRoutes.signUp}?email=${Uri.encodeComponent(email)}&oobCode=$oobCode';
            print('!!! Redirecting directly to Recovery: $target');
            _router.go(target);
          } else if (mode == 'verifyEmail' && oobCode != null) {
            await FirebaseAuth.instance.applyActionCode(oobCode);
            print('!!! Email verified. Reloading user state...');
            // Reload so the router sees emailVerified=true and navigates to home
            final authProvider = _router.routerDelegate.navigatorKey.currentContext
                ?.read<AuthProvider>();
            if (authProvider != null) {
              await authProvider.reloadUser();
            }
            _router.go(AppRoutes.home);
          } else {
            print('!!! Unhandled link mode: $mode. Doing nothing.');
          }
        });
      }
    } catch (e, stack) {
      print('!!! Error in _handleDeepLink: $e');
      print(stack);
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final scale = settings.hasTextScaleOverride ? settings.textScale : 1.0;
    final fontFamily = settings.fontFamily;

    return MaterialApp.router(
      title: 'Sard - Chocolate Shop',
      theme: AppTheme.lightTheme(scale: scale, fontFamily: fontFamily),
      darkTheme: AppTheme.darkTheme(scale: scale, fontFamily: fontFamily),
      themeMode: settings.themeMode,
      locale: settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return Directionality(
          textDirection: settings.locale.languageCode == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: child!,
        );
      },
      routerConfig: _router,
    );
  }
}
