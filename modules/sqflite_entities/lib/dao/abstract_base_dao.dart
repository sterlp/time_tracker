import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_entities/entity/abstract_entity.dart';
import 'package:sqflite_entities/entity/attached_entity.dart';

abstract class AbstractBaseDao<KeyType> {
  final Database _db;
  final String tableName;
  final String keyColumnName;

  AbstractBaseDao(this._db, this.tableName, this.keyColumnName);

  Database get db => _db;

  Future<int> deleteAll() async {
    return _db.delete(tableName);
  }

  Future<int> delete(KeyType id) async {
    if (id == null) return 0;
    return _db.delete(tableName, where: "$keyColumnName = ?", whereArgs: [id]);
  }

  Future<int> countAll() async {
    final r = await _db.rawQuery("SELECT COUNT(1) as result FROM $tableName");
    return Sqflite.firstIntValue(r) ?? 0;
  }
}