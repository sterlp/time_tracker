import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:time_tracker/booking/bean/booking_service.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/booking/page/edit_booking_page.dart';
import 'package:time_tracker/booking/widget/daily_bookings_list.dart';
import 'package:time_tracker/common/feedback.dart';
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
  @override
  void dispose() {
    if (_bookings != null) _bookings!.dispose();
    super.dispose();
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
      return Scaffold(
        body: DailyBookingsList(
          _bookings!,
          _doEdit,
          _doDelete,
          showFirstDayHeader: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            FeedbackFixed.touch(context);
            final saved = await showEditBookingPage(context, widget._container);
            if (saved != null && mounted) _reload();
          },
          child: const Icon(Icons.add),
        ),
      );
    }
  }
  Future<void> _doEdit(TimeBooking booking) async {
    final r = await showEditBookingPage(context, widget._container, booking: booking);
    if (r != null && mounted) {
      _reload();
    }
  }
  Future<void> _doDelete(TimeBooking booking) async {
    await widget._container.get<BookingService>().delete(booking);
    if (mounted) {
      ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Buchung gelöscht.')),
      );
      await _reload();
    }
  }
}
