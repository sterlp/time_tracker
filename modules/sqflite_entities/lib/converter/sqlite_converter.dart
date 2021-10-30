
int? dateTimeToInt(DateTime? v) {
  if (v == null) return null;
  return v.millisecondsSinceEpoch;
}
DateTime? parseDateTime(dynamic v) {
  DateTime? result;
  if (v == null) {
    result = null;
  } else if (v is DateTime) {
    result = v;
  } else if (v is String) {
    result = DateTime.fromMillisecondsSinceEpoch(int.parse(v));
  } else {
    result = DateTime.fromMillisecondsSinceEpoch(v as int);
  }
  return result;
}

/// Returns the value of an ENUM as String, otherwise null.
String? enumToString(dynamic e) => e?.toString().split('.').last;
/// Returns the first matching ENUM to the given String
T? parseEnum<T>(String? v, List<T> enumValues) {
  if (v == null) return null;
  return enumValues.firstWhere((e) => enumToString(e) == v);
}
/// Returns the first matching ENUM to the given String, otherwise the default value.
T parseEnumWithDefault<T>(String? v, T defaultValue, List<T> enumValues) {
  if (v == null) return defaultValue;
  return enumValues.firstWhere((e) => enumToString(e) == v, orElse: () => defaultValue);
}