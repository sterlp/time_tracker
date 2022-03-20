import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeUtil {
  DateTimeUtil._();

  static final Map<String, DateFormat> _formatterCache = {};

  static DateTime midnight(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59, 59);
  }
  static DateTime clearTime(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  static String format(DateTime? d, DateFormat f) {
    if (d == null) return '';
    else return f.format(d);
  }

  static String formatWithString(DateTime? date, String format, [String? locale]) {
    if (date == null) return '';
    return getFormat(format, locale).format(date);
  }

  static DateFormat getFormat(String format, [String? locale]) {
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
    return DateTime(now.year, now.month, now.day, now.hour, now.minute, now.second, now.millisecond);
  }
  static DateTime precisionSeconds(DateTime now) {
    return DateTime(now.year, now.month, now.day, now.hour, now.minute, now.second);
  }
  static DateTime precisionMinutes(DateTime now) {
    return DateTime(now.year, now.month, now.day, now.hour, now.minute);
  }
  static DateTime asDateTime(DateTime newDate, TimeOfDay newTime) {
    return DateTime(newDate.year,
      newDate.month, newDate.day, newTime.hour, newTime.minute,
    );
  }
}
