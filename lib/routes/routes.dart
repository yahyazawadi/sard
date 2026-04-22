import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';
import '../screens/home_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/verify_screen.dart';
import '../providers/auth_provider.dart';

import 'app_routes.dart';

GoRouter createRouter(AuthProvider auth) {
  return GoRouter(
    initialLocation: AppRoutes.onboarding,
    refreshListenable: auth,
    redirect: (context, state) {
      final path = state.uri.path;
      final isAuthenticated = auth.isAuthenticated;
      final hasSeenOnboarding = auth.hasSeenOnboarding;
      final isLoading = auth.isLoading;

      print('!!! Router Redirect: path=$path, auth=$isAuthenticated, onboarding=$hasSeenOnboarding, loading=$isLoading');

      if (isLoading) {
        print('!!! Router: Loading, staying put.');
        return null;
      }

      final isAuthRoute = path == AppRoutes.login || 
                          path == AppRoutes.signUp || 
                          path == AppRoutes.forgotPassword ||
                          path == AppRoutes.verify ||
                          path == AppRoutes.onboarding ||
                          path == '/__/auth/action';
      final isOnboardingRoute = path == AppRoutes.onboarding;

      // 1. If NOT authenticated and HASN'T seen onboarding, force OnboardingScreen
      if (!isAuthenticated && !hasSeenOnboarding) {
        if (!isOnboardingRoute) {
          print('!!! Router: Not auth, no onboarding -> Redirecting to Onboarding');
          return AppRoutes.onboarding;
        }
        return null;
      }

      // 2. If authenticated, restrict returning to onboarding/auth screens
      // UNLESS we are on the Verify route (to allow the link processing to finish)
      if (isAuthenticated) {
        if ((isAuthRoute || isOnboardingRoute) && path != AppRoutes.verify) {
          print('!!! Router: Authenticated but on Auth page -> Redirecting to Home');
          return AppRoutes.home;
        }
        return null; 
      }

      // 3. If NOT authenticated but HAS seen onboarding, redirect Onboarding to Login
      if (isOnboardingRoute) {
        print('!!! Router: Allowing Auth Action/Verify route.');
        return null;
      }

      if (!isAuthRoute) {
        print('!!! Router: Not on auth route -> Redirecting to Login');
        return AppRoutes.login;
      }

      print('!!! Router: Staying on $path');
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, _) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) {
          final email = state.uri.queryParameters['email'];
          final isSignUp = state.uri.queryParameters['signup'] == 'true';
          final oobCode = state.uri.queryParameters['oobCode'];
          return LoginScreen(
            initialEmail: email, 
            initialIsSignUp: isSignUp,
            oobCode: oobCode,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (context, state) {
          final email = state.uri.queryParameters['email'];
          final oobCode = state.uri.queryParameters['oobCode'];
          return LoginScreen(
            initialEmail: email, 
            initialIsSignUp: true,
            oobCode: oobCode,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, _) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/__/auth/action',
        builder: (context, state) {
          // This captures the Firebase Auth links natively
          final fullLink = state.uri.toString();
          print('!!! GoRouter caught Auth link: $fullLink');
          return VerifyScreen(emailLink: fullLink);
        },
      ),
      GoRoute(
        path: AppRoutes.verify,
        builder: (context, state) {
          final link = state.uri.queryParameters['link'];
          print('!!! GoRouter /verify builder. link param: $link');
          return VerifyScreen(emailLink: link);
        },
      ),
      ShellRoute(
        builder: (context, state, child) => Scaffold(
          body: child,
          bottomNavigationBar: Directionality(
            textDirection: TextDirection.ltr,
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Theme.of(context).colorScheme.primary,
              unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
              backgroundColor: Theme.of(context).colorScheme.surface,
              currentIndex: state.uri.path == AppRoutes.home
                  ? 0
                  : state.uri.path == AppRoutes.settings
                  ? 1
                  : 0,
              onTap: (index) {
                if (index == 0) context.go(AppRoutes.home);
                if (index == 1) context.go(AppRoutes.settings);
              },
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home),
                  label: AppLocalizations.of(context)?.home ?? 'Home',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.settings),
                  label: AppLocalizations.of(context)?.settings ?? 'Settings',
                ),
              ],
            ),
          ),
        ),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (_, _) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (_, _) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
}
