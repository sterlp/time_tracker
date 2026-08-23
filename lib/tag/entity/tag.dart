import 'package:flutter/material.dart';
import 'package:sqflite_entities/entity/abstract_entity.dart';
import 'package:time_tracker/db/db_v3.dart';

class Tag extends AbstractEntity<String> {
  Color color;

  Tag(String name, this.color) : super(name);

  Tag.fromMap(Map<String, dynamic> map)
      : color = Color(map[DbTagTablesV3.tagColor] as int? ?? 0),
        super(map[DbTagTablesV3.tagName] as String);

  Map<String, dynamic> toMap() {
    return {
      DbTagTablesV3.tagName: id,
      DbTagTablesV3.tagColor: color.toARGB32(),
    };
  }

  @override
  String toString() => 'Tag[$id]';

}
