import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:time_tracker/main.dart';

import 'test_helper.dart';

void main() {
  setUpAll(() => databaseFactory = databaseFactoryFfi);
  testWidgets('Start App should show Loading', (WidgetTester tester) async {
    // GIVEN
    await tester.pumpWidget(MyApp());
    // THEN
    expect(find.text('Lade ...'), findsOneWidget);
  });

  testWidgets('Loaded App should show a "Start"', (WidgetTester tester) async {
    // GIVEN
    final context = AppContextMock();
    await tester.pumpWidget(MyApp(c: context.initMockContext(),));
    // WHEN
    await tester.pumpAndSettle();
    // THEN
    expect(find.text('Start'), findsOneWidget);
  });

  /** has to be an integration test
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
  */
}
