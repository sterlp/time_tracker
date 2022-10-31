import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:time_tracker/booking/entity/time_booking_statistics.dart';
import 'package:time_tracker/statistic/entity/overview_stats.dart';
import 'package:week_of_year/week_of_year.dart';

void main() {
  setUpAll(() => initializeDateFormatting('de'));

  testWidgets('MonthOverviewStats simple', (WidgetTester tester) async {
    // GIVEN
    final bookings = [
      DailyBookingStatistic.ofStartAndDuration(DateTime.parse("2022-10-10 08:00:00"),
          const Duration(hours: 7),),
      DailyBookingStatistic.ofStartAndDuration(DateTime.parse("2022-10-11 08:00:00"),
        const Duration(hours: 7),),

      DailyBookingStatistic.ofStartAndDuration(DateTime.parse("2021-10-10 08:00:00"),
        const Duration(hours: 7),),
    ];
    // WHEN
    final stats = MonthOverviewStats.split(bookings);

    // THEN
    expect(stats.length, 2);
    expect(stats[0].time.month, 10);
    expect(stats[1].time.month, 10);
    expect(stats[1].time.year, 2021);
  });

  testWidgets('WeekOverviewStats empty', (WidgetTester tester) async {
    WeekOverviewStats(DateTime.now(), []);
  });

  testWidgets('WeekOverviewStats simple', (WidgetTester tester) async {
    // GIVEN
    final List<DailyBookingStatistic> bookings = [
      DailyBookingStatistic("2012-02-27",
        DateTime.parse("2012-01-04 08:00:00"),
        DateTime.parse("2012-01-04 15:00:00"),
        const Duration(hours: 7), const Duration(hours: 8),
        1,
      ),
    ];
    // WHEN
    final stats = WeekOverviewStats.split(bookings);

    // THEN
    expect(stats.length, 1);
    expect(stats[0].time.weekOfYear, 1);
  });

  testWidgets('WeekOverviewStats two weeks', (WidgetTester tester) async {
    // GIVEN
    final bookings = [
      DailyBookingStatistic("2012-01-04",
        DateTime.parse("2012-01-04 08:00:00"),
        DateTime.parse("2012-01-04 15:00:00"),
        const Duration(hours: 7), const Duration(hours: 8),
        1,
      ),
      DailyBookingStatistic("2012-01-11",
        DateTime.parse("2012-01-11 08:00:00"),
        DateTime.parse("2012-01-11 12:00:00"),
        const Duration(hours: 4), const Duration(hours: 8),
        1,
      ),
      DailyBookingStatistic("2012-01-11",
        DateTime.parse("2012-01-11 13:00:00"),
        DateTime.parse("2012-01-11 16:00:00"),
        const Duration(hours: 3), const Duration(hours: 8),
        1,
      ),
    ];
    // WHEN
    final stats = WeekOverviewStats.split(bookings);

    // THEN
    expect(stats.length, 2);
    expect(stats[1].time.weekOfYear, 2);
  });
}
