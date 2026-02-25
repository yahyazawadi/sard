import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker/l10n/app_localizations.dart';
import 'package:tracker/providers/settings_provider.dart';

import '../widets/section_header.dart';

class LanguageSectionWidget extends StatelessWidget {
  const LanguageSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Consumer<AppSettingsProvider>(
      builder: (context, prov, _) {
        return ExpansionTile(
          key: const PageStorageKey('language'),
          initiallyExpanded: prov.isSectionExpanded('language'),
          onExpansionChanged: (expanded) =>
              prov.setSectionExpanded('language', expanded),
          shape: const RoundedRectangleBorder(side: BorderSide.none),
          collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
          title: SectionHeader(title: t.language),
          childrenPadding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            RadioListTile<String>(
              value: 'en',
              groupValue: prov.locale.languageCode,
              title: Text(t.english),
              onChanged: (code) {
                if (code != null) prov.locale = Locale(code);
              },
            ),
            RadioListTile<String>(
              value: 'ar',
              groupValue: prov.locale.languageCode,
              title: Text(t.arabic),
              onChanged: (code) {
                if (code != null) prov.locale = Locale(code);
              },
            ),
          ],
        );
      },
    );
  }
}
