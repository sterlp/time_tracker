
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/booking/entity/time_booking_statistics.dart';

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

  final List<TimeBooking> bookings;
  final DailyBookingStatistic stats;

  bool get hasBookings => bookings.isNotEmpty;
  bool get hasBreak => bookings.length > 1;
  String get planedWorkTime => hasBookings
      ? stats.planedWorkTime.toDecimal().toStringAsFixed(2).replaceFirst(".", ",") : '';
  String get workedTime => hasBookings
      ? stats.workedTime.toDecimal().toStringAsFixed(2).replaceFirst(".", ",") : '';
  String get startTime => hasBookings ? formatTime(stats.start) : '';
  String get endTime => hasBookings ? formatTime(stats.end) : '';

  String get startBreak => hasBreak ? formatTime(bookings[0].end) : '';
  String get endBreak => hasBreak ? formatTime(bookings[0].end?.add(stats.breakTime)) : '';
  String get breakTime => hasBreak ? toDecimal(stats.breakTime) : '';

  ExportDailyStats(this.bookings, this.stats);

  factory ExportDailyStats.fromBookings(List<TimeBooking> bookings) {
    var start = DateTime.now();
    var end = DateTime(1900);
    var workedTime = Duration.zero;
    var planedWorkTime = Duration.zero;
    String day = '';
    for (final b in bookings) {
      day = b.day;
      if (b.start.isBefore(start)) start = b.start;
      if (b.end != null && b.end!.isAfter(end)) end = b.end!;
      workedTime = workedTime + b.workTime;
      if (planedWorkTime < b.targetWorkTime) planedWorkTime = b.targetWorkTime;
    }
    return ExportDailyStats(bookings, DailyBookingStatistic(day, start, end, workedTime, planedWorkTime));
  }
}
