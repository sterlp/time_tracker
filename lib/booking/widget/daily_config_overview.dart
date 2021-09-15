import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:time_tracker/util/time_util.dart';

class DailyConfigOverview extends StatelessWidget {
  final Duration workHoursToday;
  final DateTime? workStarted;
  final Duration workedToday;

  const DailyConfigOverview(this.workHoursToday, this.workStarted, this.workedToday,
      {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.subtitle1;
    final valueStyle = Theme.of(context).textTheme.subtitle1;
    final workEndTime = DateTime.now().add(workHoursToday).subtract(workedToday);

    return Padding(
      padding: const EdgeInsets.fromLTRB(72, 0, 0, 0),
      child: Table(children: [
          TableRow(children: [
              Text('Arbeitsbeginn:', style: textStyle,),
              Text('${toHoursWithMinutes(workStarted)} Uhr', style: valueStyle)
            ]
          ),
          TableRow(children: [
              Text('vorauss. Arbeitsende:', style: textStyle,),
              Text('${toHoursWithMinutes(workEndTime)} Uhr', style: valueStyle)
            ]
          ),
        ],
        //border: TableBorder.symmetric(inside: BorderSide(width: 1.0, style: BorderStyle.solid)),
      ),
    );
  }
}
