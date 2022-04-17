
import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_entities/entity/query.dart';
import 'package:time_tracker/booking/bean/booking_service.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/booking/page/bookings_list_page.dart';

import '../../test_helper.dart';

void main() {
  AppContainer _container = AppContainer();
  BookingServiceMock _bookingServiceMock = BookingServiceMock();
  List<TimeBooking> _bookings = [];
  setUpAll(() {
    initializeDateFormatting();
    _container = AppContainer();
    _bookingServiceMock = BookingServiceMock();
    _container.add<BookingService>(_bookingServiceMock);
    _bookings = [];
    registerFallbackValue(SortOrder.DESC);
    when(() => _bookingServiceMock.all(order: any(named: 'order'))).thenAnswer((_) => Future.value(_bookings));
  });

  testWidgets('Load empty bookings', (WidgetTester tester) async {
    // GIVEN
    await tester.pumpWidget(MaterialApp(
      title: 'test',
      home: BookingListPage(_container))
    );
    // THEN
    expect(find.text('Lade ...'), findsOneWidget);
    // WHEN
    await tester.pumpAndSettle();
    // THEN
    expect(find.text('Buchung'), findsNothing);
  });
}
