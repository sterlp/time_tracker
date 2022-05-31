
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/booking/widget/delete_booking_dialog.dart';
import 'package:time_tracker/common/feedback.dart';
import 'package:time_tracker/common/list/dismissible_backgrounds.dart';
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
    Icon icon;
    if (booking.end == null) {
      icon = const Icon(MdiIcons.clockFast);
      title = Row(children: _expandItems([
          const Text('Beginn:'),
          Text(bookingStart)
        ]),
      );
    } else {
      icon = _basedOn(booking.workTime);
      title = Row(children: _expandItems([
          const Text('Dauer:'),
          Text(bookingDuration)
        ]),
      );
      subTitle = Text('Start: $bookingStart, Ende: ${toHoursWithMinutes(booking.end)} Uhr');
    }

    return ListTile(
      onLongPress: FeedbackFixed.wrapLongTouch(() => editFn(booking), context),
      leading: icon,
      title: title,
      subtitle: subTitle,
    );
  }

  Icon _basedOn(Duration duration) {
    Icon result;
    const hour = 61;

    if (duration.inMinutes <= 1 * hour) {
      result = const Icon(MdiIcons.clockTimeOneOutline);
    } else if (duration.inMinutes <= 2 * hour) {
      result = const Icon(MdiIcons.clockTimeTwoOutline);
    } else if (duration.inMinutes <= 3 * hour) {
      result = const Icon(MdiIcons.clockTimeThreeOutline);
    } else if (duration.inMinutes <= 4 * hour) {
      result = const Icon(MdiIcons.clockTimeFourOutline);
    } else if (duration.inMinutes <= 5 * hour) {
      result = const Icon(MdiIcons.clockTimeFiveOutline);
    } else if (duration.inMinutes <= 6 * hour) {
      result = const Icon(MdiIcons.clockTimeSixOutline);
    } else if (duration.inMinutes <= 7 * hour) {
      result = const Icon(MdiIcons.clockTimeSevenOutline);
    } else if (duration.inMinutes <= 8 * hour) {
      result = const Icon(MdiIcons.clockTimeEightOutline);
    }else if (duration.inMinutes <= 9 * hour) {
      result = const Icon(MdiIcons.clockTimeNineOutline);
    }else if (duration.inMinutes <= 10 * hour) {
      result = const Icon(MdiIcons.clockTimeTenOutline);
    }else if (duration.inMinutes <= 11 * hour) {
      result = const Icon(MdiIcons.clockTimeElevenOutline);
    } else {
      result = const Icon(MdiIcons.clockTimeTwelveOutline);
    }
    return result;
  }

  List<Widget> _expandItems(List<Widget> widgets) {
    final results = <Widget>[];
    for (final w in widgets) results.add(Expanded(child: w));
    return results;
  }
}
