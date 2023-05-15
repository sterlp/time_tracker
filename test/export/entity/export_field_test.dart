

import 'package:flutter_test/flutter_test.dart';
import 'package:time_tracker/export/entity/export_field.dart';

void main() {

  test('Selected export fields', () {
    // GIVEN
    final subject = ExportFields();
    // WHEN
    subject.clear();
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

  test('test parse fields', () {
    // GIVEN
    final subject = ExportFields();
    // WHEN
    for(final f in subject.availableValues) {
      subject.selectedValuesString = f.key;
      // THEN
      expect(subject.selectedValues.length, 1);
      expect(subject.selectedValues, contains(f));
    }
  });
}
