
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:time_tracker/booking/bean/booking_service.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/common/list_functions.dart';
import 'package:time_tracker/log/logger.dart';

class TodayBean extends ValueNotifier<List<TimeBooking>> {
  final _log = LoggerFactory.get<TodayBean>();
  final BookingService _bookingService;
  Duration _workHours = const Duration(hours: 8);
  TimeBooking? _currentRunning;
  var _day = DateUtils.dateOnly(DateTime.now());

  TodayBean(this._bookingService) : super([]);

  DateTime get day => _day;
  Duration get workHours => _workHours;
  bool get hasCurrentBooking => _currentRunning != null;

  bool isDifferentDay(DateTime newDay) {
    return DateUtils.isSameDay(_day, newDay);
  }

  Future<List<TimeBooking>> changeDay(DateTime newDay) async {
    if (DateUtils.isSameDay(_day, newDay)) return SynchronousFuture(value);
    else {
      _day = DateUtils.dateOnly(newDay);
      return reload();
    }
  }

  TodayBean init() {
    reload();
    return this;
  }

  Duration sumTimeBookingsWorkTime() {
    var result = Duration.zero;
    for (final b in value) result += b.workTime;
    return result;
  }
  Duration sumBreakTime() {
    if (value.isEmpty) return Duration.zero;

    Duration breakTime = Duration.zero;
    TimeBooking? _lastBooking;
    for (final b in value.reversed) {
      if (_lastBooking != null) {
        _log.debug('Diff ${_lastBooking.end} -> ${b.start}');
        breakTime += b.start.difference(_lastBooking.end!);
      }
      _lastBooking = b;
    }
    // if the last booking has an end, we add any time spend as break
    if (_lastBooking != null && _lastBooking.end != null) {
      breakTime += DateTimeUtil.precisionMinutes(DateTime.now()).difference(_lastBooking.end!);
    }
    return breakTime;
  }

  Future<List<TimeBooking>> reload() async {
    final dbData = await _bookingService.loadDay(_day);
    _selectFirstOpenBooking(dbData);
    if (dbData.isNotEmpty) _workHours = dbData[0].targetWorkTime;
    value = dbData;
    return dbData;
  }

  void _selectFirstOpenBooking(List<TimeBooking> bookings) {
    _currentRunning = firstWhere(bookings, (e) => e.isOpen);
  }

  Future<TimeBooking> startNewBooking() async {
    await stopBooking();

    var result = TimeBooking.now();
    result.targetWorkTime = _workHours;
    result = await _bookingService.save(result);
    value.insert(0, result);
    _currentRunning = result;
    notifyListeners();

    return result;
  }
  Future<TimeBooking?> stopBooking() async {
    if (hasCurrentBooking) {
      final b = _currentRunning!;
      b.end = DateTimeUtil.precisionMinutes(DateTime.now());
      await _bookingService.save(b);
      _selectFirstOpenBooking(value);
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
    return _bookingService.delete(booking);
  }
  Future<TimeBooking> save(TimeBooking booking) async {
    final result = await _bookingService.save(booking);
    reload();
    return result;
  }
}
