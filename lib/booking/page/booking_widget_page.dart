import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/material.dart';
import 'package:time_tracker/booking/bean/today_bean.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/booking/page/edit_booking_page.dart';
import 'package:time_tracker/booking/widget/daily_bookings_list.dart';
import 'package:time_tracker/booking/widget/daily_config_overview.dart';
import 'package:time_tracker/booking/widget/timer_button.dart';
import 'package:time_tracker/export/widget/export_dialog_widget.dart';

class BookingWidgetPage extends StatelessWidget {
  final AppContainer _container;
  const BookingWidgetPage(this._container, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final todayBean = _container.get<TodayBean>();
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
