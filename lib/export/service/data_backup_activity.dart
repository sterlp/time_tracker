
import 'package:csv/csv.dart';
import 'package:csv/csv_settings_autodetection.dart';
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/log/logger.dart';
import 'package:time_tracker/util/time_util.dart';

class DataBackupActivity {
  static final _log = LoggerFactory.get<DataBackupActivity>();
  static const _dateTimeFormat = 'dd.MM.yyyy HH:mm';
  static final _format = DateTimeUtil.getFormat(_dateTimeFormat);

  String toCsvData(List<TimeBooking> bookings) {
    final List<List<String>?> result = [
      [
        'Kalenderwoche',
        'Tag',
        'Wochentag',
        'Start',
        'Ende',
        'Arbeitszeit',
        'Soll'
      ]
    ];
    for (final b in bookings) {
      result.add(_bookingToBackupList(b));
    }

    final csvData = const ListToCsvConverter(
      fieldDelimiter: ';',
    ).convert(result);

    return csvData;
  }

  List<String> _bookingToBackupList(TimeBooking b) {
    return [
      'KW ${b.start.weekOfYear}',
      b.day,
      b.start.toWeekdayString(),
      DateTimeUtil.format(b.start, _format),
      DateTimeUtil.format(b.end, _format),
      toHoursAndMinutes(b.workTime),
      toHoursAndMinutes(b.targetWorkTime),
    ];
  }

  List<TimeBooking> fromCsvData(String csvData) {
    final List<List<dynamic>> data = const CsvToListConverter(
      fieldDelimiter: ';',
      csvSettingsDetector: FirstOccurrenceSettingsDetector(
        eols: ['\r\n', '\n'],),
    ).convert(csvData);

    final result = <TimeBooking>[];
    for (final row in data) {
      if (row.length > 4) {
        // only if we have the "KW xx" in the start it is a data row
        final start = _parse(row[3].toString());
        if (row[0].toString().startsWith('KW') && start != null) {
          _log.debug('Parsing row => $row');


          final end = _parse(row[4].toString());
          var target = const Duration(hours: 8);
          if (row.length > 6) target = hoursAndMinutesToDuration(row[6].toString());

          result.add(TimeBooking(
            start, endTime: end, target: target,
          ),);
        }
      } else {
        _log.debug('skipped row => ${row[0]}');
      }
    }
    return result;
  }

  DateTime? _parse(dynamic dateTime) {
    if (dateTime != null && dateTime.toString().length == _dateTimeFormat.length) {
      return _format.parse(dateTime.toString());
    } else {
      return null;
    }
  }
}
