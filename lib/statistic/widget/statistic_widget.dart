import 'package:flutter/material.dart';
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:time_tracker/booking/widget/work_time_widget.dart';
import 'package:time_tracker/common/time_util.dart';
import 'package:time_tracker/common/widget/label_text_widget.dart';
import 'package:time_tracker/common/widget/labeled_card_widget.dart';
import 'package:time_tracker/statistic/entity/overview_stats.dart';

class StatisticWidget extends StatelessWidget {
  final StatsEntity item;
  final GestureLongPressCallback? onLongPress;

  const StatisticWidget({required this.item, this.onLongPress, super.key});

  @override
  Widget build(BuildContext context) {
    const space = TableRow(
      children: [SizedBox(height: 6), SizedBox(height: 6)],
    );
    final valueStyle = Theme.of(context).textTheme.titleMedium;

    return LabeledCardWidget(
      item.title,
      Table(
        children: [
          TableRow(
            children: [
              LabelTextWidget(
                'erster Arbeitstag',
                DateTimeUtil.formatWithString(item.start, 'E dd.MM.yyyy'),
              ),
              LabelTextWidget(
                'letzter Arbeitstag',
                DateTimeUtil.formatWithString(item.end, 'E dd.MM.yyyy'),
              ),
            ],
          ),
          space,
          TableRow(
            children: [
              LabelTextWidget(
                'Tage gearbeitet',
                item.statisticList.count.toString(),
              ),
              LabeledWidget(
                'Überstunden',
                child: Text(
                  toDurationHoursAndMinutes(item.statisticList.sumOverHours),
                  style: valueStyle,
                ),
              ),
            ],
          ),
          space,
          TableRow(
            children: [
              LabelTextWidget.ofDuration(
                'Std gearbeitet',
                item.statisticList.sumWorkedTime,
              ),
              LabelTextWidget.ofDuration(
                'Ø Std gearbeitet',
                item.statisticList.avgWorkTime,
              ),
            ],
          ),
          space,
          TableRow(
            children: [
              LabelTextWidget.ofDuration(
                'Sollarbeitszeit',
                item.statisticList.sumPlannedWorkTime,
              ),
              LabelTextWidget.ofDuration(
                'Ø Sollarbeitszeit',
                item.statisticList.avgPlannedWorkTime,
              ),
            ],
          ),
          space,
          TableRow(
            children: [
              LabelTextWidget.ofDuration(
                'Pause',
                item.statisticList.sumBreakTime,
              ),
              LabelTextWidget.ofDuration(
                'Ø Pause',
                item.statisticList.avgBreakTime,
              ),
            ],
          ),
        ],
      ),
      onLongPress: onLongPress,
    );
  }
}
