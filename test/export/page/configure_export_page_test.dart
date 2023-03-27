import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_tracker/export/entity/export_field.dart';
import 'package:time_tracker/export/page/configure_export_page.dart';

import '../../test_helper.dart';

void main() {

  testWidgets('Load BookingsStatisticWidget', (WidgetTester tester) async {
    // GIVEN
    final page = ConfigureExportPage(await AppContextMock().initMockContext());
    await tester.pumpWidget(MaterialApp(
        title: 'test',
        home: page,
      ),
    );

    // WHEN
    await tester.pumpAndSettle();

    // THEN we should see all available fields
    for (final f in ExportFields().availableValues) {
      expect(find.text(f.name), findsAtLeastNWidgets(1));
    }
  });
}
