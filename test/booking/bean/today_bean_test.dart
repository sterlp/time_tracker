import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_tracker/booking/bean/today_bean.dart';
import 'package:time_tracker/booking/dao/time_booking_dao.dart';

import '../../test_helper.dart';
import '../booking_test_data.dart';

Future<void> main() async {
  final dbProvider = await initTestDB();
  final db = await dbProvider.init();
  final dao = TimeBookingDao(db);
  final testData = BookingTestData(dao);
  var subject = TodayBean(dao);

  tearDownAll(() async {
    await dbProvider.close();
  });

  setUp(() async {
    await dao.deleteAll();
    subject = TodayBean(dao);
  });

  test('Start booking should create a new one in the DB', () async {
    // GIVEN
    // WHEN
    final b = await subject.startNewBooking();
    // THEN
    expect(b.id, isNotNull);
    expect(subject.hasCurrentBooking, isTrue);
    expect(b.start, isNotNull);
    expect(b.workTime, isNotNull);
    expect(await dao.countAll(), 1);
  });

  test('Stop without start does nothing', () async {
    // GIVEN
    expect(subject.hasCurrentBooking, isFalse);
    // WHEN
    final foo = await subject.stopBooking();
    // THEN
    expect(subject.hasCurrentBooking, isFalse);
    expect(foo, isNull);
  });

  test('Stop booking should set end date', () async {
    // GIVEN
    final start = await subject.startNewBooking();
    // WHEN
    final stop = await subject.stopBooking();
    // THEN
    expect(stop, isNotNull);
    expect(start.id, stop!.id);
    expect(stop.end, isNotNull);
    expect(await dao.countAll(), 1);
  });

  test('Stop booking should set end date', () async {
    // GIVEN
    await dao.deleteAll();
    // WHEN
    for (var i = 0; i < 5; ++i) {
      await subject.startNewBooking();
    }
    await subject.stopBooking();
    // THEN
    expect(await dao.countAll(), 5);
    for (final e in subject.value) {
      expect(e.id, isNotNull);
      expect(e.start, isNotNull);
      expect(e.end, isNotNull);
    }
  });

  test('Test delete', () async {
    // GIVEN
    final b = await subject.startNewBooking();
    // WHEN
    await subject.delete(b);
    // THEN
    expect(await dao.countAll(), 0);
  });

  test('Test delete current booking', () async {
    // GIVEN
    await subject.startNewBooking();
    final current = await subject.startNewBooking();
    // WHEN
    await subject.delete(current);
    // THEN
    expect(await dao.countAll(), 1);
    expect(subject.hasCurrentBooking, isFalse);
  });

  test('Test delete not current booking', () async {
    // GIVEN
    await subject.startNewBooking();
    final any = await subject.startNewBooking();
    await subject.startNewBooking();
    // WHEN
    await subject.delete(any);
    // THEN
    expect(await dao.countAll(), 2);
    expect(subject.hasCurrentBooking, isTrue);
  });

  test('Open booking is always the first one', () async {
    // GIVEN
    await subject.startNewBooking();
    // WHEN
    await subject.startNewBooking();
    // THEN
    expect(subject.value[0].end, isNull);
    expect(subject.value[1].end, isNotNull);
    expect(subject.hasCurrentBooking, isTrue);
  });

  test('Test reload with open booking', () async {
    // GIVEN
    await subject.startNewBooking();
    await subject.startNewBooking();
    await subject.startNewBooking();
    // WHEN
    subject = TodayBean(dao);
    await subject.reload();
    // THEN
    expect(subject.value.length, 3);
    expect(subject.hasCurrentBooking, isTrue);
    expect(subject.value[0].end, isNull);
    expect(subject.value[1].end, isNotNull);
  });

  test('Test reload with only closed bookings', () async {
    // GIVEN
    await subject.startNewBooking();
    await subject.startNewBooking();
    await subject.stopBooking();
    // WHEN
    await subject.reload();
    // THEN
    expect(subject.value.length, 2);
    expect(subject.hasCurrentBooking, isFalse);
    expect(subject.value[0].end, isNotNull);
    expect(subject.value[1].end, isNotNull);
  });

  test('Will change day', () async {
    // GIVEN
    expect(DateUtils.isSameDay(subject.day, DateTime.now()), isTrue);
    // WHEN
    final date = DateTime.now().add(const Duration(days: -3));
    await subject.changeDay(date);
    // THEN
    expect(DateUtils.isSameDay(subject.day, date), isTrue);
  });

  test('Change day selects right booking', () async {
    // GIVEN
    await testData.newBooking(-2, const Duration(days: -2));
    await testData.newBooking(-2, const Duration(days: -2));
    final runningBooking = await testData.newBooking(-1, null);
    // WHEN
    final bookings = await subject.reload();
    // THEN
    expect(bookings.length, 1);
    expect(subject.value.length, 1);
    expect(subject.value[0].end, isNull);
    expect(subject.value[0], runningBooking);
  });

  test('Open bookings will be selected', () async {
    // GIVEN
    await testData.newBooking(-2, null);
    await testData.newBooking(-1, null);
    // WHEN
    await subject.reload();
    subject.stopBooking();
    // THEN
    expect(subject.hasCurrentBooking, isTrue);
    expect(subject.value.length, 2);
  });
}