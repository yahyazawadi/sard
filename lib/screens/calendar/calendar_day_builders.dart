import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tracker/l10n/app_localizations.dart';
import 'package:tracker/providers/settings_provider.dart';
import 'calendar_localization.dart';

class CalendarDayBuilders {
  final ThemeData theme;
  final AppLocalizations t;
  final AppSettingsProvider settingsProvider;
  final bool isRangeMode;
  final DateTime? rangeStart;

  const CalendarDayBuilders({
    required this.theme,
    required this.t,
    required this.settingsProvider,
    required this.isRangeMode,
    this.rangeStart,
    required TextStyle dayTextStyle,
  });

  CalendarBuilders build() {
    return CalendarBuilders(
      dowBuilder: _buildDayOfWeek,
      defaultBuilder: _buildDefaultDay,
      todayBuilder: _buildTodayCell,
    );
  }

  Widget _buildDayOfWeek(BuildContext context, DateTime day) {
    final text = CalendarLocalization.getDayOfWeekText(day.weekday, t);
    final isWeekend = settingsProvider.weekendDays.contains(day.weekday);
    final color = isWeekend
        ? theme.colorScheme.onSurface.withOpacity(0.65)
        : theme.colorScheme.onSurface;

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultDay(
    BuildContext context,
    DateTime day,
    DateTime focused,
  ) {
    final isTempFirstDay =
        isRangeMode && rangeStart != null && isSameDay(day, rangeStart);
    final isToday = isSameDay(day, DateTime.now());

    final textColor = isToday
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface;

    final baseWidget = Center(
      child: Text(
        '${day.day}',
        style: TextStyle(
          color: textColor,
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    if (isTempFirstDay) {
      return Stack(
        alignment: Alignment.center,
        children: [baseWidget, _buildRangeStartHighlight()],
      );
    }

    return baseWidget;
  }

  Widget _buildRangeStartHighlight() {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: theme.colorScheme.tertiary, width: 3.5),
      ),
    );
  }

  Widget _buildTodayCell(BuildContext context, DateTime day, DateTime focused) {
    final indicatorColor = theme.colorScheme.secondary;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${day.day}',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: indicatorColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: indicatorColor.withOpacity(0.5),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
