import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_entities/converter/sqlite_converter.dart';

import '../util/date_utils.dart';

main() {
  var now = dateTimePrecisionMilliseconds(DateTime.now());

  test('Test dateTimeToInt', () {
    expect(dateTimeToInt(null), isNull);
    expect(dateTimeToInt(now), now.millisecondsSinceEpoch);
  });

  test('Test toDateTime', () {
    expect(parseDateTime(null), isNull);
    expect(parseDateTime(now.millisecondsSinceEpoch), now);
  });
}