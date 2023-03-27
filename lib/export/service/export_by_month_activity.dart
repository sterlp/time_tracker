
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/export/entity/export_day_statistic.dart';
import 'package:time_tracker/export/entity/export_field.dart';

class _BookingsMap {
  final Map<String, List<TimeBooking>> byDay = {};
  var _exportStartDay = DateUtils.dateOnly(DateTime.now());
  var _exportEndDay = DateTime(1900);

  bool get hasDayToExport {
    return _exportStartDay.isBefore(_exportEndDay) || _exportStartDay.isAtSameMomentAs(_exportEndDay);
  }

  void initExport() {
    _exportStartDay = DateTime(_exportStartDay.year, _exportStartDay.month);
    _exportEndDay = DateTime(_exportEndDay.year, _exportStartDay.month + 1, 0);
  }
  void addDay() {
    _exportStartDay = _exportStartDay.add(const Duration(days: 1));
  }

  ExportDailyStats get currentExportDailyStats {
    final dayKey = _exportStartDay.toIsoDateString();
    return ExportDailyStats.fromBookings(_exportStartDay, byDay[dayKey] ?? []);
  }

  _BookingsMap.fromBookings(List<TimeBooking> bookings) {
    for(final b in bookings) {
      if (b.start.isBefore(_exportStartDay)) _exportStartDay = DateUtils.dateOnly(b.start);
      if (b.start.isAfter(_exportEndDay)) _exportEndDay = DateUtils.dateOnly(b.start);
      if (b.end != null && b.end!.isAfter(_exportEndDay)) _exportEndDay = DateUtils.dateOnly(b.end!);

      if (byDay.containsKey(b.day)) byDay[b.day]!.add(b);
      else byDay[b.day] = [b];
    }
  }
}

class ExportByMonthActivity {

  String execute(ExportFields fields, List<TimeBooking> bookings) {
    final bookingsMap = _BookingsMap.fromBookings(bookings);

    final List<List<String>?> result = [fields.selectedHeaders];

    bookingsMap.initExport();
    while(bookingsMap.hasDayToExport) {
      final stats = bookingsMap.currentExportDailyStats;
      result.add(fields.exportWith(stats));
      bookingsMap.addDay();
    }

    return const ListToCsvConverter(
      fieldDelimiter: ';',
    ).convert(result);
  }
}
