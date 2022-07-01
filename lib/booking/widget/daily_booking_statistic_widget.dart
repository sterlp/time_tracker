import 'package:flutter/material.dart';
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:time_tracker/booking/entity/time_booking_statistics.dart';
import 'package:time_tracker/common/widget/expanded_row_widget.dart';
import 'package:time_tracker/common/widget/label_text_widget.dart';
import 'package:time_tracker/common/widget/labeled_card_widget.dart';

class DailyBookingStatisticWidget extends StatelessWidget {
  final DailyBookingStatistic item;
  final GestureLongPressCallback? onLongPress;
  const DailyBookingStatisticWidget(this.item, {Key? key, this.onLongPress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _df = DateTimeUtil.getFormat('EEEE, dd.MM.yyyy');
    final breakTime = item.end.difference(item.start) - item.workedTime;

    return LabeledCardWidget(
      _df.format(item.start),
      Column(
        children: [
          ExpandedRowWidget(
            children: [
              LabelTextWidget.ofTime('Start', item.start),
              LabelTextWidget.ofTime('Ende', item.end)
            ],
          ),
          ExpandedRowWidget(
            children: [
              LabelTextWidget.ofDuration('Arbeitszeit', item.workedTime),
              LabelTextWidget.ofDuration('Überstunden', item.overHours)
            ],
          ),
            ExpandedRowWidget(
              children: [
                LabelTextWidget.ofDuration('Pause', breakTime),
                LabelTextWidget.ofDuration('Soll', item.planedWorkTime),
              ],
            )
        ],
      ),
      onLongPress: onLongPress,
    );
  }
}
