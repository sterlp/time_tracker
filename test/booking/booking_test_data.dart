
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:time_tracker/booking/dao/time_booking_dao.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';

class BookingTestData {
  final TimeBookingDao timeBookingDao;

  BookingTestData(this.timeBookingDao);

  Future<TimeBooking> newBooking(int daysFromNow, Duration? duration) async {
    final result = TimeBooking(
      DateTimeUtil.precisionMinutes(
          DateTime.now().add(Duration(days: daysFromNow))));
    if (duration != null) {
      result.workTime = duration;
    }
    return timeBookingDao.save(result);
  }
}