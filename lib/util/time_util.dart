
int durationToMinutes(Duration? d) {
  if (d == null) return 0;
  else {
    return d.inMinutes;
  }
}

/// Returns the [duration] as <b>HH:mm</b> <code>String</code>.
String toHoursAndMinutes(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes - hours * 60;
  return '${_padWith0(hours)}:${_padWith0(minutes)}';
}

/// Returns the time as <b>00:00</b>
String toHoursWithMinutes(DateTime? time) {
  if (time == null) return '';
  else {
    return '${_padWith0(time.hour)}:${_padWith0(time.minute)}';
  }
}
/// h Std m Min
String toDurationHoursAndMinutes(Duration? inDuration) {
  final duration = inDuration ?? Duration.zero;
  final minutes = duration.inMinutes - duration.inHours * 60;
  return '${duration.inHours} Std $minutes Min';
}

String _padWith0(int value) {
  return value.toString().padLeft(2, '0');
}
