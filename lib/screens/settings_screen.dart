import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as p;
import '../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/sync_provider.dart';
import '../routes/app_routes.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: settings.themeMode == ThemeMode.dark,
            onChanged: (val) {
              settingsNotifier.setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
            },
          ),
          ListTile(
            title: const Text('Language (EN/AR)'),
            trailing: DropdownButton<String>(
              value: settings.locale.languageCode,
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'ar', child: Text('العربية')),
              ],
              onChanged: (val) {
                if (val != null) settingsNotifier.setLocale(Locale(val));
              },
            ),
          ),
          const SizedBox(height: 32),
          ListTile(
            iconColor: Theme.of(context).colorScheme.error,
            textColor: Theme.of(context).colorScheme.error,
            leading: const Icon(Icons.delete_forever),
            title: const Text('Delete Cache (Debug)'),
            onTap: () async {
              // 1. Clear Isar Database (Riverpod)
              await ref.read(syncProvider).clearAllData();

              // 2. Reset Auth & Prefs (Auth still uses ChangeNotifier)
              if (context.mounted) {
                await p.Provider.of<AuthProvider>(context, listen: false).fullReset();
              }

              // 3. Reset Settings
              await settingsNotifier.resetToDefaults();

              // 4. Force redirect to onboarding
              if (context.mounted) {
                context.go(AppRoutes.onboarding);
              }
            },
          )
        ],
      ),
    );
  }
}
