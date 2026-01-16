import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_entities/dao/abstract_dao.dart';
import 'package:sqflite_entities/entity/abstract_entity.dart';
import 'package:sqflite_entities/service/db_provider.dart';
import 'package:sqflite_entities/service/db_update.dart';

void main() {
  Database? db;
  _FooDao? subject;

  setUpAll(() async {
    sqfliteFfiInit();
    final database = databaseFactoryFfi.openDatabase(inMemoryDatabasePath);

    final dbProvider = DbProvider.withDb(database, [_DbV1(), _DbV2()]);
    db = await dbProvider.init();
    assert(db != null);
  });
  setUp(() async {
    await db!.execute("DELETE FROM FOO_TABLE");
    subject = _FooDao(db!);
  });

  tearDownAll(() async {
    if (db != null) await db!.close();
  });

  test('Test CREATE and GET', () async {
    // GIVEN: we save something
    final f = await subject!.save(_FooBE(name: 'hallo'));

    // WHEN it should be saved
    expect(f.id, isNotNull);
    expect(f.name, 'hallo');

    // THEN
    final loaded = await subject!.getById(f.id!);
    expect(loaded, isNotNull);
    expect(loaded!.id, f.id);
    expect(loaded.name, f.name);
  });

  test('Test DELETE', () async {
    var f = await subject!.save(_FooBE(name: 'hallo'));
    expect(f.id, isNotNull);
    expect(await subject!.countAll(), 1);

    f = await subject!.deleteEntity(f);
    expect(f.id, isNull);
    expect(await subject!.countAll(), 0);

    f = await subject!.deleteEntity(f);
    expect(f, f);

    f = await subject!.save(_FooBE(name: 'hallo'));
    final deleteCount = await subject!.delete(f.id);
    expect(deleteCount, 1);
    expect(await subject!.countAll(), 0);
  });

  test('Test UPDATE', () async {
    final orig = await subject!.save(_FooBE(name: 'hallo'));

    orig.name = 'nix da';
    final saved = await subject!.save(orig);
    expect(await subject!.countAll(), 1);
    expect(saved.name, 'nix da');
    expect(saved.id, orig.id);
  });

  test('Test countAll', () async {
    expect(await subject!.countAll(), 0);

    for (int i = 0; i < 10; ++i) {
      await subject!.save(_FooBE(name: 'hallo $i'));
    }

    expect(await subject!.countAll(), 10);

    expect(await subject!.deleteAll(), 10);
    expect(await subject!.countAll(), 0);
  });

  test('Test attached CRUD', () async {
    final rattlinger = subject!.attach(_FooBE(name: 'Rattlinger'));
    final paul = subject!.attach(_FooBE(name: 'Paul'));

    expect(await subject!.countAll(), 0);

    await rattlinger.save();
    expect(await subject!.countAll(), 1);

    await paul.save();
    expect(await subject!.countAll(), 2);

    await paul.delete();
    expect(paul.isDeleted(), true);
    expect(await subject!.countAll(), 1);

    await rattlinger.delete();
    expect(await subject!.countAll(), 0);

    await paul.save();
    expect(await subject!.countAll(), 1);
    expect(paul.isDeleted(), false);
  });
}

class _FooBE extends AbstractEntity {
  String? name;

  _FooBE({this.name});
}

class _FooDao extends AbstractDao<_FooBE> {
  _FooDao(Database db) : super(db, "FOO_TABLE");

  @override
  _FooBE fromMap(Map<String, dynamic> values) {
    final result = _FooBE();
    result.id = values['id'] as int;
    result.name = values['name'] as String;
    return result;
  }

  @override
  Map<String, dynamic> toMap(_FooBE value) {
    return {
      'id': value.id,
      'name': value.name,
    };
  }
}

class _DbV1 extends DbUpdate {
  _DbV1() : super(1);

  @override
  Future<void> update(Database db) {
    return db.execute('''
CREATE TABLE IF NOT EXISTS FOO_TABLE (
  id integer PRIMARY KEY AUTOINCREMENT,
  name text
);''');
  }
}

class _DbV2 extends DbUpdate {
  _DbV2() : super(2);

  @override
  Future<void> update(Database db) {
    return db.execute("DELETE FROM FOO_TABLE");
  }
}
