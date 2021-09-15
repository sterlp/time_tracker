import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_entities/service/db_update.dart';

class DbProvider {
  final Future<Database>? _futureDb;
  Database? _db;
  final String dbName;
  final List<DbUpdate> updates;
  final int version;

  //Future<Database> get db => _completer.future;

  DbProvider(this.dbName, this.updates, {this.version = 99999}) : this._futureDb = null;

  DbProvider.withDb(Future<Database> database, this.updates, {this.version = 99999})
      : this.dbName = 'testDB', this._futureDb = database;

  Future<Database> init() async {
    _db ??= await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final _completer = Completer<Database>();
    Database db;
    try {
      if (_futureDb == null) {
        // await deleteDatabase(join(await getDatabasesPath(), dbName));
        db = await openDatabase(join(await getDatabasesPath(), dbName), version: version, onUpgrade: _createDB);
      } else {
        db = await _createDB(await _futureDb!, 0, version);
      }
      _completer.complete(db);
    } on Exception catch (e, stack) {
      print('Failed to load DB $e\n$stack');
      _completer.completeError(e);
    }
    return _completer.future;
  }

  Future<Database> _createDB(Database db, int oldVersion, int newVersion) async {
    if (kDebugMode) print('DEBUG: createDB from version $oldVersion to $newVersion');
    for (final update in this.updates) {
      try {
        oldVersion = await update.execute(oldVersion, db);
      } catch (e, stack) {
        if (kDebugMode) print('ERROR: Failed to apply update $oldVersion -> $e\n$stack');
        rethrow;
      }
    }
    return db;
  }

  Future<void> close() async {
    if (_db != null)  {
      return await (await _db!).close();
    }
  }
}
