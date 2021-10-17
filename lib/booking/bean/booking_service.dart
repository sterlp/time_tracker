
import 'package:time_tracker/booking/dao/time_booking_dao.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';

class BookingService {
  final TimeBookingDao _timeBookingDao;

  BookingService(this._timeBookingDao);

  Future<TimeBooking> create(TimeBooking b) {
    b.id = null;
    return _timeBookingDao.save(b);
  }
  Future<TimeBooking> save(TimeBooking b) {
    return _timeBookingDao.save(b);
  }

  Future<List<TimeBooking>> all() {
    return _timeBookingDao.allOrderByStart();
  }
  Future<TimeBooking> delete(TimeBooking booking) {
    return _timeBookingDao.deleteEntity(booking);
  }
}