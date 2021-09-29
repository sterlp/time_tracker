
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_tracker/booking/dao/time_booking_dao.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';

import '../../test_helper.dart';

Future<void> main() async {
  final dbProvider = await initTestDB();
  final db = await dbProvider.init();
  final subject = TimeBookingDao(db);

  tearDownAll(() async {
    await dbProvider.close();
  });

  setUp(() async {
      await subject.deleteAll();
  });

  test('Test Save TimeBookingDao', () async {
    final b = await subject.save(TimeBooking(DateTime(2021, 3, 1, 8))
      ..targetWorkTime = const Duration(hours: 6)
      ..end = DateTime(2021, 3, 1, 12));
    final saved = await subject.getById(b.id!);

    expect(saved?.id, b.id);
    expect(saved?.start, b.start);
    expect(saved?.end, b.end);
    expect(saved?.targetWorkTime, b.targetWorkTime);
    expect(saved?.workTime.inMinutes, 4 * 60);
  });

  test('Test Daily load', () async {
    // GIVEN
    await subject.saveAll([
      TimeBooking(DateTime(2021, 3, 3, 9))..workTime = _time(8),
      TimeBooking(DateTime(2021, 3, 1, 8))..workTime = _time(4),
      TimeBooking(DateTime(2021, 3, 1, 14))..workTime = _time(2)
    ]);

    // WHEN
    var items = await subject.loadDay(DateTime(2021, 3, 1, 8, 8, 8));
    // THEN
    expect(items.length, 2);

    // WHEN
    items = await subject.loadDay(DateTime(2021, 3, 3));
    // THEN
    expect(items.length, 1);

    // WHEN
    items = await subject.loadDay(DateTime(2021, 3, 5));
    // THEN
    expect(items.length, 0);
  });

  test('Query daily stats', () async {
    // GIVEN
    await subject.saveAll([
      TimeBooking(DateTime(2021, 3, 4, 9))..workTime = _time(7),
      TimeBooking(DateTime(2021, 3, 3, 9))..workTime = _time(8),
      TimeBooking(DateTime(2021, 3, 1, 8))..workTime = _time(4, minutes: 17),
      TimeBooking(DateTime(2021, 3, 1, 14))..workTime = _time(2, minutes: 15)
    ]);
    // WHEN
    var stats = await subject.queryDailyStats(DateTime(2021, 3, 1, 8));
    // THEN
    expect(stats.day, DateUtils.dateOnly(DateTime(2021, 3, 1, 8)));
    expect(stats.planedWorkTime, const Duration(hours: 8));
    expect(stats.workedMinutes, const Duration(minutes: (4 + 2) * 60 + 15 + 17));

    // WHEN
    stats = await subject.queryDailyStats(DateTime(2021, 3, 3, 12));
    // THEN
    expect(stats.workedMinutes, const Duration(hours: 8));
  });
}
Duration _time(int hours, {int minutes = 0}) {
  return Duration(hours: hours, minutes: minutes);
}