import 'package:flutter/material.dart';
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:time_tracker/booking/bean/today_bean.dart';
import 'package:time_tracker/booking/widget/start_stop_widget.dart';
import 'package:time_tracker/booking/widget/time_account.dart';


class TimerButton extends StatelessWidget {
  final TodayBean todayBean;

  const TimerButton(this.todayBean, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final headerFormat = DateTimeUtil.getFormat('E, HH:mm dd.MM.yyyy');
    return ValueListenableBuilder(
      valueListenable: todayBean,
      builder: (context, value, child) {
        final textStyle = Theme.of(context).textTheme.headline6;

        final workHours = todayBean.workHours;
        return Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
              child: FittedBox(child:
              Text(headerFormat.format(DateTime.now()), style: textStyle,),),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
              child: StartAndStopWidget(
                !todayBean.hasCurrentBooking,
                todayBean.sumTimeBookingsWorkTime(),
                todayBean.workHours,
                _startPressed,
              ),
            ),
            TimeAccount(workHours,
              totalWorkTime,
              todayBean.sumBreakTime(),
            )
          ],
        );
      },
    );
  }

  Duration get totalWorkTime {
    return todayBean.sumTimeBookingsWorkTime();
  }

  void _startPressed() {
    final today = todayBean;
    if (today.hasCurrentBooking) {
      today.stopBooking();
    } else {
      today.startNewBooking();
    }
  }
}
