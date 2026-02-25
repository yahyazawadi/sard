import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tracker/l10n/app_localizations.dart';
import 'calendar_localization.dart';

/// Builder class for calendar style and header configuration.
class CalendarStyleBuilder {
  final ThemeData theme;
  final bool isRangeMode;

  const CalendarStyleBuilder({required this.theme, required this.isRangeMode});

  /// Builds the CalendarStyle for the TableCalendar.
  CalendarStyle buildCalendarStyle() {
    return CalendarStyle(
      outsideDaysVisible: false,
      weekendTextStyle: TextStyle(color: theme.colorScheme.error),
      rangeHighlightColor: Colors.transparent,
      selectedDecoration: _buildSelectedDecoration(),
      todayDecoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
      ),
      rangeStartDecoration: const BoxDecoration(),
      rangeEndDecoration: const BoxDecoration(),
      cellMargin: EdgeInsets.zero,
    );
  }

  BoxDecoration _buildSelectedDecoration() {
    final color = isRangeMode
        ? theme.colorScheme.tertiary
        : theme.colorScheme.primary.withOpacity(0.6);
    final width = isRangeMode ? 3.5 : 2.5;

    return BoxDecoration(
      border: Border.all(color: color, width: width),
      shape: BoxShape.circle,
    );
  }

  /// Builds the HeaderStyle for the TableCalendar.
  HeaderStyle buildHeaderStyle(AppLocalizations t) {
    return HeaderStyle(
      formatButtonVisible: true,
      titleCentered: true,
      titleTextFormatter: (date, locale) {
        final monthName = CalendarLocalization.getMonthName(date.month, t);
        return '$monthName ${date.year}';
      },
    );
  }

  /// Builds the available calendar format map.
  static Map<CalendarFormat, String> buildFormatMap(AppLocalizations t) {
    return {
      CalendarFormat.month: t.calendarFormatMonth,
      CalendarFormat.twoWeeks: t.calendarFormatTwoWeeks,
      CalendarFormat.week: t.calendarFormatWeek,
    };
  }
}
