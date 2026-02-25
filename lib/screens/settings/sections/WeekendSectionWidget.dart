import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker/l10n/app_localizations.dart';
import 'package:tracker/providers/settings_provider.dart';

import '../widets/section_header.dart';

class WeekendSectionWidget extends StatelessWidget {
  const WeekendSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Consumer<AppSettingsProvider>(
      builder: (context, prov, _) {
        return ExpansionTile(
          key: const PageStorageKey('weekendDays'),
          initiallyExpanded: prov.isSectionExpanded('weekendDays'),
          onExpansionChanged: (expanded) =>
              prov.setSectionExpanded('weekendDays', expanded),
          shape: const RoundedRectangleBorder(side: BorderSide.none),
          collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
          title: SectionHeader(title: t.weekendDays),
          childrenPadding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            CheckboxListTile(
              title: Text(t.fridayShort),
              value: prov.weekendDays.contains(DateTime.friday),
              onChanged: (checked) => prov.toggleWeekendDay(DateTime.friday),
            ),
            CheckboxListTile(
              title: Text(t.saturdayShort),
              value: prov.weekendDays.contains(DateTime.saturday),
              onChanged: (checked) => prov.toggleWeekendDay(DateTime.saturday),
            ),
            CheckboxListTile(
              title: Text(t.sundayShort),
              value: prov.weekendDays.contains(DateTime.sunday),
              onChanged: (checked) => prov.toggleWeekendDay(DateTime.sunday),
            ),
          ],
        );
      },
    );
  }
}
