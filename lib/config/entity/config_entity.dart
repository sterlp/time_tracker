
import 'package:sqflite_entities/dao/abstract_map_dao.dart';
import 'package:sqflite_entities/entity/attached_map.dart';

class TimeTrackerConfig extends AttachedMap {
  TimeTrackerConfig(Map<String, String?> map, AbstractMapDao dao) : super(map, dao);

  static const _dailyWorkHours = 'dailyWorkHours';

  Future<void> setDailyWorkHours(int hours) {
    return setValue(_dailyWorkHours, hours.toString());
  }
  int getDailyWorkHours() {
    return int.parse(value[_dailyWorkHours] ?? '8');
  }
}
