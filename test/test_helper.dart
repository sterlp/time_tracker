

import 'package:dependency_container/dependency_container.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_entities/service/db_provider.dart';
import 'package:time_tracker/booking/bean/booking_service.dart';
import 'package:time_tracker/booking/bean/today_bean.dart';
import 'package:time_tracker/booking/dao/time_booking_dao.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/config/dao/config_dao.dart';
import 'package:time_tracker/config/entity/config_entity.dart';
import 'package:time_tracker/db/time_traker_db.dart';
import 'package:time_tracker/main.dart';

Future<DbProvider> initTestDB() async {
  sqfliteFfiInit();
  return initDb(testDb: databaseFactoryFfi.openDatabase(inMemoryDatabasePath));
}

Future<AppContainer> initTestContext() async {
  return initContext(dbProvider: initTestDB());
}
class CreditServiceMock with Mock implements ConfigDao {}
class RewardServiceMock with Mock implements TimeBookingDao {}
class BookingServiceMock with Mock implements BookingService {}

class AppContextMock {
  final configDao = CreditServiceMock();
  final timeBookingDao = RewardServiceMock();
  TimeTrackerConfig? config;
  TodayBean? todayBean;

  final todayBookings = <TimeBooking>[];

  AppContextMock() {
    config = TimeTrackerConfig({}, configDao);
  }

  Future<AppContainer> initMockContext() {
    final result = AppContainer();

    when(() => timeBookingDao.loadDay(any())).thenAnswer((_) => Future.value(todayBookings));

    result.add<ConfigDao>(configDao);
    result.add<TimeBookingDao>(timeBookingDao);
    result.add<TodayBean>(TodayBean(timeBookingDao));
    result.add<BookingService>(BookingService(timeBookingDao));
    return Future.value(result);
  }
}
