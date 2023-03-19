
import 'package:flutter/material.dart';

int durationToMinutes(Duration? d) {
  if (d == null) return 0;
  else {
    return d.inMinutes;
  }
}

/// Returns the [duration] as <b>HH:mm</b> <code>String</code>.
String toHoursAndMinutes(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes - hours * 60;
  return '${_padWith0(hours)}:${_padWith0(minutes)}';
}
Duration hoursAndMinutesToDuration(String? time) {
  if (time == null || time.length < 3) return Duration.zero;
  final hm = time.split(':');
  return Duration(hours: int.parse(hm[0]), minutes: int.parse(hm[1]));
}

/// Returns the time as <b>00:00</b>
String toHoursWithMinutes(DateTime? time) {
  if (time == null) return '';
  else {
    return '${_padWith0(time.hour)}:${_padWith0(time.minute)}';
  }
}
/// h Std m Min
String toDurationHoursAndMinutes(Duration? inDuration) {
  final duration = inDuration ?? Duration.zero;
  final minutes = duration.inMinutes - duration.inHours * 60;
  return '${duration.inHours} Std $minutes Min';
}

String _padWith0(int value) {
  return value.toString().padLeft(2, '0');
}

extension ToTimeOfDay on DateTime {
  TimeOfDay toTimeOfDay() {
    return TimeOfDay(hour: hour, minute: minute);
  }
}

extension ToDateTime on TimeOfDay {
  DateTime toDateTime(DateTime date) {
    return DateTime(date.year, date.month, date.day, hour, minute);
  }
}

extension DateTimeExtension on DateTime {
  String toWeekdayString() {
    switch (weekday) {
      case 1:
        return 'Montag';
      case 2:
        return 'Dienstag';
      case 3:
        return 'Mittwoch';
      case 4:
        return 'Donnerstag';
      case 5:
        return 'Freitag';
      case 6:
        return 'Samstag';
      default:
        return 'Sonntag';
    }
  }
  bool isWeekend() {
    return weekday >= 6;
  }
  // https://github.com/KadaDev/week_of_year/blob/master/lib/date_week_extensions.dart
  /// The ISO 8601 week of year [1..53].
  ///
  /// Algorithm from https://en.wikipedia.org/wiki/ISO_week_date#Algorithms
  int get weekOfYear {
    // Add 3 to always compare with January 4th, which is always in week 1
    // Add 7 to index weeks starting with 1 instead of 0
    final woy = (ordinalDate - weekday + 10) ~/ 7;

    // If the week number equals zero, it means that the given date belongs to the preceding (week-based) year.
    if (woy == 0) {
      // The 28th of December is always in the last week of the year
      return DateTime(year - 1, 12, 28).weekOfYear;
    }

    // If the week number equals 53, one must check that the date is not actually in week 1 of the following year
    if (woy == 53 &&
        DateTime(year, 1, 1).weekday != DateTime.thursday &&
        DateTime(year, 12, 31).weekday != DateTime.thursday) {
      return 1;
    }

    return woy;
  }
  /// The ordinal date, the number of days since December 31st the previous year.
  ///
  /// January 1st has the ordinal date 1
  ///
  /// December 31st has the ordinal date 365, or 366 in leap years
  int get ordinalDate {
    const offsets = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334];
    return offsets[month - 1] + day + (isLeapYear && month > 2 ? 1 : 0);
  }

  /// True if this date is on a leap year.
  bool get isLeapYear {
    return year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);
  }
}
