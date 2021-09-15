import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_entities/dao/abstract_base_dao.dart';
import 'package:sqflite_entities/entity/abstract_entity.dart';
import 'package:sqflite_entities/entity/attached_entity.dart';

abstract class AbstractMapDao extends AbstractBaseDao<String> {

  final String valueColumnName;

  AbstractMapDao(Database db, String tableName,
      {String keyColumnName = 'key', this.valueColumnName = 'value'})
    : super(db, tableName, keyColumnName);


  Future<Map<String, String?>> loadAll({
    int? limit,
    int? offset}) async {

    final List<Map<String, dynamic>> results = await db.query(tableName,
        orderBy: keyColumnName, limit: limit, offset: offset);

    final result = <String, String?>{};
    for (final m in results) {
      if (m.isNotEmpty) {
        String? value;
        if (m[valueColumnName] != null) value = m[valueColumnName] as String;
        result[m[keyColumnName] as String] = value;
      }
    }
    return result;
  }

  Future<bool> setValue(String key, String? value) async {
    return await db.insert(tableName, {
      keyColumnName: key,
      valueColumnName: value
     },
     conflictAlgorithm: ConflictAlgorithm.replace) > 0;
  }
  Future<String?> getValue(String key) async {
    final List<Map<String, dynamic>> results = await db.query(
        tableName,
        where: "$keyColumnName = ?",
        whereArgs: [key]);
    assert(results.length <= 1, 'Get by ID should return only one element but returned ${results.length} elements.');
    if (results.isEmpty || results[0][valueColumnName] == null) {
      return null;
    } else {
      return results[0][valueColumnName] as String;
    }
  }

  Future<String> getValueWithDefault(String key, String defaultValue) async {
    return await getValue(key) ?? defaultValue;
  }

  Map<String, String> fromDb(Map<String, dynamic> dbValue) {
    return dbValue as Map<String, String>;
  }
}