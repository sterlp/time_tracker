import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:sqflite_entities/entity/query.dart';
import 'package:time_tracker/booking/bean/booking_service.dart';
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

  Future<String> exportAll() async {
    final bookings = await _bookingService.all(order: SortOrder.ASC);
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
}
