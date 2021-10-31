
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:time_tracker/booking/dao/time_booking_dao.dart';
import 'package:time_tracker/booking/entity/time_booking_statistics.dart';
import 'package:time_tracker/booking/page/bookings_by_week_page.dart';

import '../../test_helper.dart';

void main() {
  TimeBookingDao _timeBookingDao = TimeBookingDaoMock();
  List<DailyBookingStatistic> stats = [];

  setUpAll(() => initializeDateFormatting());

  setUp(() {
    _timeBookingDao = TimeBookingDaoMock();
    stats = [];
    when(() => _timeBookingDao.stats()).thenAnswer((_) => Future.value(stats));
  });

  testWidgets('Load empty BookingsWeekPage', (WidgetTester tester) async {
    // GIVEN
    await tester.pumpWidget(MaterialApp(
        title: 'test',
        home: BookingsWeekPage(_timeBookingDao),
      ),
    );
    // THEN
    expect(find.text('Loading ...'), findsOneWidget);
    // WHEN
    await tester.pumpAndSettle();
    // THEN
    expect(find.text('Loading ...'), findsNothing);
    expect(find.byType(Card), findsNothing);
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('Load two stats', (WidgetTester tester) async {
    // GIVEN
    stats.add(
      DailyBookingStatistic(
        '2021-10-04',
        DateTime(2021, 10, 4, 8),
        DateTime(2021, 10, 4, 13),
        const Duration(hours: 5),
        const Duration(hours: 8),
      ),
    );

    stats.add(
      DailyBookingStatistic(
        '2021-10-05',
        DateTime(2021, 10, 5, 9),
        DateTime(2021, 10, 5, 16),
        const Duration(hours: 6),
        const Duration(hours: 7),
      ),
    );

    // WHEN
    await tester.pumpWidget(MaterialApp(
        title: 'test',
        home: BookingsWeekPage(_timeBookingDao),
      ),
    );
    await tester.pumpAndSettle();

    // THEN --> TODO
    expect(find.byType(Card), findsNWidgets(1));
  });
}