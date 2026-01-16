import 'package:flutter/material.dart';
import 'package:time_tracker/booking/widget/work_time_widget.dart';
import 'package:time_tracker/common/time_util.dart';

class TimeAccount extends StatelessWidget {
  final Duration target;
  final Duration done;
  final Duration pause;

  const TimeAccount(this.target, this.done, this.pause, {super.key});

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.titleMedium;
    final headStyle = Theme.of(context).textTheme.titleLarge;

    return Table(
      children: [
        TableRow(
          children: [
            Center(child: Text('Soll', style: headStyle)),
            Center(child: Text('Ist', style: headStyle)),
            Center(child: Text('Pause', style: headStyle)),
          ],
        ),
        TableRow(
          children: [
            Center(
              child: Text(toDurationHoursAndMinutes(target), style: textStyle),
            ),
            Center(child: WorkTimeWidget(done, target, style: textStyle)),
            Center(
              child: Text(toDurationHoursAndMinutes(pause), style: textStyle),
            ),
          ],
        ),
      ],
    );
  }
}
