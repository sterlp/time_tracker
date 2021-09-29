import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:time_tracker/booking/bean/booking_service.dart';
import 'package:time_tracker/booking/dao/time_booking_dao.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/booking/widget/daily_bookings_list.dart';
import 'package:time_tracker/booking/widget/time_booking_list_item.dart';
import 'package:time_tracker/home/widget/loading_widget.dart';

class BookingListPage extends StatefulWidget {
  final AppContainer _container;
  const BookingListPage(this._container, {Key? key}) : super(key: key);

  @override
  _BookingListPageState createState() => _BookingListPageState();
}

class _BookingListPageState extends State<BookingListPage> {
  ValueNotifier<List<TimeBooking>>? _bookings;

  @override
  void initState() {
    _reload();
    super.initState();
  }

  Future<void> _reload() async {
    final items = await widget._container.get<BookingService>().all();
    if (_bookings == null) {
      setState(() {
        _bookings = ValueNotifier(items);
      });
    } else {
      _bookings!.value = items;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_bookings == null) {
      return const LoadingWidget();
    } else {
      return DailyBookingsList(_bookings!, (booking) async {
        await widget._container.get<BookingService>().delete(booking);
        _reload();
      });
      /*
      return ListView.builder(
        itemCount: bookings!.length,
        itemBuilder: (context, i) {
          return TimeBookingListItem(bookings![i], (b) =>
              widget._container.get<BookingService>().delete(b));
        }
      );
      */
    }
  }
}