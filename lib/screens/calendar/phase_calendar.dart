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
    final ranges = cycleProvider.getDateRanges();
    // Debug: Verify multiRanges data flow
    print('🔍 Passing ${ranges.length} multiRanges to TableCalendar:');
    for (var range in ranges) {
      print(
        '- ${range.phase ?? 'Unnamed'}: ${range.start} to ${range.end}, color: ${range.color}',
      );
    }

    final t = AppLocalizations.of(context)!;

    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2035, 12, 31),
      focusedDay: focusedDay,
      calendarFormat: calendarFormat,
      locale: 'ar',
      weekendDays: Provider.of<AppSettingsProvider>(
        context,
      ).weekendDays.toList(),
      daysOfWeekHeight:
          (Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14.0) *
          Provider.of<AppSettingsProvider>(context).textScale *
          1.8, // base multiplier – tune 1.6–2.0
      selectedDayPredicate: isRangeMode
          ? (day) =>
                isSameDay(rangeStart, day) // Highlight first tap in range mode
          : (day) => isSameDay(selectedDay, day),
      rangeSelectionMode: RangeSelectionMode.disabled, // We handle manually
      rangeStartDay: null,
      rangeEndDay: null,
      multiRanges: ranges,
      isRtl: Directionality.of(context) == TextDirection.rtl,
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        weekendTextStyle: const TextStyle(color: Colors.red),
        rangeHighlightColor:
            Colors.transparent, // We don't need package highlight
        selectedDecoration: BoxDecoration(
          border: Border.all(
            color: isRangeMode
                ? Colors.green.withOpacity(0.9)
                : Colors.blue.withOpacity(0.6),
            width: isRangeMode ? 3.5 : 2.5,
          ),
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent, // no background
        ),
        rangeStartDecoration:
            const BoxDecoration(), // Empty to disable package's own green
        rangeEndDecoration: const BoxDecoration(),
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

          final isWeekend = Provider.of<AppSettingsProvider>(
            context,
          ).weekendDays.contains(day.weekday);

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

        // Custom day builder for temp green highlight in edit mode
        defaultBuilder: (context, day, focusedDay) {
          final isTempFirstDay =
              isRangeMode && rangeStart != null && isSameDay(day, rangeStart);

          final baseWidget = Center(
            child: Text(
              '${day.day}',
              style: TextStyle(
                color: isSameDay(day, DateTime.now())
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
            ),
          );

          if (isTempFirstDay) {
            return Stack(
              alignment: Alignment.center,
              children: [
                baseWidget,
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.green.withOpacity(0.9),
                      width: 3.5,
                    ),
                  ),
                ),
              ],
            );
          }

          return baseWidget;
        },

        // Today builder with small dot below + subtle glow
        todayBuilder: (context, day, focusedDay) {
          final text = '${day.day}';
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.tealAccent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.tealAccent.withOpacity(0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ],
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
      onFormatChanged: onFormatChanged,
      onPageChanged: onPageChanged,
      startingDayOfWeek: t.localeName == 'ar'
          ? StartingDayOfWeek.sunday
          : StartingDayOfWeek.monday,
    );
  }
}
