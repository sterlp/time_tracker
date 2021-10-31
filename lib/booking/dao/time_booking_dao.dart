import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:sqflite_entities/converter/sqlite_converter.dart';
import 'package:sqflite_entities/dao/abstract_dao.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/booking/entity/time_booking_statistics.dart';
import 'package:time_tracker/db/db_v2.dart';

class TimeBookingDao extends AbstractDao<TimeBooking> {
  final dayFormat = DateTimeUtil.getFormat('yyyy-MM-dd');
  final _orderByStartDate = '${DbBookingTableV2.startDate} DESC, id DESC';

  TimeBookingDao(Database db) : super(db, DbBookingTableV2.table);

  Future<List<TimeBooking>> allOrderByStart() {
    return loadAll(orderBy: _orderByStartDate);
  }

  Future<List<TimeBooking>> loadDay(DateTime dateTime) {
    return loadAll(
        where: "day = ? OR end_date is null",
        whereArgs: [dayFormat.format(dateTime)],
        orderBy: _orderByStartDate
    );
  }

  Future<List<DailyBookingStatistic>> stats([DateTime? withoutDay]) async {
    var query = '''
SELECT
  ${DbBookingTableV2.day} as ${DbBookingTableV2.day},
  min(${DbBookingTableV2.startDate}) as ${DbBookingTableV2.startDate},
  max(${DbBookingTableV2.endDate}) as ${DbBookingTableV2.endDate},
  sum(${DbBookingTableV2.workedHoursInMin}) as worked,
  max(${DbBookingTableV2.targetHoursInMin}) as planed
FROM $tableName
''';
    final sortAndGroup = '''
    GROUP BY ${DbBookingTableV2.day}
    ORDER BY ${DbBookingTableV2.startDate} DESC
    ''';
    List<Map<String, Object?>> qResult;
    final List<DailyBookingStatistic> result = [];
    if (withoutDay == null) {
      query += 'WHERE ${DbBookingTableV2.endDate} IS NOT NULL';
      query += sortAndGroup;
      qResult = await db.rawQuery(query);
    } else {
      query += 'WHERE ${DbBookingTableV2.day} <> ? AND ${DbBookingTableV2.endDate} IS NOT NULL';
      query += sortAndGroup;
      qResult = await db.rawQuery(query, [dayFormat.format(withoutDay)]);
    }
    if (qResult.isNotEmpty) {
      for (final r in qResult) {
        final t = DailyBookingStatistic(
          r[DbBookingTableV2.day]! as String,
          parseDateTime(r[DbBookingTableV2.startDate])!,
          parseDateTime(r[DbBookingTableV2.endDate]),
          Duration(minutes: r['worked']! as int),
          Duration(minutes: r['planed']! as int));
        result.add(t);
      }
    }
    return result;
  }

  @override
  TimeBooking fromMap(Map<String, dynamic> values) {
    final result = TimeBooking(parseDateTime(values['start_date'])!);
    result.setMap(values);
    return result;
  }
  @override
  Map<String, dynamic> toMap(TimeBooking value) {
    return value.asMap();
  }
}