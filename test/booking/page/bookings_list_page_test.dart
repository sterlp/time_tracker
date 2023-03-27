
import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_entities/entity/query.dart';
import 'package:time_tracker/booking/service/booking_service.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/booking/page/bookings_list_page.dart';

import '../../test_helper.dart';

void main() {
  AppContainer container = AppContainer();
  BookingServiceMock bookingServiceMock = BookingServiceMock();
  List<TimeBooking> bookings = [];
  setUpAll(() {
    initializeDateFormatting();
    container = AppContainer();
    bookingServiceMock = BookingServiceMock();
    container.add<BookingService>(bookingServiceMock);
    bookings = [];
    registerFallbackValue(SortOrder.DESC);
    when(() => bookingServiceMock.fromTo(
        any(), any(),),).thenAnswer((_) => Future.value(bookings));
  });

  testWidgets('Load empty bookings', (WidgetTester tester) async {
    // GIVEN
    await tester.pumpWidget(MaterialApp(
      title: 'test',
      home: BookingListPage(container, DateTime.now(), DateTime.now()),),
    );
    // THEN
    expect(find.text('Lade ...'), findsOneWidget);
    // WHEN
    await tester.pumpAndSettle();
    // THEN
    expect(find.text('Buchung'), findsNothing);
  });
}
