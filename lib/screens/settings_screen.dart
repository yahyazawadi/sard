import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppSettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: provider.themeMode == ThemeMode.dark,
            onChanged: (val) {
              provider.themeMode = val ? ThemeMode.dark : ThemeMode.light;
            },
          ),
          ListTile(
            title: const Text('Language (EN/AR)'),
            trailing: DropdownButton<String>(
              value: provider.locale.languageCode,
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'ar', child: Text('العربية')),
              ],
              onChanged: (val) {
                if (val != null) provider.locale = Locale(val);
              },
            ),
          )
        ],
      ),
    );
  }
}
