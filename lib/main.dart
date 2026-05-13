import 'package:flutter/material.dart';
import 'data/admin_product_store.dart';
import 'screens/admin_dashboard_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AdminProductProvider(),
      child: const SardApp(),
    ),
  );
}

class SardApp extends StatelessWidget {
  const SardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sard Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF5A2D1A),
        scaffoldBackgroundColor: const Color(0xFFF8F3EF),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.brown.shade100),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.brown.shade600, width: 1.5),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8F3EF),
          foregroundColor: Color(0xFF2E1A12),
          elevation: 0,
          centerTitle: false,
        ),
      ),
      home: const AdminDashboardScreen(),
    );
  }
}
