
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_entities/dao/abstract_map_dao.dart';
import 'package:sqflite_entities/entity/attached_map.dart';
import 'package:sqflite_entities/service/db_provider.dart';

import '../map/map_db_v1.dart';
import '../map/map_db_v2.dart';

void main() {

  DbProvider? dbProvider;
  Database? db;

  setUp(() async {
    sqfliteFfiInit();
    final database = databaseFactoryFfi.openDatabase(inMemoryDatabasePath);

    dbProvider = DbProvider.withDb(database, [MapDbV1(), MapDbV2()]);
    db = await dbProvider!.init();
  });

  tearDown(() async {
    await dbProvider?.close();
  });

  test('Test CRUD', () async {
      final dao = _TestMapDao(db!);
      var attachedMap = AttachedMap({}, dao);

      // CREATE
      await attachedMap.setValue('foo', 'baar');
      expect(await dao.countAll(), 1);
      expect(await dao.getValue('foo'), 'baar');

      await attachedMap.setValue('foo2', 'baar2');
      expect(await dao.countAll(), 2);

      // UPDATE
      await attachedMap.setValue('foo', 'baar2');
      expect(await dao.countAll(), 2);
      expect(await dao.getValue('foo'), 'baar2');

      // READ
      attachedMap = AttachedMap({}, dao);
      expect(await attachedMap.getValue('foo'), 'baar2');
      expect(await attachedMap.getValue('foo2'), 'baar2');

      // DELETE
      await attachedMap.delete('foo');
      expect(await dao.countAll(), 1);
      expect(await dao.getValue('foo'), isNull);
  });


}

class _TestMapDao extends AbstractMapDao {
  _TestMapDao(Database db) : super(db, MapDbV1.tableName);
}
