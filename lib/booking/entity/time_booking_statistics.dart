
import 'package:sqflite_entities/converter/date_util.dart';

class DailyBookingStatistic {
  final String day;
  final DateTime start;
  final DateTime end;
  final Duration workedTime;
  final Duration planedWorkTime;
  final int bookingsCount;

  DailyBookingStatistic(this.day,
      this.start,
      this.end,
      this.workedTime,
      this.planedWorkTime,
      this.bookingsCount);

  DailyBookingStatistic.ofStartAndDuration(this.start, Duration duration)
    : day = DateTimeUtil.formatWithString(start, 'yyyy-MM-dd'),
      end = start.add(duration),
      workedTime = duration,
      planedWorkTime = const Duration(hours: 8),
      bookingsCount = 1;

  Duration get overHours => workedTime - planedWorkTime;
  Duration get breakTime => end.difference(start) - workedTime;

  @override
  String toString() {
    return 'DailyBookingStatistic[start=$start, end=$end, workedTime=$workedTime]';
  }
}

class DailyBookingStatisticList {
  List<DailyBookingStatistic> _elements = [];
  Duration _sumWorkedTime = Duration.zero;
  Duration _sumPlannedWorkTime = Duration.zero;
  Duration _sumOverHours = Duration.zero;
  Duration _sumBreakTime = Duration.zero;

  Duration get sumWorkedTime => _sumWorkedTime;
  Duration get sumOverHours => _sumOverHours;
  Duration get sumBreakTime => _sumBreakTime;
  Duration get sumPlannedWorkTime => _sumPlannedWorkTime;

  int get count => _elements.length;
  List<DailyBookingStatistic> get elements => _elements;

  Duration get avgWorkTime => count > 0
      ? Duration(minutes: (_sumWorkedTime.inMinutes / count).round())
      : Duration.zero;
  Duration get avgPlannedWorkTime => count > 0
      ? Duration(minutes: (_sumPlannedWorkTime.inMinutes / count).round())
      : Duration.zero;
  Duration get avgBreakTime => count > 0
      ? Duration(minutes: (_sumBreakTime.inMinutes / count).round())
      : Duration.zero;

  DailyBookingStatisticList.of(List<DailyBookingStatistic> v) {
    _elements = v;

    for(final e in _elements) {
      _sumWorkedTime += e.workedTime;
      _sumOverHours += e.overHours;
      _sumBreakTime += e.breakTime;
      _sumPlannedWorkTime += e.planedWorkTime;
    }
  }
}
