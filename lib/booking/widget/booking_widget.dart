
import 'package:flutter/material.dart';
import 'package:time_tracker/booking/bean/today_bean.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/booking/widget/daily_bookings_list.dart';
import 'package:time_tracker/booking/widget/daily_config_overview.dart';
import 'package:time_tracker/booking/widget/timer_button.dart';

class BookingWidget extends StatelessWidget {
  final TodayBean todayBean;
  const BookingWidget(this.todayBean, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
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
                    todayBean.sumTimeBookingsWorkTime());
              },
            ),
          ),
          Expanded(child: DailyBookingsList(todayBean,
              todayBean.save,
              todayBean.delete))
        ]
    );
  }
}
