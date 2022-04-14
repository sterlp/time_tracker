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
    final headStyle = Theme.of(context).textTheme.headline6;

    Color? c;
    if (divToday.inMinutes >= 0) c = Colors.green;
    else if (divToday.inMinutes < -45) c = Colors.red;
    // final doneAt = DateTime.now().subtract(done).add(target);

    return Table(
      children: [
        TableRow(
          children: [
            Center(child: Text('Soll', style: headStyle,)),
            Center(child: Text('Ist', style: headStyle,)),
          ]
        ),
        TableRow(children: [
          Center(child: Text(toDurationHoursAndMinutes(divToday),
            style: textStyle?.apply(color: c),),),
          Center(child: Text(toDurationHoursAndMinutes(done),
              style: textStyle,),)
        ]),
      ],
    );
  }
}
