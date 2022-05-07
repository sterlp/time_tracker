import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:time_tracker/booking/bean/booking_service.dart';
import 'package:time_tracker/booking/dao/time_booking_dao.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/booking/entity/time_booking_statistics.dart';
import 'package:time_tracker/export/export_service.dart';

import '../../booking/booking_test_data.dart';
import '../../test_helper.dart';

Future<void> main() async {
  final dbProvider = await initTestDB();
  final db = await dbProvider.init();
  final dao = TimeBookingDao(db);
  final bService = BookingService(dao);
  final testData = BookingTestData(dao);
  final subject = ExportService(bService);


  tearDownAll(() async {
    await dbProvider.close();
  });

  setUpAll(() async {
    await initializeDateFormatting();
  });

  setUp(() async {
      await dao.deleteAll();
  });

  test('toMonthCsvData should add all days', () async {
    // GIVEN & WHEN
    final data = subject.toMonthCsvData([TimeBooking(DateTime.parse("2020-04-04 13:27:00"))]);
    // THEN
    expect(data, contains("01.04.2020"));
    expect(data, contains("30.04.2020"));
  });
}
