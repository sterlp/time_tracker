import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/booking/widget/time_booking_list_item.dart';

class DailyBookingsList extends StatelessWidget {
  final ValueListenable<List<TimeBooking>> items;
  final Function(TimeBooking b) saveFn;
  final Function(TimeBooking b) deleteFn;
  const DailyBookingsList(this.items, this.saveFn, this.deleteFn, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<TimeBooking>>(
        valueListenable: items,
        builder: (context, value, child) {
          final items = value;
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) =>
                TimeBookingListItem(items[index], saveFn, deleteFn),
          );
        }
    );
  }
}