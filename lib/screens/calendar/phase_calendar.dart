import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:tracker/l10n/app_localizations.dart';
import 'package:tracker/providers/cycle_provider.dart';
import 'package:tracker/providers/settings_provider.dart';

class PhaseCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final CalendarFormat calendarFormat;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(DateTime?, DateTime?, DateTime) onRangeSelected;
  final Function(CalendarFormat) onFormatChanged;
  final Function(DateTime) onPageChanged;
  final double daysOfWeekHeight;

  const PhaseCalendar({
    super.key,
    required this.focusedDay,
    this.selectedDay,
    this.rangeStart,
    this.rangeEnd,
    required this.calendarFormat,
    required this.onDaySelected,
    required this.onRangeSelected,
    required this.onFormatChanged,
    required this.onPageChanged,
    required this.daysOfWeekHeight,
  });

  @override
  Widget build(BuildContext context) {
    final cycleProvider = Provider.of<CycleProvider>(context);
    final ranges = cycleProvider.getDateRanges();
    final double daysOfWeekHeight = this.daysOfWeekHeight;
    // Debug: Verify multiRanges data flow
    print('🔍 Passing ${ranges.length} multiRanges to TableCalendar:');
    for (var range in ranges) {
      print(
        '- ${range.phase ?? 'Unnamed'}: ${range.start} to ${range.end}, color: ${range.color}',
      );
    }

    final t = AppLocalizations.of(context)!;

    return Directionality(
      textDirection:
          TextDirection.ltr, // ← Forces LTR (Arabic names stay LTR layout)
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2035, 12, 31),
        focusedDay: focusedDay,
        calendarFormat: calendarFormat,
        locale: 'ar',
        daysOfWeekHeight:
            (Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14.0) *
            Provider.of<AppSettingsProvider>(context).textScale *
            1.8, // base multiplier – tune 1.6–2.0
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        rangeSelectionMode: RangeSelectionMode.disabled,
        multiRanges: ranges,

        calendarStyle: const CalendarStyle(
          rangeHighlightColor: Colors.transparent,
          selectedDecoration: BoxDecoration(color: Colors.transparent),
          rangeStartDecoration: BoxDecoration(color: Colors.transparent),
          rangeEndDecoration: BoxDecoration(color: Colors.transparent),
          todayDecoration: BoxDecoration(color: Colors.transparent),
          cellMargin: EdgeInsets.zero,
        ),

        // Updated daysOfWeekStyle
        calendarBuilders: CalendarBuilders(
          dowBuilder: (context, day) {
            final text = switch (day.weekday) {
              DateTime.sunday => t.sundayShort,
              DateTime.monday => t.mondayShort,
              DateTime.tuesday => t.tuesdayShort,
              DateTime.wednesday => t.wednesdayShort,
              DateTime.thursday => t.thursdayShort,
              DateTime.friday => t.fridayShort,
              DateTime.saturday => t.saturdayShort,
              _ => '',
            };

            final isWeekend =
                day.weekday == DateTime.saturday ||
                day.weekday == DateTime.sunday;

            return Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize:
                        Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14,
                    fontWeight: FontWeight.w500,
                    color: isWeekend
                        ? Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.65)
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            );
          },
        ),

        // Format button text from your l10n
        availableCalendarFormats: {
          CalendarFormat.month: t.calendarFormatMonth,
          CalendarFormat.twoWeeks: t.calendarFormatTwoWeeks,
          CalendarFormat.week: t.calendarFormatWeek,
        },

        // Header title from your l10n
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          titleTextFormatter: (date, locale) {
            final monthName = switch (date.month) {
              1 => t.january,
              2 => t.february,
              3 => t.march,
              4 => t.april,
              5 => t.may,
              6 => t.june,
              7 => t.july,
              8 => t.august,
              9 => t.september,
              10 => t.october,
              11 => t.november,
              12 => t.december,
              _ => '',
            };
            return '$monthName ${date.year}';
          },
        ),

        onDaySelected: onDaySelected,
        onRangeSelected: onRangeSelected,
        onFormatChanged: onFormatChanged,
        onPageChanged: onPageChanged,
        startingDayOfWeek: t.localeName == 'ar'
            ? StartingDayOfWeek.sunday
            : StartingDayOfWeek.monday,
      ),
    );
  }
}
