import 'package:flutter/material.dart';
import 'package:time_tracker/booking/widget/work_time_widget.dart';
import 'package:time_tracker/util/time_util.dart';

class TimeAccount extends StatelessWidget {
  final Duration target;
  final Duration done;
  final Duration pause;

  const TimeAccount(this.target, this.done, this.pause, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final divToday = done - target;
    final textStyle = Theme.of(context).textTheme.subtitle1;
    final headStyle = Theme.of(context).textTheme.headline6;

    return Table(
      children: [
        TableRow(
          children: [
            Center(child: Text('Soll', style: headStyle,)),
            Center(child: Text('Ist', style: headStyle,)),
            Center(child: Text('Pause', style: headStyle,)),
          ],
        ),
        TableRow(children: [
          Center(child: WorkTimeWidget(divToday, style: textStyle,)),
          Center(child: Text(toDurationHoursAndMinutes(done), style: textStyle)),
          Center(child: Text(toDurationHoursAndMinutes(pause), style: textStyle)),
        ],),
      ],
    );
  }
}
