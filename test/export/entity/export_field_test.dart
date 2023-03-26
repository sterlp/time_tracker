

import 'package:flutter_test/flutter_test.dart';
import 'package:time_tracker/export/entity/export_field.dart';

void main() {

  test('Selected export fields', () {
    // GIVEN
    final subject = ExportFields();
    // WHEN
    subject.add(ExportField.day);
    subject.add(ExportField.workedTime);
    // THEN
    expect(subject.selectedValuesString,
        ExportField.day.key + valueSeparator + ExportField.workedTime.key);
  });

  test('Import export fields', () {
    // GIVEN
    final subject = ExportFields();
    // WHEN
    subject.selectedValuesString = ExportField.day.key + valueSeparator + ExportField.workedTime.key;
    // THEN
    expect(subject.selectedValues.length, 2);
    expect(subject.selectedValues, contains(ExportField.day));
    expect(subject.selectedValues, contains(ExportField.workedTime));
  });
}
