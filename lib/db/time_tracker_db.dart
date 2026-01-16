

import 'package:sqflite/sqflite.dart';
import 'package:sqflite_entities/service/db_provider.dart';
import 'package:time_tracker/db/db_v1.dart';
import 'package:time_tracker/db/db_v2.dart';

final _dbUpdates = [
  DbConfigV1(),
  DbBookingTableV2(),
];

Future<DbProvider> initDb({Future<Database>? testDb}) async {
  DbProvider result;
  if (testDb == null) result = DbProvider('time_tracker.db', _dbUpdates);
  else result = DbProvider.withDb(testDb, _dbUpdates);
  return result;
}
