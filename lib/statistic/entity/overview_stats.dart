import 'package:sqflite_entities/converter/date_util.dart';
import 'package:time_tracker/booking/entity/time_booking_statistics.dart';
import 'package:week_of_year/week_of_year.dart';

List<T> _split<T extends StatsEntity>(
    List<DailyBookingStatistic> elements,
    bool Function(DateTime newDate, DateTime currentDate) splitter,
    T Function(DateTime d, List<DailyBookingStatistic> elements) builder) {
  final List<T> result = [];

  if (elements.isNotEmpty) {
    var currentDate = elements[0].start;
    List<DailyBookingStatistic> stats = [];

    for (final s in elements) {
      final newDate = s.start;
      if (splitter(newDate, currentDate)) {
        result.add(builder(currentDate, stats));
        currentDate = newDate;
        stats = [s];
      } else {
        stats.add(s);
      }
    }
    if (stats.isNotEmpty) {
      result.add(builder(currentDate, stats));
    }
  }
  return result;
}

abstract class StatsEntity {
  final DateTime time;
  final DailyBookingStatisticList statisticList;

  StatsEntity(this.time, this.statisticList);

  String get title;

  DateTime get start {
    var r = DateTime.now();
    for (final e in statisticList.elements) {
      if (e.start.isBefore(r)) r = e.start;
    }
    return r;
  }

  DateTime get end {
    var r = DateTime(1900); // ensure we have a very old date to begin with
    for (final e in statisticList.elements) {
      if (e.end.isAfter(r)) r = e.end;
    }
    return r;
  }
  @override
  String toString() {
    return '${runtimeType.toString()}[time=$time, statisticList=${statisticList.elements.length}]';
  }
}

class MonthOverviewStats extends StatsEntity {
  MonthOverviewStats(DateTime time, List<DailyBookingStatistic> elements)
      : super(time, DailyBookingStatisticList.of(elements));

  @override
  String get title => '${DateTimeUtil.formatWithString(time, 'MMMM')} - ${time.year}';

  static List<MonthOverviewStats> split(List<DailyBookingStatistic> elements) {
    return _split(elements,
            (newDate, currentDate) => currentDate.year != newDate.year
                || currentDate.month != newDate.month,
            (d, elements) => MonthOverviewStats(d, elements),);
  }
}

class WeekOverviewStats extends StatsEntity {
  @override
  String get title => 'KW ${time.weekOfYear} - ${statisticList.elements[0].start.year}';
  @override

  WeekOverviewStats(DateTime week, List<DailyBookingStatistic> elements)
      : super(week, DailyBookingStatisticList.of(elements));

  static List<WeekOverviewStats> split(List<DailyBookingStatistic> elements) {
    return _split(elements,
          (newDate, currentDate) => currentDate.year != newDate.year
            || currentDate.weekOfYear != newDate.weekOfYear,
          (d, elements) => WeekOverviewStats(d, elements),);
  }
}
