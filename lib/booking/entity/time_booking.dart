import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:sqflite_entities/converter/sqlite_converter.dart';
import 'package:sqflite_entities/entity/abstract_entity.dart';
import 'package:time_tracker/db/db_v2.dart';

class TimeBooking extends AbstractEntity {
  static final dayFormat = DateFormat('yyyy-MM-dd');

  DateTime start;
  DateTime? end;
  Duration targetWorkTime = const Duration(hours: 8);

  TimeBooking(this.start, {DateTime? endTime}) : end = endTime;
  TimeBooking.now() : this(DateTimeUtil.precisionMinutes(DateTime.now()));
  
  Duration get workTime {
    final currentEnd = end ?? DateTimeUtil.precisionMinutes(DateTime.now());
    return currentEnd.difference(start);
  }
  bool get isOpen => end == null;
  set workTime(Duration time) {
    end = start.add(time);
  }
  @override
  String toString() {
    return 'TimeBooking[id=$id, start=$start, end=$end]';
  }

  void setMap(Map<String, dynamic> values) {
    id = values['id'] as int;
    start = parseDateTime(values['start_date'])!;
    end = parseDateTime(values['end_date']);
    targetWorkTime = Duration(minutes: values[DbBookingTableV2.targetHoursInMin] as int);
  }
  Map<String, dynamic> asMap() {
    final value = this;
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