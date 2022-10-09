

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/booking/widget/time_booking_list_item.dart';

void main() {
  Widget newTimeBookingList(List<Widget> children) {
    return MaterialApp(
      title: 'test',
      home: Scaffold(
        body: ListView(children: children,),
      ),
    );
  }

  setUpAll(() async {
    await initializeDateFormatting();
  });

  testWidgets('Load TimeBookingListItem', (WidgetTester tester) async {
    // GIVEN
    final now = DateTime.now();
    await tester.pumpWidget(newTimeBookingList([
      TimeBookingListItem(TimeBooking(now), (b) { }, (b) {}),
    ]),);

    // WHEN
    await tester.pumpAndSettle();

    // THEN
    expect(find.text('${DateTimeUtil.formatWithString(now, 'HH:mm')} Uhr'),
        findsOneWidget,);
  });

  testWidgets('Edit TimeBooking with long press', (WidgetTester tester) async {
    // GIVEN
    final now = DateTime.now();
    bool edit = false;
    await tester.pumpWidget(newTimeBookingList([
      TimeBookingListItem(TimeBooking(now), (b) { edit = true; }, (b) {}),
    ]));

    // WHEN
    await tester.pumpAndSettle();
    await tester.longPress(find.text('Beginn'));

    // THEN
    await tester.pumpAndSettle();
    expect(edit, true);
  });

}
