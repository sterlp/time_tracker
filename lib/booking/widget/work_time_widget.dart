import 'package:flutter/material.dart';
import 'package:time_tracker/common/time_util.dart';

class WorkTimeWidget extends StatelessWidget {
  final Duration duration;
  final Duration target;
  final TextStyle? style;

  const WorkTimeWidget(this.duration, this.target, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    Color? c;
    final s = style ?? DefaultTextStyle.of(context).style;

    if (duration.inMinutes + 45 >= target.inMinutes) c = Colors.green;
    else c = Colors.red;

    final v = toDurationHoursAndMinutes(duration);

    return Text(v, style: s.apply(color: c),);
  }
}
