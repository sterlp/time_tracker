import 'package:flutter/material.dart';
import 'package:time_tracker/booking/bean/today_bean.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/util/time_util.dart';

class DailyBookingsList extends StatefulWidget {
  final TodayBean todayBean;
  const DailyBookingsList(this.todayBean, {Key? key}) : super(key: key);

  @override
  _DailyBookingsListState createState() => _DailyBookingsListState();
}

class _DailyBookingsListState extends State<DailyBookingsList> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<TimeBooking>>(
      valueListenable: widget.todayBean,
      builder: (context, value, child) {
        final items = value.reversed.toList(growable: false);
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) => _buildTimeBookingItem(items[index]),
        );
      });
  }

  Widget _buildTimeBookingItem(TimeBooking booking) {
    if (booking.end == null) {
      return ListTile(
        leading: const Icon(Icons.lock_clock),
        title: Row(children: _expandItems([
          const Text('Beginn:'),
          Text('${toHoursWithMinutes(booking.start)} Uhr')
        ])),
      );
    } else {
      return ListTile(
        leading: const Icon(Icons.lock_clock),
        title: Row(children: _expandItems([
          const Text('Buchung:'),
          Text(toDurationHoursAndMinutes(booking.workTime))
        ])),
        subtitle: Text('Start: ${toHoursWithMinutes(booking.start)} Uhr, Ende: ${toHoursWithMinutes(booking.end)} Uhr'),
      );
    }
  }

  List<Widget> _expandItems(List<Widget> widgets) {
    final results = <Widget>[];
    for (Widget w in widgets) results.add(Expanded(child: w));
    return results;
  }
}
