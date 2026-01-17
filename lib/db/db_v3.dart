import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_entities/service/db_update.dart';

class DbTagTablesV3 extends DbUpdate {
  static const String tagTable = 'TAG';
  static const String dayTagTable = 'DAY_TAG';

  // TAG columns
  static const String tagId = 'id';
  static const String tagName = 'name';
  static const String tagColor = 'color';

  // DAY_TAG columns
  static const String dayTagDay = 'day';
  static const String dayTagTagId = 'tag_id';

  DbTagTablesV3() : super(3);

  @override
  Future<void> update(Database db) async {
    // Tag master table
    await db.execute('''
CREATE TABLE IF NOT EXISTS $tagTable (
  $tagId INTEGER PRIMARY KEY AUTOINCREMENT,
  $tagName VARCHAR(50) NOT NULL UNIQUE,
  $tagColor VARCHAR(7)
);
    ''');

    // Junction table: Day-to-Tag relationship
    await db.execute('''
CREATE TABLE IF NOT EXISTS $dayTagTable (
  $dayTagDay VARCHAR(10) NOT NULL,
  $dayTagTagId INTEGER NOT NULL,
  PRIMARY KEY ($dayTagDay, $dayTagTagId),
  FOREIGN KEY ($dayTagTagId) REFERENCES $tagTable($tagId) ON DELETE CASCADE
);
    ''');

    await db.execute(
        'CREATE INDEX IF NOT EXISTS IDX_DAY_TAG_DAY ON $dayTagTable($dayTagDay);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS IDX_DAY_TAG_TAG_ID ON $dayTagTable($dayTagTagId);');

    // Insert default tags
    await db.execute('''
INSERT INTO $tagTable ($tagName, $tagColor) VALUES
  ('Homeoffice', '#4CAF50'),
  ('Dienstreise', '#2196F3');
    ''');
  }
}
