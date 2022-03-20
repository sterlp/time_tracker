import 'package:csv/csv.dart';
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:sqflite_entities/entity/query.dart';
import 'package:time_tracker/booking/bean/booking_service.dart';
import 'package:time_tracker/util/time_util.dart';

class ExportService {
  final BookingService _bookingService;

  ExportService(this._bookingService);

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
