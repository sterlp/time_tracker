import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_tracker/tag/dao/tag_dao.dart';
import 'package:time_tracker/tag/entity/tag.dart';

import '../test_helper.dart';

Future<void> main() async {
  final dbProvider = await initTestDB();
  final db = await dbProvider.init();
  final subject = TagDao(db);

  tearDownAll(() async {
    await dbProvider.close();
  });

  setUp(() async {
    await subject.deleteAll();
  });

  test('TAG create', () async {
    // GIVEN
    await subject.save(Tag('Urlaub', Colors.blue));

    // WHEN
    final Tag? saved = await subject.getById('Urlaub');

    expect(saved, isNotNull);
    expect(saved!.id, 'Urlaub');
    expect(saved.color, Colors.blue.toARGB32());
  });
}
