
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_entities/converter/date_util.dart';

void main() {

  test('Test dateTimeToInt', () {
    expect(Duration.zero.toDecimal(), 0);
    expect(const Duration(minutes: 30).toDecimal(), 0.5);
    expect(const Duration(minutes: 60).toDecimal(), 1);
    expect(const Duration(hours: 8).toDecimal(), 8);
    expect(const Duration(hours: 8, minutes: 30).toDecimal(), 8.5);
  });

}
