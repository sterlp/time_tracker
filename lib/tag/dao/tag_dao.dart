import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_entities/dao/abstract_dao.dart';
import 'package:time_tracker/db/db_v3.dart';
import 'package:time_tracker/tag/entity/tag.dart';

class TagDao extends AbstractDao<Tag> {
  TagDao(Database db) : super(db, DbTagTablesV3.tagTable);

  Future<List<Tag>> allTags() {
    return loadAll(orderBy: '${DbTagTablesV3.tagName} ASC');
  }

  Future<Tag?> findByName(String name) async {
    final result = await loadAll(
      where: '${DbTagTablesV3.tagName} = ?',
      whereArgs: [name],
      limit: 1,
    );
    return result.isEmpty ? null : result.first;
  }

  @override
  Tag fromMap(Map<String, dynamic> values) => Tag.fromMap(values);

  @override
  Map<String, dynamic> toMap(Tag value) => value.toMap();
}
