import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_tracker/home/widget/loading_widget.dart';

void main() {
  testWidgets('LoadingWidget displays default caption', (WidgetTester tester) async {
    // GIVEN & WHEN
    await tester.pumpWidget(const MaterialApp(
      home: LoadingWidget(),
    ));

    // THEN
    expect(find.text('Lade ...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('LoadingWidget displays custom caption', (WidgetTester tester) async {
    // GIVEN
    const customCaption = 'Bitte warten...';

    // WHEN
    await tester.pumpWidget(const MaterialApp(
      home: LoadingWidget(caption: customCaption),
    ));

    // THEN
    expect(find.text(customCaption), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('LoadingWidget has CircularProgressIndicator with correct size', (WidgetTester tester) async {
    // GIVEN & WHEN
    await tester.pumpWidget(const MaterialApp(
      home: LoadingWidget(),
    ));

    // THEN
    final sizedBox = tester.widget<SizedBox>(
      find.ancestor(
        of: find.byType(CircularProgressIndicator),
        matching: find.byType(SizedBox),
      ).first,
    );
    expect(sizedBox.width, 60);
    expect(sizedBox.height, 60);
  });
}
