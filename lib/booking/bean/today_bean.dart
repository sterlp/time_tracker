
import 'package:flutter/material.dart';
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:time_tracker/booking/dao/time_booking_dao.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/common/list_functions.dart';

class TodayBean extends ValueNotifier<List<TimeBooking>> {
  final TimeBookingDao _timeBookingDao;
  final _workHours = const Duration(hours: 8);
  TimeBooking? _currentRunning;
  var _day = DateUtils.dateOnly(DateTime.now());

  TodayBean(this._timeBookingDao) : super([]);

  DateTime get day => _day;
  Duration get workHours => _workHours;
  bool get hasCurrentBooking => _currentRunning != null;

  void changeDay(DateTime day) {

  }

  Duration sumTimeBookingsWorkTime() {
    var result = Duration.zero;
    for (final b in value) result += b.workTime;
    return result;
  }

  Future<List<TimeBooking>> reload() async {
    final dbData = await _timeBookingDao.loadDay(_day);
    _currentRunning = firstWhere(dbData, (e) => e.isOpen);
    return value = dbData;
  }

  Future<TimeBooking> startNewBooking() async {
    await stopBooking();

    var result = TimeBooking(DateTimeUtil.precisionMinutes(DateTime.now()));
    result.targetWorkTime = _workHours;
    result = await _timeBookingDao.save(result);
    value.insert(0, result);
    _currentRunning = result;
    notifyListeners();

    return result;
  }
  Future<TimeBooking?> stopBooking() async {
    if (hasCurrentBooking) {
      final b = _currentRunning!;
      _currentRunning = null;
      b.end = DateTimeUtil.precisionMinutes(DateTime.now());
      await _timeBookingDao.save(b);
      notifyListeners();
      return b;
    }
    return null;
  }
  void add(TimeBooking booking) {
    value.add(booking);
    notifyListeners();
  }

  Future<TimeBooking> delete(TimeBooking booking) {
    value.removeWhere((e) => e == booking);
    if (_currentRunning == booking) {
      _currentRunning = null;
    }
    notifyListeners();
    return _timeBookingDao.deleteEntity(booking);
  }
}