import 'package:sqflite_entities/entity/query.dart';
import 'package:time_tracker/booking/dao/time_booking_dao.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/db/db_v2.dart';

class BookingService {
  final TimeBookingDao _timeBookingDao;

  BookingService(this._timeBookingDao);

  Future<TimeBooking> create(TimeBooking b) {
    b.id = null;
    return _timeBookingDao.save(b);
  }
  Future<TimeBooking> reload(TimeBooking b) async {
    var result = await _timeBookingDao.getById(b.id!);
    return result ??= await _timeBookingDao.save(b);
  }
  Future<TimeBooking> save(TimeBooking b) async {
    final r = await _timeBookingDao.save(b);
    await _timeBookingDao.updateTargetTime(r.day, r.targetWorkTime);
    return r;
  }
  Future<List<TimeBooking>> loadDay(DateTime dateTime) {
    return _timeBookingDao.loadDay(dateTime);
  }
  Future<List<TimeBooking>> fromTo(DateTime from, DateTime to) {
    return _timeBookingDao.fromTo(from, to);
  }
  Future<List<TimeBooking>> all({SortOrder order = SortOrder.DESC}) {
    if (order == SortOrder.DESC) return _timeBookingDao.allOrderByStart();
    else return _timeBookingDao.loadAll(orderBy: '${DbBookingTableV2.startDate} ASC');
  }
  Future<TimeBooking> delete(TimeBooking booking) {
    return _timeBookingDao.deleteEntity(booking);
  }
}
