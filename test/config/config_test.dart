
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_entities/service/db_provider.dart';
import 'package:time_tracker/config/dao/config_dao.dart';
import 'package:time_tracker/config/entity/config_entity.dart';
import 'package:time_tracker/db/db_v1.dart';

void main() {
  DbProvider? dbProvider;
  Database? db;

  setUpAll(() async {
    sqfliteFfiInit();
    final database = databaseFactoryFfi.openDatabase(inMemoryDatabasePath);

    dbProvider = DbProvider.withDb(database, [DbConfigV1()]);
    db = await dbProvider!.init();
  });

  tearDownAll(() async {
    await dbProvider?.close();
  });

  test('Test ConfigService defaults', () async {
    final subject = ConfigDao(db!);
    
    final config = await subject.loadConfig();
    expect(config.getDailyWorkHours(), 8);
    expect(config.getWeeklyWorkHours(), 40);
  });

  test('Test change config', () async {

    final subject = ConfigDao(db!);
    var config = await subject.loadConfig();

    await config.setDailyWorkHours(6);
    await config.setWeeklyWorkHours(30);

    config = await subject.loadConfig();
    expect(config.getDailyWorkHours(), 6);
    expect(config.getWeeklyWorkHours(), 30);
  });
}