import 'package:flutter/material.dart';
import 'package:time_tracker/booking/entity/time_booking_statistics.dart';
import 'package:time_tracker/util/time_util.dart';

class BookingsStatisticWidget extends StatelessWidget {
  final List<DailyBookingStatistic> value;

  const BookingsStatisticWidget(this.value, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final overHoursTotal = DailyBookingStatistic.sumOverHours(value);
    var avgWorkTime = Duration.zero;
    var avgBreakTime = Duration.zero;

    if (value.isNotEmpty) {
      avgWorkTime = Duration(
        minutes: (DailyBookingStatistic.sumWorkedTime(value).inMinutes / value.length).round(),
      );
      avgBreakTime = Duration(
        minutes: (DailyBookingStatistic.sumBreakTime(value).inMinutes / value.length).round(),
      );
    }

    return Column(
      children: [
        KeyValueWidget('Überstunden gesamt:', toDurationHoursAndMinutes(overHoursTotal)),
        KeyValueWidget('Ø Arbeitszeit:', toDurationHoursAndMinutes(avgWorkTime)),
        KeyValueWidget('Ø Pausenzeit:', toDurationHoursAndMinutes(avgBreakTime)),
      ],
    );
  }
}

class KeyValueWidget extends StatelessWidget {
  final String _key;
  final String _value;
  const KeyValueWidget(this._key, this._value, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final headStyle = Theme.of(context).textTheme.headline6;
    const padding = EdgeInsets.fromLTRB(16, 8, 16, 0);
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: FittedBox(
              alignment: Alignment.centerLeft,
              child: Text(_key, style: headStyle,),
              fit: BoxFit.scaleDown,
            ),
          ),
          Container(width: 64),
          Expanded(flex: 2, child: FittedBox(
            alignment: Alignment.centerRight,
            child: Text(_value, textScaleFactor: 1.3),
            fit: BoxFit.scaleDown,),
          ),
        ],
      ),
    );
  }
}

