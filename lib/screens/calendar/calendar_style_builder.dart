import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tracker/l10n/app_localizations.dart';
import 'calendar_localization.dart';

class CalendarStyleBuilder {
  final ThemeData theme;
  final bool isRangeMode;

  const CalendarStyleBuilder({required this.theme, required this.isRangeMode});

  CalendarStyle buildCalendarStyle() {
    final colorScheme = theme.colorScheme;

    return CalendarStyle(
      outsideDaysVisible: false,

      // ── All day numbers (including inside colored ranges) ──
      defaultTextStyle: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
      ),
      weekendTextStyle: TextStyle(
        color: colorScheme.error.withOpacity(0.85),
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
      ),
      selectedTextStyle: TextStyle(
        // ← Fixed: now uses onSurface (border-only)
        color: colorScheme.onSurface,
        fontWeight: FontWeight.bold,
        fontSize: 14.5,
      ),
      todayTextStyle: TextStyle(
        color: colorScheme.primary,
        fontWeight: FontWeight.bold,
        fontSize: 14.0,
      ),
      outsideTextStyle: TextStyle(
        color: colorScheme.onSurface.withOpacity(0.38),
        fontSize: 14.0,
      ),

      // ── Fix for numbers inside colored ranges (multiRanges) ──
      withinRangeTextStyle: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
      ),

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

  HeaderStyle buildHeaderStyle(AppLocalizations t) {
    final colorScheme = theme.colorScheme;

    return HeaderStyle(
      formatButtonVisible: true,
      titleCentered: true,
      titleTextFormatter: (date, locale) {
        final monthName = CalendarLocalization.getMonthName(date.month, t);
        return '$monthName ${date.year}';
      },
      // FIXED: Month name ("February 2026")
      titleTextStyle: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      // FIXED: Format button ("2 Weeks", "Month", etc.)
      formatButtonTextStyle: TextStyle(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      formatButtonDecoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  static Map<CalendarFormat, String> buildFormatMap(AppLocalizations t) {
    return {
      CalendarFormat.month: t.calendarFormatMonth,
      CalendarFormat.twoWeeks: t.calendarFormatTwoWeeks,
      CalendarFormat.week: t.calendarFormatWeek,
    };
  }
}
