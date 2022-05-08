import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:time_tracker/booking/bean/booking_service.dart';
import 'package:time_tracker/booking/dao/time_booking_dao.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
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

  test('Test export data csv', () async {
    // GIVEN
    testData.newBookingWithStart(DateTime.parse("2022-05-02 08:00:00"), const Duration(hours: 8));
    testData.newBookingWithStart(DateTime.parse("2022-05-03 09:20:21"), const Duration(hours: 8));
    dao.save(TimeBooking(DateTime.parse("2022-05-04 13:00:00"))
      ..targetWorkTime = const Duration(hours: 3),);
    // WHEN
    final data = await subject.exportAll();
    // THEN we should have the data
    expect(data, contains("Montag;02.05.2022 08:00;02.05.2022 16:00;08:00;08:00"));
    expect(data, contains("Dienstag;03.05.2022 09:20;03.05.2022 17:20;08:00;08:00"));
    // AND we should see the target work time
    expect(data, contains(";03:00"));
    expect(data, contains("Mittwoch;04.05.2022 13:00;;"));
    // AND we should have the header
    expect(data, contains("Kalenderwoche;Tag;Wochentag;Start;Ende;Arbeitszeit;Soll"));
  });
}
