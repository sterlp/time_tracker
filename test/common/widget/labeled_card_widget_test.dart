import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_tracker/common/widget/labeled_card_widget.dart';

void main() {
  testWidgets('LabeledCardWidget displays header and child', (WidgetTester tester) async {
    // GIVEN
    const headerText = 'Test Header';
    const childText = 'Child Content';

    // WHEN
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: LabeledCardWidget(
          headerText,
          Text(childText),
        ),
      ),
    ));

    // THEN
    expect(find.text(headerText), findsOneWidget);
    expect(find.text(childText), findsOneWidget);
    expect(find.byType(Card), findsOneWidget);
  });

  testWidgets('LabeledCardWidget has correct structure', (WidgetTester tester) async {
    // GIVEN
    const headerText = 'Header';
    const childText = 'Content';

    // WHEN
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: LabeledCardWidget(
          headerText,
          Text(childText),
        ),
      ),
    ));

    // THEN
    expect(find.byType(Card), findsOneWidget);
    expect(find.byType(InkWell), findsOneWidget);
    expect(find.byType(Padding), findsWidgets);
  });

  testWidgets('LabeledCardWidget calls onLongPress when long pressed', (WidgetTester tester) async {
    // GIVEN
    bool longPressed = false;
    void onLongPress() {
      longPressed = true;
    }

    // WHEN
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: LabeledCardWidget(
          'Header',
          const Text('Content'),
          onLongPress: onLongPress,
        ),
      ),
    ));

    await tester.longPress(find.byType(InkWell));
    await tester.pumpAndSettle();

    // THEN
    expect(longPressed, true);
  });

  testWidgets('LabeledCardWidget works without onLongPress', (WidgetTester tester) async {
    // GIVEN & WHEN
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: LabeledCardWidget(
          'Header',
          Text('Content'),
        ),
      ),
    ));

    // THEN
    expect(find.byType(InkWell), findsOneWidget);
    expect(find.text('Header'), findsOneWidget);
    expect(find.text('Content'), findsOneWidget);
  });
}
