
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:time_tracker/booking/dao/time_booking_dao.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';

class BookingTestData {
  final TimeBookingDao timeBookingDao;

  BookingTestData(this.timeBookingDao);

  Future<TimeBooking> newBooking([int daysFromNow = 0, Duration? duration]) {
    return newBookingOf(Duration(days: daysFromNow), duration);
  }

  Future<TimeBooking> newBookingOf(Duration fromNow, Duration? duration) {
    return newBookingWithStart(DateTimeUtil.precisionMinutes(DateTime.now().add(fromNow),), duration);
  }
  Future<TimeBooking> newBookingWithStart(DateTime start, Duration? duration) async {
    final result = TimeBooking(DateTimeUtil.precisionMinutes(start));
    if (duration != null) {
      result.workTime = duration;
    }
    return timeBookingDao.save(result);
  }
}
