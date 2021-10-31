
class DailyBookingStatistic {
  final String day;
  final DateTime start;
  final DateTime? end;
  final Duration workedTime;
  final Duration planedWorkTime;

  static Duration sumWorkedTime(List<DailyBookingStatistic> elements) {
    return elements.map((e) => e.workedTime).reduce((v, e) => v + e);
  }
  static Duration sumOverHours(List<DailyBookingStatistic> elements) {
    return elements.map((e) => e.overHours).reduce((v, e) => v + e);
  }
  static Duration sumBreakTime(List<DailyBookingStatistic> value) {
    return value.map((e) => e.breakTime).reduce((v, e) => v + e);
  }
  DailyBookingStatistic(this.day,
      this.start,
      this.end,
      this.workedTime,
      this.planedWorkTime);

  Duration get overHours => workedTime - planedWorkTime;
  Duration get breakTime => (end ?? DateTime.now()).difference(start) - workedTime;
}