import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/material.dart';
import 'package:time_tracker/booking/dao/time_booking_dao.dart';
import 'package:time_tracker/booking/entity/time_booking_statistics.dart';
import 'package:time_tracker/booking/page/bookings_list_page.dart';
import 'package:time_tracker/booking/page/edit_booking_page.dart';
import 'package:time_tracker/booking/service/booking_service.dart';
import 'package:time_tracker/booking/widget/bookings_statistic_widget.dart';
import 'package:time_tracker/booking/widget/daily_booking_statistic_widget.dart';
import 'package:time_tracker/home/widget/loading_widget.dart';

class BookingsHistoryPage extends StatefulWidget {
  final AppContainer _container;
  const BookingsHistoryPage(this._container, {Key? key}) : super(key: key);

  @override
  _BookingsHistoryPageState createState() => _BookingsHistoryPageState();

}

class _BookingsHistoryPageState extends State<BookingsHistoryPage> {
  final _stats = ValueNotifier<List<DailyBookingStatistic>?>(null);

  Future<void> _reload() async {
    _stats.value = await widget._container.get<TimeBookingDao>().stats();
  }
  @override
  void initState() {
    super.initState();
    _reload();
  }
  @override
  void dispose() {
    _stats.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<DailyBookingStatistic>?>(
      valueListenable: _stats,
      builder: (context, value, child) {
        if (value == null) {
          return const LoadingWidget();
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Historie'),
            ),
            body: _buildWeekList(value),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                await showBookingPageWithCallback(context, widget._container);
                if (mounted) _reload();
              },
              child: const Icon(Icons.add),
            ),
          );
        }
      },
    );
  }

  Widget _buildWeekList(List<DailyBookingStatistic> value) {
    return ListView.builder(
      itemCount: value.length,
      itemBuilder: (context, index) {
        final item = value[index];

        if (index == 0) {
          return Column(
            children: [
              BookingsStatisticWidget(DailyBookingStatisticList.of(value)),
              _buildWeekItem(item),
            ],
          );
        } else {
          return _buildWeekItem(item);
        }
      },
    );
  }

  Widget _buildWeekItem(DailyBookingStatistic item) {
    return DailyBookingStatisticWidget(item,
      onLongPress: () async {
        if (item.bookingsCount > 1) {
          await showBookingListPage(context, widget._container, item.start, item.end);
        } else {
          final booking = await widget._container
              .get<BookingService>()
              .getBookingByStartDate(item.start);
          if (mounted) await showEditBookingPage(context, widget._container, booking: booking);
        }
        if (mounted) _reload();
      },
    );
  }
}
