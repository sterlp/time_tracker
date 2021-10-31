import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:time_tracker/util/time_util.dart';

class LabelTextWidget extends StatelessWidget {
  final String label;
  final String text;

  const LabelTextWidget(this.label, this.text, {Key? key}) : super(key: key);
  LabelTextWidget.ofDate(this.label, DateTime? date, {Key? key})
      : text = DateTimeUtil.formatWithString(date, 'dd.MM.yyyy HH:mm'),
        super(key: key);
  LabelTextWidget.ofDuration(this.label, Duration? duration, {Key? key})
      : text = toDurationHoursAndMinutes(duration),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final headerStyle = Theme.of(context).textTheme.subtitle2?.apply(
        color: Theme.of(context).disabledColor);
    final valueStyle = Theme.of(context).textTheme.subtitle1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: headerStyle,),
        Text(text, style: valueStyle,),
      ],
    );
  }
}