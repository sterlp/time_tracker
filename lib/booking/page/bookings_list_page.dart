import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/booking/page/edit_booking_page.dart';
import 'package:time_tracker/booking/service/booking_service.dart';
import 'package:time_tracker/booking/widget/daily_bookings_list.dart';
import 'package:time_tracker/common/logger.dart';
import 'package:time_tracker/export/service/export_service.dart';
import 'package:time_tracker/home/widget/loading_widget.dart';

Future<void> showBookingListPage(
    BuildContext context,
    AppContainer container,
    DateTime from, DateTime to,) {
  return Navigator.push<void>(
    context,
    MaterialPageRoute(
      builder: (context) => BookingListPage(container,
        DateTimeUtil.clearTime(from), DateTimeUtil.midnight(to),),
    ),
  );
}


class BookingListPage extends StatefulWidget {
  final AppContainer _container;
  final DateTime _from;
  final DateTime _to;
  const BookingListPage(this._container, this._from, this._to, {Key? key}) : super(key: key);

  @override
  _BookingListPageState createState() => _BookingListPageState();
}

class _BookingListPageState extends State<BookingListPage> {
  final _df = DateTimeUtil.getFormat('dd.MM');
  static final _log = LoggerFactory.get<BookingListPage>();
  ValueNotifier<List<TimeBooking>>? _bookings;

  @override
  void initState() {
    super.initState();
    _doReload();
  }

  @override
  void dispose() {
    if (_bookings != null) _bookings!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_bookings == null) {
      return const LoadingWidget();
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('von ${_df.format(widget._from)} bis ${_df.format(widget._to)}'),
          actions: [
            IconButton(
              onPressed: _bookings!.value.isNotEmpty ? _doExport : null,
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
          onPressed: () => _newBooking(),
          child: const Icon(Icons.add),
        ),
      );
    }
  }

  Future<void> _doReload() async {
    final items = await widget._container.get<BookingService>().fromTo(widget._from, widget._to);
    _log.debug('Doing a reload now ${items.length} items ...');
    if (_bookings == null) {
      if (mounted) setState(() => _bookings = ValueNotifier(items));
    } else {
      _bookings!.value = items;
    }
  }

  Future<void> _doExport() async {
    final fD = DateTimeUtil.getFormat('dd.MM');
    final tD = DateTimeUtil.getFormat('dd.MM.yyyy');
    final fileName = 'Datenexport ${fD.format(widget._from)} bis ${tD.format(widget._to)}.csv';
    final csvData = widget._container.get<ExportService>().toCsvData(_bookings!.value);
    final f = await widget._container.get<ExportService>().writeToFile(csvData, fileName: fileName);
    await Share.shareXFiles(
      [XFile(f.path, mimeType: 'text/csv', name: fileName)],
    );
    f.delete();
  }
  Future<void> _doEdit(TimeBooking booking) async {
    await  showBookingPageWithCallback(context, widget._container,
      booking: booking,
    );
    await _doReload();
  }
  Future<void> _doDelete(TimeBooking booking) async {
    await widget._container.get<BookingService>().delete(booking);
    if (mounted) {
      ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Buchung gelöscht.')),
      );
      await _doReload();
    }
  }
  Future<void> _newBooking() async {
    await showBookingPageWithCallback(context, widget._container,
      booking: TimeBooking(widget._to, end: widget._to.add(const Duration(hours: 1))),
    );
    await _doReload();
  }
}
