import 'package:flutter/material.dart';
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:time_tracker/common/time_util.dart';

class LabeledWidget extends StatelessWidget {
  final String label;
  final Widget child;

  const LabeledWidget(this.label, {required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final headerStyle = Theme.of(
      context,
    ).textTheme.titleSmall?.apply(color: Theme.of(context).disabledColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: headerStyle),
        child,
      ],
    );
  }
}

class LabelTextWidget extends StatelessWidget {
  final String label;
  final String text;

  const LabelTextWidget(this.label, this.text, {super.key});

  LabelTextWidget.ofTime(this.label, DateTime? date, {super.key})
    : text = '${DateTimeUtil.formatWithString(date, 'HH:mm')} Uhr';

  LabelTextWidget.ofDate(this.label, DateTime? date, {super.key})
    : text = DateTimeUtil.formatWithString(date, 'dd.MM.yyyy HH:mm');

  LabelTextWidget.ofDuration(this.label, Duration? duration, {super.key})
    : text = toDurationHoursAndMinutes(duration);

  @override
  Widget build(BuildContext context) {
    final valueStyle = Theme.of(context).textTheme.titleMedium;
    return LabeledWidget(label, child: Text(text, style: valueStyle));
  }
}
