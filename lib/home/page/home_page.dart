import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:new_version/new_version.dart';
import 'package:time_tracker/booking/bean/today_bean.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/booking/page/bookings_list_page.dart';
import 'package:time_tracker/booking/widget/booking_widget.dart';
import 'package:time_tracker/booking/widget/timer_button.dart';

class HomePage extends StatefulWidget {
  final AppContainer _container;

  const HomePage(this._container, {Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;
  var title = 'Time Tracker';
  @override
  void initState() {
    _checkVersion();
    super.initState();
  }
  Future<void> _checkVersion() async {
    final newVersion = NewVersion();
    final version = await newVersion.getVersionStatus();
    if (version != null) {
      setState(() {
        title = 'Time Tracker ${version.localVersion}';
      });
    }
    newVersion.showAlertIfNecessary(context: context);
    return;
  }
  @override
  Widget build(BuildContext context) {
    final today = widget._container.get<TodayBean>();
    return Scaffold(
      appBar: AppBar(
        title: const  Text('Time Tracker'),
      ),
      body: _index == 0 ? BookingWidget(today) : BookingListPage(widget._container),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.today),
            label: 'Heute',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
        currentIndex: _index,
        //selectedItemColor: Colors.amber[800],
        onTap: (value) => setState(() => _index = value),
      ),
    );
  }
}
