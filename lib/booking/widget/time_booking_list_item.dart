
import 'package:flutter/material.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/booking/page/edit_booking_page.dart';
import 'package:time_tracker/booking/widget/delete_booking_dialog.dart';
import 'package:time_tracker/common/list/dismissable_backgrounds.dart';
import 'package:time_tracker/util/time_util.dart';

class TimeBookingListItem extends StatelessWidget {

  final TimeBooking booking;
  final Function(TimeBooking b) deleteFn;
  final Function(TimeBooking b) saveFn;
  const TimeBookingListItem(this.booking, this.saveFn, this.deleteFn,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ListTile result;
    final bookingStart = '${toHoursWithMinutes(booking.start)} Uhr';
    final bookingDuration = toDurationHoursAndMinutes(booking.workTime);
    if (booking.end == null) {
      result = ListTile(
        onLongPress: () => _editBooking(booking, context),
        leading: const Icon(Icons.lock_clock),
        title: Row(children: _expandItems([
          const Text('Beginn:'),
          Text(bookingStart)
        ])),
      );
    } else {
      result = ListTile(
        onLongPress: () => _editBooking(booking, context),
        leading: const Icon(Icons.lock_clock),
        title: Row(children: _expandItems([
          const Text('Buchung:'),
          Text(bookingDuration)
        ])),
        subtitle: Text('Start: $bookingStart, Ende: ${toHoursWithMinutes(booking.end)} Uhr'),
      );
    }

    return Dismissible(
      key: Key(booking.id.toString()),
      direction: DismissDirection.endToStart,
      background: deleteDismissableBackground(context),
      child: result,
      onDismissed: (direction) => deleteFn(booking),
      confirmDismiss: (direction) async {
        return showConfirmDeleteBookingDialog(context, booking);
      },
    );
  }

  Future<void> _editBooking(TimeBooking booking, BuildContext context) async {
    final saved = await showEditBookingPage(context, booking: booking);
    if (saved != null) {
      saveFn(saved);
    }
  }

  List<Widget> _expandItems(List<Widget> widgets) {
    final results = <Widget>[];
    for (final w in widgets) results.add(Expanded(child: w));
    return results;
  }
}
