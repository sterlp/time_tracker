import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:time_tracker/booking/bean/booking_service.dart';
import 'package:time_tracker/booking/page/bookings_list_page.dart';
import 'package:time_tracker/booking/page/edit_booking_page.dart';
import 'package:time_tracker/common/widget/expanded_row_widget.dart';
import 'package:time_tracker/common/widget/label_text_widget.dart';
import 'package:time_tracker/common/widget/labeled_card_widget.dart';
import 'package:time_tracker/week/entity/week_overview_stats.dart';

class WeekListPage extends StatefulWidget {
  final AppContainer _container;
  const WeekListPage(this._container, {Key? key}) : super(key: key);

  @override
  State<WeekListPage> createState() => _WeekListPageState();
}

class _WeekListPageState extends State<WeekListPage> {
  final data = ValueNotifier<List<WeekOverviewStats>>([]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wochenübersicht')),
      body: _buildWeekListView(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showBookingPageWithCallback(context, widget._container, _reload),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildWeekListView(BuildContext context) {
    return ValueListenableBuilder<List<WeekOverviewStats>>(
      valueListenable: data,
      builder: (context, value, child) {
        return ListView.builder(
          shrinkWrap: true,
          itemCount: value.length,
          itemBuilder: (context, index) {
            final item = value[index];
            return LabeledCardWidget(
              'KW ${item.week} - ${item.statisticList.elements[0].start.year}',
              Column(
                children: [
                  ExpandedRowWidget(
                    children: [
                      LabelTextWidget('erster Arbeitstag', DateTimeUtil.formatWithString(item.start, 'E dd.MM.yyyy')),
                      LabelTextWidget('letzter Arbeitstag', DateTimeUtil.formatWithString(item.end, 'E dd.MM.yyyy')),
                    ],
                  ),
                  ExpandedRowWidget(
                    children: [
                      LabelTextWidget.ofDuration('gearbeitet', item.statisticList.sumWorkedTime),
                      LabelTextWidget.ofDuration('Ø gearbeitet', item.statisticList.avgWorkTime),
                    ],
                  ),
                  ExpandedRowWidget(
                    children: [
                      LabelTextWidget.ofDuration('Pause', item.statisticList.sumBreakTime),
                      LabelTextWidget.ofDuration('Ø Pause', item.statisticList.avgBreakTime),
                    ],
                  ),
                  ExpandedRowWidget(
                    children: [
                      LabelTextWidget.ofDuration('Überstunden', item.statisticList.sumOverHours),
                      LabelTextWidget('Buchungen', item.statisticList.count.toString()),
                    ],
                  ),
                ],
              ),
              onLongPress: () async {
                await showBookingListPage(context, widget._container, item.start, item.end);
                if (mounted) _reload();
              },
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final stats = await widget._container.get<BookingService>().statisticByDay();
    data.value = WeekOverviewStats.split(stats);
  }
}
