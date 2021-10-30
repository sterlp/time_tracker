
import 'package:flutter_test/flutter_test.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';

void main() {
  test('Test empty copy', () async {
    // GIVEN
    final root = TimeBooking.now();
    final copy = TimeBooking(DateTime(2016));
    // WHEN
    copy.setMap(root.asMap());
    // THEN
    expect(copy.start, root.start);
  });

  test('Test full copy', () async {
    // GIVEN
    final root = TimeBooking.now()
      ..targetWorkTime = const Duration(hours: 2, minutes: 20)
      ..workTime = const Duration(hours: 2, minutes: 10)
      ..id = 1;

    final copy = TimeBooking(DateTime(2016));
    // WHEN
    copy.setMap(root.asMap());
    // THEN
    expect(copy, root);
    expect(copy.id, root.id);
    expect(copy.start, root.start);
    expect(copy.end, root.end);
    expect(copy.targetWorkTime, root.targetWorkTime);
  });
}
