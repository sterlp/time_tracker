
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:time_tracker/util/time_util.dart';

void main() {
  test('test toHoursAndMinutes', () {
    expect('00:00', toHoursAndMinutes(Duration.zero));
    expect('00:01', toHoursAndMinutes(const Duration(minutes: 1)));
    expect('00:59', toHoursAndMinutes(const Duration(minutes: 59)));
    expect('01:01', toHoursAndMinutes(const Duration(minutes: 61)));

    expect('11:20', toHoursAndMinutes(const Duration(hours: 11, minutes: 20)));
    expect('111:20', toHoursAndMinutes(const Duration(hours: 111, minutes: 20)));
  });

  test('test toDurationHoursAndMinutes', () {
    expect('0 Std 0 Min', toDurationHoursAndMinutes(Duration.zero));
    expect('5 Std 0 Min', toDurationHoursAndMinutes(const Duration(hours: 5)));
    expect('-3 Std -15 Min', toDurationHoursAndMinutes(
        const Duration(hours: 5) - const Duration(hours: 8, minutes: 15)));
  });

  test('test format cache', () {
    // GIVEN
    expect(DateFormat('yyyy'), isNot(DateFormat('yyyy')));
    // THEN
    expect(DateTimeUtil.getFormat('yyyy', null), DateTimeUtil.getFormat('yyyy', null));
    expect(DateTimeUtil.getFormat('yyyy', null), DateTimeUtil.getFormat('yyyy', null));
  });
}
