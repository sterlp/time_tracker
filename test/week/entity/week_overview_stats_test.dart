import 'package:flutter_test/flutter_test.dart';
import 'package:time_tracker/booking/entity/time_booking_statistics.dart';
import 'package:time_tracker/week/entity/week_overview_stats.dart';

void main() {
  testWidgets('WeekOverviewStats empty', (WidgetTester tester) async {
    final WeekOverviewStats stats = WeekOverviewStats(1, []);
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
    expect(stats[0].week, 1);
  });

  testWidgets('WeekOverviewStats two weeks', (WidgetTester tester) async {
    // GIVEN
    List<DailyBookingStatistic> bookings = [
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
    expect(stats[1].week, 2);
  });
}
