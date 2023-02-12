import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_entities/converter/date_util.dart';

void main() {
  test('Test toIsoString', () {
    expect(DateTime.parse("2012-02-27").toIsoDateString(), "2012-02-27");
    expect(DateTime.parse("2012-11-27").toIsoDateString(), "2012-11-27");
  });

  test('Test dateTimeToInt', () {
    expect(Duration.zero.toDecimal(), 0);
    expect(const Duration(minutes: 30).toDecimal(), 0.5);
    expect(const Duration(minutes: 60).toDecimal(), 1);
    expect(const Duration(hours: 8).toDecimal(), 8);
    expect(const Duration(hours: 8, minutes: 30).toDecimal(), 8.5);
  });
}
