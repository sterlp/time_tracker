import 'package:time_tracker/tag/entity/tag.dart';

/// Statistics for a single tag showing how many days it was used
class TagStatistic {
  final Tag tag;
  final int dayCount;

  TagStatistic(this.tag, this.dayCount);

  TagStatistic.fromMap(Map<String, dynamic> map)
      : tag = Tag.fromMap(map),
        dayCount = map['day_count'] as int;

  @override
  String toString() => 'TagStatistic[tag=${tag.name}, dayCount=$dayCount]';
}
