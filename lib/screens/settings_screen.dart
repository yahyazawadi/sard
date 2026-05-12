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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: Text(AppLocalizations.of(context)!.dark),
            value: settings.themeMode == ThemeMode.dark,
            onChanged: (val) {
              settingsNotifier.setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
            },
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.language),
            trailing: DropdownButton<String>(
              value: settings.locale.languageCode,
              items: [
                DropdownMenuItem(value: 'en', child: Text(AppLocalizations.of(context)!.english)),
                DropdownMenuItem(value: 'ar', child: Text(AppLocalizations.of(context)!.arabic)),
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
            title: Text(AppLocalizations.of(context)!.deleteCacheDebug),
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
