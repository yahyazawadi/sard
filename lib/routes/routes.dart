// =============================================================================
// ROUTER — NAVIGATION LOGIC
// =============================================================================
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/product_detail_screen.dart';
import '../models/product.dart';
import '../screens/profile_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/verify_screen.dart';
import '../providers/auth_provider.dart';
import '../screens/search_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/checkout_screen.dart';
import '../screens/collection_screen.dart';
import '../models/cart_item.dart';
import '../models/featured_template.dart';
import 'app_routes.dart';
import '../custom/app_theme.dart';

int _getSelectedIndex(String path) {
  if (path == AppRoutes.settings) return 3;
  if (path == AppRoutes.cart) return 2;
  if (path == AppRoutes.search) return 1;
  if (path == AppRoutes.home ||
      path == '/' ||
      path == AppRoutes.collection ||
      path == AppRoutes.productDetail) {
    return 0;
  }
  return -1;
}

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

      // ── Authenticated Routes (Shell with bottom nav) ──────────────────────
      ShellRoute(
        builder: (context, state, child) => Scaffold(
          body: child,
          bottomNavigationBar: NavigationBar(
            selectedIndex: _getSelectedIndex(state.uri.path) == -1
                ? 0
                : _getSelectedIndex(state.uri.path),
            onDestinationSelected: (index) {
              if (index == 0) context.go(AppRoutes.home);
              if (index == 1) context.go(AppRoutes.search);
              if (index == 2) context.go(AppRoutes.cart);
              if (index == 3) context.go(AppRoutes.settings);
            },
            destinations: [
              NavigationDestination(
                icon: const SizedBox(
                  width: 52,
                  height: 52,
                  child: Center(child: Icon(Icons.home_outlined)),
                ),
                selectedIcon: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(child: Icon(Icons.home_rounded)),
                ),
                label: 'Home',
              ),
              NavigationDestination(
                icon: const SizedBox(
                  width: 52,
                  height: 52,
                  child: Center(child: Icon(Icons.search_rounded)),
                ),
                selectedIcon: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(child: Icon(Icons.search_rounded)),
                ),
                label: 'Search',
              ),
              NavigationDestination(
                icon: const SizedBox(
                  width: 52,
                  height: 52,
                  child: Center(child: Icon(Icons.shopping_cart_outlined)),
                ),
                selectedIcon: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(child: Icon(Icons.shopping_cart_rounded)),
                ),
                label: 'Cart',
              ),
              NavigationDestination(
                icon: const SizedBox(
                  width: 52,
                  height: 52,
                  child: Center(child: Icon(Icons.person_outline_rounded)),
                ),
                selectedIcon: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(child: Icon(Icons.person_rounded)),
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
        routes: [
          GoRoute(path: AppRoutes.home, builder: (_, _) => const HomeScreen()),
          GoRoute(
            path: AppRoutes.search,
            builder: (context, state) {
              final categoryId = state.uri.queryParameters['category'];
              final focus = state.uri.queryParameters['focus'] == 'true';
              return SearchScreen(
                initialCategoryId: categoryId,
                autofocus: focus,
              );
            },
          ),
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
        ],
      ),
      GoRoute(
        path: AppRoutes.checkout,
        builder: (_, _) => const CheckoutScreen(),
      ),
    ],
  );
}
