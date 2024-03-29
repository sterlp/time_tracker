import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/booking/widget/time_booking_list_item.dart';
import 'package:time_tracker/common/widget/divider_with_label.dart';

class DailyBookingsList extends StatelessWidget {
  final ValueListenable<List<TimeBooking>> items;
  final Function(TimeBooking b) editFn;
  final Function(TimeBooking b) deleteFn;
  final String ignoreDay;

  const DailyBookingsList(this.items, this.editFn, this.deleteFn,
      {Key? key, this.ignoreDay = "none", }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final df = DateTimeUtil.getFormat('EEEE, dd.MM');
    String lastDay = "none";

    return ValueListenableBuilder<List<TimeBooking>>(
      valueListenable: items,
      builder: (context, value, child) {
        final items = value;
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final day = items[index].day;
            Widget result;
            if (_addItemWithoutDivider(lastDay, day)) {
              result = TimeBookingListItem(items[index], editFn, deleteFn);
            } else {
              result = Column(
                children: [
                  DividerWithLabel(df.format(items[index].start)),
                  TimeBookingListItem(items[index], editFn, deleteFn)
                ],
              );
            }
            lastDay = day;
            return result;
          },
        );
      },
    );
  }

  bool _addItemWithoutDivider(String lastDay, String day) => lastDay == day || ignoreDay == day;
}
