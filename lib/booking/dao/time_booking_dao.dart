import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:sqflite_entities/converter/sqlite_converter.dart';
import 'package:sqflite_entities/dao/abstract_dao.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/booking/entity/time_booking_statistics.dart';
import 'package:time_tracker/db/db_v2.dart';

class TimeBookingDao extends AbstractDao<TimeBooking> {
  final _orderByStartDate = '${DbBookingTableV2.startDate} DESC, id DESC';

  TimeBookingDao(Database db) : super(db, DbBookingTableV2.table);

  Future<int> updateTargetTime(String day, Duration newTarget) {
    return db.rawUpdate("""
      UPDATE ${DbBookingTableV2.table}
      SET ${DbBookingTableV2.targetHoursInMin} = ?
      WHERE ${DbBookingTableV2.day} = ?
      """,
      [newTarget.inMinutes, day],);
  }

  Future<List<TimeBooking>> all() {
    return loadAll(orderBy: _orderByStartDate);
  }
  Future<List<TimeBooking>> allOrderByStart() {
    return loadAll(orderBy: _orderByStartDate);
  }

  Future<List<TimeBooking>> fromTo(DateTime from, DateTime to) {
    return loadAll(
      where: "${DbBookingTableV2.startDate} >= ? "
             "AND (${DbBookingTableV2.startDate} <= ? )",
      whereArgs: [dateTimeToInt(from), dateTimeToInt(to)],
      orderBy: "${DbBookingTableV2.startDate} ASC",
    );
  }

  /// loads the last open booking for the given date
  Future<List<TimeBooking>> loadDay(DateTime dateTime) {
    return loadAll(
        where: "day = ? OR end_date is null",
        whereArgs: [dateTime.toIsoDateString()],
        orderBy: _orderByStartDate,
    );
  }

  Future<List<DailyBookingStatistic>> stats([DateTime? withoutDay]) async {
    var query = '''
    SELECT
      ${DbBookingTableV2.day} as ${DbBookingTableV2.day},
      min(${DbBookingTableV2.startDate}) as ${DbBookingTableV2.startDate},
      max(${DbBookingTableV2.endDate}) as ${DbBookingTableV2.endDate},
      sum(${DbBookingTableV2.workedHoursInMin}) as worked,
      max(${DbBookingTableV2.targetHoursInMin}) as planed,
      count(1) as bookingsCount
    FROM $tableName
    ''';
    const sortAndGroup = '''
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
      qResult = await db.rawQuery(query, [withoutDay.toIsoDateString()]);
    }
    if (qResult.isNotEmpty) {
      for (final r in qResult) {
        final t = DailyBookingStatistic(
          r[DbBookingTableV2.day]! as String,
          parseDateTime(r[DbBookingTableV2.startDate])!,
          parseDateTime(r[DbBookingTableV2.endDate]) ?? DateTime.now(),
          Duration(minutes: r['worked']! as int),
          Duration(minutes: r['planed']! as int),
          r['bookingsCount']! as int,
        );
        result.add(t);
      }
    }
    return result;
  }

  Future<TimeBooking?> findOpenByStart(DateTime start) async {
    final result = await loadAll(
      where: "${DbBookingTableV2.startDate} = ?",
      whereArgs: [dateTimeToInt(start)],
      limit: 1,
    );
    if (result.isEmpty) return null;
    else return result[0];
  }

  Future<TimeBooking?> findByStartAndEnd(DateTime start, DateTime end) async {
    final result = await loadAll(
      where: "${DbBookingTableV2.startDate} = ? AND ${DbBookingTableV2.endDate} = ?",
      whereArgs: [dateTimeToInt(start), dateTimeToInt(end)],
      limit: 1,
    );
    if (result.isEmpty) return null;
    else return result[0];
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
