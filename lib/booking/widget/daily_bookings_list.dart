import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/booking/widget/time_booking_list_item.dart';
import 'package:time_tracker/common/widget/divider_with_label.dart';

class DailyBookingsList extends StatelessWidget {
  final ValueListenable<List<TimeBooking>> items;
  final Function(TimeBooking b) saveFn;
  final Function(TimeBooking b) deleteFn;
  final bool showFirstDayHeader;

  const DailyBookingsList(this.items, this.saveFn, this.deleteFn,
      {Key? key, this.showFirstDayHeader = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? lastDay;
    final df = DateTimeUtil.getFormat('EEEE, dd.MM', 'de');
    return ValueListenableBuilder<List<TimeBooking>>(
      valueListenable: items,
      builder: (context, value, child) {
        final items = value;
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final day = items[index].day;
            if (lastDay == null) {
              if (showFirstDayHeader) lastDay = '';
              else lastDay = day;
            }
            if (lastDay != day) {
              lastDay = day;
              return Column(
                children: [
                  DividerWithLabel(df.format(items[index].start)),
                  TimeBookingListItem(items[index], saveFn, deleteFn)
                ],
              );
            } else {
              return TimeBookingListItem(items[index], saveFn, deleteFn);
            }
          },
        );
      },
    );
  }
}