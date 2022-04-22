import 'package:time_tracker/booking/entity/time_booking_statistics.dart';
import 'package:time_tracker/log/logger.dart';
import 'package:week_of_year/week_of_year.dart';

class WeekOverviewStats {
  static final _log = LoggerFactory.get<WeekOverviewStats>();
  final int week;
  final DailyBookingStatisticList statisticList;

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
      if (e.start.isAfter(r)) r = e.start;
    }
    return r;
  }
  @override
  String toString() {
    return 'WeekOverviewStats[week=$week, statisticList=${statisticList.elements.length}]';
  }

  WeekOverviewStats(this.week, List<DailyBookingStatistic> elements) :
    statisticList = DailyBookingStatisticList.of(elements);

  static List<WeekOverviewStats> split(List<DailyBookingStatistic> elements) {
    final List<WeekOverviewStats> result = [];

    if (elements.isNotEmpty) {
      var currentWeek = elements[0].start.weekOfYear;
      List<DailyBookingStatistic> week = [];

      for (DailyBookingStatistic s in elements) {
        final newWeek = s.start.weekOfYear;
        if (currentWeek == newWeek) {
          week.add(s);
          _log.debug('$newWeek -> $s');
        } else {
          // close this week stats
          final ws = WeekOverviewStats(currentWeek, week);
          result.add(ws);
          // we start a new one
          week = [];
          week.add(s);
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
