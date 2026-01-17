import 'package:flutter/material.dart';
import 'package:sqflite_entities/entity/abstract_entity.dart';
import 'package:time_tracker/db/db_v3.dart';

class Tag extends AbstractEntity {
  String name;
  Color? color;

  Tag(this.name, {this.color});

  Tag.fromMap(Map<String, dynamic> map)
      : name = map[DbTagTablesV3.tagName] as String,
        color = _parseColor(map[DbTagTablesV3.tagColor] as String?) {
    id = map[DbTagTablesV3.tagId] as int?;
  }

  Map<String, dynamic> toMap() {
    return {
      DbTagTablesV3.tagId: id,
      DbTagTablesV3.tagName: name,
      DbTagTablesV3.tagColor: _colorToHex(color),
    };
  }

  static Color? _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final hexCode = hex.replaceFirst('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  static String? _colorToHex(Color? color) {
    if (color == null) return null;
    final argb = color.toARGB32();
    return '#${argb.toRadixString(16).substring(2).toUpperCase()}';
  }

  @override
  String toString() => 'Tag[id=$id, name=$name]';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tag && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
