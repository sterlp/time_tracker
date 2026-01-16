import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_tracker/common/widget/duration_summary_card.dart';

void main() {
  testWidgets('DurationSummaryCard displays default label and duration', (WidgetTester tester) async {
    // GIVEN
    const duration = Duration(hours: 8, minutes: 30);

    // WHEN
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: DurationSummaryCard(duration: duration),
      ),
    ));

    // THEN
    expect(find.text('Gesamtdauer:'), findsOneWidget);
    expect(find.text('8 Std 30 Min'), findsOneWidget);
    expect(find.byType(Card), findsOneWidget);
  });

  testWidgets('DurationSummaryCard displays custom label', (WidgetTester tester) async {
    // GIVEN
    const duration = Duration(hours: 2);
    const customLabel = 'Arbeitszeit:';

    // WHEN
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: DurationSummaryCard(
          duration: duration,
          label: customLabel,
        ),
      ),
    ));

    // THEN
    expect(find.text(customLabel), findsOneWidget);
    expect(find.text('2 Std 0 Min'), findsOneWidget);
  });

  testWidgets('DurationSummaryCard displays zero duration', (WidgetTester tester) async {
    // GIVEN
    const duration = Duration.zero;

    // WHEN
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: DurationSummaryCard(duration: duration),
      ),
    ));

    // THEN
    expect(find.text('0 Std 0 Min'), findsOneWidget);
  });

  testWidgets('DurationSummaryCard displays minutes only', (WidgetTester tester) async {
    // GIVEN
    const duration = Duration(minutes: 45);

    // WHEN
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: DurationSummaryCard(duration: duration),
      ),
    ));

    // THEN
    expect(find.text('0 Std 45 Min'), findsOneWidget);
  });
}
