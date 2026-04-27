// =============================================================================
// ROUTER — NAVIGATION LOGIC
// =============================================================================
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/product_detail_screen.dart';
import '../models/product.dart';
import '../screens/profile_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/verify_screen.dart';
import '../providers/auth_provider.dart';
import '../screens/cart_screen.dart';
import '../screens/checkout_screen.dart';
import '../screens/collection_screen.dart';
import '../models/cart_item.dart';
import '../models/featured_template.dart';
import 'app_routes.dart';

import '../screens/main_wrapper_screen.dart';

GoRouter createRouter(AuthProvider auth) {
  return GoRouter(
    initialLocation: AppRoutes.onboarding,
    refreshListenable: auth,
    debugLogDiagnostics: true, // Helpful for debugging route issues
    redirect: (context, state) {
      final path = state.uri.path;
      final isAuthenticated = auth.isAuthenticated;
      final isLoading = auth.isLoading;

      if (isLoading) return null;

      if (!isAuthenticated) {
        const allowedWhenLoggedOut = {
          AppRoutes.onboarding,
          AppRoutes.login,
          AppRoutes.signUp,
          AppRoutes.forgotPassword,
          AppRoutes.verify,
        };
        if (allowedWhenLoggedOut.contains(path)) return null;
        return AppRoutes.onboarding;
      }

      final user = auth.user;
      final isEmailUser =
          user?.providerData.any((p) => p.providerId == 'password') ?? false;
      if (isEmailUser && !(user?.emailVerified ?? true)) {
        if (path != AppRoutes.verify) return AppRoutes.verify;
        return null;
      }

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
      GoRoute(path: AppRoutes.verify, builder: (_, _) => const VerifyScreen()),

      // ── Authenticated Routes (Main Wrapper with bottom nav) ──────────────────────
      GoRoute(
        path: AppRoutes.home,
        builder: (_, _) => const MainWrapperScreen(),
      ),

      // Standalone routes (these push over the main wrapper, hiding the bottom nav bar)
      GoRoute(path: AppRoutes.cart, builder: (_, _) => const CartScreen()),
      GoRoute(
        path: AppRoutes.productDetail,
        builder: (context, state) {
          if (state.extra is Product) {
            return ProductDetailScreen(product: state.extra as Product);
          } else if (state.extra is Map<String, dynamic>) {
            final map = state.extra as Map<String, dynamic>;
            return ProductDetailScreen(
              product: map['product'] as Product,
              editingItem: map['editingItem'] as CartItem?,
            );
          }
          return const Scaffold(
            body: Center(child: Text("Product data missing")),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (_, _) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.collection,
        builder: (context, state) {
          final template = state.extra as FeaturedTemplate;
          return CollectionScreen(template: template);
        },
      ),
      GoRoute(
        path: AppRoutes.checkout,
        builder: (_, _) => const CheckoutScreen(),
      ),
    ],
  );
}
