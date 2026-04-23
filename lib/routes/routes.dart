// =============================================================================
// ROUTER — NAVIGATION LOGIC
// =============================================================================
// ╔══════════════════════════════════════════════════════════════════════════╗
// ║  ██████████████  DO NOT TOUCH THE REDIRECT LOGIC  ████████████████████  ║
// ║                                                                          ║
// ║  Routing Rules (in priority order):                                      ║
// ║  1. If loading → stay put (null)                                         ║
// ║  2. If NOT authenticated → allow only: onboarding, login, signup,        ║
// ║       forgotPassword, verify. Everything else → onboarding               ║
// ║  3. If authenticated + email NOT verified (email/password only) → /verify ║
// ║  4. If authenticated + verified + on auth page → /home                   ║
// ║  5. Otherwise → stay put (null)                                          ║
// ║                                                                          ║
// ║  ⚠️  Onboarding is ALWAYS the front door when not logged in.             ║
// ║      hasSeenOnboarding is for UI only (e.g. skip intro animation).       ║
// ║      It does NOT gate routing. Do NOT redirect onboarding → login.       ║
// ║                                                                          ║
// ║  ⚠️  emailVerified is ONLY gated here. Do NOT check it in auth methods.  ║
// ║      Calling signOut() in loginWithEmail creates a race condition where   ║
// ║      the auth stream fires first (→ home), then signOut fires (→ login). ║
// ╚══════════════════════════════════════════════════════════════════════════╝
// =============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';
import '../screens/home_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
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
      final isLoading = auth.isLoading;

      print('!!! Router: path=$path, auth=$isAuthenticated, loading=$isLoading');

      // ── Loading: stay put ───────────────────────────────────────────────────
      if (isLoading) return null;

      // ── NOT authenticated ───────────────────────────────────────────────────
      // Onboarding is ALWAYS the front door. All auth pages are allowed.
      // ⚠️  Do NOT redirect onboarding → login here. That caused an infinite
      //     loop where the back button on login bounced between the two.
      if (!isAuthenticated) {
        const allowedWhenLoggedOut = {
          AppRoutes.onboarding,
          AppRoutes.login,
          AppRoutes.signUp,
          AppRoutes.forgotPassword,
          AppRoutes.verify,
        };
        if (allowedWhenLoggedOut.contains(path)) return null;
        // Any protected page → kick to onboarding
        return AppRoutes.onboarding;
      }

      // ── Authenticated ───────────────────────────────────────────────────────
      // ⚠️  This is the ONLY emailVerified gate. Do NOT add checks elsewhere.
      // ⚠️  Do NOT call signOut() in auth code based on emailVerified — race condition.
      final user = auth.user;
      final isEmailUser = user?.providerData.any((p) => p.providerId == 'password') ?? false;
      if (isEmailUser && !(user?.emailVerified ?? true)) {
        // Signed in but unverified → stay on verify screen
        print('!!! Router: Unverified email → /verify');
        if (path != AppRoutes.verify) return AppRoutes.verify;
        return null;
      }

      // Authenticated + verified: kick off auth/onboarding pages
      const authPages = {
        AppRoutes.onboarding,
        AppRoutes.login,
        AppRoutes.signUp,
        AppRoutes.forgotPassword,
        AppRoutes.verify,
      };
      if (authPages.contains(path)) return AppRoutes.home;

      return null;
    },
    routes: [
      // ── Auth / Onboarding Routes ──────────────────────────────────────────
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, _) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) {
          final email = state.uri.queryParameters['email'];
          final isSignUp = state.uri.queryParameters['signup'] == 'true';
          final oobCode = state.uri.queryParameters['oobCode'];
          return CustomTransitionPage(
            key: state.pageKey,
            transitionDuration: const Duration(milliseconds: 600),
            child: LoginScreen(
              initialEmail: email,
              initialIsSignUp: isSignUp,
              oobCode: oobCode,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: animation.drive(
                    Tween(begin: const Offset(1, 0), end: Offset.zero)
                        .chain(CurveTween(curve: Curves.easeOutCubic)),
                  ),
                  child: child,
                ),
              );
            },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.signUp,
        pageBuilder: (context, state) {
          final email = state.uri.queryParameters['email'];
          final oobCode = state.uri.queryParameters['oobCode'];
          return CustomTransitionPage(
            key: state.pageKey,
            transitionDuration: const Duration(milliseconds: 600),
            child: LoginScreen(
              initialEmail: email,
              initialIsSignUp: true,
              oobCode: oobCode,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: animation.drive(
                    Tween(begin: const Offset(1, 0), end: Offset.zero)
                        .chain(CurveTween(curve: Curves.easeOutCubic)),
                  ),
                  child: child,
                ),
              );
            },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          transitionDuration: const Duration(milliseconds: 600),
          child: const ForgotPasswordScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: animation.drive(
                  Tween(begin: const Offset(1, 0), end: Offset.zero)
                      .chain(CurveTween(curve: Curves.easeOutCubic)),
                ),
                child: child,
              ),
            );
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.verify,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          transitionDuration: const Duration(milliseconds: 600),
          child: const VerifyScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: animation.drive(
                  Tween(begin: const Offset(1, 0), end: Offset.zero)
                      .chain(CurveTween(curve: Curves.easeOutCubic)),
                ),
                child: child,
              ),
            );
          },
        ),
      ),

      // ── Authenticated Routes (Shell with bottom nav) ──────────────────────
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
              currentIndex: state.uri.path == AppRoutes.settings ? 1 : 0,
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
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              transitionDuration: const Duration(milliseconds: 600),
              child: const HomeScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: animation.drive(
                      Tween(begin: const Offset(1, 0), end: Offset.zero)
                          .chain(CurveTween(curve: Curves.easeOutCubic)),
                    ),
                    child: child,
                  ),
                );
              },
            ),
          ),
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              transitionDuration: const Duration(milliseconds: 600),
              child: const SettingsScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: animation.drive(
                      Tween(begin: const Offset(1, 0), end: Offset.zero)
                          .chain(CurveTween(curve: Curves.easeOutCubic)),
                    ),
                    child: child,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ],
  );
}
