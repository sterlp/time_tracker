import 'package:flutter/material.dart';
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:time_tracker/booking/service/today_bean.dart';
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

        final workHours = todayBean.targetWorkHours;
        return Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
              child: FittedBox(child:
              Text(headerFormat.format(DateTime.now()), style: textStyle,),),
            ),
            Expanded(
              child: StartAndStopWidget(
                !todayBean.hasCurrentBooking,
                todayBean.sumTimeBookingsWorkTime(),
                todayBean.targetWorkHours,
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
