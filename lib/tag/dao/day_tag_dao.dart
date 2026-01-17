import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:time_tracker/db/db_v3.dart';
import 'package:time_tracker/tag/entity/tag.dart';
import 'package:time_tracker/tag/entity/tag_statistic.dart';

class DayTagDao {
  final Database db;

  DayTagDao(this.db);

  /// Add a tag to a day
  Future<void> addTagToDay(String day, int tagId) async {
    await db.insert(
      DbTagTablesV3.dayTagTable,
      {
        DbTagTablesV3.dayTagDay: day,
        DbTagTablesV3.dayTagTagId: tagId,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// Remove a tag from a day
  Future<int> removeTagFromDay(String day, int tagId) {
    return db.delete(
      DbTagTablesV3.dayTagTable,
      where: '${DbTagTablesV3.dayTagDay} = ? AND ${DbTagTablesV3.dayTagTagId} = ?',
      whereArgs: [day, tagId],
    );
  }

  /// Get all tags for a specific day
  Future<List<Tag>> getTagsForDay(String day) async {
    final results = await db.rawQuery('''
      SELECT t.* FROM ${DbTagTablesV3.tagTable} t
      INNER JOIN ${DbTagTablesV3.dayTagTable} dt ON t.${DbTagTablesV3.tagId} = dt.${DbTagTablesV3.dayTagTagId}
      WHERE dt.${DbTagTablesV3.dayTagDay} = ?
      ORDER BY t.${DbTagTablesV3.tagName} ASC
    ''', [day]);
    return results.map((e) => Tag.fromMap(e)).toList();
  }

  /// Get all days with a specific tag within date range
  Future<List<String>> getDaysWithTag(int tagId, {DateTime? from, DateTime? to}) async {
    var query = '''
      SELECT ${DbTagTablesV3.dayTagDay} FROM ${DbTagTablesV3.dayTagTable}
      WHERE ${DbTagTablesV3.dayTagTagId} = ?
    ''';
    final args = <dynamic>[tagId];

    if (from != null) {
      query += ' AND ${DbTagTablesV3.dayTagDay} >= ?';
      args.add(from.toIsoDateString());
    }
    if (to != null) {
      query += ' AND ${DbTagTablesV3.dayTagDay} <= ?';
      args.add(to.toIsoDateString());
    }
    query += ' ORDER BY ${DbTagTablesV3.dayTagDay} ASC';

    final results = await db.rawQuery(query, args);
    return results.map((e) => e[DbTagTablesV3.dayTagDay]! as String).toList();
  }

  /// Get tag statistics (count of days per tag) within date range
  Future<List<TagStatistic>> getTagStatistics({DateTime? from, DateTime? to}) async {
    var query = '''
      SELECT t.${DbTagTablesV3.tagId}, t.${DbTagTablesV3.tagName}, t.${DbTagTablesV3.tagColor}, COUNT(dt.${DbTagTablesV3.dayTagDay}) as day_count
      FROM ${DbTagTablesV3.tagTable} t
      LEFT JOIN ${DbTagTablesV3.dayTagTable} dt ON t.${DbTagTablesV3.tagId} = dt.${DbTagTablesV3.dayTagTagId}
    ''';
    final args = <dynamic>[];

    if (from != null || to != null) {
      query += ' AND ';
      if (from != null) {
        query += 'dt.${DbTagTablesV3.dayTagDay} >= ?';
        args.add(from.toIsoDateString());
      }
      if (from != null && to != null) {
        query += ' AND ';
      }
      if (to != null) {
        query += 'dt.${DbTagTablesV3.dayTagDay} <= ?';
        args.add(to.toIsoDateString());
      }
    }
    query += ' GROUP BY t.${DbTagTablesV3.tagId}, t.${DbTagTablesV3.tagName} ORDER BY day_count DESC';

    final results = await db.rawQuery(query, args);
    return results.map((e) => TagStatistic.fromMap(e)).toList();
  }

  /// Get all days with their tags within date range (for report)
  Future<Map<String, List<Tag>>> getDaysWithTagsInRange(DateTime from, DateTime to) async {
    final results = await db.rawQuery('''
      SELECT dt.${DbTagTablesV3.dayTagDay}, t.${DbTagTablesV3.tagId}, t.${DbTagTablesV3.tagName}, t.${DbTagTablesV3.tagColor}
      FROM ${DbTagTablesV3.dayTagTable} dt
      INNER JOIN ${DbTagTablesV3.tagTable} t ON t.${DbTagTablesV3.tagId} = dt.${DbTagTablesV3.dayTagTagId}
      WHERE dt.${DbTagTablesV3.dayTagDay} >= ? AND dt.${DbTagTablesV3.dayTagDay} <= ?
      ORDER BY dt.${DbTagTablesV3.dayTagDay} ASC, t.${DbTagTablesV3.tagName} ASC
    ''', [from.toIsoDateString(), to.toIsoDateString()]);

    final Map<String, List<Tag>> dayTags = {};
    for (final row in results) {
      final day = row[DbTagTablesV3.dayTagDay]! as String;
      final tag = Tag.fromMap(row);
      dayTags.putIfAbsent(day, () => []).add(tag);
    }
    return dayTags;
  }
}
