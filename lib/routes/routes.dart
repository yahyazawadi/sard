import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker/l10n/app_localizations.dart';
import 'package:tracker/screens/InfoScreen.dart';
import 'package:tracker/screens/calendar/calendar_screen.dart';
import 'package:tracker/screens/settings/settings_screen.dart';

import '../routes/app_routes.dart';

final GoRouter router = GoRouter(
  initialLocation: AppRoutes.home,

  routes: [
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
                : state.uri.path == AppRoutes.phase
                ? 1
                : state.uri.path == AppRoutes.settings
                ? 2
                : 0,
            onTap: (index) {
              if (index == 0) context.go(AppRoutes.home);
              if (index == 1) context.go(AppRoutes.phase);
              if (index == 2) context.go(AppRoutes.settings);
            },

            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.info),
                label: AppLocalizations.of(context)!.phase,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: AppLocalizations.of(context)!.home,
              ),

              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: AppLocalizations.of(context)!.settings,
              ),
            ],
          ),
        ),
      ),
      routes: [
        GoRoute(
          path: AppRoutes.home,
          builder: (_, _) => const CalendarScreen(),
        ),
        GoRoute(path: AppRoutes.phase, builder: (_, _) => const InfoScreen()),
        GoRoute(
          path: AppRoutes.settings,
          builder: (_, _) => const SettingsScreen(),
        ),
        // Add more like:
        // GoRoute(path: AppRoutes.newNote, builder: (_, __) => const EntryScreen()),
        // GoRoute(path: AppRoutes.editNote, builder: (context, state) {
        //   final date = state.pathParameters['date'] ?? DateTime.now().toIso8601String();
        //   return EntryScreen(date: DateTime.parse(date));
        // }),
      ],
    ),
  ],
);
