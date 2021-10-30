
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_entities/service/db_update.dart';

class DbBookingTableV2 extends DbUpdate {
  static const String table = 'TIME_BOOKING';
  /// [int] in minutes
  static const String workedHoursInMin = 'worked_hours_in_min';
  /// [int] in minutes
  static const String targetHoursInMin = 'target_hours_in_min';
  static const String weekday = 'weekday';
  static const String day = 'day';
  static const String startDate = 'start_date';
  static const String endDate = 'end_date';

  DbBookingTableV2() : super(2);

  @override
  Future<void> update(Database db) {
    return db.execute('''
CREATE TABLE IF NOT EXISTS $table (
  id integer PRIMARY KEY AUTOINCREMENT,
  $day varchar(10),
  $startDate int NOT NULL,
  $endDate int,
  $workedHoursInMin int,
  $targetHoursInMin int,
  $weekday NOT NULL
);
CREATE INDEX IF NOT EXISTS IDX_${table}_WEEKDAY ON $table($weekday);
CREATE INDEX IF NOT EXISTS IDX_${table}_DAY ON $table($day);
CREATE INDEX IF NOT EXISTS IDX_${table}_START_DATE ON $table($startDate);
CREATE INDEX IF NOT EXISTS IDX_${table}_END_DATE ON $table($endDate);
      ''');
  }
}