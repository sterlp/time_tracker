import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_tracker/booking/widget/duration_icon_widget.dart';

void main() {
  testWidgets('DurationIconWidget displays clock 1 for up to 1 hour', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: DurationIconWidget(Duration(hours: 1))),
      ),
    );

    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.icon, MdiIcons.clockTimeOneOutline);
  });

  testWidgets('DurationIconWidget displays clock 2 for up to 2 hours', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: DurationIconWidget(Duration(hours: 2))),
      ),
    );

    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.icon, MdiIcons.clockTimeTwoOutline);
  });

  testWidgets('DurationIconWidget displays clock 8 for up to 8 hours', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: DurationIconWidget(Duration(hours: 8))),
      ),
    );

    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.icon, MdiIcons.clockTimeEightOutline);
  });

  testWidgets('DurationIconWidget displays clock 12 for 12+ hours', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: DurationIconWidget(Duration(hours: 15))),
      ),
    );

    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.icon, MdiIcons.clockTimeTwelveOutline);
  });

  testWidgets('DurationIconWidget displays clock 1 for 30 minutes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: DurationIconWidget(Duration(minutes: 30))),
      ),
    );

    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.icon, MdiIcons.clockTimeOneOutline);
  });
}
