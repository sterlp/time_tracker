
DateTime dateTimePrecisionMilliseconds(DateTime now) {
  return DateTime(now.year, now.month, now.day, now.hour, now.minute, now.second, now.millisecond);
}

DateTime dateTimePrecisionSeconds(DateTime now) {
  return DateTime(now.year, now.month, now.day, now.hour, now.minute, now.second);
}

DateTime dateTimePrecisionMinutes(DateTime now) {
  return DateTime(now.year, now.month, now.day, now.hour, now.minute);
}