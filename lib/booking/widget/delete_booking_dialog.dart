
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/util/time_util.dart';

Future<bool?> showConfirmDeleteBookingDialog(BuildContext context, TimeBooking booking) {
  final bookingStart = '${toHoursWithMinutes(booking.start)} Uhr';
  final bookingDuration = toDurationHoursAndMinutes(booking.workTime);

  return showDialog<bool?>(context: context,
    barrierDismissible: false,
    builder: (c) => AlertDialog(
      title: const Text('Buchung Löschen?'),
      content: Text('Buchung von $bookingStart und Dauer: $bookingDuration.'),
      actions: [
        TextButton(onPressed: () => Navigator.of(c).pop(false),
            child: const Text('Nein')),
        TextButton(onPressed: () => Navigator.of(c).pop(true),
            child: const Text('Ja'))
      ],
    ),
  );
}