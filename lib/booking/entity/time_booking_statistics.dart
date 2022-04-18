
class DailyBookingStatistic {
  final String day;
  final DateTime start;
  final DateTime end;
  final Duration workedTime;
  final Duration planedWorkTime;

  DailyBookingStatistic(this.day,
      this.start,
      this.end,
      this.workedTime,
      this.planedWorkTime);

  Duration get overHours => workedTime - planedWorkTime;
  Duration get breakTime => end.difference(start) - workedTime;
}

class DailyBookingStatisticList {
  List<DailyBookingStatistic> _elements = [];
  Duration _sumWorkedTime = Duration.zero;
  Duration _sumOverHours = Duration.zero;
  Duration _sumBreakTime = Duration.zero;

  Duration get sumWorkedTime => _sumWorkedTime;
  Duration get sumOverHours => _sumOverHours;
  Duration get sumBreakTime => _sumBreakTime;
  int get count => _elements.length;

  Duration get avgWorkTime => count > 0
      ? Duration(minutes: (_sumWorkedTime.inMinutes / count).round())
      : Duration.zero;
  Duration get avgBreakTime => count > 0
      ? Duration(minutes: (_sumBreakTime.inMinutes / count).round())
      : Duration.zero;

  DailyBookingStatisticList.of(List<DailyBookingStatistic> elements) {
    _elements = elements;

    for(DailyBookingStatistic e in elements) {
      _sumWorkedTime += e.workedTime;
      _sumOverHours += e.overHours;
      _sumBreakTime += e.breakTime;
    }
  }
}

