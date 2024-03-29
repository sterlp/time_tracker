import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:time_tracker/booking/page/booking_widget_page.dart';
import 'package:time_tracker/booking/page/bookings_history_page.dart';
import 'package:time_tracker/common/feedback.dart';
import 'package:time_tracker/statistic/page/statistic_list_page.dart';

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
    _pages = [
      BookingWidgetPage(widget._container),
      StatisticListPage(widget._container),
      BookingsHistoryPage(widget._container),
    ];
    //initializeDateFormatting('de');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(MdiIcons.calendarToday),
            label: 'Heute',
          ),
          BottomNavigationBarItem(
            icon: Icon(MdiIcons.calendar),
            label: 'Statistik',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_day),
            label: 'Buchungshistorie',
          ),
        ],
        currentIndex: _index,
        //selectedItemColor: Colors.amber[800],
        onTap: (value) {
          if (_index != value) {
            FeedbackFixed.touch(context);
            setState(() => _index = value);
          }
        },
      ),
    );
  }
}
