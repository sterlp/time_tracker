import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:sqflite_entities/entity/query.dart';
import 'package:time_tracker/booking/bean/booking_service.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/booking/page/edit_booking_page.dart';
import 'package:time_tracker/booking/widget/daily_bookings_list.dart';
import 'package:time_tracker/common/feedback.dart';
import 'package:time_tracker/home/widget/loading_widget.dart';

Future<void> showBookingListPage(
    BuildContext context,
    AppContainer container,
    DateTime from, DateTime to,) {
  return Navigator.push<void>(
    context,
    MaterialPageRoute(builder: (context) => BookingListPage(container, from, to,)),
  );
}


class BookingListPage extends StatefulWidget {
  final AppContainer _container;
  final DateTime from;
  final DateTime to;
  const BookingListPage(this._container, this.from, this.to, {Key? key}) : super(key: key);

  @override
  _BookingListPageState createState() => _BookingListPageState();
}

class _BookingListPageState extends State<BookingListPage> {
  final _df = DateTimeUtil.getFormat('EEEE, dd.MM', 'de');
  ValueNotifier<List<TimeBooking>>? _bookings;

  @override
  void initState() {
    super.initState();
    _reload();
  }
  @override
  void dispose() {
    if (_bookings != null) _bookings!.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    final items = await widget._container.get<BookingService>().fromTo(widget.from, widget.to);

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
        appBar: AppBar(
          title: Text(_df.format(widget.from)),
        ),
        body: DailyBookingsList(
          _bookings!,
          _doEdit,
          _doDelete,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _newBooking,
          child: const Icon(Icons.add),
        ),
      );
    }
  }
  Future<void> _newBooking() async {
    FeedbackFixed.touch(context);
    final saved = await showEditBookingPage(
      context,
      widget._container,
      booking: TimeBooking(widget.to, endTime: widget.to.add(Duration(hours: 1))),
    );
    if (saved != null && mounted) await _reload();
  }
  Future<void> _doEdit(TimeBooking booking) async {
    final r = await showEditBookingPage(context, widget._container, booking: booking);
    if (r != null && mounted) {
      await _reload();
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
