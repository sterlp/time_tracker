import 'package:flutter/foundation.dart';
import 'package:sqflite_entities/entity/abstract_entity.dart';

typedef AttachedEntityAction<T> = Future<T?> Function(T value);

class AttachedEntity<Entity extends AbstractEntity>
    extends ValueNotifier<Entity> {
  final AttachedEntityAction<Entity> doReloadCallback;
  final AttachedEntityAction<Entity> doSaveCallback;
  final AttachedEntityAction<Entity> doDeleteCallback;

  bool _deleted = false;

  AttachedEntity(
    Entity entity,
    this.doReloadCallback,
    this.doSaveCallback,
    this.doDeleteCallback,
  ) : super(entity);

  bool isDeleted() => _deleted;

  Future<Entity> reload() async {
    final e = await doReloadCallback(value);
    if (e == null) {
      value.id = null;
      _deleted = true;
      notifyListeners();
    } else {
      value = e;
    }
    return value;
  }

  Future<Entity> save() async {
    final e = await doSaveCallback(value);
    _deleted = false;
    _updateValue(e);
    return value;
  }

  Future<Entity> delete() async {
    _deleted = true;
    await doDeleteCallback(value);
    value.id = null;
    notifyListeners();
    return value;
  }

  void _updateValue(Entity? e) {
    if (e == null || e.id == null) {
      value.id = null;
      _deleted = true;
      notifyListeners();
    } else {
      // TODO: broken as we compare with ID!
      final notificationNeeded = e == value;
      value = e;
      if (notificationNeeded) notifyListeners();
    }
  }
}
