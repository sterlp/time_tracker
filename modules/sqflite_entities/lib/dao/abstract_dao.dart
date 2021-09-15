import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_entities/entity/abstract_entity.dart';
import 'package:sqflite_entities/entity/attached_entity.dart';

abstract class AbstractDao<T extends AbstractEntity> {
  final Database _db;
  final String tableName;

  AbstractDao(this._db, this.tableName);

  @protected
  Database get db => _db;

  AttachedEntity<T> attach(T entity) {
    return AttachedEntity<T>(entity,
      reload, save, deleteEntity);
  }

  Future<AttachedEntity<T>?> getAttached(int id) async {
    final e = await getById(id);
    if (e == null) return null;
    else return this.attach(e);
  }

  Future<T?> reload(T e) async {
    if (e.id == null) return null;
    else return getById(e.id!);
  }

  Future<T?> getById(int id) async {
    final List<Map<String, dynamic>> results = await _db.query(
        tableName,
        where: "id = ?",
        whereArgs: [id]);
    assert(results.length <= 1, 'Get by ID should return only one element but returned ${results.length} elements.');
    return results.isEmpty ? null : fromMap(results[0]);
  }

  Future<List<T>> loadAll({bool? distinct,
      String? where,
      List<dynamic>? whereArgs,
      String? groupBy,
      String? having,
      String? orderBy,
      int? limit,
      int? offset}) async {

    final List<Map<String, dynamic>> results = await _db.query(tableName,
        where: where, whereArgs: whereArgs, groupBy: groupBy, having: having,
        orderBy: orderBy, limit: limit, offset: offset);

    return results.map((e) => fromMap(e)).toList();
  }

  Future<int> deleteAll() async {
    return _db.delete(tableName);
  }

  Future<int> delete(int? id) async {
    if (id == null) return 0;

    return _db.delete(tableName, where: "id = ?", whereArgs: [id]);
  }

  Future<T> deleteEntity(T e) async {
    if (e.id == null) return SynchronousFuture(e);
    await delete(e.id);
    e.id = null;
    return e;
  }

  Future<List<T>> saveAll(List<T> entities) async {
    for(final e in entities) await save(e);
    return entities;
  }

  ///
  /// Checks if the id is set of the entity and either calls insert or update
  ///
  Future<T> save(T entity) async {
    T result;
    if (entity.id == null) {
      result = await insert(entity);
    } else {
      result = await update(entity);
    }
    return result;
  }
  Future<T> insert(T entity) async {
    entity.id = await _db.insert(tableName, toMap(entity),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return entity;
  }
  Future<T> update(T entity) async {
    assert(entity.id != null);

    await _db.update(tableName, toMap(entity), where: "id = ?", whereArgs: [entity.id]);
    // if (count == 0) _log.warn('Record not found anymore to update $entity');

    return entity;
  }

  Future<int> countAll() async {
    final r = await _db.rawQuery("SELECT COUNT(1) as result FROM $tableName");
    return Sqflite.firstIntValue(r) ?? 0;
  }

  T fromMap(Map<String, dynamic> values);
  Map<String, dynamic> toMap(T value);
}