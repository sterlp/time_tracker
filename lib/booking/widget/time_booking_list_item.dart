
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/booking/widget/delete_booking_dialog.dart';
import 'package:time_tracker/booking/widget/duration_icon_widget.dart';
import 'package:time_tracker/common/feedback.dart';
import 'package:time_tracker/common/list/dismissible_backgrounds.dart';
import 'package:time_tracker/common/widget/key_value_line_widget.dart';
import 'package:time_tracker/util/time_util.dart';

class TimeBookingListItem extends StatelessWidget {

  final TimeBooking booking;
  final Function(TimeBooking b) deleteFn;
  final Function(TimeBooking b) editFn;
  const TimeBookingListItem(this.booking, this.editFn, this.deleteFn,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(booking.id.toString()),
      background: editDismissibleBackground(context),
      secondaryBackground: deleteDismissibleBackground(context),
      child: _buildListTitle(context),
      onDismissed: (direction) {
        FeedbackFixed.touch(context);
        deleteFn(booking);
      },
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return showConfirmDeleteBookingDialog(context, booking);
        }
        FeedbackFixed.touch(context);
        editFn(booking);
        return false;
      },
    );
  }

  ListTile _buildListTitle(BuildContext context) {
    final bookingStart = '${toHoursWithMinutes(booking.start)} Uhr';
    final bookingDuration = toDurationHoursAndMinutes(booking.workTime);
    Widget title;
    Widget? subTitle;
    Widget icon;
    if (booking.end == null) {
      icon = const Icon(MdiIcons.clockFast);
      title = KeyValueLineWidget(
        const Text('Beginn:'),
        Text(bookingStart),
      );
    } else {
      icon = DurationIconWidget(booking.workTime);
      title = KeyValueLineWidget(
        const Text('Dauer:'),
        Text(bookingDuration),
      );
      subTitle = KeyValueLineWidget(
        Text('Start: $bookingStart'),
        Text('Ende: ${toHoursWithMinutes(booking.end)} Uhr'),
      );
    }

    return ListTile(
      onLongPress: FeedbackFixed.wrapLongTouch(() => editFn(booking), context),
      leading: icon,
      title: title,
      subtitle: subTitle,
    );
  }
}
