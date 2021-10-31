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

    return Table(
      // border: TableBorder.symmetric(inside: BorderSide(width: 1.0, style: BorderStyle.solid)),
      children: [
        _keyValueRow(
          Text('Arbeitsbeginn:', style: textStyle,),
            Text('${toHoursWithMinutes(workStarted)} Uhr', style: valueStyle),
        ),
        _keyValueRow(
          Text('vorauss. Arbeitsende:', style: textStyle,),
          Text('${toHoursWithMinutes(workEndTime)} Uhr', style: valueStyle),
        ),
      ],
    );
  }

  TableRow _keyValueRow(Widget key, Widget value) {
    return TableRow(
      children: [
        Container(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: key,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: value,
        ),
      ],
    );
  }
}
