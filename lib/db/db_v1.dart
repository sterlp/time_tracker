
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_entities/service/db_update.dart';

class DbConfigV1 extends DbUpdate {
  static const String table = 'CONFIG';

  DbConfigV1() : super(1);

  @override
  Future<void> update(Database db) {
    return db.execute('''
CREATE TABLE IF NOT EXISTS $table (
  key varchar(16) PRIMARY KEY,
  value text
);''');
  }

}