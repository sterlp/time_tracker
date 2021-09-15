import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:time_tracker/booking/bean/today_bean.dart';
import 'package:time_tracker/booking/widget/time_account.dart';
import 'package:time_tracker/util/time_util.dart';


class TimerButton extends StatefulWidget {
  final TodayBean todayBean;

  const TimerButton(this.todayBean, {Key? key}) : super(key: key);

  @override
  _TimerButtonState createState() => _TimerButtonState();
}

class _TimerButtonState extends State<TimerButton> {
  Timer? _refreshTimer;
  final _headerFormat = DateFormat('EEEE, dd.MM.yyyy');
  var now = DateTimeUtil.precisionMinutes(DateTime.now());

  @override
  void initState() {
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 5),
        (timer) {
        final newNow  = DateTimeUtil.precisionMinutes(DateTime.now());
        if (newNow.millisecondsSinceEpoch - now.millisecondsSinceEpoch > 1) {
          setState(() {
            now = newNow;
          });
          print('Update $now');
        }
      }
    );

    super.initState();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final textStyle = Theme.of(context).textTheme.headline6;

    return ValueListenableBuilder(
      valueListenable: widget.todayBean,
      builder: (context, value, child) {
        final workHours = widget.todayBean.workHours;
        return Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                child: Text(_headerFormat.format(now),
                    style: textStyle)),
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
                child: Text('${toHoursWithMinutes(now)} Uhr',
                    style: textStyle)),
            Stack(
              alignment: AlignmentDirectional.center,
              children: [
                _buildDailyProgress(),
                _buildStartButton(context),
              ],
            ),
            TimeAccount(workHours, totalWorkTime)
          ],
        );
      }
    );
  }

  Duration get totalWorkTime {
    return widget.todayBean.sumTimeBookingsWorkTime();
  }

  SizedBox _buildDailyProgress() {
    final progress = totalWorkTime.inSeconds / (widget.todayBean.workHours.inSeconds);
    return SizedBox(
      child: CircularProgressIndicator(value: progress, strokeWidth: 12,),
      height: 180,
      width: 180,
    );
  }

  ElevatedButton _buildStartButton(BuildContext context) {
    Widget text;
    final today = widget.todayBean;
    if (today.hasCurrentBooking) {
      final total = totalWorkTime;
      text = Text('Stopp',
        style: Theme.of(context).textTheme.headline4,);
    } else {
      text = Text('Starten',
        style: Theme.of(context).textTheme.headline4,);
    }

    return ElevatedButton(
      onPressed: _startPressed,
      child: text,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(48),
      ),
    );
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
