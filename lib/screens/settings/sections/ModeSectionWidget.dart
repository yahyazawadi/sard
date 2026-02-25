import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker/l10n/app_localizations.dart';
import 'package:tracker/providers/settings_provider.dart';

import '../widets/section_header.dart';

class ModeSectionWidget extends StatelessWidget {
  const ModeSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Consumer<AppSettingsProvider>(
      builder: (context, prov, _) {
        return ExpansionTile(
          key: const PageStorageKey('appearanceMode'),
          initiallyExpanded: prov.isSectionExpanded('appearanceMode'),
          onExpansionChanged: (expanded) =>
              prov.setSectionExpanded('appearanceMode', expanded),
          shape: const RoundedRectangleBorder(side: BorderSide.none),
          collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
          title: SectionHeader(title: t.appearanceMode),
          childrenPadding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            RadioListTile<ThemeMode>(
              value: ThemeMode.system,
              groupValue: prov.themeMode,
              title: Text(t.systemAuto),
              onChanged: (mode) {
                if (mode != null) prov.themeMode = mode;
              },
            ),
            RadioListTile<ThemeMode>(
              value: ThemeMode.light,
              groupValue: prov.themeMode,
              title: Text(t.light),
              onChanged: (mode) {
                if (mode != null) prov.themeMode = mode;
              },
            ),
            RadioListTile<ThemeMode>(
              value: ThemeMode.dark,
              groupValue: prov.themeMode,
              title: Text(t.dark),
              onChanged: (mode) {
                if (mode != null) prov.themeMode = mode;
              },
            ),
          ],
        );
      },
    );
  }
}
