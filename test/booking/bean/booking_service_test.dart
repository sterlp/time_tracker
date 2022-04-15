
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

  test('Test update Day target', () async {
    // GIVEN
    var b1 = TimeBooking(DateTime(2021, 3, 3, 9))..workTime = _time(3);
    var b2 = TimeBooking(DateTime(2021, 3, 3, 8))..workTime = _time(2);
    var b3 = TimeBooking(DateTime(2021, 3, 8, 13))..workTime = _time(4);
    b1 = await subject.save(b1);
    b2 = await subject.save(b2);
    b3 = await subject.save(b3);

    // WHEN
    b1.targetWorkTime = const Duration(hours: 4);
    b1 = await subject.save(b1);
    b2 = await subject.reload(b2);

    // THEN
    expect(b2.targetWorkTime, equals(b1.targetWorkTime));
  });
}
Duration _time(int hours, {int minutes = 0}) {
  return Duration(hours: hours, minutes: minutes);
}