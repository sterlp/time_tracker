import 'package:flutter/material.dart';
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:sqflite_entities/entity/abstract_entity.dart';

class TimeBooking extends AbstractEntity {
  DateTime start;
  DateTime? end;
  Duration targetWorkTime = const Duration(hours: 8);

  TimeBooking(this.start, {DateTime? endTime}) : end = endTime;
  
  Duration get workTime {
    final currentEnd = end ?? DateTimeUtil.precisionMinutes(DateTime.now());
    return currentEnd.difference(start);
  }

  bool get isOpen => end == null;
  set workTime(Duration time) {
    end = start.add(time);
  }
}
/*
class TimeBookings extends ValueNotifier<List<TimeBooking>> {
  TimeBookings(List<TimeBooking> value) : super(value);

  void stopBooking(TimeBooking booking) {
    booking.end = DateTime.now();
    if (!value.contains(booking)) {
      value.add(booking);
    }
    notifyListeners();
  }
  void add(TimeBooking booking) {
    value.add(booking);
    notifyListeners();
  }
}*/