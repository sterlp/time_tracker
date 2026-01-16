import 'dart:math';

import 'package:flutter/material.dart';
import 'package:time_range_picker/time_range_picker.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/common/time_util.dart';

Future<TimeRange?> showBreakPickerDialog(
  BuildContext context,
  TimeBooking booking,
) async {
  final endTime = booking.end ?? DateTime.now();
  final durationToMidTime = endTime.difference(booking.start).inMinutes ~/ 2;
  final breakStart = max(1, durationToMidTime - 15);

  return showTimeRangePicker(
    context: context,
    fromText: "Pausenstart",
    toText: "Pausenende",
    paintingStyle: PaintingStyle.fill,
    disabledTime: TimeRange(
      startTime: endTime.add(const Duration(minutes: -1)).toTimeOfDay(),
      endTime: booking.start.add(const Duration(minutes: 1)).toTimeOfDay(),
    ),
    start: booking.start.add(Duration(minutes: breakStart)).toTimeOfDay(),
    end: booking.start
        .add(Duration(
          minutes: breakStart == 1 ? breakStart + 1 : durationToMidTime + 15,
        ))
        .toTimeOfDay(),
    interval: const Duration(minutes: 1),
    ticks: 8,
    strokeColor: Theme.of(context).primaryColor.withValues(alpha: 0.5),
    ticksColor: Colors.black,
    labels: [
      "24:00",
      "03:00",
      "06:00",
      "09:00",
      "12:00",
      "15:00",
      "18:00",
      "21:00",
    ]
        .asMap()
        .entries
        .map((e) => ClockLabel.fromIndex(idx: e.key, length: 8, text: e.value))
        .toList(),
  ) as TimeRange?;
}
