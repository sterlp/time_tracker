import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/export/entity/export_day_statistic.dart';

Future<void> main() async {

  setUpAll(() async {
    await initializeDateFormatting();
  });

  test('One fromBookings', () async {
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
  });

  test('Two fromBookings', () async {
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
    expect(subject.startBreak, '12:00');
    expect(subject.endBreak, '13:00');
    expect(subject.workedTime, '8,00');
  });

  test('Three fromBookings', () async {
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

    expect(subject.startBreak, '11:50');
    expect(subject.endBreak, '13:05');
    expect(subject.breakTime, '1,25');
    expect(subject.workedTime, '8,25');

    expect(subject.endTime, '17:30');
  });
}
