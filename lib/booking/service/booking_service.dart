import 'package:sqflite_entities/entity/query.dart';
import 'package:time_range_picker/time_range_picker.dart';
import 'package:time_tracker/booking/dao/time_booking_dao.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/booking/entity/time_booking_statistics.dart';
import 'package:time_tracker/common/time_util.dart';
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
  Future<TimeBooking> addBreakToBooking(TimeBooking b,
      TimeRange breakTime) async {

    final newBooking = b.split(
        breakTime.startTime.toDateTime(b.start),
        breakTime.endTime.toDateTime(b.start));

    await _timeBookingDao.save(b);
    return _timeBookingDao.save(newBooking);
  }
  Future<List<DailyBookingStatistic>> statisticByDay() {
    return _timeBookingDao.stats();
  }
  Future<TimeBooking?> findByStartEnd(DateTime start, DateTime? end) async {
    TimeBooking? result;
    if (end == null) result = await _timeBookingDao.findOpenByStart(start);
    else result = await _timeBookingDao.findByStartAndEnd(start, end);
    return result;
  }

  Future<TimeBooking?> getBookingByStartDate(DateTime start) async {
    TimeBooking? result = await _timeBookingDao.findOpenByStart(start);
    if (result == null) {
      final day = await _timeBookingDao.loadDay(start);
      if (day.isNotEmpty) result = day[0];
    }
    return result;
  }
}
