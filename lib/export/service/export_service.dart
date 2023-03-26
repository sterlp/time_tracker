import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite_entities/entity/query.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/booking/service/booking_service.dart';
import 'package:time_tracker/common/logger.dart';
import 'package:time_tracker/export/entity/export_field.dart';
import 'package:time_tracker/export/service/data_backup_activity.dart';
import 'package:time_tracker/export/service/export_by_month_activity.dart';

class ExportService {
  static final _log = LoggerFactory.get<ExportService>();
  final _monthExportActivity = ExportByMonthActivity();
  final _dataBackupActivity = DataBackupActivity();
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

  String exportUsingFields(ExportFields fields, List<TimeBooking> bookings) {
    return _monthExportActivity.execute(fields, bookings);
  }

  String toMonthCsvData(List<TimeBooking> bookings) {
    return _monthExportActivity.toCsvData(bookings);
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
