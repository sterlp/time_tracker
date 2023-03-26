
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/export/entity/export_day_statistic.dart';
import 'package:time_tracker/export/entity/export_field.dart';

class _BookingsMap {
  final Map<String, List<TimeBooking>> byDay = {};
  var _exportStartDay = DateUtils.dateOnly(DateTime.now());
  var _exportEndDay = DateUtils.dateOnly(DateTime.now());

  bool get hasDayToExport {
    return _exportStartDay.isBefore(_exportEndDay);
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

  String toCsvData(List<TimeBooking> bookings) {
    final dFormat = DateTimeUtil.getFormat('dd.MM.yyyy');
    final dName = DateTimeUtil.getFormat('EEEE');

    // first we collect the data into a map, and get the earliest Month
    final Map<String, List<TimeBooking>> byDay = {};

    var firstMonth = DateUtils.dateOnly(DateTime.now());
    for(final b in bookings) {
      if (b.start.isBefore(firstMonth)) firstMonth = DateUtils.dateOnly(b.start);
      if (byDay.containsKey(b.day)) byDay[b.day]!.add(b);
      else byDay[b.day] = [b];
    }

    final monthNow = DateTime.now().month;
    final yearNow = DateTime.now().year;
    firstMonth = DateTime(firstMonth.year, firstMonth.month);

    final List<List<String>?> result = [[
      'Datum', 'Tag', 'Soll',
      'Arbeitsbeginn', 'Arbeitsende', 'Arbeitszeit',
      'Pause 1 Start', 'Pause 1 Ende',
      'Pause 2 Start', 'Pause 2 Ende',
      'Pause Rest Start', 'Pause Rest Ende',
      'Pausenzeit']
    ];

    while(firstMonth.year < yearNow
        || (firstMonth.month <= monthNow && firstMonth.year == yearNow)) {

      final dayKey = firstMonth.toIsoDateString();
      final dayStats = ExportDailyStats.fromBookings(firstMonth, byDay[dayKey] ?? []);

      result.add([
        dFormat.format(firstMonth),
        dName.format(firstMonth),
        dayStats.planedWorkTime,

        dayStats.startTime,
        dayStats.endTime,
        dayStats.workedTime,

        dayStats.startFirstBreak,
        dayStats.endFirstBreak,
        dayStats.startSecondBreak,
        dayStats.endSecondBreak,
        dayStats.startRemainingBreak,
        dayStats.endRemainingBreak,

        dayStats.breakTime,
      ]);
      firstMonth = firstMonth.add(const Duration(days: 1));
    }
    return const ListToCsvConverter(
      fieldDelimiter: ';',
    ).convert(result);
  }
}
