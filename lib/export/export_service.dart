import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:sqflite_entities/entity/query.dart';
import 'package:time_tracker/booking/bean/booking_service.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/db/db_v2.dart';
import 'package:time_tracker/export/entity/export_day_statistic.dart';
import 'package:time_tracker/log/logger.dart';
import 'package:time_tracker/util/time_util.dart';

class ExportService {
  static final _log = LoggerFactory.get<ExportService>();
  final BookingService _bookingService;

  ExportService(this._bookingService);

  Future<File> exportAllToFile({String fileName = 'Datenexport.csv'}) async {
    final csvData = await exportAll();
    return writeToFile(csvData, fileName: fileName);
  }

  Future<File> writeToFile(String csvData, {String fileName = 'Datenexport.csv'}) async {
    final directory = await getApplicationDocumentsDirectory();
    var f = File('${directory.path}/$fileName');
    if (await f.exists()) await f.delete();

    await f.create();
    f = await f.writeAsString(csvData, flush: true);
    _log.info("Written ${f.lengthSync()} to file ${f.path}");
    return f;
  }

  String toMonthCsvData(List<TimeBooking> bookings) {
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
    final dFormat = DateTimeUtil.getFormat('dd.MM.yyyy');
    final dName = DateTimeUtil.getFormat('EEEE');
    final List<List<String>?> result = [['Datum', 'Tag', 'Soll', 'Arbeitsbeginn', 'Arbeitsende', 'Arbeitszeit', 'Pause Start', 'Pause Ende', 'Pausenzeit']];
    while(firstMonth.month <= monthNow && yearNow <= yearNow) {
      final dayStats = ExportDailyStats.fromBookings(byDay[TimeBooking.dayFormat.format(firstMonth)] ?? []);
      result.add([
        dFormat.format(firstMonth),
        dName.format(firstMonth),
        dayStats.planedWorkTime,
        dayStats.startTime,
        dayStats.endTime,
        dayStats.workedTime,

        dayStats.startBreak,
        dayStats.endBreak,
        dayStats.breakTime,
      ]);
      firstMonth = firstMonth.add(const Duration(days: 1));
    }
    return const ListToCsvConverter(
        fieldDelimiter: ';',
      ).convert(result);
  }

  String toCsvData(List<TimeBooking> bookings) {
    final List<List<String>?> result = [['Kalenderwoche', 'Tag', 'Wochentag', 'Start', 'Ende', 'Arbeitszeit']];
    final format = DateTimeUtil.getFormat('dd.MM.yyyy HH:mm');
    for (final b in bookings) {
      result.add([
        'KW ${b.start.weekOfYear}',
        b.day,
        b.start.toWeekdayString(),
        DateTimeUtil.format(b.start, format),
        DateTimeUtil.format(b.end, format),
        toHoursAndMinutes(b.workTime)],
      );
    }

    final csvData = const ListToCsvConverter(
      fieldDelimiter: ';',
    ).convert(result);

    return csvData;
  }

  Future<String> exportAll() async {
    final bookings = await _bookingService.all(order: SortOrder.ASC);
    return toCsvData(bookings);
  }
}
