import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:time_tracker/booking/bean/today_bean.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/booking/widget/booking_widget.dart';
import 'package:time_tracker/booking/widget/timer_button.dart';

class HomePage extends StatefulWidget {
  final AppContainer _container;

  const HomePage(this._container, {Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    final today = widget._container.get<TodayBean>();
    return Scaffold(
      appBar: AppBar(
        title: const  Text('Time Tracker'),
      ),
      body: BookingWidget(today),
    );
  }
}
