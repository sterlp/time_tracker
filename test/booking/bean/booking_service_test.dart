
import 'package:flutter_test/flutter_test.dart';
import 'package:time_tracker/booking/bean/booking_service.dart';
import 'package:time_tracker/booking/dao/time_booking_dao.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';

import '../../test_helper.dart';

Future<void> main() async {
  final dbProvider = await initTestDB();
  final db = await dbProvider.init();
  final dao = TimeBookingDao(db);
  final subject = BookingService(dao);

  tearDownAll(() async {
    await dbProvider.close();
  });

  setUp(() async {
    await dao.deleteAll();
  });

  test('Load all', () async {
    // GIVEN
    await subject.create(TimeBooking.now());
    await subject.create(TimeBooking.now());
    // WHEN
    final result = await subject.all();
    // THEN
    expect(result.length, 2);
  });

}