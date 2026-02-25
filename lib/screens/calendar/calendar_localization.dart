import 'package:tracker/l10n/app_localizations.dart';

/// Helper functions for calendar localization.
class CalendarLocalization {
  const CalendarLocalization._();

  /// Returns the short day name for the given weekday.
  static String getDayOfWeekText(int weekday, AppLocalizations t) {
    return switch (weekday) {
      DateTime.sunday => t.sundayShort,
      DateTime.monday => t.mondayShort,
      DateTime.tuesday => t.tuesdayShort,
      DateTime.wednesday => t.wednesdayShort,
      DateTime.thursday => t.thursdayShort,
      DateTime.friday => t.fridayShort,
      DateTime.saturday => t.saturdayShort,
      _ => '',
    };
  }

  /// Returns the localized month name for the given month number.
  static String getMonthName(int month, AppLocalizations t) {
    return switch (month) {
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
  }
}
