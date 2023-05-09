
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/booking/entity/time_booking_statistics.dart';
import 'package:time_tracker/common/time_util.dart';

class ExportDailyStats {
  static final _timeFormat = DateTimeUtil.getFormat('HH:mm');

  static String formatTime(DateTime? time) {
    if (time == null) return '';
    else return _timeFormat.format(time);
  }
  /// Formats a duration as decimal number using a "," as separator
  static String toDecimal(Duration duration) {
    return duration.toDecimal().toStringAsFixed(2).replaceFirst(".", ",");
  }

  final DateTime day;
  final List<TimeBooking> bookings;
  final DailyBookingStatistic stats;

  bool get hasBookings => bookings.isNotEmpty;
  bool get hasBreak => bookings.length > 1;
  bool get hasSecondBreak => bookings.length > 2;
  bool get hasRemainingBreak => bookings.length > 3;
  String get planedWorkTime => hasBookings
      ? stats.planedWorkTime.toDecimal().toStringAsFixed(2).replaceFirst(".", ",") : '';
  String get workedTime => hasBookings
      ? stats.workedTime.toDecimal().toStringAsFixed(2).replaceFirst(".", ",") : '';
  String get startTime => hasBookings ? formatTime(stats.start) : '';
  String get endTime => hasBookings ? formatTime(stats.end) : '';

  String get startFirstBreak => hasBreak ? formatTime(bookings[0].end) : '';
  String get endFirstBreak => hasBreak ? formatTime(bookings[1].start) : '';
  String get startSecondBreak => hasSecondBreak ? formatTime(bookings[1].end) : '';
  String get endSecondBreak => hasSecondBreak ? formatTime(bookings[2].start) : '';
  String get startRemainingBreak => hasRemainingBreak ? formatTime(bookings[2].end) : '';
  String get endRemainingBreak => hasRemainingBreak
      ? formatTime(bookings[2].end!.add( stats.breakTime - calculateBreakTime() - calculateBreakTime(2) ))
      : '';
  String get breakTime => hasBreak ? toDecimal(stats.breakTime) : '0,0';
  String get breakTimeHHmm => hasBreak
      ? toHHmm(stats.breakTime) // '${stats.breakTime.inHours}:${stats.breakTime.inMinutes - stats.breakTime.inHours * 60}'
      : '00:00';

  ExportDailyStats(this.day, this.bookings, this.stats);

  factory ExportDailyStats.fromBookings(DateTime day, List<TimeBooking> bookings) {
    var start = DateTime.now();
    var end = DateTime(1900);
    var workedTime = Duration.zero;
    var planedWorkTime = Duration.zero;
    String dayString = '';
    for (final b in bookings) {
      dayString = b.day;
      if (b.start.isBefore(start)) start = b.start;
      if (b.end != null && b.end!.isAfter(end)) end = b.end!;
      workedTime = workedTime + b.workTime;
      if (planedWorkTime < b.targetWorkTime) planedWorkTime = b.targetWorkTime;
    }
    return ExportDailyStats(day, bookings, DailyBookingStatistic(dayString, start, end, workedTime, planedWorkTime, bookings.length));
  }

  Duration calculateBreakTime([int breakNumber = 1]) {
    if (bookings.length > breakNumber) {
      return bookings[breakNumber].start.difference(bookings[breakNumber - 1].end!);
    }
    return Duration.zero;
  }
}
