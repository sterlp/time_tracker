import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:time_tracker/booking/bean/today_bean.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/booking/widget/delete_booking_dialog.dart';
import 'package:time_tracker/common/list/dismissable_backgrounds.dart';
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
      }
    );
  }

  Widget _buildTimeBookingItem(TimeBooking booking) {
    Widget result;
    final bookingStart = '${toHoursWithMinutes(booking.start)} Uhr';
    final bookingDuration = toDurationHoursAndMinutes(booking.workTime);
    if (booking.end == null) {
      result = ListTile(
        leading: const Icon(Icons.lock_clock),
        title: Row(children: _expandItems([
          const Text('Beginn:'),
          Text(bookingStart)
        ])),
      );
    } else {
      result = ListTile(
        leading: const Icon(Icons.lock_clock),
        title: Row(children: _expandItems([
          const Text('Buchung:'),
          Text(bookingDuration)
        ])),
        subtitle: Text('Start: ${bookingStart}, Ende: ${toHoursWithMinutes(booking.end)} Uhr'),
      );
    }

    return Dismissible(
      key: Key(booking.id.toString()),
      direction: DismissDirection.endToStart,
      background: deleteDismissableBackground(context),
      child: result,
      onDismissed: (direction) {
        widget.todayBean.delete(booking);
        ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content:
              Text('Buchung von $bookingStart und Dauer: $bookingDuration wurde gelöscht.')
            )
          );
      },
      confirmDismiss: (direction) async {
        return showConfirmDeleteBookingDialog(context, booking);
      },
    );
  }

  List<Widget> _expandItems(List<Widget> widgets) {
    final results = <Widget>[];
    for (final w in widgets) results.add(Expanded(child: w));
    return results;
  }
}
