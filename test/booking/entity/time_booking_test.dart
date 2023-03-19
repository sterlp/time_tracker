
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

  test('Test Booking split', () {
    // GIVEN
    final original = TimeBooking.now();
    original.targetWorkTime = const Duration(hours: 7, minutes: 3);
    final end = DateTime.now().add(const Duration(hours: 4));
    final newStart = DateTime.now().add(const Duration(hours: 5));

    // WHEN
    final newBooking = original.split(end, newStart);

    // THEN
    expect(original.targetWorkTime, newBooking.targetWorkTime);
    expect(original.end, end);
    expect(newBooking.start, newStart);
    expect(newBooking.end, isNull);
  });

  test('Test Booking split with end', () {
    // GIVEN
    final original = TimeBooking.now();
    final start = DateTime.now().add(const Duration(hours: -8));
    final end = DateTime.now();
    original.start = start;
    original.end = end;

    // WHEN
    final newBooking = original.split(
        DateTime.now().add(const Duration(hours: -5)),
        DateTime.now().add(const Duration(hours: -4)));

    // THEN
    expect(newBooking.end, end);
  });
}
