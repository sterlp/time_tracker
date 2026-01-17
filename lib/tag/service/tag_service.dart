import 'package:time_tracker/tag/dao/day_tag_dao.dart';
import 'package:time_tracker/tag/dao/tag_dao.dart';
import 'package:time_tracker/tag/entity/tag.dart';
import 'package:time_tracker/tag/entity/tag_statistic.dart';

class TagService {
  final TagDao _tagDao;
  final DayTagDao _dayTagDao;

  TagService(this._tagDao, this._dayTagDao);

  // Tag CRUD
  Future<List<Tag>> getAllTags() => _tagDao.allTags();

  Future<Tag> saveTag(Tag tag) => _tagDao.save(tag);

  Future<Tag> deleteTag(Tag tag) => _tagDao.deleteEntity(tag);

  Future<Tag?> findTagByName(String name) => _tagDao.findByName(name);

  // Day-Tag operations
  Future<void> addTagToDay(String day, Tag tag) =>
      _dayTagDao.addTagToDay(day, tag.id!);

  Future<void> removeTagFromDay(String day, Tag tag) =>
      _dayTagDao.removeTagFromDay(day, tag.id!);

  Future<List<Tag>> getTagsForDay(String day) => _dayTagDao.getTagsForDay(day);

  // Report queries
  Future<List<TagStatistic>> getTagStatistics({DateTime? from, DateTime? to}) =>
      _dayTagDao.getTagStatistics(from: from, to: to);

  Future<Map<String, List<Tag>>> getDaysWithTagsInRange(
          DateTime from, DateTime to) =>
      _dayTagDao.getDaysWithTagsInRange(from, to);

  Future<List<String>> getDaysWithTag(int tagId,
          {DateTime? from, DateTime? to}) =>
      _dayTagDao.getDaysWithTag(tagId, from: from, to: to);
}
