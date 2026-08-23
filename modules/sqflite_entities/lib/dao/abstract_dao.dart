import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_entities/entity/abstract_entity.dart';
import 'package:sqflite_entities/entity/attached_entity.dart';

/// Base DAO with int ID. For other ID types, use [AbstractDao].
typedef IntDao<T extends AbstractEntity<int>> = AbstractDao<int, T>;
typedef StringDao<T extends AbstractEntity<String>> = AbstractDao<String, T>;

abstract class AbstractDao<E, T extends AbstractEntity<E>> {
  final Database _db;
  final String tableName;
  final String idColumn;

  AbstractDao(this._db, this.tableName, {this.idColumn = 'id'});

  @protected
  Database get db => _db;

  AttachedEntity<T> attach(T entity) {
    return AttachedEntity<T>(entity, reload, save, deleteEntity);
  }

  Future<AttachedEntity<T>?> getAttached(E id) async {
    final e = await getById(id);
    if (e == null)
      return null;
    else
      return this.attach(e);
  }

  Future<T?> reload(T e) async {
    if (e.id == null)
      return null;
    else
      return getById(e.id!);
  }

  Future<T?> getById(E id) async {
    final List<Map<String, dynamic>> results = await _db.query(
      tableName,
      where: "$idColumn = ?",
      whereArgs: [id],
    );
    assert(
      results.length <= 1,
      'Get by ID should return only one element but returned ${results.length} elements.',
    );
    return results.isEmpty ? null : fromMap(results[0]);
  }

  Future<List<T>> loadAll({
    bool? distinct,
    String? where,
    List<dynamic>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final List<Map<String, dynamic>> results = await _db.query(
      tableName,
      distinct: distinct,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );

    return results.map((e) => fromMap(e)).toList();
  }

  Future<int> deleteAll() {
    return _db.delete(tableName);
  }

  Future<int> delete(E? id) async {
    if (id == null) return 0;
    return _db.delete(tableName, where: "$idColumn = ?", whereArgs: [id]);
  }

  Future<T> deleteEntity(T e) async {
    if (e.id == null) return SynchronousFuture(e);
    await delete(e.id);
    e.id = null;
    return e;
  }

  Future<List<T>> saveAll(List<T> entities) async {
    for (final e in entities) await save(e);
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
    final int newId = await db.insert(
      tableName,
      toMap(entity),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    if (entity.id is int?) entity.id = newId as E;
    return entity;
  }

  Future<T> update(T entity) async {
    assert(entity.id != null);

    final int count = await _db.update(
      tableName,
      toMap(entity),
      where: "$idColumn = ?",
      whereArgs: [entity.id],
    );
    if (count == 0) {
      print('Record not found anymore to update $entity adding again ...');
      return insert(entity);
    }

    return entity;
  }

  Future<int> countAll() async {
    final r = await _db.rawQuery("SELECT COUNT(1) as result FROM $tableName");
    return Sqflite.firstIntValue(r) ?? 0;
  }

  T fromMap(Map<String, dynamic> values);
  Map<String, dynamic> toMap(T value);
}
