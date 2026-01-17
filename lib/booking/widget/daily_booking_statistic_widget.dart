import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:time_tracker/booking/entity/time_booking_statistics.dart';
import 'package:time_tracker/common/widget/expanded_row_widget.dart';
import 'package:time_tracker/common/widget/label_text_widget.dart';
import 'package:time_tracker/common/widget/labeled_card_widget.dart';
import 'package:time_tracker/tag/entity/tag.dart';

class DailyBookingStatisticWidget extends StatelessWidget {
  final DailyBookingStatistic item;
  final GestureLongPressCallback? onLongPress;
  final List<Tag>? tags;
  final VoidCallback? onTagTap;

  const DailyBookingStatisticWidget(
    this.item, {
    super.key,
    this.onLongPress,
    this.tags,
    this.onTagTap,
  });

  @override
  Widget build(BuildContext context) {
    final df = DateTimeUtil.getFormat('EEEE, dd.MM.yyyy');
    final breakTime = item.end.difference(item.start) - item.workedTime;

    return LabeledCardWidget(
      df.format(item.start),
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
          ),
          if (tags != null) _buildTagsRow(context),
        ],
      ),
      onLongPress: onLongPress,
    );
  }

  Widget _buildTagsRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: InkWell(
        onTap: onTagTap,
        child: Row(
          children: [
            Icon(MdiIcons.tag, size: 16, color: Theme.of(context).hintColor),
            const SizedBox(width: 4),
            if (tags!.isEmpty)
              Text(
                'Keine Tags',
                style: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontSize: 12,
                ),
              )
            else
              Expanded(
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: tags!
                      .map((tag) => Chip(
                            label: Text(
                              tag.name,
                              style: const TextStyle(fontSize: 11),
                            ),
                            backgroundColor: tag.color?.withAlpha(51),
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ))
                      .toList(),
                ),
              ),
            if (onTagTap != null)
              Icon(
                MdiIcons.pencil,
                size: 14,
                color: Theme.of(context).hintColor,
              ),
          ],
        ),
      ),
    );
  }
}
