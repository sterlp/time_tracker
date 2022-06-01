
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_entities/service/db_update.dart';

class MapDbV1 extends DbUpdate {
  static const String tableName = 'MAP_TABLE';
  static const String keyColumn = 'key';
  static const String valueColumn = 'value';

  MapDbV1() : super(1);
  @override
  Future<void> update(Database db) {
    return db.execute('''
CREATE TABLE IF NOT EXISTS $tableName (
  $keyColumn varchar(16) PRIMARY KEY,
  $valueColumn text
);''',);
  }
}
