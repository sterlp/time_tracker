
import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:time_tracker/booking/bean/booking_service.dart';
import 'package:time_tracker/booking/bean/today_bean.dart';
import 'package:time_tracker/booking/dao/time_booking_dao.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/booking/entity/time_booking_statistics.dart';
import 'package:time_tracker/booking/page/booking_widget_page.dart';

import '../../test_helper.dart';

void main() {
  AppContainer _container = AppContainer();
  BookingService _bookingService = BookingServiceMock();
  TodayBean _todayBean = TodayBean(_bookingService);
  List<TimeBooking> _loadDay = [];

  setUpAll(() => initializeDateFormatting());
  setUp(() {
    _container = AppContainer();
    _bookingService = BookingServiceMock();
    _todayBean = TodayBean(_bookingService);

    when(() => _bookingService.loadDay(any())).thenAnswer((i) => Future.value(_loadDay));

    _container.add<BookingService>(_bookingService);
    _container.add<TodayBean>(_todayBean);
  });

  Future<void> _loadBookingWidgetPage(WidgetTester tester) {
    return tester.pumpWidget(MaterialApp(
        title: 'test',
        home: BookingWidgetPage(_container),
      ),
    );
  }
  testWidgets('Load empty BookingWidgetPage', (WidgetTester tester) async {
    // GIVEN
    await _loadBookingWidgetPage(tester);
    // WHEN
    await tester.pumpAndSettle();
    // WHEN
    expect(find.text('Zeiterfassung'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Soll'), findsOneWidget);
    expect(find.text('Ist'), findsOneWidget);
    expect(find.text('Beginn'), findsNothing);
  });

  testWidgets('Load yesterday BookingWidgetPage', (WidgetTester tester) async {
    // GIVEN
    await _loadBookingWidgetPage(tester);
    await tester.pumpAndSettle();
    // WHEN
    _loadDay = [
      TimeBooking(DateTime.now().addDays(-1))
    ];
    _todayBean.changeDay(DateTime.now().addDays(-1));
    await tester.pumpAndSettle();
    // THEN
    expect(find.text('Start'), findsNothing);
    expect(find.text('Stopp'), findsOneWidget);
    expect(find.text('Beginn'), findsOneWidget);
  });
}
