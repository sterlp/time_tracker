import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:sqflite_entities/entity/query.dart';
import 'package:time_tracker/booking/bean/booking_service.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/booking/page/edit_booking_page.dart';
import 'package:time_tracker/booking/widget/daily_bookings_list.dart';
import 'package:time_tracker/common/feedback.dart';
import 'package:time_tracker/export/service/export_service.dart';
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
  final _df = DateTimeUtil.getFormat('EEEE, dd.MM');
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
      if (mounted) setState(() => _bookings = ValueNotifier(items));
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
          actions: [
            IconButton(
              onPressed: _bookings!.value.isNotEmpty ? _export : null,
              icon: const Icon(Icons.download),
            ),
          ],
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
  Future<void> _export() async {
    final fD = DateTimeUtil.getFormat('dd.MM');
    final tD = DateTimeUtil.getFormat('dd.MM.yyyy');
    final fileName = 'Datenexport ${fD.format(widget.from)} bis ${tD.format(widget.to)}.csv';
    final csvData = widget._container.get<ExportService>().toCsvData(_bookings!.value);
    final f = await widget._container.get<ExportService>().writeToFile(csvData, fileName: fileName);
    await Share.shareFiles(
      [f.path],
      subject: fileName,
      mimeTypes: ['text/csv'],);
    f.delete();
  }
  Future<void> _newBooking() async {
    await showBookingPageWithCallback(context, widget._container, _reload,
      booking: TimeBooking(widget.to, endTime: widget.to.add(const Duration(hours: 1))),
    );
  }
  Future<void> _doEdit(TimeBooking booking) async {
    await  showBookingPageWithCallback(context, widget._container, _reload,
      booking: booking,
    );
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
