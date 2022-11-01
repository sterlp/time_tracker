import 'package:flutter/material.dart';
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:time_tracker/common/time_util.dart';

class LabeledWidget extends StatelessWidget {
  final String label;
  final Widget child;

  const LabeledWidget(this.label, {required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final headerStyle = Theme.of(context).textTheme.subtitle2?.apply(
      color: Theme.of(context).disabledColor,);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: headerStyle,),
        child,
      ],
    );
  }
}

class LabelTextWidget extends StatelessWidget {
  final String label;
  final String text;

  const LabelTextWidget(this.label, this.text, {Key? key}) : super(key: key);

  LabelTextWidget.ofTime(this.label, DateTime? date, {Key? key})
      : text = '${DateTimeUtil.formatWithString(date, 'HH:mm')} Uhr',
        super(key: key);

  LabelTextWidget.ofDate(this.label, DateTime? date, {Key? key})
      : text = DateTimeUtil.formatWithString(date, 'dd.MM.yyyy HH:mm'),
        super(key: key);

  LabelTextWidget.ofDuration(this.label, Duration? duration, {Key? key})
      : text = toDurationHoursAndMinutes(duration),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final valueStyle = Theme.of(context).textTheme.subtitle1;
    return LabeledWidget(label, child: Text(text, style: valueStyle,));
  }
}
