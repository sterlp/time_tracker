import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:time_tracker/booking/dao/time_booking_dao.dart';
import 'package:time_tracker/booking/entity/time_booking_statistics.dart';
import 'package:time_tracker/common/widget/label_text_widget.dart';
import 'package:time_tracker/common/widget_functions.dart';
import 'package:time_tracker/home/widget/loading_widget.dart';
import 'package:time_tracker/util/time_util.dart';

class BookingsWeekPage extends StatefulWidget {
  final TimeBookingDao _bookingDao;
  const BookingsWeekPage(this._bookingDao, {Key? key}) : super(key: key);

  @override
  _BookingsWeekPageState createState() => _BookingsWeekPageState();
}

class _BookingsWeekPageState extends State<BookingsWeekPage> {
  final _stats = ValueNotifier<List<DailyBookingStatistic>?>(null);
  final _df = DateFormat('EEEE, dd.MM.yyyy', 'DE');
  Future<void> _reload() async {
    _stats.value = await widget._bookingDao.stats();
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
          return _buildWeekList(value);
        }
      },
    );
  }

  Widget _buildWeekList(List<DailyBookingStatistic> value) {
    return ListView.builder(
      itemCount: value.length,
      itemBuilder: (context, index) {
        final overHoursTotal = DailyBookingStatistic.sumOverHours(value);

        final item = value[index];
        final headStyle = Theme.of(context).textTheme.headline6;

        if (index == 0) {
          return Column(
            children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Überstunden gesamt', style: headStyle,),
            ),
            Text(toDurationHoursAndMinutes(overHoursTotal), textScaleFactor: 1.3,),
              _buildWeekItem(item)
            ],
          );
        } else {
          return _buildWeekItem(item);
        }
      }
    );
  }

  Widget _buildWeekItem(DailyBookingStatistic item) {
    final headStyle = Theme.of(context).textTheme.headline6;
    final breakTime = (item.end ?? DateTime.now()).difference(item.start) - item.workedTime;

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Card(
        elevation: 5,
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

