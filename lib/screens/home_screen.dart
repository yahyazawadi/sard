import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.home),
      ),
      body: Center(
        child: Text(
          'Home Screen Boilerplate',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
