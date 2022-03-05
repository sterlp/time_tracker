import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:time_tracker/booking/bean/today_bean.dart';
import 'package:time_tracker/booking/dao/time_booking_dao.dart';
import 'package:time_tracker/booking/page/bookings_by_week_page.dart';
import 'package:time_tracker/booking/page/bookings_list_page.dart';
import 'package:time_tracker/booking/page/booking_widget_page.dart';
import 'package:time_tracker/common/feedback.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Tracker Zeiterfassung'),
        actions: [
          /*IconButton(
            onPressed: () {
              Share.share('Fooo.csv', subject: 'Look what I made!');
            },
            icon: const Icon(Icons.download)
          )*/
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
