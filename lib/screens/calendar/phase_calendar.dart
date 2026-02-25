import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:tracker/l10n/app_localizations.dart';
import 'package:tracker/providers/cycle_provider.dart';
import 'package:tracker/providers/settings_provider.dart';
import 'calendar_style_builder.dart';
import 'calendar_day_builders.dart';

/// Calendar widget that displays cycle phases with colored date ranges.
class PhaseCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final DateTime? rangeStart;
  final CalendarFormat calendarFormat;
  final bool isRangeMode;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(CalendarFormat) onFormatChanged;
  final Function(DateTime) onPageChanged;

  const PhaseCalendar({
    super.key,
    required this.focusedDay,
    this.selectedDay,
    this.rangeStart,
    required this.calendarFormat,
    required this.isRangeMode,
    required this.onDaySelected,
    required this.onFormatChanged,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cycleProvider = Provider.of<CycleProvider>(context);
    final settingsProvider = Provider.of<AppSettingsProvider>(context);
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final ranges = cycleProvider.getDateRanges();

    final styleBuilder = CalendarStyleBuilder(
      theme: theme,
      isRangeMode: isRangeMode,
    );

    final dayBuilders = CalendarDayBuilders(
      theme: theme,
      t: t,
      settingsProvider: settingsProvider,
      isRangeMode: isRangeMode,
      rangeStart: rangeStart,
    );

    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2035, 12, 31),
      focusedDay: focusedDay,
      calendarFormat: calendarFormat,
      locale: t.localeName,
      weekendDays: settingsProvider.weekendDays.toList(),
      daysOfWeekHeight: _calcDaysOfWeekHeight(theme, settingsProvider),
      selectedDayPredicate: _buildSelectedPredicate,
      rangeSelectionMode: RangeSelectionMode.disabled,
      rangeStartDay: null,
      rangeEndDay: null,
      multiRanges: ranges,
      isRtl: Directionality.of(context) == TextDirection.rtl,
      calendarStyle: styleBuilder.buildCalendarStyle(),

      // ── Also fix days-of-week headers (Mon, Tue, ...) ──
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle:
            theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ) ??
            TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
        weekendStyle:
            theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w600,
            ) ??
            TextStyle(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
      ),

      calendarBuilders: dayBuilders.build(),
      availableCalendarFormats: CalendarStyleBuilder.buildFormatMap(t),
      headerStyle: styleBuilder.buildHeaderStyle(t),
      onDaySelected: onDaySelected,
      onFormatChanged: onFormatChanged,
      onPageChanged: onPageChanged,
      startingDayOfWeek: _getStartingDayOfWeek(t),
    );
  }

  double _calcDaysOfWeekHeight(ThemeData theme, AppSettingsProvider settings) {
    final baseFontSize = theme.textTheme.bodyMedium?.fontSize ?? 14.0;
    return baseFontSize * settings.textScale * 1.8;
  }

  bool _buildSelectedPredicate(DateTime day) {
    return isRangeMode
        ? isSameDay(rangeStart, day)
        : isSameDay(selectedDay, day);
  }

  StartingDayOfWeek _getStartingDayOfWeek(AppLocalizations t) {
    return t.localeName == 'ar'
        ? StartingDayOfWeek.sunday
        : StartingDayOfWeek.monday;
  }
}
