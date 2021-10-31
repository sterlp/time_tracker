
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_tracker/booking/widget/time_account.dart';

void main() {
  testWidgets('Load TimeAccount', (WidgetTester tester) async {
    // GIVEN
    await tester.pumpWidget(const MaterialApp(
        title: 'test',
        home: TimeAccount(Duration(hours: 8, minutes: 15), Duration(hours: 5)))
    );

    // WHEN
    await tester.pumpAndSettle();

    // THEN
    expect(find.text('Ist'), findsOneWidget);
    expect(find.text('5 Std 0 Min'), findsOneWidget);

    expect(find.text('Soll'), findsOneWidget);
    expect(find.text('-3 Std -15 Min'), findsOneWidget);
  });

  testWidgets('TimeAccount negativ color test', (WidgetTester tester) async {
    // GIVEN
    await tester.pumpWidget(const MaterialApp(
        title: 'test',
        home: TimeAccount(Duration(hours: 7, minutes: 15), Duration(hours: 5)))
    );
    // THEN
    var text = tester.widget<Text>(find.text('-2 Std -15 Min'));
    expect(text.style?.color, Colors.red);
  });

  testWidgets('TimeAccount positiv color test', (WidgetTester tester) async {
    // Given
    await tester.pumpWidget(const MaterialApp(
        title: 'test',
        home: TimeAccount(Duration(hours: 4), Duration(hours: 5)))
    );
    // THEN
    final text = tester.widget<Text>(find.text('1 Std 0 Min'));
    expect(text.style?.color, Colors.green);
  });

  testWidgets('TimeAccount neutral color test', (WidgetTester tester) async {
    // GIVEN
    await tester.pumpWidget(MaterialApp(
        title: 'test',
        theme: ThemeData.dark(),
        home: TimeAccount(Duration(hours: 4, minutes: 30), Duration(hours: 4)))
    );
    // THEN
    final text = tester.widget<Text>(find.text('0 Std -30 Min'));
    expect(text.style?.color, Colors.white);
  });

}