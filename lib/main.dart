import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:sard/l10n/app_localizations.dart'; 
import 'package:sard/providers/settings_provider.dart';
import 'package:sard/providers/cart_provider.dart';
import 'package:sard/providers/auth_provider.dart';

import 'routes/routes.dart';
import 'routes/app_routes.dart';
import 'custom/app_theme.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(const SardAppConfigurator());
}

class SardAppConfigurator extends StatelessWidget {
  const SardAppConfigurator({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        final prefs = snapshot.data!;
        
        return MultiProvider(
          providers: [
            ChangeNotifierProvider<AppSettingsProvider>(
              create: (_) => AppSettingsProvider(prefs),
            ),
            ChangeNotifierProvider<CartProvider>(
              create: (_) => CartProvider(prefs),
            ),
            ChangeNotifierProvider<AuthProvider>(
              create: (_) => AuthProvider(prefs),
            ),
          ],
          child: const MyApp(),
        );
      },
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
    final prov = Provider.of<AppSettingsProvider>(context);
    final scale = prov.hasTextScaleOverride ? prov.textScale : 1.0;
    final fontFamily = prov.fontFamily;

    return MaterialApp.router(
      title: 'Sard - Chocolate Shop',
      theme: AppTheme.lightTheme(scale: scale, fontFamily: fontFamily),
      darkTheme: AppTheme.darkTheme(scale: scale, fontFamily: fontFamily),
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
        return Directionality(
          textDirection: prov.locale.languageCode == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: child!,
        );
      },
      routerConfig: _router,
    );
  }
}
