
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_entities/service/db_update.dart';

import 'map_db_v1.dart';

class MapDbV2 extends DbUpdate {

  MapDbV2() : super(2);

  @override
  Future<void> update(Database db) {
    return db.execute('DELETE FROM ${MapDbV1.tableName};');
  }
}