import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/locale.dart';

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

  static String formatWithString(DateTime? date, String format, Locale? locale) {
    DateFormat? f = _formatterCache[format];
    if (f == null) {
      if (locale == null) {
        f = DateFormat(format);
      } else {
        f = DateFormat(format, locale.languageCode);
      }
      _formatterCache[format] = f;
    }
    return DateTimeUtil.format(date, f);
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
      newDate.month, newDate.day, newTime.hour, newTime.minute
    );
  }
}