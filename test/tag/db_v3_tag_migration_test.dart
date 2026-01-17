import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_entities/service/db_provider.dart';
import 'package:time_tracker/db/db_v1.dart';
import 'package:time_tracker/db/db_v2.dart';
import 'package:time_tracker/db/db_v3.dart';
import 'package:time_tracker/tag/dao/day_tag_dao.dart';
import 'package:time_tracker/tag/dao/tag_dao.dart';
import 'package:time_tracker/tag/entity/tag.dart';

Color _hexToColor(String hex) {
  final hexCode = hex.replaceFirst('#', '');
  return Color(int.parse('FF$hexCode', radix: 16));
}

void main() {
  late Database db;
  late TagDao tagDao;
  late DayTagDao dayTagDao;

  setUpAll(() async {
    sqfliteFfiInit();
    final database = databaseFactoryFfi.openDatabase(inMemoryDatabasePath);

    final dbProvider = DbProvider.withDb(database, [
      DbConfigV1(),
      DbBookingTableV2(),
      DbTagTablesV3(),
    ]);
    db = await dbProvider.init();
  });

  setUp(() async {
    // Clear DAY_TAG table before each test
    await db.delete(DbTagTablesV3.dayTagTable);
    // Clear TAG table and re-insert defaults
    await db.delete(DbTagTablesV3.tagTable);
    await db.execute('''
INSERT INTO ${DbTagTablesV3.tagTable} (${DbTagTablesV3.tagName}, ${DbTagTablesV3.tagColor}) VALUES
  ('Homeoffice', '#4CAF50'),
  ('Dienstreise', '#2196F3');
    ''');
    tagDao = TagDao(db);
    dayTagDao = DayTagDao(db);
  });

  tearDownAll(() async {
    await db.close();
  });

  group('DbTagTablesV3 Migration', () {
    test('TAG table exists and has correct structure', () async {
      final result = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='TAG'");
      expect(result, isNotEmpty, reason: 'TAG table should exist');
    });

    test('DAY_TAG table exists and has correct structure', () async {
      final result = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='DAY_TAG'");
      expect(result, isNotEmpty, reason: 'DAY_TAG table should exist');
    });

    test('Default tags are created', () async {
      final tags = await tagDao.allTags();

      expect(tags.length, 2);
      expect(tags.any((t) => t.name == 'Homeoffice'), isTrue);
      expect(tags.any((t) => t.name == 'Dienstreise'), isTrue);
    });

    test('Default tag colors are correct', () async {
      final homeoffice = await tagDao.findByName('Homeoffice');
      final dienstreise = await tagDao.findByName('Dienstreise');

      expect(homeoffice?.color, _hexToColor('#4CAF50'));
      expect(dienstreise?.color, _hexToColor('#2196F3'));
    });

    test('Indexes are created', () async {
      final indexes = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='DAY_TAG'");
      final indexNames = indexes.map((e) => e['name'] as String?).whereType<String>().toList();

      expect(indexNames, contains('IDX_DAY_TAG_DAY'));
      expect(indexNames, contains('IDX_DAY_TAG_TAG_ID'));
    });
  });

  group('TagDao', () {
    test('save new tag', () async {
      final newTag = Tag('Urlaub', color: _hexToColor('#FF5722'));

      final saved = await tagDao.save(newTag);

      expect(saved.id, isNotNull);
      expect(saved.name, 'Urlaub');
      expect(saved.color, _hexToColor('#FF5722'));
    });

    test('find tag by name', () async {
      final tag = await tagDao.findByName('Homeoffice');

      expect(tag, isNotNull);
      expect(tag!.name, 'Homeoffice');
    });

    test('find non-existent tag returns null', () async {
      final tag = await tagDao.findByName('NonExistent');
      expect(tag, isNull);
    });

    test('update existing tag', () async {
      final tag = await tagDao.findByName('Homeoffice');
      tag!.color = _hexToColor('#00FF00');

      final updated = await tagDao.save(tag);

      expect(updated.id, tag.id);
      expect(updated.color, _hexToColor('#00FF00'));
    });

    test('delete tag', () async {
      final tag = await tagDao.findByName('Homeoffice');
      await tagDao.deleteEntity(tag!);

      final deleted = await tagDao.findByName('Homeoffice');
      expect(deleted, isNull);
    });

    test('duplicate name replaces existing (ConflictAlgorithm.replace)', () async {
      final originalHomeoffice = await tagDao.findByName('Homeoffice');
      expect(originalHomeoffice?.color, _hexToColor('#4CAF50'));

      // Saving with same name but different color should replace
      final duplicateTag = Tag('Homeoffice', color: _hexToColor('#000000'));
      await tagDao.save(duplicateTag);

      // Count should still be 2 (not 3)
      final allTags = await tagDao.allTags();
      expect(allTags.length, 2);

      // The new color should be saved
      final updated = await tagDao.findByName('Homeoffice');
      expect(updated?.color, _hexToColor('#000000'));
    });
  });

  group('DayTagDao', () {
    test('add tag to day', () async {
      final homeoffice = await tagDao.findByName('Homeoffice');
      await dayTagDao.addTagToDay('2024-01-15', homeoffice!.id!);

      final tags = await dayTagDao.getTagsForDay('2024-01-15');

      expect(tags.length, 1);
      expect(tags.first.name, 'Homeoffice');
    });

    test('add multiple tags to same day', () async {
      final homeoffice = await tagDao.findByName('Homeoffice');
      final dienstreise = await tagDao.findByName('Dienstreise');

      await dayTagDao.addTagToDay('2024-01-15', homeoffice!.id!);
      await dayTagDao.addTagToDay('2024-01-15', dienstreise!.id!);

      final tags = await dayTagDao.getTagsForDay('2024-01-15');

      expect(tags.length, 2);
    });

    test('add same tag twice is ignored (no error)', () async {
      final homeoffice = await tagDao.findByName('Homeoffice');

      await dayTagDao.addTagToDay('2024-01-15', homeoffice!.id!);
      await dayTagDao.addTagToDay('2024-01-15', homeoffice.id!);

      final tags = await dayTagDao.getTagsForDay('2024-01-15');

      expect(tags.length, 1);
    });

    test('remove tag from day', () async {
      final homeoffice = await tagDao.findByName('Homeoffice');
      await dayTagDao.addTagToDay('2024-01-15', homeoffice!.id!);

      final removed = await dayTagDao.removeTagFromDay('2024-01-15', homeoffice.id!);

      expect(removed, 1);

      final tags = await dayTagDao.getTagsForDay('2024-01-15');
      expect(tags, isEmpty);
    });

    test('get days with tag', () async {
      final homeoffice = await tagDao.findByName('Homeoffice');

      await dayTagDao.addTagToDay('2024-01-15', homeoffice!.id!);
      await dayTagDao.addTagToDay('2024-01-16', homeoffice.id!);
      await dayTagDao.addTagToDay('2024-01-17', homeoffice.id!);

      final days = await dayTagDao.getDaysWithTag(homeoffice.id!);

      expect(days.length, 3);
      expect(days, containsAll(['2024-01-15', '2024-01-16', '2024-01-17']));
    });

    test('get days with tag in date range', () async {
      final homeoffice = await tagDao.findByName('Homeoffice');

      await dayTagDao.addTagToDay('2024-01-15', homeoffice!.id!);
      await dayTagDao.addTagToDay('2024-01-20', homeoffice.id!);
      await dayTagDao.addTagToDay('2024-01-25', homeoffice.id!);

      final days = await dayTagDao.getDaysWithTag(
        homeoffice.id!,
        from: DateTime(2024, 1, 16),
        to: DateTime(2024, 1, 22),
      );

      expect(days.length, 1);
      expect(days.first, '2024-01-20');
    });

    test('get tag statistics', () async {
      final homeoffice = await tagDao.findByName('Homeoffice');
      final dienstreise = await tagDao.findByName('Dienstreise');

      await dayTagDao.addTagToDay('2024-01-15', homeoffice!.id!);
      await dayTagDao.addTagToDay('2024-01-16', homeoffice.id!);
      await dayTagDao.addTagToDay('2024-01-17', homeoffice.id!);
      await dayTagDao.addTagToDay('2024-01-20', dienstreise!.id!);

      final stats = await dayTagDao.getTagStatistics();

      expect(stats.length, 2);

      final homeofficeStats = stats.firstWhere((s) => s.tag.name == 'Homeoffice');
      final dienstreiseStats = stats.firstWhere((s) => s.tag.name == 'Dienstreise');

      expect(homeofficeStats.dayCount, 3);
      expect(dienstreiseStats.dayCount, 1);
    });

    test('get days with tags in range', () async {
      final homeoffice = await tagDao.findByName('Homeoffice');
      final dienstreise = await tagDao.findByName('Dienstreise');

      await dayTagDao.addTagToDay('2024-01-15', homeoffice!.id!);
      await dayTagDao.addTagToDay('2024-01-15', dienstreise!.id!);
      await dayTagDao.addTagToDay('2024-01-16', homeoffice.id!);

      final dayTags = await dayTagDao.getDaysWithTagsInRange(
        DateTime(2024, 1, 1),
        DateTime(2024, 1, 31),
      );

      expect(dayTags.keys, containsAll(['2024-01-15', '2024-01-16']));
      expect(dayTags['2024-01-15']!.length, 2);
      expect(dayTags['2024-01-16']!.length, 1);
    });

    test('cascade delete removes day_tag entries', () async {
      final homeoffice = await tagDao.findByName('Homeoffice');
      final tagId = homeoffice!.id!;
      await dayTagDao.addTagToDay('2024-01-15', tagId);
      await dayTagDao.addTagToDay('2024-01-16', tagId);

      // Enable foreign keys for CASCADE to work in SQLite
      await db.execute('PRAGMA foreign_keys = ON');

      await tagDao.deleteEntity(homeoffice);

      final days = await dayTagDao.getDaysWithTag(tagId);
      expect(days, isEmpty);
    });
  });

  group('TagDao SQL Edge Cases', () {
    test('tag name with special characters', () async {
      final tag = Tag("Test'Tag\"Special", color: _hexToColor('#FFFFFF'));

      final saved = await tagDao.save(tag);
      final loaded = await tagDao.getById(saved.id!);

      expect(loaded?.name, "Test'Tag\"Special");
    });

    test('tag with null color', () async {
      final tag = Tag('NoColor');

      final saved = await tagDao.save(tag);
      expect(saved.id, isNotNull);
      expect(saved.color, isNull);
    });

    test('tag name max length', () async {
      final longName = 'A' * 50; // VARCHAR(50)
      final tag = Tag(longName, color: _hexToColor('#000000'));

      final saved = await tagDao.save(tag);
      expect(saved.name, longName);
    });
  });
}
