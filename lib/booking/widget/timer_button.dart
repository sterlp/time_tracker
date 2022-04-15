import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:time_tracker/booking/bean/today_bean.dart';
import 'package:time_tracker/booking/widget/time_account.dart';
import 'package:time_tracker/common/feedback.dart';
import 'package:time_tracker/util/time_util.dart';


class TimerButton extends StatefulWidget {
  final TodayBean todayBean;

  const TimerButton(this.todayBean, {Key? key}) : super(key: key);

  @override
  _TimerButtonState createState() => _TimerButtonState();
}

class _TimerButtonState extends State<TimerButton> {
  Timer? _refreshTimer;
  final _headerFormat = DateTimeUtil.getFormat('EEEE, dd.MM.yyyy', 'de');
  var _now = DateTimeUtil.precisionMinutes(DateTime.now());

  @override
  void initState() {
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
            print('Update $_now');
          }
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
                child: Text(_headerFormat.format(_now),
                    style: textStyle,),),
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
                child: Text('${toHoursWithMinutes(_now)} Uhr',
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
    final size = min(
        MediaQuery.of(context).size.width,
        MediaQuery.of(context).size.height) / 2.5;
    final stroke = size / 10;

    final progress = totalWorkTime.inSeconds / (widget.todayBean.workHours.inSeconds);
    return SizedBox(
      child: CircularProgressIndicator(value: progress, strokeWidth: stroke,),
      height: size + stroke * 2,
      width: size + stroke * 2,
    );
  }

  Widget _buildStartButton(BuildContext context) {
    Widget text;
    final today = widget.todayBean;
    if (today.hasCurrentBooking) {
      // final total = totalWorkTime;
      text = Text('Stopp',
        style: Theme.of(context).textTheme.headline4,);
    } else {
      text = Text('Starten',
        style: Theme.of(context).textTheme.headline4,);
    }
    final size = min(MediaQuery.of(context).size.width,
      MediaQuery.of(context).size.height) / 2.5;

    return ElevatedButton(
      onPressed: FeedbackFixed.wrapTouch(_startPressed, context),
      child: text,
      style: ElevatedButton.styleFrom(
        enableFeedback: true,
        shape: const CircleBorder(),
        elevation: 6.0,
        fixedSize: Size(size, size)
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
