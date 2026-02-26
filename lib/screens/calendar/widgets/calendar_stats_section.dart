import 'package:flutter/material.dart';
import 'package:tracker/l10n/app_localizations.dart';
import 'package:tracker/providers/cycle_provider.dart';
import 'package:tracker/screens/calendar/stat_item.dart';

/// Collapsible stats section showing cycle statistics.
class CalendarStatsSection extends StatelessWidget {
  const CalendarStatsSection({
    super.key,
    required this.cycleProvider,
    required this.isExpanded,
    required this.onToggle,
  });

  final CycleProvider cycleProvider;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Text(t.cycleStats),
          trailing: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
          onTap: onToggle,
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                StatItem(t.currentCycleDay, '${cycleProvider.currentCycleDay}'),
                StatItem(t.daysUntilPeriod, '${cycleProvider.daysUntilPeriod}'),
                StatItem(
                  t.averageCycleLength,
                  '${cycleProvider.averageCycleLength} ${t.days}',
                ),
              ],
            ),
          ),
      ],
    );
  }
}
