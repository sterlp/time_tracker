
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:time_tracker/booking/bean/booking_service.dart';
import 'package:time_tracker/booking/dao/time_booking_dao.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/statistic/entity/overview_stats.dart';

import '../../test_helper.dart';
import '../booking_test_data.dart';

Future<void> main() async {
  final dbProvider = await initTestDB();
  final db = await dbProvider.init();
  final dao = TimeBookingDao(db);
  final subject = BookingService(dao);
  final testData = BookingTestData(dao);

  tearDownAll(() async {
    await dbProvider.close();
  });

  setUp(() async {
    await initializeDateFormatting();
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

  test('Load week detail bookins', () async {
    // GIVEN
    await subject.save(TimeBooking(DateTime.parse("2022-04-11 08:00:00"))..workTime = _time(8));
    await subject.save(TimeBooking(DateTime.parse("2022-04-12 08:00:00"))..workTime = _time(8));
    await subject.save(TimeBooking(DateTime.parse("2022-04-13 08:00:00"))..workTime = _time(8));
    await subject.save(TimeBooking(DateTime.parse("2022-04-14 08:00:00"))..workTime = _time(8));
    await subject.save(TimeBooking(DateTime.parse("2022-04-15 08:00:00"))..workTime = _time(4));
    await subject.save(TimeBooking(DateTime.parse("2022-04-15 13:00:00"))..workTime = _time(3));

    await subject.save(TimeBooking(DateTime.parse("2022-04-19 08:00:00"))..workTime = _time(8));

    // WHEN
    final stats = await subject.statisticByDay();
    final weeks = WeekOverviewStats.split(stats);
    expect(weeks.length, 2);
    print('${weeks[1].start} -> ${weeks[1].end}');
    final weekBookings = await subject.fromTo(weeks[1].start, weeks[1].end);

    // THEN
    for(var s in stats) {
      print('$s');
    }
    expect(weeks[1].start, DateTime.parse("2022-04-11 08:00:00"));
    expect(weeks[1].end, DateTime.parse("2022-04-15 16:00:00"));
    expect(weekBookings.length, 6);
  });
}

Duration _time(int hours, {int minutes = 0}) {
  return Duration(hours: hours, minutes: minutes);
}
