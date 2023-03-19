import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension ToDecimal on Duration {
  double toDecimal() {
    return this.inSeconds / 3600;
  }
}

extension AddDuration on DateTime {
  DateTime addDays(int days) {
    return this.add(Duration(days: days));
  }

  DateTime addHours(int hours) {
    return this.add(Duration(hours: hours));
  }

  /// Returns the date as `yyyy-MM-dd`
  String toIsoDateString() {
    final y = this.year;
    final m = this.month;
    final d = this.day;
    return "$y-${DateTimeUtil.twoDigits(m)}-${DateTimeUtil.twoDigits(d)}";
  }
}

class DateTimeUtil {
  DateTimeUtil._();

  static final Map<String, DateFormat> _formatterCache = {};

  static String twoDigits(int value) {
    if (value < 10) {
      return "0$value";
    } else {
      return value.toString();
    }
  }

  static DateTime midnight(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59, 59);
  }

  static DateTime clearTime(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  static String format(DateTime? d, DateFormat f) {
    if (d == null)
      return '';
    else
      return f.format(d);
  }

  static String formatWithString(DateTime? date, String format,
      [String? locale = 'de',]) {
    if (date == null) return '';
    return getFormat(format, locale).format(date);
  }

  static DateFormat getFormat(String format, [String? locale = 'de']) {
    final key = '$format$locale';
    DateFormat? f = _formatterCache[key];
    if (f == null) {
      if (locale == null) {
        f = DateFormat(format);
      } else {
        f = DateFormat(format, locale);
      }
      _formatterCache[key] = f;
    }
    return f;
  }

  static DateTime precisionMilliseconds(DateTime now) {
    return DateTime(now.year, now.month, now.day, now.hour, now.minute,
        now.second, now.millisecond);
  }

  static DateTime precisionSeconds(DateTime now) {
    return DateTime(
        now.year, now.month, now.day, now.hour, now.minute, now.second);
  }

  static DateTime precisionMinutes(DateTime now) {
    return DateTime(now.year, now.month, now.day, now.hour, now.minute);
  }

  static DateTime asDateTime(DateTime newDate, TimeOfDay newTime) {
    return DateTime(
      newDate.year,
      newDate.month,
      newDate.day,
      newTime.hour,
      newTime.minute,
    );
  }
}
