
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/booking/entity/time_booking_statistics.dart';

class ExportDailyStats {
  static final timeFormat = DateTimeUtil.getFormat('HH:mm');
  final List<TimeBooking> bookings;
  final DailyBookingStatistic stats;

  bool get hasBookings => bookings.isNotEmpty;
  bool get hasBreak => bookings.length > 1;
  String get planedWorkTime => hasBookings
      ? stats.planedWorkTime.toDecimal().toStringAsFixed(2).replaceFirst(".", ",") : '';
  String get workedTime => hasBookings
      ? stats.workedTime.toDecimal().toStringAsFixed(2).replaceFirst(".", ",") : '';
  String get startTime => hasBookings ? timeFormat.format(stats.start) : '';
  String get endTime => hasBookings ? timeFormat.format(stats.end) : '';

  String get startBreak => hasBreak ? timeFormat.format(bookings[0].start) : '';
  String get endBreak => hasBreak ? timeFormat.format(bookings[0].start.add(stats.breakTime)) : '';
  String get breakTime => hasBreak ? stats.breakTime.toDecimal().toStringAsFixed(2).replaceFirst(".", ",") : '';

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
