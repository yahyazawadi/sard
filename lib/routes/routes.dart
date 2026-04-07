import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';
import '../screens/home_screen.dart';
import '../screens/settings_screen.dart';

import 'app_routes.dart';

final GoRouter router = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    ShellRoute(
      builder: (context, state, child) => Scaffold(
        body: child,
        bottomNavigationBar: Directionality(
          textDirection: TextDirection.ltr, // Keep LTR for the bottom nav bar or change depending on requirements
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
