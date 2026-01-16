import 'package:flutter/material.dart';
import 'package:time_tracker/common/time_util.dart';

class DailyConfigOverview extends StatelessWidget {
  final Duration targetWorkHours;
  final DateTime? workStarted;
  final Duration workedToday;

  const DailyConfigOverview(
    this.targetWorkHours,
    this.workStarted,
    this.workedToday, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.titleMedium;
    final valueStyle = Theme.of(context).textTheme.titleMedium;
    final workEndTime = DateTime.now()
        .add(targetWorkHours)
        .subtract(workedToday);
    final rows = <TableRow>[];
    if (workStarted != null) {
      rows.add(
        _keyValueRow(
          Text('Arbeitsbeginn:', style: textStyle),
          Text('${toHoursWithMinutes(workStarted)} Uhr', style: valueStyle),
        ),
      );
    }
    rows.add(
      _keyValueRow(
        Text('Arbeitsende:', style: textStyle),
        Text('${toHoursWithMinutes(workEndTime)} Uhr', style: valueStyle),
      ),
    );
    return Table(
      // border: TableBorder.symmetric(inside: BorderSide(width: 1.0, style: BorderStyle.solid)),
      children: rows,
    );
  }

  TableRow _keyValueRow(Widget key, Widget value) {
    return TableRow(children: [_rowLabel(key), _rowValue(value)]);
  }

  Padding _rowValue(Widget value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: value,
    );
  }

  Container _rowLabel(Widget key) {
    return Container(alignment: Alignment.centerRight, child: _rowValue(key));
  }
}
