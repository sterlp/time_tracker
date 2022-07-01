
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/booking/widget/delete_booking_dialog.dart';
import 'package:time_tracker/booking/widget/duration_icon_widget.dart';
import 'package:time_tracker/common/feedback.dart';
import 'package:time_tracker/common/list/dismissible_backgrounds.dart';
import 'package:time_tracker/common/widget/label_text_widget.dart';

class TimeBookingListItem extends StatelessWidget {

  final TimeBooking booking;
  final Function(TimeBooking b) deleteFn;
  final Function(TimeBooking b) editFn;
  const TimeBookingListItem(this.booking, this.editFn, this.deleteFn,
      {Key? key,})
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

  Widget _buildListTitle(BuildContext context) {
    Widget end;
    Widget icon;
    if (booking.end == null) {
      icon = const Icon(MdiIcons.clockFast);
      end = Expanded(child: Container());
    } else {
      icon = DurationIconWidget(booking.workTime);
      end = Expanded(child: LabelTextWidget.ofTime("Ende", booking.end));
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        Padding(padding: const  EdgeInsets.fromLTRB(0, 0, 16, 0), child: icon),
        Expanded(child: LabelTextWidget.ofTime("Beginn", booking.start)),
        end,
        Expanded(child: LabelTextWidget.ofDuration("Dauer", booking.workTime)),
      ],),
    );
  }
}
