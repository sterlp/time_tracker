import 'package:sqflite_entities/dao/abstract_map_dao.dart';
import 'package:sqflite_entities/entity/attached_map.dart';

class TimeTrackerConfig extends AttachedMap {
  TimeTrackerConfig(Map<String, String?> map, AbstractMapDao dao) : super(map, dao);

  static const dailyWorkHours = 'dailyWorkHours';

  Future<void> setDailyWorkHours(Duration workTime) {
    return setValue(dailyWorkHours, '${workTime.inMinutes}');
  }
  Duration getDailyWorkHours() {
    final stringDuration = value[dailyWorkHours];
    Duration result = const Duration(hours: 8);
    if (stringDuration != null) result = Duration(minutes: int.parse(stringDuration));
    return result;
  }
}
