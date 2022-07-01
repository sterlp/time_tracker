import 'dart:async';

import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:time_tracker/booking/bean/today_bean.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/booking/page/edit_booking_page.dart';
import 'package:time_tracker/booking/widget/daily_bookings_list.dart';
import 'package:time_tracker/booking/widget/daily_config_overview.dart';
import 'package:time_tracker/booking/widget/timer_button.dart';
import 'package:time_tracker/export/widget/export_dialog_widget.dart';

class BookingWidgetPage extends StatefulWidget {
  final AppContainer _container;
  const BookingWidgetPage(this._container, {Key? key}) : super(key: key);

  @override
  State<BookingWidgetPage> createState() => _BookingWidgetPageState();
}

class _BookingWidgetPageState extends State<BookingWidgetPage> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(
        const Duration(seconds: 10), (timer) {
          final todayBean = widget._container.get<TodayBean>();
          final newNow  = DateTimeUtil.precisionMinutes(DateTime.now());
          todayBean.changeDay(newNow);
          if (mounted) setState(() {});
        }
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todayBean = widget._container.get<TodayBean>();
    final _container = widget._container;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zeiterfassung'),
      ),
      drawer: Drawer(
        child: ExportDataWidget(_container),
      ),
      body: Column(
        children: [
          TimerButton(todayBean),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 24, 0, 16),
            child: ValueListenableBuilder<List<TimeBooking>>(
              valueListenable: todayBean,
              builder: (context, value, child) {
                final startTime = value.isNotEmpty ? value.first.start : null;
                return DailyConfigOverview(
                  todayBean.workHours,
                  startTime,
                  todayBean.sumTimeBookingsWorkTime(),
                );
              },
            ),
          ),
          Expanded(
            child: DailyBookingsList(
              todayBean,
                  (b) async {
                await showEditBookingPage(context, _container, booking: b);
                todayBean.reload();
              },
              todayBean.delete,
            ),
          ),
        ],
      ),
    );
  }
}
