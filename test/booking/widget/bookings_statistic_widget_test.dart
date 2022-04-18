
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_tracker/booking/entity/time_booking_statistics.dart';
import 'package:time_tracker/booking/widget/bookings_statistic_widget.dart';
import 'package:time_tracker/booking/widget/time_account.dart';

void main() {
  testWidgets('Load BookingsStatisticWidget', (WidgetTester tester) async {
    // GIVEN
    await tester.pumpWidget(MaterialApp(
        title: 'test',
        home: BookingsStatisticWidget(DailyBookingStatisticList.of([])),
      ),
    );

    // WHEN
    await tester.pumpAndSettle();

    // THEN
    expect(find.text('0 Std 0 Min'), findsNWidgets(3));
    expect(find.text('Ø Arbeitszeit:'), findsOneWidget);
    expect(find.text('Ø Pausenzeit:'), findsOneWidget);
  });

  testWidgets('BookingsStatisticWidget shows work time', (WidgetTester tester) async {
    // GIVEN
    final april4 = DateTime.parse("2012-04-04 08:00:00");
    final april5 = DateTime.parse("2012-04-05 08:00:00");
    const hours6 = Duration(hours: 6);
    await tester.pumpWidget(MaterialApp(
        title: 'test',
        home: BookingsStatisticWidget(
            DailyBookingStatisticList.of([
              DailyBookingStatistic('2022-04-04', april4, april4.add(hours6), hours6, hours6),
              DailyBookingStatistic('2022-04-05', april5, april5.add(hours6),
                const Duration(hours: 4 ,minutes: 30), const Duration(hours: 8)),
          ])
        )
      ),
    );

    // WHEN
    await tester.pumpAndSettle();

    // THEN minus time
    expect(find.text('-3 Std -30 Min'), findsNWidgets(1));
    // AND avg work time
    expect(find.text('5 Std 15 Min'), findsNWidgets(1));
  });
}