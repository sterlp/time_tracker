
import 'package:flutter_test/flutter_test.dart';
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
}