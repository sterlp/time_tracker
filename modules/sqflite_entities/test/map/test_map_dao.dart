import 'package:sqflite/sqflite.dart';
import 'package:sqflite_entities/dao/abstract_map_dao.dart';

import 'map_db_v1.dart';

class TestMapDao extends AbstractMapDao {
  TestMapDao(Database db)
      : super(
          db,
          MapDbV1.tableName,
          keyColumnName: MapDbV1.keyColumn,
          valueColumnName: MapDbV1.valueColumn,
        );
}
