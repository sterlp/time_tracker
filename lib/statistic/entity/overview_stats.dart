import 'package:time_tracker/booking/entity/time_booking_statistics.dart';
import 'package:week_of_year/week_of_year.dart';

abstract class StatsEntity {
  final DailyBookingStatisticList statisticList;
  StatsEntity(this.statisticList);

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
}

class MonthOverviewStats extends StatsEntity {
  final int month;
  MonthOverviewStats(this.month, List<DailyBookingStatistic> elements) :
        super(DailyBookingStatisticList.of(elements));

  @override
  String get title => '$month - ${statisticList.elements[0].start.year}';

  static List<MonthOverviewStats> split(List<DailyBookingStatistic> elements) {
    final List<MonthOverviewStats> result = [];

    if (elements.isNotEmpty) {
      var month = elements[0].start.month;
      List<DailyBookingStatistic> stats = [];
      for (final s in elements) {
        final newMonth = s.start.month;
        if (month == newMonth) {
          stats.add(s);
        } else {
          result.add(MonthOverviewStats(month, stats));
          month = newMonth;
          stats = [s];
        }
      }
    }
    return result;
  }
}
class WeekOverviewStats extends StatsEntity {
  final int week;
  @override
  String get title => 'KW $week - ${statisticList.elements[0].start.year}';
  @override
  String toString() {
    return 'WeekOverviewStats[week=$week, statisticList=${statisticList.elements.length}]';
  }

  WeekOverviewStats(this.week, List<DailyBookingStatistic> elements) :
    super(DailyBookingStatisticList.of(elements));

  static List<WeekOverviewStats> split(List<DailyBookingStatistic> elements) {
    final List<WeekOverviewStats> result = [];

    if (elements.isNotEmpty) {
      var currentWeek = elements[0].start.weekOfYear;
      List<DailyBookingStatistic> week = [];

      for (final s in elements) {
        final newWeek = s.start.weekOfYear;
        if (currentWeek == newWeek) {
          week.add(s);
        } else {
          // close this week stats
          final ws = WeekOverviewStats(currentWeek, week);
          result.add(ws);
          // we start a new one
          week = [s];
          currentWeek = newWeek;
        }
      }
      // if something is left, add it as last week
      if (week.isNotEmpty) {
        result.add(WeekOverviewStats(currentWeek, week));
      }
    }
    return result;
  }
}
