import 'package:flutter/material.dart';
import 'package:time_tracker/util/time_util.dart';

class TimeAccount extends StatelessWidget {
  final Duration target;
  final Duration done;

  const TimeAccount(this.target, this.done, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final divToday = done - target;
    final textStyle = Theme.of(context).textTheme.subtitle1;
    final doneAt = DateTime.now().subtract(done).add(target);

    return Table(
      children: [
        const TableRow(
          children: [
            Center(child: Icon(Icons.hourglass_top, size: 32)),
            Center(child: Icon(Icons.hourglass_bottom, size: 32,)),
          ]
        ),
        TableRow(children: [
          Center(child: Text(toDurationHoursAndMinutes(divToday), style: textStyle,)),
          Center(child: Text(toDurationHoursAndMinutes(done), style: textStyle))
        ]),
      ],
    );
  }
}
