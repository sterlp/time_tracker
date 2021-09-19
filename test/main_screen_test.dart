import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_tracker/home/page/home_page.dart';

import 'package:time_tracker/main.dart';

import 'test_helper.dart';

void main() {
  Future<AppContainer>? _container;

  setUpAll(() {
    _container = initTestContext();
  });

  testWidgets('Start App should show Loading', (WidgetTester tester) async {
    // GIVEN
    await tester.pumpWidget(MyApp());
    // THEN
    expect(find.text('Loading ...'), findsOneWidget);
  });

  testWidgets('Loaded App should show a "Starten"', (WidgetTester tester) async {
    // GIVEN
    final context = AppContextMock();
    await tester.pumpWidget(MyApp(c: context.initMockContext(),));
    // WHEN
    await tester.pumpAndSettle();
    // THEN
    expect(find.text('Starten'), findsOneWidget);
  });

  testWidgets('Press Starten should show a "Stopp"', (WidgetTester tester) async {
    // GIVEN
    final context = AppContextMock();
    await tester.pumpWidget(MyApp(c: context.initMockContext(),));
    await tester.pumpAndSettle();

    // WHEN
    await tester.press(find.text('Starten'));
    await tester.pumpAndSettle();

    // THEN
    expect(find.text('Stopp'), findsOneWidget);
    expect(find.text('Beginn'), findsOneWidget);
  });
}
