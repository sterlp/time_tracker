import 'package:flutter/foundation.dart';
import 'package:sqflite_entities/dao/abstract_map_dao.dart';

class AttachedMap
    extends ValueNotifier<Map<String, String?>> {

  final AbstractMapDao dao;

  AttachedMap(Map<String, String?> map, this.dao) : super(map);

  Future<Map<String, String?>> reload() async {
    final e = await dao.loadAll();
    return value = e;
  }

  Future<String?> setValue(String key, String? inValue) async {
    if (this.value[key] != inValue) {
      this.value[key] = inValue;
      notifyListeners();

      if (await dao.setValue(key, inValue)) {
        return inValue;
      } else {
        throw 'Failed to set $key to $inValue';
      }
    } else {
      return inValue;
    }
  }

  Future<String?> getValue(String key) async {
    var result = value[key];
    if (result == null) {
      result = await dao.getValue(key);
      value[key] = result;
    }
    return result;
  }

  Future<String> getValueWithDefault(String key, String defaultValue) async {
    var result = value[key];
    if (result == null) {
      result = await dao.getValueWithDefault(key, defaultValue);
      value[key] = result;
    }
    return result;
  }

  Future<void> delete(String key) {
    this.value[key] = null;
    return dao.delete(key);
   }
}
