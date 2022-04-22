import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:time_tracker/booking/bean/today_bean.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/booking/page/edit_booking_page.dart';
import 'package:time_tracker/booking/widget/daily_bookings_list.dart';
import 'package:time_tracker/booking/widget/daily_config_overview.dart';
import 'package:time_tracker/booking/widget/timer_button.dart';
import 'package:time_tracker/export/export_service.dart';

class BookingWidgetPage extends StatelessWidget {
  final AppContainer _container;
  const BookingWidgetPage(this._container, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final todayBean = _container.get<TodayBean>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zeiterfassung'),
        actions: [
          IconButton(
            onPressed: () async {
              final f = await _container.get<ExportService>().exportAllToFile();
              await Share.shareFiles(
                [f.path],
                subject: 'Datenexport.csv', mimeTypes: ['text/csv'],);
              f.delete();
            },
            icon: const Icon(Icons.download),
          ),
        ],
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
                  todayBean.sumTimeBookingsWorkTime()
                );
              },
            ),
          ),
          Expanded(
            child: DailyBookingsList(
              todayBean,
              (b) async {
                final r = await showEditBookingPage(context, _container, booking: b);
                if (r != null) todayBean.reload();
              },
              todayBean.delete,
            ),
          ),
        ],
      ),
    );
  }
}
