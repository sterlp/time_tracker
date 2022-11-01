import 'package:flutter/material.dart';
import 'package:time_tracker/common/time_util.dart';

class WorkTimeWidget extends StatelessWidget {
  final Duration duration;
  final TextStyle? style;

  const WorkTimeWidget(this.duration, {Key? key, this.style})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color? c;
    final s = style ?? DefaultTextStyle.of(context).style;
    if (duration.inMinutes >= 0) c = Colors.green;
    else if (duration.inMinutes < -45) c = Colors.red;
    final v = toDurationHoursAndMinutes(duration);

    if (c == null) return Text(v, style: s,);
    else return Text(v, style: s.apply(color: c),);
  }
}
