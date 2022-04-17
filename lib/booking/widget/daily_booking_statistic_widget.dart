import 'package:flutter/material.dart';
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:time_tracker/booking/entity/time_booking_statistics.dart';
import 'package:time_tracker/common/widget/label_text_widget.dart';
import 'package:time_tracker/util/widget_util.dart';

class DailyBookingStatisticWidget extends StatelessWidget {
  final DailyBookingStatistic item;
  final GestureLongPressCallback? onLongPress;
  const DailyBookingStatisticWidget(this.item, {Key? key, this.onLongPress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _df = DateTimeUtil.getFormat('EEEE, dd.MM.yyyy', 'de');
    final headStyle = Theme.of(context).textTheme.headline6;
    final breakTime = item.end.difference(item.start) - item.workedTime;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      elevation: 8,
      child: InkWell(
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(_df.format(item.start), style: headStyle,),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: expandWidgets([
                    LabelTextWidget.ofDate('Start', item.start),
                    LabelTextWidget.ofDate('Ende', item.end)
                  ]),
                ),
              ),
              Row(
                children: expandWidgets([
                  LabelTextWidget.ofDuration('Arbeitszeit', item.workedTime),
                  LabelTextWidget.ofDuration('Überstunden', item.overHours)
                ]),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: expandWidgets([
                    LabelTextWidget.ofDuration('Pause', breakTime),
                    LabelTextWidget.ofDuration('Soll', item.planedWorkTime),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
