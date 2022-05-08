import 'dart:io';
import 'package:csv/csv.dart';
import 'package:csv/csv_settings_autodetection.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:sqflite_entities/entity/query.dart';
import 'package:time_tracker/booking/bean/booking_service.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/export/entity/export_day_statistic.dart';
import 'package:time_tracker/export/service/data_backup_activity.dart';
import 'package:time_tracker/log/logger.dart';
import 'package:time_tracker/util/time_util.dart';

class ExportService {
  static final _log = LoggerFactory.get<ExportService>();
  final DataBackupActivity _dataBackupActivity;
  final BookingService _bookingService;

  ExportService(this._dataBackupActivity, this._bookingService);

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
    final List<List<String>?> result = [['Datum', 'Tag', 'Soll', 'Arbeitsbeginn', 'Arbeitsende', 'Arbeitszeit',
      'Pause 1 Start', 'Pause 1 Ende',
      'Pause 2 Start', 'Pause 2 Ende',
      'Pause Rest', 'Pause Rest',
      'Pausenzeit']];
    while(firstMonth.month <= monthNow && yearNow <= yearNow) {
      final dayStats = ExportDailyStats.fromBookings(byDay[TimeBooking.dayFormat.format(firstMonth)] ?? []);
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

  String toCsvData(List<TimeBooking> bookings) {
    return _dataBackupActivity.toCsvData(bookings);
  }

  Future<String> exportAll() async {
    final bookings = await _bookingService.all(order: SortOrder.ASC);
    return toCsvData(bookings);
  }

  Future<List<TimeBooking>> importBackup(String csvData) async {
    final toSave = _dataBackupActivity.fromCsvData(csvData);
    final result = <TimeBooking>[];
    for (final b in toSave) {
      final stored = await _bookingService.findByStartEnd(b.start, b.end);
      if (stored == null) result.add(await _bookingService.save(b));
    }
    return result;
  }
}
