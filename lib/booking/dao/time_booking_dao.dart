
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_entities/converter/sqlite_converter.dart';
import 'package:sqflite_entities/dao/abstract_dao.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/booking/entity/time_booking_statistics.dart';
import 'package:time_tracker/db/db_v2.dart';

class TimeBookingDao extends AbstractDao<TimeBooking> {
  final dayFormat = DateFormat('yyyy-MM-dd');
  final _zero = Duration.zero;

  TimeBookingDao(Database db) : super(db, DbBookingTableV2.table);

  Future<List<TimeBooking>> loadDay(DateTime dateTime) {
    return loadAll(
        where: "day = ?",
        whereArgs: [dayFormat.format(dateTime)],
        orderBy: "start_date ASC"
    );
  }

  Future<DailyBookingStatistic> queryDailyStats(DateTime dateTime) async {
    final result = await db.rawQuery('''
SELECT 
  sum(${DbBookingTableV2.workedHoursInMin}) as worked, 
  max(${DbBookingTableV2.targetHoursInMin}) as planed 
FROM $tableName 
WHERE ${DbBookingTableV2.day} = ? 
''', [dayFormat.format(dateTime)]);

    if (result.isEmpty) {
      return DailyBookingStatistic(DateUtils.dateOnly(dateTime), _zero, _zero);
    } else {
      return DailyBookingStatistic(DateUtils.dateOnly(dateTime),
          Duration(minutes: result[0]['worked']! as int),
          Duration(minutes: result[0]['planed']! as int));
    }
  }

  @override
  TimeBooking fromMap(Map<String, dynamic> values) {
    final result = TimeBooking(parseDateTime(values['start_date'])!);
    result.id = values['id'] as int;
    result.end = parseDateTime(values['end_date']);
    result.targetWorkTime = Duration(minutes: values[DbBookingTableV2.targetHoursInMin] as int);
    return result;
  }
  /// id integer PRIMARY KEY AUTOINCREMENT,
  //   day varchar(10),
  //   start_date int NOT NULL,
  //   end_date int,
  //   $workedHoursInMin int,
  //   $plannedHoursInMin int,
  //   $weekday NOT NULL
  @override
  Map<String, dynamic> toMap(TimeBooking value) {
    return {
      'id': value.id,
      'day': dayFormat.format(value.start),
      'start_date': dateTimeToInt(value.start),
      'end_date': dateTimeToInt(value.end),
      DbBookingTableV2.workedHoursInMin: value.workTime.inMinutes,
      DbBookingTableV2.targetHoursInMin: value.targetWorkTime.inMinutes,
      'weekday': value.start.weekday
    };
  }
}