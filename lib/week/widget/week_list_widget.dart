
import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/material.dart';
import 'package:time_tracker/booking/bean/booking_service.dart';

class WeekListWidget extends StatefulWidget {
  final AppContainer _container;
  const WeekListWidget(this._container, {Key? key}) : super(key: key);

  @override
  State<WeekListWidget> createState() => _WeekListWidgetState();
}

class _WeekListWidgetState extends State<WeekListWidget> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final stats = await widget._container.get<BookingService>().statisticByDay();
  }
}
