import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/export/entity/export_day_statistic.dart';

Future<void> main() async {

  setUpAll(() async {
    await initializeDateFormatting();
  });

  test('One fromBookings', () {
    // GIVEN
    final bookings = [
      TimeBooking(DateTime(2021, 3, 1, 8, 30))..end = DateTime(2021, 3, 1, 16, 20)
    ];
    // WHEN
    final subject = ExportDailyStats.fromBookings(bookings);
    // THEN
    expect(subject.workedTime, '7,83');
    expect(subject.startTime, '08:30');
    expect(subject.endTime, '16:20');
    // AND no break time
    expect(subject.breakTime, '0,0');
    expect(subject.startFirstBreak, '');
    expect(subject.endFirstBreak, '');
  });

  test('Two fromBookings', () {
    // GIVEN
    final bookings = [
      TimeBooking(DateTime(2021, 3, 1, 8))..end = DateTime(2021, 3, 1, 12),
      TimeBooking(DateTime(2021, 3, 1, 13))..end = DateTime(2021, 3, 1, 17)
    ];
    // WHEN
    final subject = ExportDailyStats.fromBookings(bookings);
    // THEN
    expect(subject.startTime, '08:00');
    expect(subject.endTime, '17:00');
    expect(subject.startFirstBreak, '12:00');
    expect(subject.endFirstBreak, '13:00');
    expect(subject.workedTime, '8,00');
  });

  test('Three fromBookings', () {
    // GIVEN
    final bookings = [
      TimeBooking(DateTime(2021, 3, 1, 8))..end = DateTime(2021, 3, 1, 11, 50), // 30min break
      TimeBooking(DateTime(2021, 3, 1, 12, 20))..end = DateTime(2021, 3, 1, 14, 20), // 45min break
      TimeBooking(DateTime(2021, 3, 1, 15, 05))..end = DateTime(2021, 3, 1, 17, 30)
    ];
    // WHEN
    final subject = ExportDailyStats.fromBookings(bookings);
    // THEN
    expect(subject.startTime, '08:00');

    expect(subject.startFirstBreak, '11:50');
    expect(subject.endFirstBreak, '12:20');
    expect(subject.startSecondBreak, '14:20');
    expect(subject.endSecondBreak, '15:05');
    expect(subject.breakTime, '1,25');
    expect(subject.workedTime, '8,25');

    expect(subject.endTime, '17:30');
  });

  test('Test calculateBreakTime', () {
    // GIVEN
    final bookings = [
      TimeBooking(DateTime(2021, 3, 1, 8))..end = DateTime(2021, 3, 1, 9),
      TimeBooking(DateTime(2021, 3, 1, 10))..end = DateTime(2021, 3, 1, 11),
      TimeBooking(DateTime(2021, 3, 1, 13))..end = DateTime(2021, 3, 1, 17),
    ];
    // WHEN
    final subject = ExportDailyStats.fromBookings(bookings);
    // THEN
    expect(subject.calculateBreakTime(), const Duration(hours: 1));
    expect(subject.calculateBreakTime(2), const Duration(hours: 2));

  });

  test('Many breaks fromBookings', () {
    // GIVEN
    final bookings = [
      TimeBooking(DateTime(2021, 3, 1, 8))..end = DateTime(2021, 3, 1, 9),
      TimeBooking(DateTime(2021, 3, 1, 10))..end = DateTime(2021, 3, 1, 11),
      TimeBooking(DateTime(2021, 3, 1, 12))..end = DateTime(2021, 3, 1, 13),
      TimeBooking(DateTime(2021, 3, 1, 14))..end = DateTime(2021, 3, 1, 15),
      TimeBooking(DateTime(2021, 3, 1, 16))..end = DateTime(2021, 3, 1, 17),
    ];
    // WHEN
    final subject = ExportDailyStats.fromBookings(bookings);
    // THEN
    expect(subject.startTime, '08:00');
    expect(subject.endTime, '17:00');

    expect(subject.workedTime, '5,00');
    expect(subject.breakTime, '4,00');

    expect(subject.startFirstBreak, '09:00');
    expect(subject.endFirstBreak, '10:00');
    expect(subject.startSecondBreak, '11:00');
    expect(subject.endSecondBreak, '12:00');

    expect(subject.startRemainingBreak, '13:00');
    expect(subject.endRemainingBreak, '15:00');
  });
}
