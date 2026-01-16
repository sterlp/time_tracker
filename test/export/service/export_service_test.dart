import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sqflite_entities/entity/query.dart';
import 'package:time_tracker/booking/dao/time_booking_dao.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/booking/service/booking_service.dart';
import 'package:time_tracker/export/entity/export_field.dart';
import 'package:time_tracker/export/service/export_service.dart';

import '../../booking/booking_test_data.dart';
import '../../test_helper.dart';

Future<void> main() async {
  final dbProvider = await initTestDB();
  final db = await dbProvider.init();
  final dao = TimeBookingDao(db);
  final bookingService = BookingService(dao);
  final subject = ExportService(bookingService);

  final testData = BookingTestData(dao);


  tearDownAll(() async {
    await dbProvider.close();
  });

  setUpAll(() async {
    await initializeDateFormatting();
  });

  setUp(() async {
      await dao.deleteAll();
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

  test('Test import data again', () async {
    // GIVEN
    final file = await File('test_resources/export_test_data.csv').readAsString();
    // WHEN
    final bookings = await subject.importBackup(file);
    // THEN
    expect(bookings.length, 3);
    expect(bookings[0].start, DateTime.parse("2022-05-02 08:00:00"));
    expect(bookings[0].end, DateTime.parse("2022-05-02 16:00:00"));

    expect(bookings[1].start, DateTime.parse("2022-05-03 09:20:00"));
    expect(bookings[1].end, DateTime.parse("2022-05-03 17:20:00"));

    expect(bookings[2].start, DateTime.parse("2022-05-04 13:00:00"));
    expect(bookings[2].end, isNull);

    // AND it should be saved
    expect(await dao.countAll(), 3);
  });

  test('Test import should detect duplicates', () async {
    // GIVEN
    final file = await File('test_resources/export_test_data.csv').readAsString();
    // WHEN
    await subject.importBackup(file);
    await subject.importBackup(file);
    // THEN
    expect(await dao.countAll(), 3);

  });

  test('exportUsingFields should end with the last booking', () async {
    // GIVEN & WHEN
    final fields = ExportFields();
    fields.selectValues([ExportField.date, ExportField.cw]);
    final data = subject.exportUsingFields(fields, [TimeBooking(DateTime.parse("2020-04-04 13:27:00"))]);
    // THEN
    expect(data, contains('01.04.2020;14'));
    expect(data, contains('04.04.2020;14'));
  });

  test('Test exportUsingFields over years', () async {
    // GIVEN
    final file = await File('test_resources/Datenexport.csv').readAsString();
    var bookings = await subject.importBackup(file);
    bookings = await bookingService.all(order: SortOrder.ASC);

    // WHEN
    final csvData = subject.exportUsingFields(ExportFields(), bookings);

    // THEN we should have at least two years in the exported data
    expect(bookings.length, 3);
    expect(csvData, contains('01.11.2021'));
    expect(csvData, contains('02.11.2021'));
    expect(csvData, contains('29.11.2021;Montag;;;;;;;;;;;0,0'));
    expect(csvData, contains('30.11.2021;Dienstag;8,00;10:00;18:00;7,00;12:00;13:00;;;;;1,00'));
    expect(csvData, contains('01.12.2021;Mittwoch;;;;;;;;;;;0,0'));
    expect(csvData, contains('09.03.2022;Mittwoch;8,00;12:56;16:13;3,28;;;;;;;0,0'));
    expect(csvData, isNot(contains('10.03.2022')));
  });

  test('Test export break hh:mm', () async {
    // GIVEN
    final now = DateTime.now();
    testData.newBookingWithStart(now.copyWith(hour: 7), const Duration(hours: 3, minutes: 45));
    testData.newBookingWithStart(now.copyWith(hour: 13), const Duration(hours: 3));

    // WHEN
    final fields = ExportFields();
    fields.selectValues([
      ExportField.date,
      ExportField.startTime,
      ExportField.endTime,
      ExportField.startFirstBreak,
      ExportField.endFirstBreak,
      ExportField.breakTimeHHmm]);

    final export = subject.exportUsingFields(fields,
        await bookingService.fromTo(now.copyWith(hour: 0, minute: 0), now.copyWith(hour: 23, minute: 59)));

    expect(export, contains(';2:15'));
    expect(export, contains(';07:'));
    expect(export, contains(';13:'));
  });

  test('Test export break hh:mm', () async {
    // GIVEN
    final now = DateTime.now().copyWith(month: 3);
    testData.newBookingWithStart(now.copyWith(day: 1), const Duration(hours: 3));
    testData.newBookingWithStart(now.copyWith(day: 2), const Duration(hours: 3));
    testData.newBookingWithStart(now.copyWith(day: 3), const Duration(hours: 3));

    // WHEN
    final bookings = await bookingService.fromTo(
        now.copyWith(hour: 0, day: 1, month: 3),
        DateTime.now().copyWith(month: 3, day: 31),
    );
    final result = subject.exportUsingFields(ExportFields(), bookings);

    // THEN
    expect(result, contains('01.03.'));
    expect(result, contains('03.03.'));
    expect(result, isNot(contains('04.03.')));
  });
}
