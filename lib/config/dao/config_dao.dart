import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_entities/dao/abstract_map_dao.dart';
import 'package:time_tracker/config/entity/config_entity.dart';
import 'package:time_tracker/db/db_v1.dart';

class ConfigDao extends AbstractMapDao {
  ConfigDao(Database db) : super(db, DbConfigV1.table);

  Future<TimeTrackerConfig> loadConfig() async {
    final config = await loadAll();
    return TimeTrackerConfig(config, this);
  }
}