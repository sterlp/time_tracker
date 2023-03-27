import 'package:sqflite_entities/dao/abstract_map_dao.dart';
import 'package:sqflite_entities/entity/attached_map.dart';

class TimeTrackerConfig extends AttachedMap {
  TimeTrackerConfig(super.map, super.dao);

  static const dailyWorkHours = 'dailyWorkHours';
  static const exportCsvConfig = 'exportCsvConfig';

  Future<void> setExportCsvConfig(String config) {
    return setValue(exportCsvConfig, config);
  }
  Future<String?> getExportCsvConfig() {
    return getValue(exportCsvConfig);
  }

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
