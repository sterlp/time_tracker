import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/material.dart';
import 'package:time_tracker/booking/bean/booking_service.dart';
import 'package:time_tracker/booking/page/bookings_list_page.dart';
import 'package:time_tracker/booking/page/edit_booking_page.dart';
import 'package:time_tracker/log/logger.dart';
import 'package:time_tracker/statistic/entity/overview_stats.dart';
import 'package:time_tracker/statistic/widget/statistic_widget.dart';

enum _Statistic {
  week,
  month
}

class StatisticListPage extends StatefulWidget {
  final AppContainer _container;
  const StatisticListPage(this._container, {Key? key}) : super(key: key);

  @override
  State<StatisticListPage> createState() => _StatisticListPageState();
}

class _StatisticListPageState extends State<StatisticListPage> {
  static final _log = LoggerFactory.get<StatisticListPage>();
  final data = ValueNotifier<List<WeekOverviewStats>>([]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Theme(
          child: DropdownButton<_Statistic>(
            underline: Container(
              height: 2,
              color: Colors.white,
            ),
            onChanged: (v) {
              _log.debug("Changed to $v");
            },
            value: _Statistic.week,
            items: const [
              DropdownMenuItem(value: _Statistic.week, child: Text("Wochenübersicht")),
              DropdownMenuItem(value: _Statistic.month, child: Text("Monatsübersicht")),
            ],
          ),
          data: ThemeData.dark(),
        ),
      ),
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
        const space = TableRow(
          children: [SizedBox(height: 6,), SizedBox(height: 6,)],
        );
        return ListView.builder(
          shrinkWrap: true,
          itemCount: value.length,
          itemBuilder: (context, index) {
            final item = value[index];
            return StatisticWidget(
              item: item,
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
