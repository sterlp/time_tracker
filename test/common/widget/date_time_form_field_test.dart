import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:time_tracker/common/widget/date_time_form_field.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('de', null);
  });
  testWidgets('DateTimeFormField displays empty when null', (WidgetTester tester) async {
    // GIVEN & WHEN
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DateTimeFormField(
          null,
          (_) {},
          decoration: const InputDecoration(label: Text('Test')),
        ),
      ),
    ));

    // THEN - no date text should be visible
    expect(find.textContaining('Uhr'), findsNothing);
  });

  testWidgets('DateTimeFormField with clearable shows clear button and clears on tap', (WidgetTester tester) async {
    // GIVEN
    DateTime? dateTime = DateTime(2024, 1, 15, 14, 30);

    await tester.pumpWidget(MaterialApp(
      home: StatefulBuilder(
        builder: (context, setState) {
          return Scaffold(
            body: DateTimeFormField(
              dateTime,
              (newDate) => setState(() => dateTime = newDate),
              decoration: const InputDecoration(label: Text('Ende')),
              clearable: true,
            ),
          );
        },
      ),
    ));

    // Initial state - date text is visible and clear button exists
    expect(find.textContaining('Uhr'), findsOneWidget);
    expect(find.byIcon(Icons.clear), findsOneWidget);

    // WHEN - tap clear button
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pumpAndSettle();

    // THEN - date text should be gone and clear button should disappear
    expect(find.textContaining('Uhr'), findsNothing);
    expect(find.byIcon(Icons.clear), findsNothing);
  });

  testWidgets('DateTimeFormField without clearable shows no clear button', (WidgetTester tester) async {
    // GIVEN & WHEN
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DateTimeFormField(
          DateTime(2024, 1, 15, 14, 30),
          (_) {},
          decoration: const InputDecoration(label: Text('Start')),
          // clearable: false (default)
        ),
      ),
    ));

    // THEN - date text visible but no clear button
    expect(find.textContaining('Uhr'), findsOneWidget);
    expect(find.byIcon(Icons.clear), findsNothing);
  });
}
