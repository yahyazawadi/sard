import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker/screens/HomeScreen.dart';
import 'package:tracker/screens/InfoScreen.dart';
import 'package:tracker/screens/settings/SettingsScreen.dart';

import '../routes/app_routes.dart';

final GoRouter router = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    ShellRoute(
      builder: (context, state, child) => Scaffold(
        appBar: AppBar(
          title: Text(
            state.uri.path == AppRoutes.home
                ? 'Home'
                : state.uri.path == AppRoutes.info
                ? 'Info'
                : state.uri.path == AppRoutes.settings
                ? 'Settings'
                : 'Tracker',
          ),
        ),
        body: child,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: state.uri.path == AppRoutes.home
              ? 0
              : state.uri.path == AppRoutes.info
              ? 1
              : state.uri.path == AppRoutes.settings
              ? 2
              : 0,
          onTap: (index) {
            if (index == 0) context.go(AppRoutes.home);
            if (index == 1) context.go(AppRoutes.info);
            if (index == 2) context.go(AppRoutes.settings);
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Info'),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),

            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
      routes: [
        GoRoute(path: AppRoutes.home, builder: (_, __) => const HomeScreen()),
        GoRoute(path: AppRoutes.info, builder: (_, __) => const InfoScreen()),
        GoRoute(
          path: AppRoutes.settings,
          builder: (_, __) => const SettingsScreen(),
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
