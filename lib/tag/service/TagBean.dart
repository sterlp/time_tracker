import 'package:flutter/cupertino.dart';
import 'package:time_tracker/common/logger.dart';
import 'package:time_tracker/tag/dao/tag_dao.dart';
import 'package:time_tracker/tag/entity/tag.dart';
import 'package:collection/collection.dart';


class TagBean {

  static final _log = LoggerFactory.get<TagBean>();
  final TagDao _tagDao;
  late List<Tag>? _tags;

  TagBean(this._tagDao);

  Future<Tag?> get(String name) async {
    final tags = await allTags();
    return tags.where((t) => t.id == name).firstOrNull;
  }

  Future<List<Tag>> allTags() async {
    return _tags ??= await _tagDao.allTags();
  }

  Future<Tag> save(Tag tag) async {
    final tags = await allTags();
    var oldIndex = tags.indexOf(tag);
    if (oldIndex >= 0) {
      tags.removeAt(oldIndex);
    } else {
      oldIndex = 0;
    }
    final saved = await _tagDao.save(tag);
    tags.insert(oldIndex, saved);
    return saved;
  }
}
