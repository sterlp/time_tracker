
import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:time_tracker/booking/bean/booking_service.dart';
import 'package:time_tracker/booking/entity/time_booking_statistics.dart';
import 'package:time_tracker/booking/widget/bookings_statistic_widget.dart';
import 'package:time_tracker/booking/widget/time_account.dart';
import 'package:time_tracker/week/page/week_list_page.dart';

import '../../test_helper.dart';

void main() {
  setUpAll(() => initializeDateFormatting('de'));

  AppContainer container = AppContainer();
  List<DailyBookingStatistic> stats = [];

  setUp(() {
    final bookingService = BookingServiceMock();
    container = AppContainer();
    container.add<BookingService>(bookingService);
    stats = [];
    when(() => bookingService.statisticByDay()).thenAnswer((_) => Future.value(stats));
  });

  testWidgets('Load WeekListWidget', (WidgetTester tester) async {
    // GIVEN
    await tester.pumpWidget(MaterialApp(
        title: 'test',
        home: Scaffold(body: WeekListPage(container)),
      ),
    );

    // WHEN
    await tester.pumpAndSettle();

    // THEN

  });
}