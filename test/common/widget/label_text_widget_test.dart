import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_tracker/common/widget/label_text_widget.dart';

void main() {
  testWidgets('LabelTextWidget displays label and text', (WidgetTester tester) async {
    // GIVEN
    const label = 'Test Label';
    const text = 'Test Value';

    // WHEN
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: LabelTextWidget(label, text),
      ),
    ));

    // THEN
    expect(find.text(label), findsOneWidget);
    expect(find.text(text), findsOneWidget);
  });

  testWidgets('LabeledWidget displays label and child widget', (WidgetTester tester) async {
    // GIVEN
    const label = 'Custom Label';
    const childText = 'Child Content';

    // WHEN
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: LabeledWidget(
          label,
          child: const Text(childText),
        ),
      ),
    ));

    // THEN
    expect(find.text(label), findsOneWidget);
    expect(find.text(childText), findsOneWidget);
  });
}
