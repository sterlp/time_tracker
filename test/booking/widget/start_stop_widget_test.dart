import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_tracker/booking/widget/start_stop_widget.dart';

void main() {
  testWidgets('Load StartAndStopWidget', (WidgetTester tester) async {
    // GIVEN
    await tester.pumpWidget(MaterialApp(
        title: 'test',
        home: StartAndStopWidget(false,
            const Duration(minutes: 10),
            const Duration(hours: 1),
            () => {},),
      ),
    );

    // WHEN
    await tester.pumpAndSettle();

    // THEN
    expect(find.text('Stopp'), findsNWidgets(1));
  });

  testWidgets('Load StartAndStopWidget 0 duration', (WidgetTester tester) async {
    // GIVEN
    await tester.pumpWidget(MaterialApp(
      title: 'test',
      home: StartAndStopWidget(false,
        const Duration(minutes: 10),
        Duration.zero,
            () => {},),
    ),
    );

    // WHEN
    await tester.pumpAndSettle();

    // THEN
    expect(find.text('Stopp'), findsNWidgets(1));
  });
}
