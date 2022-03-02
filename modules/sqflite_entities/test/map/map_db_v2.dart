
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_entities/service/db_update.dart';

import 'map_db_v1.dart';

class MapDbV2 extends DbUpdate {

  MapDbV2() : super(2);

  @override
  Future<void> update(Database db) async {
    await db.execute('INSERT INTO ${MapDbV1.tableName} VALUES ("key1", "value1")');
    await db.execute('INSERT INTO ${MapDbV1.tableName} VALUES ("key2", "value2")');
    await db.execute('INSERT INTO ${MapDbV1.tableName} VALUES ("key3", null)');
  }
}