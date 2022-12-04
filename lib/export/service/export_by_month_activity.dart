
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/export/entity/export_day_statistic.dart';

class ExportByMonthActivity {

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
      final dayStats = ExportDailyStats.fromBookings(byDay[dayKey] ?? []);

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
