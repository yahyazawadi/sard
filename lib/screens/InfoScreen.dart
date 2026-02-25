import 'package:flutter/material.dart';
import 'package:tracker/l10n/app_localizations.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(t.phase)),
      body: Center(
        child: Text(
          'Info screen',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
