import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_entities/dao/abstract_dao.dart';
import 'package:time_tracker/db/db_v3.dart';
import 'package:time_tracker/tag/entity/tag.dart';

class TagDao extends AbstractDao<String, Tag> {
  TagDao(Database db)
    : super(db, DbTagTablesV3.tagTable, idColumn: DbTagTablesV3.tagName);

  Future<List<Tag>> allTags() {
    return loadAll(orderBy: '${DbTagTablesV3.tagName} ASC');
  }

  @override
  Tag fromMap(Map<String, dynamic> values) => Tag.fromMap(values);

  @override
  Map<String, dynamic> toMap(Tag value) => value.toMap();
}
