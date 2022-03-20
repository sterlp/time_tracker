import 'dart:io';
import 'package:sqflite_entities/entity/query.dart';
import 'package:csv/csv.dart';
import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:time_tracker/booking/bean/booking_service.dart';
import 'package:time_tracker/booking/bean/today_bean.dart';
import 'package:time_tracker/booking/dao/time_booking_dao.dart';
import 'package:time_tracker/booking/page/bookings_by_week_page.dart';
import 'package:time_tracker/booking/page/bookings_list_page.dart';
import 'package:time_tracker/booking/page/booking_widget_page.dart';
import 'package:time_tracker/common/feedback.dart';
import 'package:time_tracker/log/logger.dart';
import 'package:time_tracker/util/time_util.dart';

class HomePage extends StatefulWidget {
  final AppContainer _container;

  const HomePage(this._container, {Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;
  var _pages = <Widget>[];

  @override
  void initState() {
    super.initState();
    final today = widget._container.get<TodayBean>();
    _pages = [
      BookingWidgetPage(today),
      BookingsWeekPage(widget._container.get<TimeBookingDao>()),
      BookingListPage(widget._container)
    ];
    initializeDateFormatting('de');
  }

  @override
  Widget build(BuildContext context) {
    final _log = LoggerFactory.get<HomePage>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Tracker Zeiterfassung'),
        actions: [
          IconButton(
            onPressed: () async {
              // SUPER BETA
              final directory = await getApplicationDocumentsDirectory();
              var f = File('${directory.path}/Datenexport.csv');
              if (await f.exists()) await f.delete();

              final bs = widget._container.get<BookingService>();

              final bookings = await bs.all(order: SortOrder.ASC);
              final List<List<dynamic>?> result = [['Kalenderwoche', 'Tag', 'Wochentag', 'Start', 'Ende', 'Arbeitszeit']];
              for (final b in bookings) {
                result.add([
                  'KW${b.start.weekOfYear}',
                  b.day,
                  b.start.toWeekdayString(),
                  DateTimeUtil.formatWithString(b.start, 'dd.MM.yyyy HH:mm'),
                  DateTimeUtil.formatWithString(b.end, 'dd.MM.yyyy HH:mm'),
                  toHoursAndMinutes(b.workTime)]);
              }

              final csvData = const ListToCsvConverter(
                fieldDelimiter: ';'
              ).convert(result);
              await f.create();
              f = await f.writeAsString(csvData, flush: true);
              _log.info("Written file ${f.lengthSync()} ${f.path}");
              await Share.shareFiles(
                  [f.path],
                  subject: 'Datenexport.csv', mimeTypes: ['text/csv'],);
              f.delete();
            },
            icon: const Icon(Icons.download),
          ),
        ],
      ),
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Heute',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_view_week),
            label: 'Wochensicht',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Buchungshistorie',
          ),
        ],
        currentIndex: _index,
        //selectedItemColor: Colors.amber[800],
        onTap: (value) {
          FeedbackFixed.touch(context);
          setState(() => _index = value);
        },
      ),
    );
  }
}
