import 'package:time_tracker/db/db_v3.dart';
import 'package:time_tracker/tag/entity/tag.dart';

/// Represents a tag assignment to a specific day
class DayTag {
  final String day; // ISO date string (e.g., "2024-01-15")
  final int tagId;
  final Tag? tag; // Optionally loaded

  DayTag(this.day, this.tagId, {this.tag});

  DayTag.fromMap(Map<String, dynamic> map, {Tag? loadedTag})
      : day = map[DbTagTablesV3.dayTagDay] as String,
        tagId = map[DbTagTablesV3.dayTagTagId] as int,
        tag = loadedTag;

  @override
  String toString() => 'DayTag[day=$day, tagId=$tagId]';
}
