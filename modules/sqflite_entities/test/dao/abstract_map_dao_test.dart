
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_entities/service/db_provider.dart';

import '../map/map_db_v1.dart';
import '../map/map_db_v2.dart';
import '../map/test_map_dao.dart';

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

  test('Test count and delete', () async {
    final subject = TestMapDao(db!);

    expect(await subject.countAll(), 2);

    expect(await subject.deleteAll(), 2);
    expect(await subject.countAll(), 0);
  });

  test('Test get Value', () async {
    final subject = TestMapDao(db!);

    expect(await subject.getValue('key1'), 'value1');
    expect(await subject.getValue('key2'), 'value2');
    expect(await subject.getValue('key3'), isNull);
  });

  test('Test Set and Get Value', () async {
    final subject = TestMapDao(db!);

    expect(await subject.setValue('key3', 'value3'), true);
    expect(await subject.getValue('key3'), 'value3');

    expect(await subject.setValue('key1', 'value3'), true);
    expect(await subject.getValue('key1'), 'value3');

    expect(await subject.setValue('key3', 'rattlinger'), true);
    expect(await subject.getValue('key3'), 'rattlinger');
  });

  test('Map load all', () async {
    final subject = TestMapDao(db!);

    await subject.setValue('key3', null);
    final m = await subject.loadAll();

    expect(m.length, 3);
    expect(m['key1'], 'value1');
    expect(m['key2'], 'value2');
    expect(m['key3'], isNull);
  });

  test('Test getValueWithDefault', () async {
    final subject = TestMapDao(db!);

    expect(await subject.getValueWithDefault('foobar', 'a'), 'a');

    expect(await subject.getValueWithDefault('key1', 'a'), 'value1');
    await subject.setValue('key1', null);
    expect(await subject.getValueWithDefault('key1', 'a'), 'a');
  });
}