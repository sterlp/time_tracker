import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:time_tracker/booking/bean/today_bean.dart';
import 'package:time_tracker/booking/widget/start_stop_widget.dart';
import 'package:time_tracker/booking/widget/time_account.dart';


class TimerButton extends StatefulWidget {
  final TodayBean todayBean;

  const TimerButton(this.todayBean, {Key? key}) : super(key: key);

  @override
  _TimerButtonState createState() => _TimerButtonState();
}

class _TimerButtonState extends State<TimerButton> {
  Timer? _refreshTimer;
  final _headerFormat = DateTimeUtil.getFormat('E, HH:mm dd.MM.yyyy');
  var _now = DateTimeUtil.precisionMinutes(DateTime.now());

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 5),
        (timer) {
        final newNow  = DateTimeUtil.precisionMinutes(DateTime.now());
        if (newNow.millisecondsSinceEpoch - _now.millisecondsSinceEpoch > 1) {
          if (mounted) {
            widget.todayBean.changeDay(newNow);
            setState(() {
              _now = newNow;
            });
          }
        }
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
    return ValueListenableBuilder(
      valueListenable: widget.todayBean,
      builder: (context, value, child) {
        final textStyle = Theme.of(context).textTheme.headline6;

        final workHours = widget.todayBean.workHours;
        return Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
              child: FittedBox(child:
                Text(_headerFormat.format(_now), style: textStyle,),),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
              child: StartAndStopWidget(
                !widget.todayBean.hasCurrentBooking,
                widget.todayBean.sumTimeBookingsWorkTime(),
                widget.todayBean.workHours,
                _startPressed,
              ),
            ),
            TimeAccount(workHours,
              totalWorkTime,
              widget.todayBean.sumBreakTime(),
            )
          ],
        );
      },
    );
  }

  Duration get totalWorkTime {
    return widget.todayBean.sumTimeBookingsWorkTime();
  }

  void _startPressed() {
    final today = widget.todayBean;
    if (today.hasCurrentBooking) {
      today.stopBooking();
    } else {
      today.startNewBooking();
    }
  }
}
